# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: 2026 Stephen Clarke <stephenlclarke@mac.com> - https://github.com/stephenlclarke/mac-spinner

Output demo/spinner.gif
Set Shell zsh
Set FontSize 18
Set Columns 80
Set Rows 12
Set Theme { "name": "Mac Spinner High Contrast", "black": "#111827", "red": "#ff5555", "green": "#50fa7b", "yellow": "#f1fa8c", "blue": "#8be9fd", "magenta": "#ff79c6", "cyan": "#8be9fd", "white": "#f8f8f2", "brightBlack": "#6272a4", "brightRed": "#ff6e6e", "brightGreen": "#69ff94", "brightYellow": "#ffffa5", "brightBlue": "#a4ffff", "brightMagenta": "#ff92df", "brightCyan": "#a4ffff", "brightWhite": "#ffffff", "background": "#111827", "foreground": "#ffffff", "selection": "#334155", "cursor": "#ffffff" }
Hide
Type "swift build -c release"
Enter
Sleep 2s
Show
Type "export PATH=./.build/release:$PATH"
Enter
Type "mac-spinner --message pending --pending"
Enter
Sleep 1s
Type "mac-spinner --message done --done"
Enter
Sleep 1s
Type "mac-spinner --message run --output /tmp/mac-spinner.log -- echo ok"
Enter
Sleep 1s
Type "cat /tmp/mac-spinner.log"
Enter
Sleep 1s
Type "mac-spinner --message spinning --spin-only"
Enter
Sleep 2s
Ctrl+C
Sleep 1s
Type "./examples/repeater.sh -p 2 -- echo tick"
Enter
Sleep 2s
Space
Sleep 1s
