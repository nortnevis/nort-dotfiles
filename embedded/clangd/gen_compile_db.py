#!/usr/bin/env python3
"""Publish a BitBake/Meson compile_commands.json into an OpenBMC devtool source tree.

Why this is needed
------------------
clangd looks for ``compile_commands.json`` in the directory of the file being
edited and in its parents.  BitBake/Meson writes the database below
``build/<machine>/tmp/work/...``, which is *not* an ancestor of
``build/<machine>/workspace/sources/<recipe>`` (the tree that ``devtool modify``
gives you).  This script copies the database next to the recipe sources and
rewrites its paths to absolute paths, so clangd finds it no matter which
sub-directory of the source tree you open.

The script also replaces the bare cross-compiler name (for example
``arm-openbmc-linux-gnueabi-g++``) with its absolute path.  That lets clangd
query the compiler for the sysroot/target headers without requiring the Yocto
toolchain to be on ``$PATH``.

Usage
-----
    python3 ~/extraSpace/embedded/clangd/gen_compile_db.py            # bmcweb
    python3 ~/extraSpace/embedded/clangd/gen_compile_db.py --recipe phosphor-logging

Run ``devtool build <recipe>`` first so that Meson regenerates the database.
"""

from __future__ import annotations

import argparse
import glob as globmod
import json
import os
import shlex
import shutil
import sys
from pathlib import Path

DEFAULT_OPENBMC = Path.home() / "extraSpace" / "embedded" / "openbmc"

# Options whose *next* argument is a path relative to the compiler's cwd.
PATH_OPTIONS = {
    "-I",
    "-isystem",
    "-iquote",
    "-idirafter",
    "-include",
    "-imacros",
    "-isysroot",
    "--sysroot",
}

# Options whose path is embedded in the same argument ("-I../include").
PATH_PREFIXES = ("-I", "-isystem", "-iquote", "-idirafter")

# GCC 16 flags that clangd's clang rejects with "Unknown argument".  Dropping
# them only affects clangd's parse; the BitBake build still uses them.
CLANGD_UNSUPPORTED_FLAGS = {"-fcanon-prefix-map"}


def find_build_dir(db_path: Path) -> Path:
    """Return build/<machine> for a database below build/<machine>/tmp/work/..."""
    parts = db_path.parts
    if "tmp" in parts:
        return Path(*parts[: parts.index("tmp")])
    # Should not happen for a BitBake build, but keep the script usable.
    return db_path.parent


def candidate_databases(openbmc: Path, recipe: str, build: str | None) -> list[Path]:
    build_glob = build or "*"
    pattern = str(
        openbmc
        / "build"
        / build_glob
        / "tmp"
        / "work"
        / "*"
        / recipe
        / "*"
        / "**"
        / "compile_commands.json"
    )
    return [Path(p) for p in globmod.glob(pattern, recursive=True)]


def database_score(db_path: Path, src_dir: Path) -> tuple[int, int, float]:
    """Rank databases: most entries pointing into the devtool source tree wins."""
    try:
        entries = json.loads(db_path.read_text())
        if not entries:
            return (0, 0, 0.0)
        directory = Path(entries[0]["directory"])
    except (OSError, ValueError, KeyError):
        return (0, 0, 0.0)

    existing = 0
    in_source = 0
    for entry in entries:
        file_path = Path(entry["file"])
        if not file_path.is_absolute():
            file_path = directory / file_path
        file_path = file_path.resolve()
        if file_path.exists():
            existing += 1
            if src_dir in file_path.parents:
                in_source += 1
    try:
        mtime = db_path.stat().st_mtime
    except OSError:
        mtime = 0.0
    return (in_source, existing, mtime)


def resolve_compiler(name: str, workdir: Path) -> str | None:
    """Find the cross compiler that belongs to this recipe's sysroot."""
    if os.path.isabs(name):
        return name if os.access(name, os.X_OK) else None

    search_dirs = []
    native_bin = workdir / "recipe-sysroot-native" / "usr" / "bin"
    if native_bin.is_dir():
        search_dirs.append(native_bin)
        search_dirs.extend(sorted(p for p in native_bin.iterdir() if p.is_dir()))
    for directory in search_dirs:
        candidate = directory / name
        if candidate.is_file() and os.access(candidate, os.X_OK):
            return str(candidate.resolve())

    found = shutil.which(name)
    return found


def absolutize_path(value: str, directory: Path) -> str:
    if os.path.isabs(value):
        return value
    return os.path.normpath(os.path.join(str(directory), value))


def rewrite_arguments(args: list[str], directory: Path, compiler: str | None) -> list[str]:
    if not args:
        return args
    args = [arg for arg in args if arg not in CLANGD_UNSUPPORTED_FLAGS]

    if compiler:
        args[0] = compiler

    rewritten: list[str] = []
    index = 0
    while index < len(args):
        arg = args[index]

        if arg in PATH_OPTIONS and index + 1 < len(args):
            rewritten.append(arg)
            rewritten.append(absolutize_path(args[index + 1], directory))
            index += 2
            continue

        if arg.startswith("--sysroot="):
            value = arg.split("=", 1)[1]
            rewritten.append("--sysroot=" + absolutize_path(value, directory))
            index += 1
            continue

        for prefix in PATH_PREFIXES:
            if arg.startswith(prefix) and len(arg) > len(prefix):
                value = arg[len(prefix) :]
                # Avoid touching unrelated flags such as "-includefoo".
                if value and not value.startswith("-"):
                    rewritten.append(prefix + absolutize_path(value, directory))
                    index += 1
                    break
        else:
            rewritten.append(arg)
            index += 1
    return rewritten


