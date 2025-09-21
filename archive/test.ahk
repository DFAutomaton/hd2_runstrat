; AHK v1.1 compatible diagnostic
#SingleInstance force
SetBatchLines -1

FallbackActiveICO   := A_ScriptDir . "\hd_active.ico"
FallbackInactiveICO := A_ScriptDir . "\hd_inactive.ico"
logFile := A_ScriptDir . "\tray_state_debug.log"

MsgBox, 64, Diagnostic start, Diagnostic script started.`nClick OK, then focus Helldivers 2 for a few seconds. Alt+Tab back and press ESC to stop.

FileDelete, %logFile%
header := A_Now . " | LOG START`n"
FileAppend, %header%, %logFile%

; ensure tray has a menu & an initial (inactive) icon so icon area appears
Menu, Tray, NoStandard
Menu, Tray, Add, Exit, ExitScript
if FileExist(FallbackInactiveICO)
    Menu, Tray, Icon, %FallbackInactiveICO%

SetTimer, Tick, 1000
Return

Tick:
    ts := A_Now
    WinGet, active_id, ID, A
    WinGetTitle, active_title, A
    winActiveVal := WinActive("ahk_class MozillaWindowClass")
    winExistMatch := 0
    if (active_id)
        winExistMatch := WinExist("ahk_id " . active_id . " ahk_class MozillaWindowClass")

    if (winActiveVal)
        desired := "active_by_WinActive"
    else if (winExistMatch)
        desired := "active_by_WinExistMatch"
    else
        desired := "inactive"

    logLine := ts . " | active_id=" . active_id . " | title=" . active_title . " | WinActive=" . winActiveVal . " | WinExistMatch=" . winExistMatch . " | desired=" . desired . "`n"
    FileAppend, %logLine%, %logFile%

    ; visual feedback
    ToolTip, % "Diag: " desired "`nTitle: " SubStr(active_title,1,60), 10, 10
    TrayTip, Helldivers2 Diagnostic, % "Detected: " desired, 1
    Sleep, 800
    ToolTip
Return

Esc::
    SetTimer, Tick, Off
    FileAppend, % A_Now . " | stopped by user (ESC)`n", %logFile%
    MsgBox, 64, Diagnostic stopped, Stopped. Open tray_state_debug.log in the script folder and paste the last lines here.
    ExitApp
Return

ExitScript:
    ExitApp
Return
