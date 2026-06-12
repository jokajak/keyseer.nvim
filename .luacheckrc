std = "luajit"
codes = true

-- formatting is stylua's job
max_line_length = false

-- callbacks often receive arguments they don't use
unused_args = false

globals = { "vim" }

exclude_files = {
  "deps/",
}

files["tests/**/*.lua"] = {
  read_globals = { "MiniTest" },
}

files["scripts/**/*.lua"] = {
  read_globals = { "MiniDoc" },
}
