
add_to_path ~/bin
add_to_path "$HOME/Dropbox/bin"
add_to_path "$HOME/.cabal/bin"

# This could be dangerous, but I play with fire.
for P in "$PROJECTS"/*/bin; do
    add_to_path "$P"
done
