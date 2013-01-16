output from `brew install mysql`

---------------------------------------
Set up databases to run AS YOUR USER ACCOUNT with:
    unset TMPDIR
    mysql_install_db --verbose --user=`whoami` --basedir="$(brew --prefix mysql)" --datadir=/usr/local/var/mysql --tmpdir=/tmp

To set up base tables in another folder, or use a different user to run
mysqld, view the help for mysqld_install_db:
    mysql_install_db --help

and view the MySQL documentation:
  * http://dev.mysql.com/doc/refman/5.5/en/mysql-install-db.html
  * http://dev.mysql.com/doc/refman/5.5/en/default-privileges.html

To run as, for instance, user "mysql", you may need to `sudo`:
    sudo mysql_install_db ...options...

A "/etc/my.cnf" from another install may interfere with a Homebrew-built
server starting up correctly.

To connect:
    mysql -uroot

To have launchd start mysql at login:
    ln -sfv /usr/local/opt/mysql/*.plist ~/Library/LaunchAgents
Then to load mysql now:
    launchctl load ~/Library/LaunchAgents/homebrew.mxcl.mysql.plist
Or, if you don't want/need launchctl, you can just run:
    mysql.server start
---------------------------------------