#!/bin/sh

# Environment variables:
# BRANCH=${bamboo.planRepository.branchName}
##

. ./deploy_scripts/nsc/functions.sh

#{{{ Variables
APP="$bamboo_app"
BRANCH=$(url_safe "$BRANCH")
DEVELOPER="$bamboo_developer"
WORKDIR="$(pwd)"
DBUSER="$APP"_"$BRANCH"
DBNAME=$(echo "$DBUSER" | cut -c 1-61)_db
DBUSER=$(echo "$DBUSER" | md5sum | cut -c 1-16) # first 16 symbols of md5 hash
INSTALL_DIR="/var/www/$APP/$BRANCH"

VERSION="$bamboo_version"
[ -z $VERSION] && VERSION=42;
echo VERSION = $VERSION
#}}}

#{{{ Create virtual host for instance
(
cd /etc/apache2/sites-enabled/ &&
cat >"$APP"_"$BRANCH" <<EOF
<VirtualHost *:80>
      DocumentRoot $INSTALL_DIR
      ServerName $BRANCH.$APP.$DEVELOPER.sourcefabric.net
      DirectoryIndex index.php index.html
      <Directory $INSTALL_DIR>
              Options -Indexes FollowSymLinks MultiViews
              AllowOverride All
              Order allow,deny
              Allow from all
      </Directory>
	ErrorLog \${APACHE_LOG_DIR}/error.$APP.$BRANCH.log
	CustomLog \${APACHE_LOG_DIR}/access.$APP.$BRANCH.log combined
</VirtualHost>
EOF
#}}}
echo $BRANCH.$APP.$DEVELOPER.sourcefabric.net
) &&

#{{{ Copy code
(
rm -fr $INSTALL_DIR/images ;
rm -fr $INSTALL_DIR/files ;
rm -fr $INSTALL_DIR/themes ;
rm -fr $INSTALL_DIR/themes_git ;

mkdir -p $INSTALL_DIR/conf &&
mkdir -p $INSTALL_DIR/themes_git/ &&

cp -R $WORKDIR/newscoop/* $INSTALL_DIR/ &&
cp -R $WORKDIR/plugins/* $INSTALL_DIR/plugins/ &&
cp -R $WORKDIR/dependencies/include/* $INSTALL_DIR/include/ &&
cp -R $WORKDIR/themes_git/* $INSTALL_DIR/themes_git/ &&

cp $WORKDIR/deploy_scripts/nsc/configuration.php.$VERSION \
	$INSTALL_DIR/conf/configuration.php &&
cp $WORKDIR/deploy_scripts/nsc/system_preferences.php $INSTALL_DIR/ &&

cd $INSTALL_DIR &&

cd themes_git &&
test ! -d publication_* && (
	mkdir -p ../themes/publication_1/theme_1;
	mv * ../themes/publication_1/theme_1;
	cd ../themes/publication_1;
	for i in $(seq 2 5); do ln -sf theme_1 theme_$i; done;
	cd .. ;
	for i in $(seq 2 5); do ln -sf publication_1 publication_$i; done;
) ||
	mv * ../themes/
) ;
#}}}

(
cd $INSTALL_DIR &&
mv htaccess .htaccess ;
rm -rf cache/* ;

rm -rf images ;
ln -s ../images images ;
rm -rf files ;
ln -s ../files files ;
) ;

#{{{ Generate DB config file
(
cd $INSTALL_DIR &&
cat >conf/database_conf.php <<EOF
<?php
global \$Campsite;
\$Campsite['DATABASE_NAME'] = '$DBNAME';
\$Campsite['DATABASE_SERVER_ADDRESS'] = 'localhost';
\$Campsite['DATABASE_SERVER_PORT'] = '3306';
\$Campsite['DATABASE_USER'] = '$DBUSER';
\$Campsite['DATABASE_PASSWORD'] = '$DBUSER';
/** Database settings **/
\$Campsite['db']['type'] = 'mysql';
\$Campsite['db']['host'] = \$Campsite['DATABASE_SERVER_ADDRESS'];
\$Campsite['db']['port'] = \$Campsite['DATABASE_SERVER_PORT'];
\$Campsite['db']['name'] = \$Campsite['DATABASE_NAME'];
\$Campsite['db']['user'] = \$Campsite['DATABASE_USER'];
\$Campsite['db']['pass'] = \$Campsite['DATABASE_PASSWORD'];
?>
EOF
) &&
#}}}

#{{{ Install composer
(
cd $INSTALL_DIR &&
export COMPOSER_HOME="$INSTALL_DIR" &&
curl -s https://getcomposer.org/installer | php &&
php composer.phar install --no-dev --prefer-dist &&
php composer.phar dump-autoload --optimize 
) &&
#}}}

(
chown -R www-data:www-data $INSTALL_DIR &&
#su - www-data -c "php $INSTALL_DIR/upgrade.php" &&
rm $INSTALL_DIR/upgrade.php 2> /dev/null ;
rm $INSTALL_DIR/conf/upgrading.php 2> /dev/null ;
rm $INSTALL_DIR/conf/installation.php 2> /dev/null ;
service apache2 reload
) 
