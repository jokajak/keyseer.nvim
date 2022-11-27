if vim.fn.has("nvim-0.7.0") == 0 then
  vim.api.nvim_err_writeln("keyfinder requires at least nvim-0.7.0.1")
  return
end

-- make sure this file is loaded only once
if vim.g.loaded_keyfinder_plugin == 1 then
  return
end
vim.g.loaded_keyfinder_plugin = 1

local function keyfinder_cmd(opts)
  local prefix = opts.fargs[1] or ""
  local mode = opts.fargs[2]
  require("keyfinder").show({
    mode = mode,
    prefix = prefix,
  })
end

vim.api.nvim_create_user_command("Keyfinder", keyfinder_cmd, {
  nargs = "*",
  desc = "Open Keyfinder",
  complete = function(_, CmdLine, _)
    local argument = vim.split(CmdLine, " ", {})
    if #argument == 3 then
      return { "n", "v", "i" }
    end
    return { "<Prefix>" }
  end,
})
