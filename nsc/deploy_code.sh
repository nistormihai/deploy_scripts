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
[ -z $VERSION ] && VERSION=42;
#}}}


echo $BRANCH.$APP.$DEVELOPER.sourcefabric.net ;


# create virtual host for instance
.  $WORKDIR/deploy_scripts/nsc/templates/vhost.sh > /etc/apache2/sites-enabled/$APP"_"$BRANCH &&

# cleanup dest dir
#rm -r $INSTALL_DIR/images ;
#rm -r $INSTALL_DIR/files ;
#rm -r $INSTALL_DIR/themes ;
#rm -r $INSTALL_DIR/themes_git ;
(
	#rm -r $INSTALL_DIR ;
	rm -r $INSTALL_DIR/cache/* ;
	mkdir -p $INSTALL_DIR/conf &&
	mkdir -p $INSTALL_DIR/themes_git/
) &&

# copy core newscoop code
cp -R $WORKDIR/newscoop/* $INSTALL_DIR/ &&
cp -R $WORKDIR/plugins/* $INSTALL_DIR/plugins/ &&
cp -R $WORKDIR/dependencies/include/* $INSTALL_DIR/include/ &&

# copy theme code
(
	cp -R $WORKDIR/themes_git/* $INSTALL_DIR/themes_git/ &&
	cd $INSTALL_DIR/themes_git &&
	test ! -d publication_* && (
		mkdir -p ../themes/publication_1/theme_1;
		mv * ../themes/publication_1/theme_1;
		cd ../themes/publication_1;
		for i in $(seq 2 5); do ln -sf theme_1 theme_$i; done;
		cd .. ;
		for i in $(seq 2 5); do ln -sf publication_1 publication_$i; done;
	) ||
		mv * ../themes/
) &&

# rename htaccess
(
	cd $INSTALL_DIR &&
	mv htaccess .htaccess ;
) ;

# create symlinks
(
	rm -r images ;
	ln -s ../images images ;

	rm -r files ;
	ln -s ../files files ;
) ;

# copy configs
cp $WORKDIR/deploy_scripts/nsc/configs/configuration.php.$VERSION $INSTALL_DIR/conf/configuration.php &&
cp $WORKDIR/deploy_scripts/nsc/configs/system_preferences.php $INSTALL_DIR/ &&

# Generate DB config file
.  $WORKDIR/deploy_scripts/nsc/templates/database_conf.php.sh > $INSTALL_DIR/conf/database_conf.php &&


#{{{ Install composer
(
cd $INSTALL_DIR &&
export COMPOSER_HOME="$INSTALL_DIR" &&
curl -s https://getcomposer.org/installer | php &&
php composer.phar install --no-dev --prefer-dist &&
php composer.phar dump-autoload --optimize 
) &&
#}}}

chown -R www-data:www-data $INSTALL_DIR &&

(
	#su - www-data -c "php $INSTALL_DIR/upgrade.php" ;
	rm $INSTALL_DIR/upgrade.php 2> /dev/null ;
	rm $INSTALL_DIR/conf/upgrading.php 2> /dev/null ;
	rm $INSTALL_DIR/conf/installation.php 2> /dev/null ;
) ;

service apache2 reload &&

/home/ubuntu/fix_www.sh ;

exit 0
