"startdb.sh" 10 lines, 160 characters 
su - oracle -c "sqlplus / as sysdba" << EOF
startup
exit
EOF
sleep 2
echo "DB STARTED"
su - oracle -c "lsnrctl start"
sleep 90
echo "LISTENER STARTED"

