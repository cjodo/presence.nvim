vim.api.nvim_create_user_command("PresenceStart", require("presence").start, {})
vim.api.nvim_create_user_command("PresenceStop", require("presence").stop, {})
