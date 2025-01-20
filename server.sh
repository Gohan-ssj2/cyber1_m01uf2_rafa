#!/bim/bash

PORT="7777"

IP_CLIENT="localhost"

echo "LSTP server (lechuga speaker transfer protocol)"

echo "0.Listen"

$DATA

DATA=`nc -l $PORT`

HEADER=`echo "$DATA" | cut -d " " -f 1 `

echo "3. CHECK HEADER"

if [ "$HEADER" != "LSTP_1.1" ]
then
	echo "ERROR 1: Header mal formado"

	echo "KO_HEADER" |nc $IP_CLIENT $PORT

	exit 1

fi

echo "4. SEND OK_HEADER"

echo "OK_HEADER" | nc $IP_CLIENT $PORT

echo "5. LISTEN FILE_NAME"

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

nc -l $PORT > server/$FILE_NAME

echo "14.SEND OK_FILE_DATA"
DATA=`cat server/$FILE_NAME | wc -c`

if [ $DATA -eq 0 ]
then
	echo "ERROR 3: Datos mal formados (vacios)"
 	echo "KO_FILE_DATA" | NC $IP_CLIENT $PORT
 	exit 3
fi
echo "OK_FILE_DATA" | nc $IP_CLIENT $PORT

echo "15.LISTEN DATA_FILE_MD5"

DATA=`nc -l $PORT`

PREFIX=`echo $DATA | cut -d " " -f 1`

if [ $PREFIX != "FILE_DATA_MD5" ]
then
	echo "KO_FILE_DATA_MD5"
	echo "ERROR 4: Prefijo incorrecto"
fi

MD5=`cat ./server/lechuga1.ogg | md5sum | cut -d " " -f 1`

if [ `echo $DATA | cut -d " " -f 2` != $MD5 ]
then
	echo "ERROR 5: Los datos han sido corrompidos/diferentes a los enviados"
	echo "KO_FILE_MD5"
fi
echo "OK_FILE_DATA_MD5"
echo "FIN"
exit 0
