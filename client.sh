#!/bim/bash

if [ $# -ne 1 ]
then
	echo "Error: El comando requiere al menos un parametro"
	echo "Ejemplo de uso: "
	echo -e "\t$0 127.0.0.1"
	exit 100
fi

PORT=7777

IP_SERVER=$1

IP_PROPIA="`ip a | grep -w -i inet | grep -i enp0s3 | cut -d "i" -f 2 | cut -d " " -f 2`"


echo "$IP_PROPIA"

echo "LSTP Client (Lechuga Speaker Transfer Protocol)"

echo "1. SEND HEADER (Client: $IP_PROPIA, Server: $IP_SERVER)"

echo "LSTP_1.1 $IP_PROPIA" | nc localhost $PORT

echo "2. LISTEN OK_HEADER"

DATA=`nc -l $PORT`

if [ "$DATA" != "OK_HEADER" ]
then
	echo "Error de comunicacion con el servidor"

	exit 1

fi

#cat client/lechuga1.lechu | text2wave -o client/lechuga1.wav

#yes | ffmpeg -i client/lechuga1.wav client/lechuga1.ogg

echo "7. SEND FILE_NAME"

echo ""FILE_NAME" lechuga1.ogg" | nc $IP_SERVER $PORT

echo "8. LISTEN"

DATA=`nc -l $PORT`

if [ "$DATA" != "OK_FILE_NAME" ]
then
	echo "ERROR 2: FILE_NAME el archivo no se envio correctamente"
	exit 2
fi

echo "12. SEND_FILE_DATA"

cat ./client/lechuga1.ogg | nc $IP_SERVER $PORT

echo "13. LISTEN OK/KO_FILE_DATA"

DATA=`nc -l $PORT`

if [ "$DATA" != "OK_FILE_DATA" ]
then
	echo "ERROR 3: Error al enviar los datos"
	exit 3
fi

echo "16.SEND FILE_DATA_MD5"

MD5=`cat ./client/lechuga1.ogg | md5sum | cut -d " " -f 1`

echo "FILE_DATA_MD5 $MD5" | nc $IP_SERVER $PORT

echo "FiN"

exit 0
