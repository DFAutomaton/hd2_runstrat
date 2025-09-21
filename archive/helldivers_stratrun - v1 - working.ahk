; AutoHotkey v1
; - WASD -> I J K L normally
; - WASD -> Arrow keys when LCtrl held OR when F11+F12 are held together
; - F11+F12 also presses & holds Ctrl+Shift+I
; - Avoid emitting Ctrl up/down while physical LCtrl is held

#SingleInstance force
#UseHook
SetBatchLines -1

; State
F11F12_active := false
SyntheticCtrlDown := false
SyntheticShiftDown := false
SyntheticIDown := false

; Per-key mode: "arrow", "ij", or ""
w_mode := ""
a_mode := ""
s_mode := ""
d_mode := ""

; ------------------------------------------------
; Function that activates/deactivates the F11+F12 mode
CheckF11F12() {
    global F11F12_active, SyntheticCtrlDown, SyntheticShiftDown, SyntheticIDown
    global w_mode, a_mode, s_mode, d_mode

    both := GetKeyState("F11","P") && GetKeyState("F12","P")

    ; Activate
    if (both && !F11F12_active) {
        F11F12_active := true

        ; Convert currently-held ij -> arrow for any pressed keys
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

        ; Synthesize Ctrl only if physical LCtrl not held
        if !GetKeyState("LControl","P") {
            Send {Ctrl down}
            SyntheticCtrlDown := true
        } else {
            SyntheticCtrlDown := false
        }

        ; Always synthesize Shift and i for the mode
        Send {Shift down}
        SyntheticShiftDown := true

        Send {i down}
        SyntheticIDown := true
    }

    ; Deactivate
    else if (!both && F11F12_active) {
        F11F12_active := false
        ctrl_held := GetKeyState("LControl","P")

        ; For each key in arrow mode: if physical Ctrl still held -> keep arrow;
        ; otherwise convert to ij if physical key still down, or release arrow if not.
        if (w_mode == "arrow") {
            if (!ctrl_held && GetKeyState("w","P")) {
                Send {Blind}{Up up}
                Send {Blind}{i down}
                w_mode := "ij"
            } else if (!ctrl_held) {
                Send {Blind}{Up up}
                w_mode := ""
            }
            ; if ctrl_held: leave arrow down and leave w_mode as "arrow"
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

        ; Release synthesized 'i' only if nothing needs it (w_mode manages 'i')
        if (SyntheticIDown) {
            if (w_mode == "ij") {
                ; give ownership to the per-key press, do NOT send i up
                SyntheticIDown := false
            } else {
                Send {Blind}{i up}
                SyntheticIDown := false
            }
        }

        ; Release synthesized Shift always
        if (SyntheticShiftDown) {
            Send {Shift up}
            SyntheticShiftDown := false
        }

        ; Release synthesized Ctrl if we owned it
        if (SyntheticCtrlDown) {
            Send {Ctrl up}
            SyntheticCtrlDown := false
        }
    }
}
; ------------------------------------------------

; F11 / F12 hooks — call CheckF11F12() on press/release
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

; ------------------------------------------------
; WASD remaps (per-key mode tracking). Use {Blind} so we don't alter physical modifier state.
$*w::
{
    global w_mode, F11F12_active
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
    w_mode := ""
    return
}

$*a::
{
    global a_mode, F11F12_active
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
    a_mode := ""
    return
}

$*s::
{
    global s_mode, F11F12_active
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
    s_mode := ""
    return
}

$*d::
{
    global d_mode, F11F12_active
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
    d_mode := ""
    return
}

; ------------------------------------------------
; LCtrl edge cases (while F11+F12 active)
~LControl::
{
    ; If physical LCtrl is pressed while we had synthesized Ctrl, relinquish ownership
    if (F11F12_active && SyntheticCtrlDown) {
        SyntheticCtrlDown := false
    }
    return
}

~LControl up::
{
    ; If the user releases physical Ctrl while the F11+F12 mode is active and we don't own Ctrl,
    ; synthesize it so the mode keeps Ctrl held.
    if (F11F12_active && !GetKeyState("LControl","P") && !SyntheticCtrlDown) {
        Send {Ctrl down}
        SyntheticCtrlDown := true
    }
    return
}

; End of script
