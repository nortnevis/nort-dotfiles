----- НАСТРОЙКА МОНИТОРОВ ------------------------------------------------------
require("nort_hypr.defaults.monitors")

local success, err = pcall(require, "nort_hypr.user_defined.monitors")

if success then
	print("[INFO] Successfully loaded nort_hypr.user_defined.monitors")
end

hl.config({
	xwayland = {
		force_zero_scaling = true,
	},
})

hl.config({
	debug = {
		overlay = false,
	},
})

-- Выключить монитор при закрытии крышки
hl.bind("switch:on:Lid Switch", function()
	hl.dispatch(hl.dsp.dpms({ action = "disable", monitor = "eDP-1" }))
end, { locked = true })

-- Включить монитор при открытии крышки
hl.bind("switch:off:Lid Switch", function()
	hl.dispatch(hl.dsp.dpms({ action = "enable", monitor = "eDP-1" }))
end, { locked = true })

----- АВТОСТАРТ ----------------------------------------------------------------

--exec-once = swaybg -i ~/.wallpapers/1.jpg
--exec-once = nwg-dock-hyprland -r -mb 5 -x -i 56 -o DVI-D-1
--exec-once = hyprctl setcursor Catppuccin-Mocha-Rosewater-Cursors 24

hl.on("hyprland.start", function()
	hl.exec_cmd("hypridle")
	hl.exec_cmd("waybar")
	hl.exec_cmd("wl-paste --type text --watch cliphist store ")
	hl.exec_cmd("wl-paste --type image --watch cliphist store ")
end)

----- ПЕРЕМЕННЫЕ ---------------------------------------------------------------

local terminal = "foot" -- kitty
local file_manager = "nemo"
--local menu = "wofi --show drun"
local kitty_args = "-o background_opacity=0.85"

----- ПОДКЛЮЧЕНИЕ ДОПОЛНИТЕЛЬНЫХ ФАЙЛОВ С КОНФИГОМ  ----------------------------

-- Source a file (multi-file configs)
-- require("nested_folder.myColors")

----- ГАПСЫ, БОРДЕРЫ, ЦВЕТА... -------------------------------------------------

hl.config({
	general = {
		gaps_in = 0,
		gaps_out = 0,
		border_size = 0,
		resize_on_border = false,
		allow_tearing = false,
		layout = "dwindle",
		col = {
			active_border = { colors = { "rgba(f2cdcdee)", "rgba(f5e0dcee)" }, angle = 45 },
			inactive_border = "rgba(1e1e2eff)",
		},
	},
	dwindle = {
		preserve_split = true, -- Keeps the split direction permanent
	},
})

----- ДЕКОРАЦИИ ОКОН -----------------------------------------------------------

hl.config({
	decoration = {
		rounding = 5,
		active_opacity = 1.0,
		inactive_opacity = 1.0,
		shadow = {
			enabled = true,
			range = 4,
			render_power = 3,
			color = "rgba(1a1a1aee)",
		},
		blur = {
			enabled = true,
			size = 6,
			passes = 1,
			vibrancy = 0.1696,
		},
	},
})

----- АНИМАЦИИ -----------------------------------------------------------------

hl.config({
	animations = {
		enabled = true,
	},
})

----- НАСТРОЙКА ЛАЙОУТОВ -------------------------------------------------------

hl.config({
	master = {
		new_status = "master",
	},
})

----- ВКЛЮЧИТЬ ДЕФОЛТНЫЕ ОБОИ --------------------------------------------------

