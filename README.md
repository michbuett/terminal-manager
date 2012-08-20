terminal-manager
================

It's an AutoHotkey script to manage terminals for Windows. It's primary purpose was to handle multiple open putty terminals but it can used with all kinds of terminals. 

Configuration
-------------
You can configure within the <code>terminal-manager.ini</code> the executable, position, dimension and login credentials for each terminal and set default values. For example:
<pre><code>
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
# e.g. different terminal and no login for second terminal
exe=cmd
user=
pw=

<code></pre>

Keyboard shortcuts
------------------
* \<WIN\>-x: (where x is one of the number keys 1 -9) binds a terminal to this number; pressing \<WIN\>-x again will toggle this terminal
* \<CTRL\>-\<WIN\>-t: terminate the active terminal
