cat <<EOF
upstream superdesk_$INSTANCE {
	server 127.0.0.1:$PORT;
}
 
server {
	listen          $NGINX_PORT;
	server_name     $URL;
	access_log      $LOG_PATH/access.log combined;
	error_log      $LOG_PATH/error.log;

	location /api {
		proxy_pass http://superdesk_$INSTANCE;
		proxy_redirect off;
		
		proxy_set_header Host \$host;
		proxy_set_header X-Real-IP \$remote_addr;
		proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
	}

	location / {
		root /var/opt/superdesk_instances/$INSTANCE/frontend/dist;
	}

}
EOF
