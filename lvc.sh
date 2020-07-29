#!/bin/sh

###### LVC = Leer Variables de Configuracion

ARCHIVO_CONF=$1
VARIABLE=$2


egrep "^$VARIABLE=" $ARCHIVO_CONF | sed -r 's/^ *[a-zA-Z_0-9]*=(.*)$/\1/g'

