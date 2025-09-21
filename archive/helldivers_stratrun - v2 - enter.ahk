; AutoHotkey v1
; WASD -> I J K L normally
; WASD -> Arrow keys when LCtrl held OR when F11+F12 are held together
; F11+F12 also presses & holds Ctrl+Shift+I
; Press Enter to toggle the script on/off (Enter still sends normally). Press Esc to re-enable.
; Based on the previously provided working version.

#SingleInstance force
#UseHook
SetBatchLines -1

; ----- Configuration / state -----
ToggleEnabled := true             ; script starts enabled
F11F12_active := false
SyntheticCtrlDown := false
SyntheticShiftDown := false
SyntheticIDown := false

; Per-key mode: "arrow", "ij", "pass" (we sent original), or "" (none)
w_mode := ""
a_mode := ""
s_mode := ""
d_mode := ""

; -----------------------
; Utility: release everything the script may hold (used when disabling)
DisableAll()
{
    global w_mode, a_mode, s_mode, d_mode
    global SyntheticCtrlDown, SyntheticShiftDown, SyntheticIDown, F11F12_active

    ; Release per-key held states
    if (w_mode == "arrow")
        Send {Blind}{Up up}
    else if (w_mode == "ij")
        Send {Blind}{i up}
    else if (w_mode == "pass")
        Send {Blind}{w up}
    w_mode := ""

    if (a_mode == "arrow")
        Send {Blind}{Left up}
    else if (a_mode == "ij")
        Send {Blind}{j up}
    else if (a_mode == "pass")
        Send {Blind}{a up}
    a_mode := ""

    if (s_mode == "arrow")
        Send {Blind}{Down up}
    else if (s_mode == "ij")
        Send {Blind}{k up}
    else if (s_mode == "pass")
        Send {Blind}{s up}
    s_mode := ""

    if (d_mode == "arrow")
        Send {Blind}{Right up}
    else if (d_mode == "ij")
        Send {Blind}{l up}
    else if (d_mode == "pass")
        Send {Blind}{d up}
    d_mode := ""

    ; Release synthetic i/Shift/Ctrl if we own them
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

    ; Clear F11F12 active flag to avoid confusion
    F11F12_active := false
}

