-- https://www.hammerspoon.org

-- utils
function isLeftHalf(windowFrame, screenFrame)
   return windowFrame.x == screenFrame.x and windowFrame.w <= screenFrame.w / 2
end

function isRightHalf(windowFrame, screenFrame)
   return windowFrame.x > screenFrame.x and windowFrame.w <= screenFrame.w / 2
end

-- -- move windows : alt ctrl + left/right
-- hs.hotkey.bind({"alt", "ctrl"}, "Left", function()
--       local win = hs.window.focusedWindow()
--       local screen = win:screen()
--       local frame = win:frame()
--       local screenFrame = screen:frame()

--       if isLeftHalf(frame, screenFrame) then
--          local previousScreen = screen:previous()

--          if previousScreen then
--             win:moveToScreen(previousScreen)
--             win:moveToUnit(hs.layout.right50)
--          end
--       else
--          win:moveToUnit(hs.layout.left50)
--       end
-- end)

-- hs.hotkey.bind({"alt", "ctrl"}, "Right", function()
--       local win = hs.window.focusedWindow()
--       local screen = win:screen()
--       local frame = win:frame()
--       local screenFrame = screen:frame()

--       if isRightHalf(frame, screenFrame) then
--          local nextScreen = screen:next()

--          if nextScreen then
--             win:moveToScreen(nextScreen)
--             win:moveToUnit(hs.layout.left50)
--          end
--       else
--          win:moveToUnit(hs.layout.right50)
--       end
-- end)

-- -- maximize window
-- hs.hotkey.bind({"alt", "ctrl"}, "Up", function()
--   local win = hs.window.focusedWindow()
--   win:moveToUnit(hs.layout.maximized)
-- end)

-- -- move focus
-- function focusTheWindowInScreen(screen)
--    if screen then
--       local windowsOnPrevScreen = screen:allWindows()
--       if #windowsOnPrevScreen > 0 then
--          windowsOnPrevScreen[1]:focus()
--       end
--    else
--       hs.alert.show("no screen")
--    end
-- end
-- hs.hotkey.bind({"ctrl", "alt", "shift"}, "Left", function()
--     local win = hs.window.focusedWindow()
--     if not win then return end

--     local currentScreen = win:screen()
--     local screen = currentScreen:previous()
--     focusTheWindowInScreen(screen)
-- end)
-- hs.hotkey.bind({"ctrl", "alt", "shift"}, "Right", function()
--     local win = hs.window.focusedWindow()
--     if not win then return end

--     local currentScreen = win:screen()
--     local screen = currentScreen:next()
--     focusTheWindowInScreen(screen)
-- end)

function focusApp(appName)
   local app = hs.application.find(appName)

   if app then
      app:activate()
   else
      hs.alert.show("Application not found: " .. appName)
   end
end
hs.hotkey.bind({"ctrl"}, "escape", function()
      focusApp("WezTerm")
end)

-- reload conf
hs.hotkey.bind({"alt", "ctrl"}, "R", function()
  hs.reload()
end)
hs.alert.show("Config loaded")