hl.config({
	misc = {
		force_default_wallpaper = -1,
		-- Set to 0 or 1 to disable the anime mascot wallpapers
		disable_hyprland_logo = true,
		-- If true disables the random hyprland logo / anime girl background. :(
	},
})

----- УСТРОЙСТВА ВВОДА ---------------------------------------------------------

hl.config({
	input = {
		kb_layout = "us,ru",
		kb_options = "grp:win_space_toggle",
		follow_mouse = 1,
		sensitivity = 0,
		numlock_by_default = true,
		touchpad = {
			natural_scroll = true,
			scroll_factor = 0.25,
		},
	},
})

----- ЖЕСТЫ --------------------------------------------------------------------

hl.gesture({
	fingers = 3,
	direction = "horizontal",
	action = "workspace",
})

----- НАСТРОЙКА УСТРОЙСТВ ------------------------------------------------------

hl.device({
	name = "epic-mouse-v1",
	sensitivity = -0.5,
})

----- КЛАВИША МОДИФИКАТОР ------------------------------------------------------

local mainMod = "SUPER"

----- ЗАПУСК ПРИЛОЖЕНИЙ --------------------------------------------------------

local choosed_terminal

if terminal == "kitty" then
	choosed_terminal = terminal .. kitty_args
else
	choosed_terminal = terminal
end

hl.bind(mainMod .. " + RETURN", hl.dsp.exec_cmd(choosed_terminal))

hl.bind(
	"ALT + CTRL + T",
	hl.dsp.exec_cmd(choosed_terminal, {
		float = true,
		move = { 50, 75 },
		size = { 500, 400 },
	})
)

hl.bind(mainMod .. " + grave", hl.dsp.exec_cmd("~/.config/hypr/nort_hypr/rofi-clipboard.sh"))

hl.bind(mainMod .. " + semicolon", hl.dsp.exec_cmd("emote"))

hl.bind(mainMod .. " + SHIFT + V", hl.dsp.exec_cmd(choosed_terminal .. " bash ~/vh.sh")) -- my nvim help notes

hl.bind(mainMod .. " + SHIFT + C", hl.dsp.exec_cmd(choosed_terminal .. " bash ~/hypr_conf.sh"))

hl.bind(mainMod .. " + SHIFT + P", hl.dsp.exec_cmd(choosed_terminal .. " nvim ~/repos/nort-dotfiles/README.md"))

hl.bind(mainMod .. " + D", hl.dsp.exec_cmd("~/.config/rofi/launchers/type-6/launcher.sh"))

hl.bind(mainMod .. " + N", hl.dsp.exec_cmd("thunar"))

hl.bind(mainMod .. " + B", hl.dsp.exec_cmd("google-chrome-stable --restore-last-session"))

hl.bind(mainMod .. " + SHIFT + B", hl.dsp.exec_cmd("google-chrome-stable"))

hl.bind(mainMod .. " + T", hl.dsp.exec_cmd("Telegram"))

hl.bind(mainMod .. " + I", hl.dsp.exec_cmd("inkscape"))

hl.bind(mainMod .. " + O", hl.dsp.exec_cmd("obsidian"))

hl.bind(mainMod .. " + SHIFT + O", hl.dsp.exec_cmd("okular"))

hl.bind(mainMod .. " + R", hl.dsp.exec_cmd("reaper"))

hl.bind(mainMod .. " + l", hl.dsp.exec_cmd("lutris"))

hl.bind(mainMod .. " + G", hl.dsp.exec_cmd("gimp"))

hl.bind(mainMod .. " + N", hl.dsp.exec_cmd("nemo"))

-- Editors

hl.bind(mainMod .. " + E", hl.dsp.exec_cmd("gedit -s"))

hl.bind(mainMod .. " + SHIFT + E", hl.dsp.exec_cmd(choosed_terminal .. " emacs -nw"))

hl.bind(mainMod .. " + V", hl.dsp.exec_cmd(choosed_terminal .. " nvim"))

hl.bind(mainMod .. " + C", hl.dsp.exec_cmd("code"))

hl.bind(mainMod .. " + M", hl.dsp.exec_cmd("musescore"))

hl.bind(mainMod .. " + CTRL + ESCAPE", hl.dsp.exec_cmd("bash ~/sleep.sh"))

hl.bind(mainMod .. " + ESCAPE", hl.dsp.exec_cmd("hyprlock"))

hl.bind(
	"Print",
	hl.dsp.exec_cmd(
		"grim -o DVI-D-1 ~/Images/screenshot/screen- $(date +%s) . png && notify-send -u normal -i accessories-screenshot скриншот сохранен"
	)
)

hl.bind(
	mainMod .. " + Print",
	hl.dsp.exec_cmd(
		"grim -g $(slurp) ~/Images/screenshot/screen- $(date +%s) . png && notify-send -u normal -i accessories-screenshot скриншот сохранен"
	)
)

hl.bind(mainMod .. " + Q", hl.dsp.window.close())

hl.bind(mainMod .. " + CTRL + Q", hl.dsp.exit())

hl.bind(mainMod .. " + CTRL + R", hl.dsp.exec_cmd("hyprctl reload && pkill waybar; systemctl restart --user waybar"))

hl.bind(mainMod .. " + S", hl.dsp.window.float())

hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen())

