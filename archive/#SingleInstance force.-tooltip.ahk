#SingleInstance force
#UseHook
SetBatchLines -1

#IfWinActive ahk_exe helldivers2.exe

; ----- State -----
ToggleEnabled := true
F11F12_active := false
SyntheticCtrlDown := false
SyntheticShiftDown := false
SyntheticIDown := false

; Per-key mode: "arrow", "ij", "pass", or ""
w_mode := ""
a_mode := ""
s_mode := ""
d_mode := ""

; Tooltip timer name/duration
ToolTipDuration := 900

; ----- Helpers: tooltip -----
ShowModeTooltip(text) {
    global ToolTipDuration
    Tooltip, %text%
    SetTimer, RemoveTooltip, -%ToolTipDuration%
}

RemoveTooltip:
Tooltip
Return

; ----- Utility functions -----
DisableAll() {
    global w_mode, a_mode, s_mode, d_mode
    global SyntheticCtrlDown, SyntheticShiftDown, SyntheticIDown, F11F12_active

    if (w_mode = "arrow")
        Send {Blind}{Up up}
    else if (w_mode = "ij")
        Send {Blind}{i up}
    else if (w_mode = "pass")
        Send {Blind}{w up}
    w_mode := ""

    if (a_mode = "arrow")
        Send {Blind}{Left up}
    else if (a_mode = "ij")
        Send {Blind}{j up}
    else if (a_mode = "pass")
        Send {Blind}{a up}
    a_mode := ""

    if (s_mode = "arrow")
        Send {Blind}{Down up}
    else if (s_mode = "ij")
        Send {Blind}{k up}
    else if (s_mode = "pass")
        Send {Blind}{s up}
    s_mode := ""

    if (d_mode = "arrow")
        Send {Blind}{Right up}
    else if (d_mode = "ij")
        Send {Blind}{l up}
    else if (d_mode = "pass")
        Send {Blind}{d up}
    d_mode := ""

    if (SyntheticIDown) {
        Send {Blind}{i up}
        SyntheticIDown := false
    }
    if (SyntheticShiftDown) {
        Send {Shift up}
        SyntheticShiftDown := false
    }
    if (SyntheticCtrlDown) {
        Send {Ctrl up}
        SyntheticCtrlDown := false
    }

    F11F12_active := false
}

EnableFromCurrentState() {
    global w_mode, a_mode, s_mode, d_mode
    global SyntheticCtrlDown, SyntheticShiftDown, SyntheticIDown, F11F12_active
    global ToggleEnabled

    both := GetKeyState("F11", "P") && GetKeyState("F12", "P")

    if (both && !F11F12_active) {
        if !GetKeyState("LControl", "P") {
            Send {Ctrl down}
            SyntheticCtrlDown := true
        } else {
            SyntheticCtrlDown := false
        }
        Send {Shift down}
        SyntheticShiftDown := true
        Send {i down}
        SyntheticIDown := true
        F11F12_active := true
    }

    ; Apply WASD mapping if keys are held
    if (GetKeyState("w", "P")) {
        global w_mode
        if (ToggleEnabled) {
            if (F11F12_active || GetKeyState("LControl", "P")) {
                Send {Blind}{Up down}
                w_mode := "arrow"
            } else {
                Send {Blind}{i down}
                w_mode := "ij"
            }
        } else {
            Send {Blind}{w down}
            w_mode := "pass"
        }
    }

    if (GetKeyState("a", "P")) {
        global a_mode
        if (ToggleEnabled) {
            if (F11F12_active || GetKeyState("LControl", "P")) {
                Send {Blind}{Left down}
                a_mode := "arrow"
            } else {
                Send {Blind}{j down}
                a_mode := "ij"
            }
        } else {
            Send {Blind}{a down}
            a_mode := "pass"
        }
    }

    if (GetKeyState("s", "P")) {
        global s_mode
        if (ToggleEnabled) {
            if (F11F12_active || GetKeyState("LControl", "P")) {
                Send {Blind}{Down down}
                s_mode := "arrow"
            } else {
                Send {Blind}{k down}
                s_mode := "ij"
            }
        } else {
            Send {Blind}{s down}
            s_mode := "pass"
        }
    }

    if (GetKeyState("d", "P")) {
        global d_mode
        if (ToggleEnabled) {
            if (F11F12_active || GetKeyState("LControl", "P")) {
                Send {Blind}{Right down}
                d_mode := "arrow"
            } else {
                Send {Blind}{l down}
                d_mode := "ij"
            }
        } else {
            Send {Blind}{d down}
            d_mode := "pass"
        }
    }
}

