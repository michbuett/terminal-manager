;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Directives
#Persistent
#SingleInstance force

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Auto-Execute

Menu, TRAY, NoStandard
Menu, TRAY, Icon, %A_ScriptDir%\terminal.ico
Menu, TRAY, Add, Hide all, HideAll
Menu, TRAY, Add, Reset, Reset
Menu, TRAY, Add, Exit, Exit
Menu, TRAY, Tip, Terminal Manager
OnExit, Exit

terminals := Array()
activeTerminal := 0
config := A_ScriptDir . "\terminal-manager.ini"

; load default configuration
IniRead, defaultExe, %config%, Defaults, exe
IniRead, defaultX, %config%, Defaults, x
IniRead, defaultY, %config%, Defaults, y
IniRead, defaultWidth, %config%, Defaults, width
IniRead, defaultHeight, %config%, Defaults, height
IniRead, defaultUser, %config%, Defaults, user
IniRead, defaultPW, %config%, Defaults, pw

Loop {
    ; load session dependent configuration
    session := "Session" . A_Index
    IniRead, currentExe, %config%, %session%, exe, %defaultExe%
    IniRead, currentX, %config%, %session%, x, %defaultX%
    IniRead, currentY, %config%, %session%, y, %defaultY%
    IniRead, currentWidth, %config%, %session%, width, %defaultWidth%
    IniRead, currentHeight, %config%, %session%, height, %defaultHeight%
    IniRead, currentUser, %config%, %session%, user, %defaultUser%
    IniRead, currentPW, %config%, %session%, pw, %defaultPW%

    sessionCfg := {exe: currentExe, x: currentX, y: currentY, width: currentWidth, height: currentHeight, user: currentUser, pw: currentPW}
    terminals.Insert(sessionCfg)
    
    ;tmp := serializeObject(sessionCfg)
    ;MsgBox, %tmp%
} Until A_Index >= 9

Return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Hotkeys

LWin & 1::SetActiveTerminal(1)
LWin & 2::SetActiveTerminal(2)
LWin & 3::SetActiveTerminal(3)
LWin & 4::SetActiveTerminal(4)
LWin & 5::SetActiveTerminal(5)
LWin & 6::SetActiveTerminal(6)
LWin & 7::SetActiveTerminal(7)
LWin & 8::SetActiveTerminal(8)
LWin & 9::SetActiveTerminal(9)
^#t::CloseTerminal(activeTerminal, false, true)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Functions/Procedures

HideAll:
    HideAllTerminals()
Return

Reset:
    DestroyAllTerminals()
Return

Exit:
    DestroyAllTerminals()
    ExitApp
Return

InitTerminal(cfg) {
    exe :=  cfg.exe
    user :=  cfg.user
    pw :=  cfg.user
    
    ; open terminal
    Run, %exe%, , , processId
    WinWaitActive, ahk_pid %processId%
    dlgId := WinExist("ahk_pid" . processId)

    ; window styles
    WinSet, Transparent, 220, ahk_id %dlgId%
    WinSet, AlwaysOnTop, On, ahk_id %dlgId%
    Send, !{Enter}
    WinMove, , , cfg.x, cfg.y
    ; resize terminal to the current monitor dimension (seperate step because immediate
    ; updating position and size can sometimes get mixed up)
    WinMove, , , , , cfg.width, cfg.height

    ; login
    if (user) {
        Sleep, 200
        Send, %user%{Enter}
    }
    if (pw) {
        Sleep, 200
        Send, %pw%{Enter}
    }
    return dlgId
}

SetActiveTerminal(index) {
    global terminals
    global activeTerminal
    
    activeTerminalCfg := terminals[index]
    activeTerminalID := activeTerminalCfg.terminalID
    
    if (activeTerminalID && WinExist("ahk_id" . activeTerminalID)) {
        ; the terminal alread exits
        ; -> toggle active state
            WinGetPos, , currentYPos
        if (currentYPos >= 0) {
            IfWinActive
            {
                ; toggle active and visible terminals
                HideTerminal(activeTerminalCfg)
            } else {
                ; the terminal is visible but not active
                ; -> focus it
                WinActivate
            }
        } else {
            ShowTerminal(activeTerminalCfg)
            WinActivate
        }
    } else {
        ; there is no terminal with this id
        ; -> create a new one
        newTerminalID := InitTerminal(terminals[index])
        terminals[index].terminalID := newTerminalID
    }
    
    activeTerminal := index
}

ShowTerminal(cfg) {
    SetWinDelay, 10
    
    winId := cfg.terminalID
    targetY := cfg.y
    
    if (WinExist("ahk_id" . winId)) {
        WinGetPos, , currentYPos
        
        while (currentYPos < targetY) {
            newYPos := currentYPos + 100
            WinMove, , newYPos 
            WinGetPos, , currentYPos
        }
    }
}

HideTerminal(cfg) {
    SetWinDelay, 10
    
    winId := cfg.terminalID
    targetY := -2000
    
    if (WinExist("ahk_id" . winId)) {
        WinGetPos, , currentYPos
        
        while (currentYPos > targetY) {
            newYPos := currentYPos - 100
            WinMove, , newYPos 
            WinGetPos, , currentYPos
        }
    }
}

/**
 * Closes (hides and may destroys) a terminal window with the given index
 *
 * @param {Number} index
 *      the index of the terminal to close
 *
 * @param {Boolean} force
 *      if set to FALSE only active terminals are closed
 *
 * @param {Boolean} kill
 *      destroys the window instance if set to TRUE
 */
CloseTerminal(index, force, kill) {
    global terminals
    global activeTerminal
    
    activeTerminalID := terminals[index].terminalID
    if (WinExist("ahk_id" . activeTerminalID)) {
        if (force || WinActive("ahk_id" . activeTerminalID)) {
            HideTerminal(terminals[index])
            if (kill) {
                WinKill, ahk_id %activeTerminalID%
                terminals[index].terminalID := -1
            }
            activeTerminal := 0
        }
    }
}

/** 
 * Hides all terminal windows
 */
HideAllTerminals() {
    global terminals

    Loop {
        CloseTerminal(A_Index, true, false)
    } Until A_Index >= 9
}

/** 
 * Destroys all terminal windows
 */
DestroyAllTerminals() {
    global terminals

    Loop {
        CloseTerminal(A_Index, true, true)
    } Until A_Index >= 9
}


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; FOR DEBUGGING

serializeObject(obj) {
    s := ""
    for key, val in obj {
        s := s . key . ": " . val . ", "
    }
    return s
}

Return