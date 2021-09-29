ve() {
    (
        python3 -mvenv venv
        source ./venv/bin/activate
        python3 -mpip install --upgrade pip setuptools wheel
    )
}

venv() {
    local first
    local ok=yes
    for I in ./*/bin/activate; do
        if [ -n "$first" ]; then
            echo "More than one venv. First was $first now I see $I."
            ok=no
            continue
        else
            first="$I"
        fi
    done
    if [[ "$ok" == "yes" ]]; then
        source "$first"
    fi
}