; -----------------------
; F11+F12 logic
CheckF11F12() {
    global F11F12_active, SyntheticCtrlDown, SyntheticShiftDown, SyntheticIDown
    global w_mode, a_mode, s_mode, d_mode, ToggleEnabled

    if (!ToggleEnabled)
        return

    both := GetKeyState("F11", "P") && GetKeyState("F12", "P")

    if (both && !F11F12_active) {
        F11F12_active := true

        if (GetKeyState("w", "P") && w_mode = "ij") {
            Send {Blind}{i up}
            w_mode := ""
            Send {Blind}{Up down}
            w_mode := "arrow"
        }
        if (GetKeyState("a", "P") && a_mode = "ij") {
            Send {Blind}{j up}
            a_mode := ""
            Send {Blind}{Left down}
            a_mode := "arrow"
        }
        if (GetKeyState("s", "P") && s_mode = "ij") {
            Send {Blind}{k up}
            s_mode := ""
            Send {Blind}{Down down}
            s_mode := "arrow"
        }
        if (GetKeyState("d", "P") && d_mode = "ij") {
            Send {Blind}{l up}
            d_mode := ""
            Send {Blind}{Right down}
            d_mode := "arrow"
        }

        if !GetKeyState("LControl", "P") {
            Send {Ctrl down}
            SyntheticCtrlDown := true
        } else {
            SyntheticCtrlDown := false
        }

        Send {Shift down}
        SyntheticShiftDown := true
        Send {i down}
        SyntheticIDown := true

        ; show tooltip for mode change
        ShowModeTooltip("WASD → Arrows (F11+F12)")
    }
    else if (!both && F11F12_active) {
        F11F12_active := false
        ctrl_held := GetKeyState("LControl", "P")

        if (w_mode = "arrow") {
            if (!ctrl_held && GetKeyState("w", "P")) {
                Send {Blind}{Up up}
                Send {Blind}{i down}
                w_mode := "ij"
            } else if (!ctrl_held) {
                Send {Blind}{Up up}
                w_mode := ""
            }
        }

        if (a_mode = "arrow") {
            if (!ctrl_held && GetKeyState("a", "P")) {
                Send {Blind}{Left up}
                Send {Blind}{j down}
                a_mode := "ij"
            } else if (!ctrl_held) {
                Send {Blind}{Left up}
                a_mode := ""
            }
        }

        if (s_mode = "arrow") {
            if (!ctrl_held && GetKeyState("s", "P")) {
                Send {Blind}{Down up}
                Send {Blind}{k down}
                s_mode := "ij"
            } else if (!ctrl_held) {
                Send {Blind}{Down up}
                s_mode := ""
            }
        }

        if (d_mode = "arrow") {
            if (!ctrl_held && GetKeyState("d", "P")) {
                Send {Blind}{Right up}
                Send {Blind}{l down}
                d_mode := "ij"
            } else if (!ctrl_held) {
                Send {Blind}{Right up}
                d_mode := ""
            }
        }

        if (SyntheticIDown) {
            if (w_mode = "ij") {
                SyntheticIDown := false
            } else {
                Send {Blind}{i up}
                SyntheticIDown := false
            }
        }

        if (SyntheticShiftDown) {
            Send {Shift up}
            SyntheticShiftDown := false
        }
        if (SyntheticCtrlDown) {
            Send {Ctrl up}
            SyntheticCtrlDown := false
        }

        ; show tooltip for mode change
        ShowModeTooltip("WASD → IJKL")
    }
}

