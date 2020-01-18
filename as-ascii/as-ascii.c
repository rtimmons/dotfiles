#if 0
    # http://stackoverflow.com/questions/9988379/how-to-grep-a-text-file-which-contain-some-binary-data
    # Compile with this:
    gcc -x c as-ascii.c -o as-ascii
#endif
#include<stdio.h>
int main (void) {
    int ch;
    while ((ch = getchar()) != EOF) {
        if ((ch == '\n') || ((ch >= ' ') && (ch <= '~'))) {
            putchar (ch);
        } else {
            printf (" {{%02x}} ", ch);
        }
    }
    return 0;
}