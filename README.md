Linux Apache site configurator
====================

Bash scripts set to help organise and backup web server.

1. Add virtual host. Creates user with homedir to store site files. Adds configured `VirtualHost` section to httpd config and restarts httpd daemon. Http server is ready now!
2. Backup files. Script to store and rotate sites file backups to file system.
3. Backup MySQL. Script to store and rotate sites MySQL db backups to file system.
4. Restore permissions. Set correct permissions to site user's home dir.
5. Change Wordpress site domain in db.
