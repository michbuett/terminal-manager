terminal-manager
================

It's an AutoHotkey script to manage terminals for Windows. It's primary purpose was to handle multiple open putty terminals but it can used with all kinds of terminals. 

Configuration
-------------
You can configure within the <code>terminal-manager.ini</code> the executable, position, dimension and login credentials for each terminal and set default values. For example:
```ini
# This section defines the keybord shortcuts
[Keys]
# the keys for toggling a terminal
term1=#LWin & 1
term2=LWin & 2
...
term9=LWin & 9
# general keybings
hideAll=^#h
# destroys the active terminal
killActive=^#t
# hides and destroys all existing terminals (make a reset)
killAll=^#r
# well ...
exit=^#e

# the value of the Defaults section will be applied to each session
[Defaults]
# this commando will be executed
exe=C:\MyAppFolder\putty.exe -load my-putty-session
# the dimensions (e.g. fullscreen for a 1280x960 resolution)
width=1280
height=960
# the position (at the 2nd monitor)
x=1280
y=0
# login data (no login if empty)
user=myUser
pw=mySecretPW

# special settings for each session
[Session2]
# e.g. different terminal without login for second terminal
exe=cmd
user=
pw=

```

Keyboard shortcuts (defaults)
-----------------------------
* <code>Win+[1..9]</code>: Binds a terminal to this number; pressing it again will toggle this terminal (config with <code>term1, ...</code>)
* <code>Ctrl+Win+t</code>: Terminate the active terminal (config with <code>killActive</code>)
* <code>Ctrl+Win+h</code>: Hides all existing terminals (config with <code>hideAll</code>)
* <code>Ctrl+Win+r</code>: Destroys all existing terminals (make a reset, config with <code>killAll</code>)
* <code>Ctrl+Win+e</code>: Exits script (config with <code>exit</code>)
