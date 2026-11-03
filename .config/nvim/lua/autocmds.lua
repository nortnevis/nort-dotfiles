require "nvchad.autocmds"

-- Устанавливаем CWD в директорию переданного файла или в саму директорию
vim.api.nvim_create_autocmd("VimEnter", {
  desc = "Set CWD to the directory passed as argument",
  group = vim.api.nvim_create_augroup("UserCwdOnStart", { clear = true }),
  callback = function()
    -- Получаем первый аргумент командной строки (файл или директорию)
    local arg = vim.fn.argv(0)
    if arg == "" then
      return
    end

    -- Проверяем, существует ли путь, и определяем его тип
    local stat = vim.loop.fs_stat(arg)
    if not stat then
      return
    end

    local target_dir
    if stat.type == "directory" then
      target_dir = arg
    else -- если это файл, берём его родительскую директорию
      target_dir = vim.fn.fnamemodify(arg, ":p:h")
    end

    -- Глобально меняем CWD. Это обновит и nvim-tree (если настроен update_cwd), и повлияет на новые терминалы.
    vim.api.nvim_set_current_dir(target_dir)
  end,
})
