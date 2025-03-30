 #!/bim/bash

 PORT="7777"

 IP_CLIENT="192.168.1.164"

 echo "LSTP server (lechuga speaker transfer protocol)"

 echo "0.Listen"

 $DATA

 DATA=`nc -l $PORT`

 HEADER=`echo "$DATA" | cut -d " " -f 1`

 echo "$HEADER"

 echo "3. CHECK HEADER"

 if [ "$HEADER" != "LSTP_1.1" ]
 then
     echo "ERROR 1: Header mal formado"

     echo "KO_HEADER" |nc $IP_CLIENT $PORT

     exit 1

 fi

 echo "4. SEND OK_HEADER"

 echo "OK_HEADER" | nc $IP_CLIENT $PORT

 echo "5.1 LISTEN NUM_FILES"

 DATA=`nc -l $PORT`

 echo "5.2 CHECK HEADER NUM_FILES"

 PREFIX=`echo $DATA | cut -d " " -f 1`

 if [ $PREFIX != "NUM_FILES" ]
 then
     echo "ERROR 22: El numero de archivos no cocuerda con los locales"
     echo "KO_NUM_FILE" | nc $IP_CLIENT $PORT
     exit 22
 fi

 echo "5.3 CHECK NUM_FILES"

 NUM_FILES=`echo $DATA | cut -d " " -f 2`

 CHECK_NUM_FILES=`echo "$NUM_FILES" | grep -E "^-?[0-9]+$"`

 if [ $CHECK_NUM_FILES == " " ]
 then
     echo "ERROR 23: El numero de archivos es erroneo"
     echo "KO_CHECK_NUM_FILE"
     exit 23
fi
 echo "OK_NUM_FILES" | nc $IP_CLIENT $PORT

 if [ $NUM_FILES != $CHECK_NUM_FILES ]
 then
     echo "ERROR X:No coincide el numero de archivos"
     echo "KO_NUM_FILES"
 fi

 for NUM in `seq $NUM_FILES`
 do

 echo "5.X LISTEN FILE_NAME $NUM"

 DATA=`nc -l $PORT`

 PREFIX=`echo $DATA | cut -d " " -f 1`

 if [ "$PREFIX" != "FILE_NAME" ]
 then
     echo "ERROR 2: FILE_NAME incorrecto"
     echo "KO_FILE_NAME" | nc $IP_CLIENT $PORT
     exit 2
 fi

 FILE_NAME=`echo $DATA | cut -d " " -f 2`

 echo "10. SEND OK_FILE_NAME"
 echo "OK_FILE_NAME" | nc $IP_CLIENT $PORT

 echo "11. LISTEN FILE DATA"

 nc -l $PORT > "server/$FILE_NAME"

 echo "14.SEND OK_FILE_DATA"
 DATA=`cat server/$FILE_NAME | wc -c`

 if [ $DATA -eq 0 ]
 then
     echo "ERROR 3: Datos mal formados (vacios)"
     echo "KO_FILE_DATA" | nc $IP_CLIENT $PORT
     exit 3
 fi
 echo "OK_FILE_DATA" | nc $IP_CLIENT $PORT

 echo "15.LISTEN DATA_FILE_MD5"

 DATA=`nc -l $PORT`



 PREFIX=`echo $DATA | cut -d " " -f 1`

 if [ "$PREFIX" != "FILE_DATA_MD5" ]
 then
     echo "KO_FILE_DATA_MD5" | nc $IP_CLIENT $PORT
     echo "ERROR 4: Prefijo incorrecto"
     exit 4
 fi

 MD5=`cat ./server/*.lechu | md5sum | cut -d " " -f 1`
 RECIVED_MD5=`echo $DATA | cut -d " " -f 2`
 echo "$MD5"
 echo "$RECIVED_MD5"

 if [ "$RECIVED_MD5" != "$MD5" ]
 then
     echo "ERROR 5: Los datos han sido corrompidos/diferentes a los enviados"
     echo "KO_FILE_MD5" | nc $IP_CLIENT $PORT
     exit 5
 fi

 echo "OK_FILE_DATA_MD5" | nc $IP_CLIENT $PORT

 done

 echo "FIN"
 exit 0