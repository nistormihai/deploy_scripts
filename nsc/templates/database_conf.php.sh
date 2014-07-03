cat <<EOF
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