hl.bind(mainMod .. " + SHIFT + F", hl.dsp.window.fullscreen_state({ internal = 0, client = 2, action = "toggle" }))

hl.bind(mainMod .. " + TAB", hl.dsp.layout("togglesplit"))

-- Laptop multimedia keys for volume and LCD brightness

hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("pactl set-sink-volume \\@DEFAULT_SINK@ +5%"), { locked = true })

hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("pactl set-sink-volume \\@DEFAULT_SINK@ -5%"), { locked = true })

hl.bind("XF86AudioMute", hl.dsp.exec_cmd("pactl set-sink-mute \\@DEFAULT_SINK@ toggle"), { locked = true })

hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("pactl set-source-mute \\@DEFAULT_SOURCE@ toggle"), { locked = true })

hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("light -A 5"), { locked = true })

hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("light -U 5"), { locked = true })

----- ПЕРЕКЛЮЧЕНИЕ ФОКУСА ------------------------------------------------------

hl.bind(mainMod .. " + H", hl.dsp.focus({ direction = "left" }))

hl.bind(mainMod .. " + L", hl.dsp.focus({ direction = "right" }))

hl.bind(mainMod .. " + K", hl.dsp.focus({ direction = "up" }))

hl.bind(mainMod .. " + J", hl.dsp.focus({ direction = "down" }))

hl.bind(mainMod .. " + left", hl.dsp.focus({ direction = "left" }))

hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))

hl.bind(mainMod .. " + up", hl.dsp.focus({ direction = "up" }))

hl.bind(mainMod .. " + down", hl.dsp.focus({ direction = "down" }))

hl.bind("ALT + TAB", function()
	hl.dispatch(hl.dsp.window.cycle_next())
	hl.dispatch(hl.dsp.window.bring_to_top())
end)

hl.config({
	misc = {
		focus_on_activate = 1,
		-- autofocus on new window and mouse moving (and also autofocus to browser when new page is loaded)
	},
})

----- ПЕРЕКЛЮЧЕНИЕ ВОРКСПЕЙСОВ -------------------------------------------------

hl.bind(mainMod .. " + " .. 1, hl.dsp.focus({ workspace = 1 }))

hl.bind(mainMod .. " + " .. 2, hl.dsp.focus({ workspace = 2 }))

hl.bind(mainMod .. " + " .. 3, hl.dsp.focus({ workspace = 3 }))

hl.bind(mainMod .. " + " .. 4, hl.dsp.focus({ workspace = 4 }))

hl.bind(mainMod .. " + " .. 5, hl.dsp.focus({ workspace = 5 }))

hl.bind(mainMod .. " + " .. 6, hl.dsp.focus({ workspace = 6 }))

hl.bind(mainMod .. " + " .. 7, hl.dsp.focus({ workspace = 7 }))

hl.bind(mainMod .. " + " .. 8, hl.dsp.focus({ workspace = 8 }))

hl.bind(mainMod .. " + " .. 9, hl.dsp.focus({ workspace = 9 }))

