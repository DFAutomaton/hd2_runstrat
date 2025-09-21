#SingleInstance force
SetBatchLines -1

logFile := A_ScriptDir . "\tray_timer_test.log"
FileDelete, %logFile%
FileAppend, % A_Now " | TIMER TEST START`n", %logFile%

FallbackActiveICO := A_ScriptDir . "\hd_active.ico"
FallbackInactiveICO := A_ScriptDir . "\hd_inactive.ico"

; Tick every 1000 ms
SetTimer, TimerTick, 1000
Return

TimerTick:
    ts := A_Now
    isActive := WinActive("ahk_class MozillaWindowClass")
    existsActive := FileExist(FallbackActiveICO)
    existsInactive := FileExist(FallbackInactiveICO)
    FileAppend, % ts " | tick | isActive=" isActive " | existsActive=" existsActive " | existsInactive=" existsInactive "`n", %logFile%

    ; Try set the active icon (if available)
    if (existsActive) {
        FileAppend, % ts " | attempt Menu,Tray -> " FallbackActiveICO "`n", %logFile%
        Menu, Tray, Icon, %FallbackActiveICO%
    } else {
        FileAppend, % ts " | hd_active.ico missing, skipping Menu,Tray`n", %logFile%
    }
Return

; Press Esc to exit quickly
Esc::ExitApp