def ensure_git_exclude(src_dir: Path) -> bool:
    """Keep the generated file out of `git status` in the devtool workspace."""
    git_dir = src_dir / ".git"
    if not git_dir.is_dir():
        return False
    info_dir = git_dir / "info"
    info_dir.mkdir(exist_ok=True)
    exclude = info_dir / "exclude"
    marker = "/compile_commands.json"
    try:
        content = exclude.read_text()
    except OSError:
        content = ""
    lines = content.splitlines()
    if marker in lines:
        return False
    with exclude.open("a") as handle:
        if content and not content.endswith("\n"):
            handle.write("\n")
        handle.write(marker + "\n")
    return True


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument(
        "--openbmc",
        type=Path,
        default=DEFAULT_OPENBMC,
        help=f"OpenBMC checkout (default: {DEFAULT_OPENBMC})",
    )
    parser.add_argument("--build", help="limit to build/<BUILD> (default: any)")
    parser.add_argument("--recipe", default="bmcweb", help="recipe name (default: bmcweb)")
    parser.add_argument(
        "--output",
        type=Path,
        help="write the database here instead of <build>/workspace/sources/<recipe>/compile_commands.json",
    )
    args = parser.parse_args()

    openbmc: Path = args.openbmc.expanduser().resolve()
    databases = candidate_databases(openbmc, args.recipe, args.build)
    if not databases:
        print(
            f"error: no compile_commands.json for '{args.recipe}' under {openbmc}/build/*/tmp/work",
            file=sys.stderr,
        )
        print("       build the recipe first, for example:", file=sys.stderr)
        print(
            f"       cd {openbmc} && . setup romulus && devtool build {args.recipe}",
            file=sys.stderr,
        )
        return 2

    best: tuple[int, int, float, Path, Path] | None = None
    for db_path in databases:
        build_dir = find_build_dir(db_path)
        src_dir = build_dir / "workspace" / "sources" / args.recipe
        score = database_score(db_path, src_dir)
        candidate = (score[0], score[1], score[2], db_path, src_dir)
        if best is None or candidate[:3] > best[:3]:
            best = candidate

    assert best is not None
    in_source, existing, _, db_path, src_dir = best

    if existing == 0:
        print(
            f"error: found {db_path} but none of its source files exist.",
            file=sys.stderr,
        )
        print(
            f"       The build tree may be stale. Run: devtool build {args.recipe}",
            file=sys.stderr,
        )
        return 2

    output = args.output.expanduser() if args.output else src_dir / "compile_commands.json"
    if not args.output and not src_dir.is_dir():
        print(
            f"error: {src_dir} does not exist; '{args.recipe}' is not a devtool workspace.",
            file=sys.stderr,
        )
        print(f"       Run: devtool modify {args.recipe}", file=sys.stderr)
        return 2
    if in_source == 0:
        print(
            f"warning: {db_path} does not reference files below {src_dir}",
            file=sys.stderr,
        )
    output.parent.mkdir(parents=True, exist_ok=True)

    try:
        entries = json.loads(db_path.read_text())
    except (OSError, ValueError) as exc:
        print(f"error: cannot read {db_path}: {exc}", file=sys.stderr)
        return 2

    workdir = db_path.parent.parent
    rewritten_entries = []
    compilers: set[str] = set()

    for entry in entries:
        directory = Path(entry["directory"]).resolve()
        file_path = Path(entry["file"])
        if not file_path.is_absolute():
            file_path = directory / file_path
        file_path = file_path.resolve()

        if "arguments" in entry:
            raw_args = list(entry["arguments"])
        else:
            raw_args = shlex.split(entry.get("command", ""))

        compiler = resolve_compiler(raw_args[0], workdir) if raw_args else None
        if compiler:
            compilers.add(compiler)
        new_args = rewrite_arguments(raw_args, directory, compiler)

        new_entry = {"directory": str(directory), "file": str(file_path)}
        if "arguments" in entry:
            new_entry["arguments"] = new_args
        else:
            new_entry["command"] = shlex.join(new_args)
        rewritten_entries.append(new_entry)

    temp_path = output.with_name(output.name + ".tmp")
    temp_path.write_text(json.dumps(rewritten_entries, indent=2) + "\n")
    os.replace(temp_path, output)

    added_exclude = ensure_git_exclude(src_dir)

    print(f"wrote {output}")
    print(f"  source database: {db_path}")
    print(f"  entries: {len(rewritten_entries)}")
    print(f"  compiler: {', '.join(sorted(compilers)) or 'unchanged'}")
    if added_exclude:
        print("  added '/compile_commands.json' to .git/info/exclude")
    return 0


if __name__ == "__main__":
    sys.exit(main())