hl.bind(mainMod .. " + " .. 0, hl.dsp.focus({ workspace = 10 }))

hl.bind(mainMod .. " + minus", hl.dsp.focus({ workspace = "r-1" }))

hl.bind(mainMod .. " + equal", hl.dsp.focus({ workspace = "r+1" }))

----- ПЕРЕМЕЩЕНИЕ ОКОН НА ДРУГОЙ ВОРКСПЕЙС -------------------------------------

hl.bind(mainMod .. " + SHIFT + 1", hl.dsp.window.move({ workspace = 1 }))

hl.bind(mainMod .. " + SHIFT + 2", hl.dsp.window.move({ workspace = 2 }))

hl.bind(mainMod .. " + SHIFT + 3", hl.dsp.window.move({ workspace = 3 }))

hl.bind(mainMod .. " + SHIFT + 4", hl.dsp.window.move({ workspace = 4 }))

hl.bind(mainMod .. " + SHIFT + 5", hl.dsp.window.move({ workspace = 5 }))

hl.bind(mainMod .. " + SHIFT + 6", hl.dsp.window.move({ workspace = 6 }))

hl.bind(mainMod .. " + SHIFT + 7", hl.dsp.window.move({ workspace = 7 }))

hl.bind(mainMod .. " + SHIFT + 8", hl.dsp.window.move({ workspace = 8 }))

hl.bind(mainMod .. " + SHIFT + 9", hl.dsp.window.move({ workspace = 9 }))

hl.bind(mainMod .. " + SHIFT + 0", hl.dsp.window.move({ workspace = 10 }))

hl.bind(mainMod .. " + SHIFT + minus", hl.dsp.window.move({ workspace = "r-1" }))

hl.bind(mainMod .. " + SHIFT + equal", hl.dsp.window.move({ workspace = "r+1" }))

----- ПЕРЕМЕЩЕНИЕ ПЛАВАЮЩИИХ ОКОН ----------------------------------------------

hl.bind(mainMod .. "+ ALT + H", hl.dsp.window.move({ x = -50, y = 0, relative = true }))

hl.bind(mainMod .. "+ ALT + L", hl.dsp.window.move({ x = 50, y = 0, relative = true }))

hl.bind(mainMod .. "+ ALT + K", hl.dsp.window.move({ x = 0, y = -50, relative = true }))

hl.bind(mainMod .. "+ ALT + J", hl.dsp.window.move({ x = 0, y = 50, relative = true }))

hl.bind(mainMod .. "+ ALT + left", hl.dsp.window.move({ x = -50, y = 0, relative = true }))

hl.bind(mainMod .. "+ ALT + right", hl.dsp.window.move({ x = 50, y = 0, relative = true }))

hl.bind(mainMod .. "+ ALT + up", hl.dsp.window.move({ x = 0, y = -50, relative = true }))

hl.bind(mainMod .. "+ ALT + down", hl.dsp.window.move({ x = 0, y = 50, relative = true }))

----- ПЕРЕМЕЩЕНИЕ ОКОН --------------------------------------------------------

hl.bind(mainMod .. " + SHIFT + H", hl.dsp.window.move({ direction = "l" }))

hl.bind(mainMod .. " + SHIFT + L", hl.dsp.window.move({ direction = "r" }))

hl.bind(mainMod .. " + SHIFT + K", hl.dsp.window.move({ direction = "u" }))

hl.bind(mainMod .. " + SHIFT + J", hl.dsp.window.move({ direction = "d" }))

hl.bind(mainMod .. " + SHIFT + left", hl.dsp.window.move({ direction = "l" }))

hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.move({ direction = "r" }))

hl.bind(mainMod .. " + SHIFT + up", hl.dsp.window.move({ direction = "u" }))

hl.bind(mainMod .. " + SHIFT + down", hl.dsp.window.move({ direction = "d" }))

----- СКРАЧПАД -----------------------------------------------------------------

--bind = $mainMod, S, togglespecialworkspace, magic

