#!/bin/bash

RUTA=`dirname $0`
TEMP_PARAMETROS=`mktemp /tmp/ces_XXXXXXXX`
TEMP_WARNINGS=`mktemp /tmp/ces_XXXXXXXX`
source $RUTA/pp.sh

function ejecutar {
	PARFILE=$1
	echo
	echo "Utilitario de Comparacion de Esquemas de Oracle. Tulains Cordova. cordovat@gmail.com"
	echo

	egrep "^COMPARADOR_" $PARFILE | tr -d ' 	' | $RUTA/./vc.sh $PARFILE

	if [ $? -ne 0 ]; then 
		salir 1
	fi

	STRCON1=`$RUTA/lvc.sh $PARFILE BD1`
	STRCON2=`$RUTA/lvc.sh $PARFILE BD2`

	if [ -n "$CESPWD1" ];then
	       password1="$CESPWD1"
	else
		echo ""
		read -s -p "Introduzca la clave de $STRCON1: " password1
		echo
	
		if [ -z "$password1" ];then
			salir 1
		fi
	fi

	if [ -n "$CESPWD2" ];then
	       password2="$CESPWD2"
	else
		echo ""
		read -s -p "Introduzca la clave de $STRCON2: " password2
		echo
	
		if [ -z "$password2" ];then
			salir 1
		fi
	fi

	echo >> $ruta_salida
	echo "Utilitario de Comparacion de Esquemas de Oracle. Tulains Cordova. cordovat@gmail.com" >> $ruta_salida
	echo >> $ruta_salida
	echo >> $ruta_salida
	java -jar $RUTA/./ComparacionEsquema.jar $PARFILE $RUTA/comparadores.conf "$password1" "$password2" 2>&1 | tee -a $ruta_salida

	if [ ${PIPESTATUS[0]} -eq 0 ] ;then
		echo| tee -a $ruta_salida
		echo
		echo Revisar reporte en $ruta_salida
		echo
	else
		echo
		rm $ruta_salida 2> /dev/null
	fi

}

if [ $pdebugparms -eq 1 ];then
	cat $TEMP_PARAMETROS
else
	ejecutar $TEMP_PARAMETROS
fi

salir 0


