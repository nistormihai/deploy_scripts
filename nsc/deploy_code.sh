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
DBNAME="$DBUSER"_db
DBUSER=$(echo "$DBUSER" | md5sum | awk '{print substr($0,0,15)}') # first 16 symbols of md5 hash
INSTALL_DIR="/var/www/$APP/$BRANCH"

#default image folder:
IMG_FOLDER="images"
#image folder for stable branch:
#test "$BRANCH" = 'wobs-stable' && IMG_FOLDER="images_prelive"

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
rm -fr $INSTALL_DIR/themes ;
rm -fr $INSTALL_DIR/themes_git ;

mkdir -p $INSTALL_DIR/conf &&
mkdir -p $INSTALL_DIR/themes_git/ &&

rm -fr $WORKDIR/newscoop/images &&
rm -fr $WORKDIR/newscoop/files &&

cp -R $WORKDIR/newscoop/* $INSTALL_DIR/ &&
cp -R $WORKDIR/plugins/* $INSTALL_DIR/plugins/ &&
cp -R $WORKDIR/dependencies/include/* $INSTALL_DIR/include/ &&
cp -R $WORKDIR/themes_git/* $INSTALL_DIR/themes_git/ &&

cp $WORKDIR/deploy_scripts/nsc/configuration.php $INSTALL_DIR/conf/ &&
cp $WORKDIR/deploy_scripts/nsc/system_preferences.php $INSTALL_DIR/

cd $INSTALL_DIR && pwd

cd themes_git
test ! -d publication_* && (
	mkdir -p ../themes/publication_1/theme_1;
	mv * ../themes/publication_1/theme_1;
	cd ../themes/publication_1;
	for i in $(seq 2 5); do ln -sf theme_1 theme_$i; done;
	cd .. ;
	for i in $(seq 2 5); do ln -sf publication_1 publication_$i; done;
) ||
	mv * ../themes/
cd ..
) ;
#}}}

(
mv htaccess .htaccess ;
rm -rf cache/* ;

rm -rf images
ln -s ../"$IMG_FOLDER" images
rm -rf files
ln -s ../"$IMG_FOLDER" files
) ;

#{{{ Install composer
(
export COMPOSER_HOME="$INSTALL_DIR" &&
curl -s https://getcomposer.org/installer | php &&
php composer.phar install --no-dev --prefer-dist &&
php composer.phar dump-autoload --optimize &&
) &
#}}}

#{{{ Generate DB config file
(
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

(
chown -R www-data:www-data $INSTALL_DIR &&
#su - www-data -c "php $INSTALL_DIR/upgrade.php" &&
rm conf/upgrading.php 2> /dev/null ;
service apache2 reload
) 