; Utility: enable and apply current state to currently-held physical keys
EnableFromCurrentState()
{
    global w_mode, a_mode, s_mode, d_mode
    global SyntheticCtrlDown, SyntheticShiftDown, SyntheticIDown, F11F12_active
    global ToggleEnabled

    ; Determine whether F11+F12 are currently both held
    both := GetKeyState("F11","P") && GetKeyState("F12","P")

    ; If F11+F12 are held, activate mode (this will also synth Ctrl/Shift/i as needed)
    if (both && !F11F12_active) {
        ; Reuse the activation logic (but avoid duplicating code)
        ; Convert currently-held native ij to arrows if needed (but since we just enabled, modes are likely empty)
        ; Synthesize Ctrl only if physical LCtrl not held
        if !GetKeyState("LControl","P") {
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

    ; For any WASD keys that are physically held now, ensure they are mapped according to current state.
    if (GetKeyState("w","P")) {
        if (ToggleEnabled) {
            if (F11F12_active || GetKeyState("LControl","P")) {
                Send {Blind}{Up down}
                w_mode := "arrow"
            } else {
                Send {Blind}{i down}
                w_mode := "ij"
            }
        } else {
            ; disabled: ensure native 'w' is down
            Send {Blind}{w down}
            w_mode := "pass"
        }
    }

    if (GetKeyState("a","P")) {
        if (ToggleEnabled) {
            if (F11F12_active || GetKeyState("LControl","P")) {
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

    if (GetKeyState("s","P")) {
        if (ToggleEnabled) {
            if (F11F12_active || GetKeyState("LControl","P")) {
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

    if (GetKeyState("d","P")) {
        if (ToggleEnabled) {
            if (F11F12_active || GetKeyState("LControl","P")) {
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
; F11+F12 activation/deactivation logic (extracted from the previous working code)
CheckF11F12() {
    global F11F12_active, SyntheticCtrlDown, SyntheticShiftDown, SyntheticIDown
    global w_mode, a_mode, s_mode, d_mode, ToggleEnabled

    ; If script is disabled, don't do anything here
    if (!ToggleEnabled)
        return

    both := GetKeyState("F11","P") && GetKeyState("F12","P")

    ; Activate
    if (both && !F11F12_active) {
        F11F12_active := true

        if (GetKeyState("w","P") && w_mode == "ij") {
            Send {Blind}{i up}
            w_mode := ""
            Send {Blind}{Up down}
            w_mode := "arrow"
        }
        if (GetKeyState("a","P") && a_mode == "ij") {
            Send {Blind}{j up}
            a_mode := ""
            Send {Blind}{Left down}
            a_mode := "arrow"
        }
        if (GetKeyState("s","P") && s_mode == "ij") {
            Send {Blind}{k up}
            s_mode := ""
            Send {Blind}{Down down}
            s_mode := "arrow"
        }
        if (GetKeyState("d","P") && d_mode == "ij") {
            Send {Blind}{l up}
            d_mode := ""
            Send {Blind}{Right down}
            d_mode := "arrow"
        }

        if !GetKeyState("LControl","P") {
            Send {Ctrl down}
            SyntheticCtrlDown := true
        } else {
            SyntheticCtrlDown := false
        }

        Send {Shift down}
        SyntheticShiftDown := true

        Send {i down}
        SyntheticIDown := true
    }

    ; Deactivate
    else if (!both && F11F12_active) {
        F11F12_active := false
        ctrl_held := GetKeyState("LControl","P")

        if (w_mode == "arrow") {
            if (!ctrl_held && GetKeyState("w","P")) {
                Send {Blind}{Up up}
                Send {Blind}{i down}
                w_mode := "ij"
            } else if (!ctrl_held) {
                Send {Blind}{Up up}
                w_mode := ""
            }
        }

        if (a_mode == "arrow") {
            if (!ctrl_held && GetKeyState("a","P")) {
                Send {Blind}{Left up}
                Send {Blind}{j down}
                a_mode := "ij"
            } else if (!ctrl_held) {
                Send {Blind}{Left up}
                a_mode := ""
            }
        }

        if (s_mode == "arrow") {
            if (!ctrl_held && GetKeyState("s","P")) {
                Send {Blind}{Down up}
                Send {Blind}{k down}
                s_mode := "ij"
            } else if (!ctrl_held) {
                Send {Blind}{Down up}
                s_mode := ""
            }
        }

        if (d_mode == "arrow") {
            if (!ctrl_held && GetKeyState("d","P")) {
                Send {Blind}{Right up}
                Send {Blind}{l down}
                d_mode := "ij"
            } else if (!ctrl_held) {
                Send {Blind}{Right up}
                d_mode := ""
            }
        }

        if (SyntheticIDown) {
            if (w_mode == "ij") {
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
    }
}

; -----------------------
; Hotkeys for F11 / F12 to trigger the check (these do nothing when script is disabled)
$*F11::
    CheckF11F12()
return

$*F11 up::
    CheckF11F12()
return

$*F12::
    CheckF11F12()
return

$*F12 up::
    CheckF11F12()
return

; -----------------------
; WASD remaps (per-key mode tracking). Keep $* so we can simulate native keys when disabled.
$*w::
{
    global w_mode, F11F12_active, ToggleEnabled
    if (!ToggleEnabled) {
        ; disabled => pass native 'w' through by sending it ourselves
        Send {Blind}{w down}
        w_mode := "pass"
        return
    }

    if (F11F12_active || GetKeyState("LControl","P")) {
        Send {Blind}{Up down}
        w_mode := "arrow"
    } else {
        Send {Blind}{i down}
        w_mode := "ij"
    }
    return
}
$*w up::
{
    global w_mode
    if (w_mode == "arrow")
        Send {Blind}{Up up}
    else if (w_mode == "ij")
        Send {Blind}{i up}
    else if (w_mode == "pass")
        Send {Blind}{w up}
    w_mode := ""
    return
}

$*a::
{
    global a_mode, F11F12_active, ToggleEnabled
    if (!ToggleEnabled) {
        Send {Blind}{a down}
        a_mode := "pass"
        return
    }

    if (F11F12_active || GetKeyState("LControl","P")) {
        Send {Blind}{Left down}
        a_mode := "arrow"
    } else {
        Send {Blind}{j down}
        a_mode := "ij"
    }
    return
}
$*a up::
{
    global a_mode
    if (a_mode == "arrow")
        Send {Blind}{Left up}
    else if (a_mode == "ij")
        Send {Blind}{j up}
    else if (a_mode == "pass")
        Send {Blind}{a up}
    a_mode := ""
    return
}

$*s::
{
    global s_mode, F11F12_active, ToggleEnabled
    if (!ToggleEnabled) {
        Send {Blind}{s down}
        s_mode := "pass"
        return
    }

    if (F11F12_active || GetKeyState("LControl","P")) {
        Send {Blind}{Down down}
        s_mode := "arrow"
    } else {
        Send {Blind}{k down}
        s_mode := "ij"
    }
    return
}
$*s up::
{
    global s_mode
    if (s_mode == "arrow")
        Send {Blind}{Down up}
    else if (s_mode == "ij")
        Send {Blind}{k up}
    else if (s_mode == "pass")
        Send {Blind}{s up}
    s_mode := ""
    return
}

$*d::
{
    global d_mode, F11F12_active, ToggleEnabled
    if (!ToggleEnabled) {
        Send {Blind}{d down}
        d_mode := "pass"
        return
    }

    if (F11F12_active || GetKeyState("LControl","P")) {
        Send {Blind}{Right down}
        d_mode := "arrow"
    } else {
        Send {Blind}{l down}
        d_mode := "ij"
    }
    return
}
$*d up::
{
    global d_mode
    if (d_mode == "arrow")
        Send {Blind}{Right up}
    else if (d_mode == "ij")
        Send {Blind}{l up}
    else if (d_mode == "pass")
        Send {Blind}{d up}
    d_mode := ""
    return
}

; -----------------------
; Toggle hotkeys: Enter toggles the script (Enter still sends normally), Esc re-enables.
~Enter::
{
    ; Toggle the enabled state, but let the physical Enter propagate (~ allows native Enter)
    ToggleEnabled := !ToggleEnabled
    if (!ToggleEnabled) {
        ; disabling: release everything the script holds
        DisableAll()
    } else {
        ; re-enabling: re-apply mapping for currently-held physical keys
        EnableFromCurrentState()
    }
    ; optional visual feedback (uncomment if you want)
    ; Tooltip, ToggleEnabled ? "Script: ENABLED" : "Script: DISABLED"
    ; SetTimer, RemoveTooltip, -800
    return
}

~Esc::
{
    ; Re-enable on Esc (and reapply state), let native Esc propagate
    if (!ToggleEnabled) {
        ToggleEnabled := true
        EnableFromCurrentState()
    }
    return
}

; Optional: remove tooltip helper
RemoveTooltip:
Tooltip
Return

; -----------------------
; LCtrl edge cases (while F11+F12 active). These do nothing when ToggleEnabled is false.
~LControl::
{
    global F11F12_active, SyntheticCtrlDown, ToggleEnabled
    if (!ToggleEnabled)
        return
    if (F11F12_active && SyntheticCtrlDown) {
        SyntheticCtrlDown := false
    }
    return
}

~LControl up::
{
    global F11F12_active, SyntheticCtrlDown, ToggleEnabled
    if (!ToggleEnabled)
        return
    if (F11F12_active && !GetKeyState("LControl","P") && !SyntheticCtrlDown) {
        Send {Ctrl down}
        SyntheticCtrlDown := true
    }
    return
}

; End of script
