"stopdb.sh" 7 lines, 144 characters 
su - oracle -c "lsnrctl stop"
sleep 2
echo "LISTENER STOPPED"
su - oracle -c "sqlplus / as sysdba" << EOF
shutdown immediate
exit
EOF
sleep 60
echo "DB STOPPED"

