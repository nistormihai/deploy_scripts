cat <<EOF
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
