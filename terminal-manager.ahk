;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Directives
#Persistent
#SingleInstance force

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Auto-Execute

keys := Array()
terminals := Array()
activeTerminal := 0
configFile := A_ScriptDir . "\terminal-manager.ini"
helpFile := A_ScriptDir . "\README.md"

; load default configuration
IniRead, defaultExe, %configFile%, Defaults, exe
IniRead, defaultX, %configFile%, Defaults, x
IniRead, defaultY, %configFile%, Defaults, y
IniRead, defaultWidth, %configFile%, Defaults, width
IniRead, defaultHeight, %configFile%, Defaults, height
IniRead, defaultUser, %configFile%, Defaults, user
IniRead, defaultPW, %configFile%, Defaults, pw

Loop {
    ; load session dependent configuration
    session := "Session" . A_Index
    IniRead, currentExe, %configFile%, %session%, exe, %defaultExe%
    IniRead, currentX, %configFile%, %session%, x, %defaultX%
    IniRead, currentY, %configFile%, %session%, y, %defaultY%
    IniRead, currentWidth, %configFile%, %session%, width, %defaultWidth%
    IniRead, currentHeight, %configFile%, %session%, height, %defaultHeight%
    IniRead, currentUser, %configFile%, %session%, user, %defaultUser%
    IniRead, currentPW, %configFile%, %session%, pw, %defaultPW%
    sessionCfg := {exe: currentExe, x: currentX, y: currentY, width: currentWidth, height: currentHeight, user: currentUser, pw: currentPW}
    terminals.Insert(sessionCfg)

    ; load keybinding to toggle terminal i
    key := "term" . A_Index
    hotkeyLabel := "SetActiveTerminal" . A_Index 
    IniRead, key, %configFile%, Keys, %key%, %defaultPW%
    Hotkey, %key%, %hotkeyLabel%
} Until A_Index >= 9

IniRead, key_HideAll, %configFile%, Keys, hideAll
IniRead, key_KillActive, %configFile%, Keys, killActive
IniRead, key_KillAll, %configFile%, Keys, killAll
IniRead, key_Exit, %configFile%, Keys, exit

Hotkey, %key_HideAll%, HideAll
Hotkey, %key_KillActive%, KillActive
Hotkey, %key_KillAll%, KillAll
Hotkey, %key_Exit%, Exit

Menu, TRAY, NoStandard
Menu, TRAY, Add, Show Help, Help 
Menu, TRAY, Add
Menu, TRAY, Icon, %A_ScriptDir%\terminal.ico
Menu, TRAY, Add, Hide all (%key_HideAll%), HideAll
Menu, TRAY, Add, Kill all (%key_KillAll%), KillAll
Menu, TRAY, Add
Menu, TRAY, Add, Exit (%key_Exit%), Exit
Menu, TRAY, Tip, Terminal Manager
OnExit, Exit

Return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Functions/Procedures

SetActiveTerminal1:
    SetActiveTerminal(1)
Return

SetActiveTerminal2:
    SetActiveTerminal(2)
Return

SetActiveTerminal3:
    SetActiveTerminal(3)
Return

SetActiveTerminal4:
    SetActiveTerminal(4)
Return

SetActiveTerminal5:
    SetActiveTerminal(5)
Return

SetActiveTerminal6:
    SetActiveTerminal(6)
Return

SetActiveTerminal7:
    SetActiveTerminal(7)
Return

SetActiveTerminal8:
    SetActiveTerminal(8)
Return

SetActiveTerminal9:
    SetActiveTerminal(9)
Return

Help:
    FileRead, helpText, %helpFile%
    MsgBox, 64, Terminal Manager Help, %helpText%
Return

HideAll:
    HideAllTerminals()
Return

KillActive:
    CloseTerminal(activeTerminal, false, true)
Return

KillAll:
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