--bind = $mainMod SHIFT, S, movetoworkspace, special:magic

----- ПЕРЕХОД ПО ВОРКСПЕЙСАМ КОЛЕСОМ МЫШИ --------------------------------------

hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))

hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

----- ПЕРЕМЕЩЕНИЕ И РЕСАЙЗ ОКОН МЫШЬЮ ------------------------------------------

hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })

hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

----- РЕСАЙЗ -------------------------------------------------------------------

hl.bind(mainMod .. "+ CTRL + H", hl.dsp.window.resize({ x = -50, y = 0, relative = true }))

hl.bind(mainMod .. "+ CTRL + L", hl.dsp.window.resize({ x = 50, y = 0, relative = true }))

hl.bind(mainMod .. "+ CTRL + K", hl.dsp.window.resize({ x = 0, y = -50, relative = true }))

hl.bind(mainMod .. "+ CTRL + J", hl.dsp.window.resize({ x = 0, y = 50, relative = true }))

hl.bind(mainMod .. "+ CTRL + left", hl.dsp.window.resize({ x = -50, y = 0, relative = true }))

hl.bind(mainMod .. "+ CTRL + right", hl.dsp.window.resize({ x = 50, y = 0, relative = true }))

hl.bind(mainMod .. "+ CTRL + up", hl.dsp.window.resize({ x = 0, y = -50, relative = true }))

hl.bind(mainMod .. "+ CTRL + down", hl.dsp.window.resize({ x = 0, y = 50, relative = true }))

----- ПРАВИЛА ОКОН -------------------------------------------------------------

-- hyprctl clients - что бы узнать класс приложения

hl.window_rule({
	name = "file_manager_window_rule",
	match = {
		class = "^(" .. file_manager .. ")$",
	},
	float = true,
})

hl.window_rule({
	name = "xdg_desktop",
	match = {
		class = "^(xdg-desktop-.*)$",
	},
	float = true,
})

hl.window_rule({
	name = "scroll_touchpad_10",
	match = {
		class = "^(" .. choosed_terminal .. ")$",
	},
	scroll_touchpad = 10,
})

-- windowrule = float on,^(org.telegram.desktop)$

-- windowrule = float on,^(Rofi)$

-- windowrule = float on,^(Viewnior)$

-- windowrule = size 800 450,^(Viewnior)$

-- windowrule = center,^(Viewnior)$

-- windowrule = float on,^(org.pulseaudio.pavucontrol)$

-- windowrule = size 730 400,^(org.pulseaudio.pavucontrol)$

-- windowrule = move 1100 70,^(org.pulseaudio.pavucontrol)$

-- windowrule = float on,^(mpv)$

-- windowrule = size 800 450,^(mpv)$

-- windowrule = center,^(mpv)$

-- windowrule = size 1600 900,^(Firefox)$

-- windowrule = float on,^(Firefox)$

-- windowrule = center,^(Firefox)$

-- windowrule = size 1600 900,^(obsidian)$

-- windowrule = float on,^(obsidian)$

-- windowrule = center,^(obsidian)$

-- windowrule = noborder,^(org.inkscape.Inkscape)$

-- windowrule = workspace 3,^(org.inkscape.Inkscape)$

-- windowrulev2 =  float on,^(org.inkscape.Inkscape)$,title:^(Импорт SVG)$

-- windowrule = noborder,^(blender)$

-- windowrule = workspace 2,^(blender)$

-- #windowrule = float on,^(blender)$

-- #windowrule = size 3840 1080,^(blender)$

-- windowrule = noborder,^(REAPER)$

-- windowrule = workspace 4,^(REAPER)$

-- windowrule = size 900 600,^(lutris)$

-- windowrule = float on,^(lutris)$

-- windowrule = center,^(lutris)$

-- windowrulev2 =  float on,^(thunar)$,title:^(.home)$

-- windowrulev2 =  float on,^($choosed_terminal)$,title:^(.home)$

-- #windowrule = noborder,^(Rofi)$
