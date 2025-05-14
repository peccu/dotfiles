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

-- option key
-- https://wezterm.org/config/keyboard-concepts.html#macos-left-and-right-option-key
config.send_composed_key_when_left_alt_is_pressed = false
config.send_composed_key_when_right_alt_is_pressed = false

return config
