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

-- OS window numbering: prefix title with [N] where N is the position of this
-- window in the window_id-sorted list. Stable per session, used by
-- `wezterm-window-jump` to identify windows.
wezterm.on('format-window-title', function(tab, pane, tabs, panes, config)
  local current_id = tab:window():window_id()
  local ids = {}
  for _, w in ipairs(wezterm.mux.all_windows()) do
    table.insert(ids, w:window_id())
  end
  table.sort(ids)
  local idx = 0
  for i, id in ipairs(ids) do
    if id == current_id then
      idx = i
      break
    end
  end
  local title = pane:get_title()
  return string.format('[%d] %s', idx, title)
end)

-- Key bindings
local act = wezterm.action
config.keys = {
  -- Rename tab title via input prompt
  {
    key = 'E',
    mods = 'CTRL|SHIFT',
    action = act.PromptInputLine {
      description = 'Enter new tab title',
      action = wezterm.action_callback(function(window, pane, line)
        if line then
          window:active_tab():set_title(line)
        end
      end),
    },
  },
  -- Rename window title via input prompt
  {
    key = 'W',
    mods = 'CTRL|SHIFT',
    action = act.PromptInputLine {
      description = 'Enter new window title',
      action = wezterm.action_callback(function(window, pane, line)
        if line then
          pane:inject_output('\x1b]2;' .. line .. '\x1b\\')
        end
      end),
    },
  },
}

return config
