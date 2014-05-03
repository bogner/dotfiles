prepend_paths=("$HOME/local/bin" "$HOME/scripts")
path=($prepend_paths ${path:|prepend_paths})
unset prepend_paths

prepend_fpaths=(~/.zshfunctions ~/scripts/completion/zsh)
fpath=($prepend_fpaths ${fpath:|prepend_fpaths})
for d in "$prepend_fpaths[@]"; do
    typeset -a fs
    # List basenames of each file in the directory
    fs=( "$d"/*(N:t) )
    # Autoload any names we found
    [ ${#fs} -eq 0 ] || autoload -U "$fs[@]"
done
unset prepend_fpaths
