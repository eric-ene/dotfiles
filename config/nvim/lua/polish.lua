local resession = require "resession"

vim.api.nvim_create_user_command(
  "SessionRestore",
  function() resession.load(vim.fn.getcwd(), { dir = "dirsession", silence_errors = true }) end,
  {}
)
