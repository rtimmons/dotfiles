
# get full (2017) version if exists else 2017basic
if [ -d "/usr/local/texlive/2017" ]; then
    add_to_path /usr/local/texlive/2017/bin/x86_64-darwin/
else
    add_to_path /usr/local/texlive/2017basic/bin/x86_64-darwin/
fi
