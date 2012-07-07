add_to_path ~/bin

# This could be dangerous, but I play with fire.
for P in "$PROJECTS/*/bin"; do
    add_to_path "$P"
done

if [ -x /usr/libexec/path_helper ]; then
	eval `/usr/libexec/path_helper -s`
fi
