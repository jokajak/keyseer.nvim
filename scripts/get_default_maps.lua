-- Add current directory to 'runtimepath' to be able to use 'lua' files
vim.cmd([[let &rtp.=','.getcwd()]])

local function parseVerboseMap(cmd)
  local command = "verbose " .. cmd
  cmd = vim.api.nvim_parse_cmd(command, {})
  local opts = { output = true }
  local output = vim.api.nvim_cmd(cmd, opts)

  local mappings = {}
  local currentMode, currentKey, currentRest, currentDescription, currentLocation

  -- for each line
  for line in output:gmatch("[^\r\n]+") do
    -- from https://github.com/neovim/neovim/blob/b0abe426d6455d9b5168af9b6375f07838ca2ce0/src/nvim/mapping.c#L160
    -- length 3: mode characters
    -- length 12: lhs
    -- length 1: * for noremap, & for script, ' ' otherwise
    -- length 1: @ if local, ' ' otherwise
    -- rest: rhs
    -- optional description
    -- last set location ("\n\tLast set from (.*)")
    --     v-- key
    -- n  <C-W>*      * <C-W><C-S>*
    -- ^-- mode       ^--- rest
    -- 	Last set from ~/.config/nvim/init.vim
    local mode, key, rest = line:match("^([^ \t]+)%s+(%S+)%s+(.*)")
    if mode and key and rest then
      if currentMode and currentKey and currentRest then
        mappings[#mappings + 1] = {
          mode = currentMode,
          key = currentKey,
          rhs = currentRest,
          description = currentDescription or "",
          location = currentLocation or "",
        }
      end
      currentMode, currentKey, currentRest, currentDescription, currentLocation =
        mode, key, rest, nil, nil
    else
      local description = line:match("^%s+(.*)$")
      if description and not line:match("Last set") then
        currentDescription = description
      else
        currentLocation = description
      end
    end
  end

  if currentMode and currentKey and currentRest then
    if not (currentMode == "No" and currentKey == "mapping" and currentRest == "found") then
      mappings[#mappings + 1] = {
        mode = currentMode,
        key = currentKey,
        description = currentDescription or "",
        location = currentLocation or "",
        rhs = currentRest,
      }
    end
  end

  return mappings
end

local commands = {
  "nmap",
  "vmap",
  "xmap",
  "smap",
  "omap",
  "map!",
  "imap",
  "lmap",
  "cmap",
  "tmap",
}
for _, cmd in ipairs(commands) do
  local mappings = parseVerboseMap(cmd)
  print(string.format("%s has %d mappings", cmd, #mappings))
  for _, mapping in ipairs(mappings) do
    print(vim.inspect(mapping))
  end
end
