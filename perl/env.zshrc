
# add perl libs on dropbox to PERL5LIB
add_to_path "$HOME/Dropbox/Library/Perl/lib/perl5" PERL5LIB

# cpanm local installation
PATH="/Users/rtimmons/perl5/bin${PATH:+:${PATH}}"; export PATH;
PERL5LIB="/Users/rtimmons/perl5/lib/perl5${PERL5LIB:+:${PERL5LIB}}"; export PERL5LIB;
PERL_LOCAL_LIB_ROOT="/Users/rtimmons/perl5${PERL_LOCAL_LIB_ROOT:+:${PERL_LOCAL_LIB_ROOT}}"; export PERL_LOCAL_LIB_ROOT;
PERL_MB_OPT="--install_base \"/Users/rtimmons/perl5\""; export PERL_MB_OPT;
PERL_MM_OPT="INSTALL_BASE=/Users/rtimmons/perl5"; export PERL_MM_OPT;
