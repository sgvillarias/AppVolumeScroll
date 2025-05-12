#Persistent
#NoEnv
#SingleInstance Force
SetBatchLines, -1

; Paths
svclPath := A_ScriptDir . "\src\svcl.exe"
configPath := A_ScriptDir . "\config\config.ini"
startupName := "VolumeScrollControl"
userStartupPath := A_Startup . "\" . startupName . ".lnk"

; Read volume step from config or default to 5
IniRead, volumeStep, %configPath%, Settings, VolumeStep, 5
if !IsInteger(volumeStep)
    volumeStep := 5

; Tray menu setup
Menu, Tray, NoStandard
Menu, Tray, Add, Change Increment, ChangeIncrement
Menu, Tray, Add, Run at Startup, ToggleStartup
Menu, Tray, Add, Exit, ExitScript
UpdateTrayStartupCheckbox()

#If GetKeyState("LWin", "P") && GetKeyState("Shift", "P")
*WheelUp::
    RunWait, %ComSpec% /c ""%svclPath%" /ChangeVolume focusedname +%volumeStep%", , Hide
    return

*WheelDown::
    RunWait, %ComSpec% /c ""%svclPath%" /ChangeVolume focusedname -%volumeStep%", , Hide
    return

*MButton::
    RunWait, %ComSpec% /c ""%svclPath%" /Switch focusedname", , Hide
    return
#If

ChangeIncrement:
InputBox, newStep, Set Volume Step, Enter a number:, , 200, 130, , , , , %volumeStep%
if (ErrorLevel)
    return  ; user pressed cancel

if IsInteger(newStep) && newStep > 0
{
    volumeStep := newStep
    IniWrite, %volumeStep%, %configPath%, Settings, VolumeStep
}
else
{
    MsgBox, 48, Invalid Input, Please enter a valid number greater than 0.
}
return

ToggleStartup:
if FileExist(userStartupPath) {
    FileDelete, %userStartupPath%
} else {
    FileCreateShortcut, %A_ScriptFullPath%, %userStartupPath%
}
UpdateTrayStartupCheckbox()
return

UpdateTrayStartupCheckbox() {
    global userStartupPath
    if FileExist(userStartupPath)
        Menu, Tray, Check, Run at Startup
    else
        Menu, Tray, Uncheck, Run at Startup
}

ExitScript:
ExitApp
return

IsInteger(val) {
    return val ~= "^\d+$"
}
