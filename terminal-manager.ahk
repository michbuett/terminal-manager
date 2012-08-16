;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Directives
#Persistent
#SingleInstance force

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Auto-Execute

Menu, TRAY, NoStandard
Menu, Tray, Icon, %A_ScriptDir%\terminal.ico
Menu, TRAY, Add, Exit, Exit
Menu, TRAY, Tip, Putty Terminal Manager
OnExit, Exit

IniRead, puttyExe, %A_ScriptDir%\terminal-manager.ini, General, putty
IniRead, puttySession, %A_ScriptDir%\terminal-manager.ini, General, session
IniRead, puttyUser, %A_ScriptDir%\terminal-manager.ini, Login, user
IniRead, puttyPW, %A_ScriptDir%\terminal-manager.ini, Login, pw

puttyTerminalList := Array()
puttyActiveDlg := 0

Return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Hotkeys

LWin & 1::SetActivePuttyTerminal(1)
LWin & 2::SetActivePuttyTerminal(2)
LWin & 3::SetActivePuttyTerminal(3)
LWin & 4::SetActivePuttyTerminal(4)
LWin & 5::SetActivePuttyTerminal(5)
LWin & 6::SetActivePuttyTerminal(6)
LWin & 7::SetActivePuttyTerminal(7)
LWin & 8::SetActivePuttyTerminal(8)
LWin & 9::SetActivePuttyTerminal(9)

#IfWinActive, ahk_class PuTTY
    ; fix escape sequences in putty windows
    Alt & Up::Send !k
    Alt & Down::Send !j
    Alt & Left::Send !h
    Alt & Right::Send !l

    Shift & Up::Send +k
    Shift & Down::Send +j
    Shift & Left::Send +h
    Shift & Right::Send +l
    
    ^#t::DestroyActivePuttyTerminal()
    LWin & Left::TerminalSwitchMonitor()
    LWin & Right::TerminalSwitchMonitor()
#IfWinActive

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Functions/Procedures

Exit:
    DestroyPuttyTerminals()
    ExitApp
Return

InitPuttyTerminal() {
    global puttyExe
    global puttySession
    global puttyUser
    global puttyPW
    
    ; open putty terminal
    cmd := puttyExe
    if (puttySession) {
        cmd := cmd . " -load " . puttySession
    }
    
    Run, %cmd%, , , PuttyDlg
    WinWaitActive, ahk_pid %PuttyDlg%
    dlgId := WinExist("ahk_pid" . PuttyDlg)

    ; window styles
    WinSet, Transparent, 220, ahk_id %dlgId%
    WinSet, AlwaysOnTop, On, ahk_id %dlgId%
    Send, !{Enter}

    ; login
    if (puttyUser) {
        Sleep, 100
        Send, %puttyUser%{Enter}
    }
    if (puttyPW) {
        Sleep, 100
        Send, %puttyPW%{Enter}
    }
    return dlgId
}

SetActivePuttyTerminal(index) {
    global puttyTerminalList
    global puttyActiveDlg
    
    activeTerminalID := puttyTerminalList[index]
    if (WinExist("ahk_id" . activeTerminalID)) {
        WinGetPos, , currentYPos
        if (currentYPos >= 0) {
            WinTransitY(activeTerminalID, -2000)
        } else {
            WinTransitY(activeTerminalID, 0)
            WinActivate
        }
    } else {
        newTerminalID := InitPuttyTerminal()
        puttyTerminalList[index] := newTerminalID
    }
    puttyActiveDlg := index
}

TerminalSwitchMonitor() {
    global puttyTerminalList
    global puttyActiveDlg
    
    activeTerminalID := puttyTerminalList[puttyActiveDlg]
    if (WinExist("ahk_id" . activeTerminalID)) {
        WinGetPos, currentXPos, , currentWidth
        ;MsgBox, pos: %currentXPos%, width: %currentWidth%
        if (currentXPos < currentWidth) {
            WinMove, , , currentWidth
        } else {
            WinMove, , , 0
        }
    }
}

DestroyPuttyTerminals() {
    global puttyTerminalList
    global puttyActiveDlg
    
    for terminalID in puttyTerminalList {
        puttyActiveDlg := terminalID
        DestroyActivePuttyTerminal()
    }
}

DestroyActivePuttyTerminal() {
    global puttyTerminalList
    global puttyActiveDlg
    
    activeTerminalID := puttyTerminalList[puttyActiveDlg]
    if (WinExist("ahk_id" . activeTerminalID)) {
        WinTransitY(activeTerminalID, -2000)
        WinKill, ahk_id %activeTerminalID%
        puttyTerminalList[puttyActiveDlg] := false
        puttyActiveDlg := 0
    }
}

WinTransitY(winId, targetY) {
    SetWinDelay, 10
    if (WinExist("ahk_id" . winId)) {
        WinGetPos, , currentYPos
        ;MsgBox Move window from %currentYPos% to %targetY%
        
        if (currentYPos > targetY) {
            while (currentYPos > targetY) {
                newYPos := currentYPos - 100
                WinMove, , newYPos 
                WinGetPos, , currentYPos
            }
        } else {
            while (currentYPos < targetY) {
                newYPos := currentYPos + 100
                WinMove, , newYPos 
                WinGetPos, , currentYPos
            }
        }
    }
    
}
Return