; -----------------------
; F11/F12 hotkeys
$*F11::CheckF11F12()
$*F11 up::CheckF11F12()
$*F12::CheckF11F12()
$*F12 up::CheckF11F12()

; -----------------------
; WASD remaps
$*w::
global w_mode, F11F12_active, ToggleEnabled
if (!ToggleEnabled) {
    Send {Blind}{w down}
    w_mode := "pass"
    return
}
if (F11F12_active || GetKeyState("LControl", "P")) {
    Send {Blind}{Up down}
    w_mode := "arrow"
} else {
    Send {Blind}{i down}
    w_mode := "ij"
}
return

$*w up::
global w_mode
if (w_mode = "arrow")
    Send {Blind}{Up up}
else if (w_mode = "ij")
    Send {Blind}{i up}
else if (w_mode = "pass")
    Send {Blind}{w up}
w_mode := ""
return

$*a::
global a_mode, F11F12_active, ToggleEnabled
if (!ToggleEnabled) {
    Send {Blind}{a down}
    a_mode := "pass"
    return
}
if (F11F12_active || GetKeyState("LControl", "P")) {
    Send {Blind}{Left down}
    a_mode := "arrow"
} else {
    Send {Blind}{j down}
    a_mode := "ij"
}
return

$*a up::
global a_mode
if (a_mode = "arrow")
    Send {Blind}{Left up}
else if (a_mode = "ij")
    Send {Blind}{j up}
else if (a_mode = "pass")
    Send {Blind}{a up}
a_mode := ""
return

$*s::
global s_mode, F11F12_active, ToggleEnabled
if (!ToggleEnabled) {
    Send {Blind}{s down}
    s_mode := "pass"
    return
}
if (F11F12_active || GetKeyState("LControl", "P")) {
    Send {Blind}{Down down}
    s_mode := "arrow"
} else {
    Send {Blind}{k down}
    s_mode := "ij"
}
return

$*s up::
global s_mode
if (s_mode = "arrow")
    Send {Blind}{Down up}
else if (s_mode = "ij")
    Send {Blind}{k up}
else if (s_mode = "pass")
    Send {Blind}{s up}
s_mode := ""
return

$*d::
global d_mode, F11F12_active, ToggleEnabled
if (!ToggleEnabled) {
    Send {Blind}{d down}
    d_mode := "pass"
    return
}
if (F11F12_active || GetKeyState("LControl", "P")) {
    Send {Blind}{Right down}
    d_mode := "arrow"
} else {
    Send {Blind}{l down}
    d_mode := "ij"
}
return

$*d up::
global d_mode
if (d_mode = "arrow")
    Send {Blind}{Right up}
else if (d_mode = "ij")
    Send {Blind}{l up}
else if (d_mode = "pass")
    Send {Blind}{d up}
d_mode := ""
return

; -----------------------
; Enter toggle
~Enter::
global ToggleEnabled
ToggleEnabled := !ToggleEnabled
if (!ToggleEnabled) {
    DisableAll()
    ShowModeTooltip("Script: DISABLED")
} else {
    EnableFromCurrentState()
    ; show current WASD mode
    if (F11F12_active || GetKeyState("LControl", "P"))
        ShowModeTooltip("WASD → Arrows")
    else
        ShowModeTooltip("WASD → IJKL")
}
return

; Esc re-enable
~Esc::
global ToggleEnabled
if (!ToggleEnabled) {
    ToggleEnabled := true
    EnableFromCurrentState()
    ShowModeTooltip("Script: ENABLED")
}
return

#IfWinActive
