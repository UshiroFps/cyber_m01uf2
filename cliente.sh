#!/bin/bash

if [ $# -ne 1  ]; then

	echo "ERROR: Malformed instruction. This command requires at least one parameter."

	echo -e "\n\tUse example: $0 127.0.0.1"

	echo " "

	exit 1
fi

PORT=7777

IP_SERVER=$1

FILE="saludo.ogg"

IP_CLIENT=`ip a | grep "inet " | grep global | cut -d " " -f 6 | cut -d "/" -f 1`

echo "LSTP Client (Lechuga Speaker Transfer Protocol)"

echo "1. SEND HEADER"

echo "LSTP_1.1 $IP_CLIENT" | nc $IP_SERVER $PORT

echo "2. LISTEN OK_HEADER"

DATA=`nc -l $PORT`

echo "6. CHECK OK_HEADER"

if [ "$DATA" != "OK_HEADER"  ]; then

	echo "ERROR 1: Header not sent correctly. $DATA"

	exit 1
fi

#text2wave client/lechuga1.lechu -o client/lechuga1.wav

#ffmpeg -i client/lechuga1.wav client/lechuga1.ogg

echo "7.1 SEND NUM_FILES"
NUM_FILES=`ls *.ogg | wc -l`
echo "NUM_FILES $NUM_FILES" | nc $IP_SERVER $PORT

DATA=`nc -l $PORT`

echo "7.2 CHECK OK_NUM_FILES"
if [ "$DATA" != "OK_NUM_FILES" ]; then
	echo "ERROR 21: NUM_FILES enviado incorrectamente"
	exit 21
fi


echo "7.3 SEND FILES"
for FILE in `ls *.ogg`
do

echo "7.x SEND FILE_NAME"
echo "FILE_NAME $FILE" | nc $IP_SERVER $PORT


echo "8. LISTEN PREFIX_OK"

DATA=`nc -l $PORT`

if [ "$DATA" != "OK_FILE_NAME" ]; then
	
	echo "ERROR 2: Filename not set correctly. $DATA"

	exit 2

fi

echo "12. SEND FILE_DATA"

cat "$FILE" | nc $IP_SERVER $PORT

echo "13. LISTEN OK_FILE_DATA"

DATA=`nc -l $PORT`

echo "16. SEND FILE_DATA_MD5"

MD5=`cat $FILE | md5sum | cut -d " " -f 1`

echo "FILE_DATA_MD5 $MD5" | nc  $IP_SERVER $PORT

echo "17. LISTEN FILE_DATA_MD5"
DATA=`nc -l $PORT`

echo "21. CHECK OK_FILE_MD5"
if [ "$DATA" != "OK_FILE_MD5" ]; then
	echo "ERROR 4: MD5 no encaja."
	exit 4
fi
done
echo "END"
exit 0
