#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

;//autohotkey.com/board/topic/21387-how-to-insert-current-date-into-a-hotkey/?p=140109
:R*?:dd11::
FormatTime, CurrentDateTime,, yyyyMMdd
SendInput %CurrentDateTime%
return


;; https://superuser.com/a/1176273
#Singleinstance Force

;Horizontal scrolling in Excel only
#IfWinActive ahk_class XLMAIN

    +WheelUp:: 
        SetScrollLockState, On 
        SendInput {Left} 
        SetScrollLockState, Off 
    Return 

    +WheelDown:: 
        SetScrollLockState, On 
        SendInput {Right} 
        SetScrollLockState, Off 
    Return 
    
; Horizontal scrolling in everything except Excel. 
#IfWinNotActive ahk_class XLMAIN 

    +WheelDown::WheelRight
    +WheelUp::WheelLeft



;; https://superuser.com/a/1365443
; show all other window with same app with current window
!PrintScreen::
WinGetClass, class, A
WinGet, currentWindowId ,, A
WinGet, id, list, ahk_class %class%
Loop, %id%
{
    this_id := id%A_Index%
    WinActivate, ahk_id %this_id%
}
WinActivate, ahk_id %currentWindowId% ;bring the current window back to front
return
