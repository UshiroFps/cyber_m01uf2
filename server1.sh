#!/bin/bash

PORT=7777
IP_CLIENT="localhost"

echo "LSTP Server (Lechuga Speaker Transfer Protocol)"

echo "0. LISTEN"

DATA=`nc -l $PORT`

echo "3. CHECK HEADER"

HEADER=`echo "$DATA" | cut -d " " -f 1`

if [ "$HEADER" != "LSTP_1" ]
then
    echo "ERROR 1: Header mal formado $DATA"

    echo "KO_HEADER" | nc $IP_CLIENT $PORT

    exit 1
fi

IP_CLIENT=`echo "$DATA" | cut -d " " -f 2`

echo "4. SEND OK_HEADER"

echo "OK_HEADER" | nc $IP_CLIENT $PORT

echo "5. LISTEN FILE_NAME"

DATA=`nc -l $PORT`

echo "9. CHECK FILE_NAME"

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

echo "14. SEND KO/OK_FILE_DATA"

DATA=`cat server/$FILE_NAME | wc -c`

if [ $DATA -eq 0 ]
then
    echo "ERROR 3: Datos mal formados (vacíos)"
    echo "KO_FILE_DATA" | nc $IP_CLIENT $PORT

    exit 3
fi

echo "OK_FILE_DATA" | nc $IP_CLIENT $PORT


echo "15. LISTEN FILE_MD5"

MD5_CLIENT=`nc -l $PORT`

echo "17. CHECK_FILE_MD5"

MD5_LOCAL=`md5sum server/$FILE_NAME | cut -d " " -f 1`

echo "MD5 recibido: $MD5_CLIENT"
echo "MD5 calculado: $MD5_LOCAL"

if [ "$MD5_CLIENT" != "$MD5_LOCAL" ]
then
    echo "ERROR 4: MD5 no coincide. Calculado: $MD5_LOCAL, Recibido: $MD5_CLIENT"
    echo "KO_FILE_MD5" | nc $IP_CLIENT $PORT
    exit 4
fi

echo "19. SEND OK_FILE_MD5"

echo "OK_FILE_MD5" | nc $IP_CLIENT $PORT

echo "Fin"
exit 0
