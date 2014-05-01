prepend_paths=("$HOME/local/bin" "$HOME/scripts")
path=($prepend_paths ${path:|prepend_paths})
unset prepend_paths
