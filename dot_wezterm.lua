-- https://wezfurlong.org/wezterm/config/files.html
local wezterm = require 'wezterm'
local config = wezterm.config_builder()

-- Color scheme:
-- config.color_scheme = 'AdventureTime'
config.color_scheme = 'Atelierforest (dark) (terminal.sexy)'
config.color_scheme = 'Abernathy'

-- Font config
config.font = wezterm.font 'FiraCode Nerd Font'
config.font_size = 14.0

return config
