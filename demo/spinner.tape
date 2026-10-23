Output demo/spinner.gif
Set Shell zsh
Set FontSize 18
Set Columns 80
Set Height 180
Set Theme "Catppuccin Mocha"
Hide
Type "swift build -c release"
Enter
Sleep 2s
Show
Type "./.build/release/mac-spinner --message 'Waiting for jobs' --spin-only"
Enter
Sleep 3s
Ctrl+C
Sleep 1s
