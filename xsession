. $HOME/.bashrc
xset b 0
xrdb $HOME/.Xdefaults
xmodmap .xmodmap
xsetroot -solid "#3f3f3f"

yeahconsole &
gnome-panel &
[ -d ~/code/panelator ] && (cd ~/code/panelator; ./panelator.py) &
xmonad
