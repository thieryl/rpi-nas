
DOMAIN=example.com

# MySQL
mkdir -p mnt/data/mysql

# NextCloud
mkdir -p mnt/config/cloud
mkdir -p mnt/data/cloud
mkdir -p mnt/www/$DOMAIN/cloud/apps
mkdir -p mnt/www/$DOMAIN/cloud/themes

# Nginx
mkdir -p mnt/config/nginx

# Portainer
mkdir -p mnt/data/portainer

# OpenLDAP
mkdir -p mnt/data/openldap/ldap
mkdir -p mnt/data/openldap/slapd

# MediaServer
mkdir -p mnt/data/media/movie/Films
mkdir -p mnt/data/media/movie/Series
mkdir -p mnt/data/media/movie/Deposit
mkdir -p mnt/data/media/music

# Config
mkdir -p mnt/config/deluge
mkdir -p mnt/config/hydra2
mkdir -p mnt/config/jackett
mkdir -p mnt/config/daapd
mkdir -p mnt/config/plex
mkdir -p mnt/config/samba
mkdir -p mnt/config/sonarr
mkdir -p mnt/config/radarr
mkdir -p mnt/config/bazarr

# Conf
mv nginx.conf mnt/config/nginx
mv smb.conf mnt/config/samba/
mv libnss-ldap.conf mnt/config/samba

mv letsencrypt mnt/config
mv ssl mnt/config


