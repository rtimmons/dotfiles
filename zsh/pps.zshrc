# https://news.ycombinator.com/item?id=31253417
pps () { local a= b= c= IFS='\0'; ps ax | while read a
  do [ "$b" ] || c=1; for b; do case "$a" in *"$b"*) c=1;;
    esac; done; [ "$c" ] && printf '%s\n' "$a" && c=; done; }
