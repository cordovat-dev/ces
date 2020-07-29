#!/bin/bash

RUTA=`dirname $0`
NOMBRE_ARCHIVO=$1
ORIGINAL=$RUTA/comparadores.conf

cat - | while read LINE
do
	hay=`grep $LINE $ORIGINAL | wc -l`
	if [ $hay -lt 1 ];then
		echo "Comparador desconocido '$LINE' en '$NOMBRE_ARCHIVO'"
		exit 1
	fi
done
