#!/bin/bash

numpar=$#
RUTA=`dirname $0`
source $RUTA/funciones.sh

pcantidad_objetos=0
pobjetos_faltantes=0
pobjetos_validos=0
pobjetos_activos=0
pusuarios_faltantes=0
pcantidad_filas=0
ppermisos=0

pbd1=0
pbd2=0
paliases=0
pprioridad=0
pplantilla=0
pversion=0
payuda=0
pdebugparms=0
pparfile=0
pincluir=0
alguncomparador=0
algunparametro=0
pruta_salida=0


if [[ $# -eq 0 ]];then
	echo Faltan parametros. Ejecute 'ces --ayuda' para obtener informacion de uso del programa
	salir 1
fi

while [[ $# > 0 ]]
do
key="$1"
case $key in
	--ruta_salida)
	pruta_salida=1
	ruta_salida=$2
	validar_valor_inicial "--ruta_salida" $2
	shift
	;;
	# --plantilla)
	#pplantilla=1
	#;;
	--bd1)
	pbd1=1
	bd1=$2
	validar_valor_inicial "--bd1" $2
	shift
	;;
	--bd2)
	pbd2=1
	bd2=$2
	validar_valor_inicial "--bd2" $2
	shift
	;;
	--aliases)
	paliases=1
	aliases="$2"
	validar_valor_inicial "--aliases" $2
	shift
	;;
	--prioridad)
	pprioridad=1
	prioridad=$2
	validar_valor_inicial "--prioridad" $2
	shift
	;;
	--cantidad_objetos)
	pcantidad_objetos=1
	cantidad_objetos="TRUE"
	alguncomparador=1
	;;
	--objetos_faltantes)
	pobjetos_faltantes=1
	objetos_faltantes="TRUE"
	alguncomparador=1
	;;
	--objetos_validos)
	pobjetos_validos=1
	objetos_validos="TRUE"
	alguncomparador=1
	;;
	--objetos_activos)
	pobjetos_activos=1
	objetos_activos="TRUE"
	alguncomparador=1
	;;
	--usuarios_faltantes)
	pusuarios_faltantes=1
	usuarios_faltantes="TRUE"
	alguncomparador=1
	;;
	--cantidad_filas)
	pcantidad_filas=1
	cantidad_filas="TRUE"
	alguncomparador=1
	;;
	--permisos)
	ppermisos=1
	permisos="TRUE"
	alguncomparador=1
	;;
	# --parfile)
	#pparfile=1
	#parfile=$2
	##validar_valor_inicial "--parfile" $2
	#shift
	#;;
	--todos)
	pcantidad_objetos=1
	cantidad_objetos="TRUE"
	pobjetos_faltantes=1
	objetos_faltantes="TRUE"
	pobjetos_validos=1
	objetos_validos="TRUE"
	pobjetos_activos=1
	objetos_activos="TRUE"
	pusuarios_faltantes=1
	usuarios_faltantes="TRUE"
	pcantidad_filas=1
	cantidad_filas="TRUE"
	ppermisos=1
	permisos="TRUE"
	alguncomparador=1
	;;	
	--version)
	pversion=1
	;;
	--ayuda)
	payuda=1
	;;
	--debugparms)
	pdebugparms=1
	;;
	--esquemas)
	pincluir=1
	incluir=$2
	validar_valor_inicial "--incluir" $2
	shift
	;;
	*)
		echo Parametro $1 desconocido
		salir 1
	;;
esac
shift
done

if [ $payuda -eq 1 ];then
	if [ $numpar -gt 1 ];then
		echo El parametro --ayuda debe usarse solo
		salir 1
	else
		man $RUTA/ces.1
		salir 0
	fi
fi

if [ $pversion -eq 1 ];then
	if [ $numpar -gt 1 ];then
		echo El parametro --version debe usarse solo
		salir 1
	else
		cat $RUTA/version
		salir 0
	fi
fi

if [ $pparfile -eq 1 ];then

	if [ ! -f "$parfile" ];then
		echo "$parfile" no existe o es una carpeta
		salir 1
	fi
fi

if [ $pparfile -eq 0 ];then
	if [ $pplantilla -eq 1 ];then
		if [ $numpar -gt 1 ];then
			echo El parametro --plantilla debe usarse solo
			salir 1
		else
			echo
			cat $RUTA/plantilla.par
			salir 0	
		fi
	fi

	if [ $pbd1 -eq 0 ];then
		echo Parametro requerido --bd1
		salir 1
	fi

	if [ $pbd2 -eq 0 ];then
		echo Parametro requerido --bd2
		salir 1
	fi

	validar_bd $bd1
	if [ $? -ne 0 ];then
		echo "bd1: cadena de conexion mal formada"
		echo "ejemplo: system@111.111.111.111:1521/instancia"
		salir 1
	fi
	validar_bd $bd2
	if [ $? -ne 0 ];then
		echo "bd2: cadena de conexion mal formada"
		echo "ejemplo: system@111.111.111.111:1521/instancia"
		salir 1
	fi


	if [ "$bd1" = "$bd2" ];then
		echo "bd1 y bd2 no deben apuntar a la misma BD"
		salir 1
	fi
	agregar "BD1=$bd1" $TEMP_PARAMETROS
	agregar "BD2=$bd2" $TEMP_PARAMETROS

	if [ $paliases -eq 0 ];then
		aliases="BD1,BD2"
	else
		aliases="$(echo $aliases|tr '[:lower:]' '[:upper:]')"
			validar_aliases "$aliases"
		if [ $? -ne 0 ];then
			echo "Cadena de aliases mal formada"
			salir 1
		fi
	fi

	agregar "ALIASES=$aliases" $TEMP_PARAMETROS

	if [ $pprioridad -eq 0 ];then
		prioridad=2
	else
		if [ ! $prioridad -eq 0 ] && [ ! $prioridad -eq 1 ] && [ ! $prioridad -eq 2 ];then
			echo "La prioridad debe ser 0(default),1 o 2"
			salir 1
		fi
	fi

	agregar "PRIORIDAD=$prioridad" $TEMP_PARAMETROS

	if [ $pincluir -eq 1 ];then
		if [[ $incluir =~ .*[a-z].* ]];then
			echo Los nombres de esquema deben ir en mayuscula
			salir 1	
		fi
		agregar "ESQUEMAS=$incluir" $TEMP_PARAMETROS
	fi

	if [ $pruta_salida -eq 0 ];then
		pruta_salida=1
		ruta_salida="./reporte_`date +%y%m%d%H%M`.txt"
		>&2 echo "WARNING: Asumiendo ruta de salida por defecto '$ruta_salida' . Si desea usar otra, especifiquela con --ruta_salida"
	else
		if [ -d "$ruta_salida" ];then
			echo Parametro ruta salida debe ser un archivo
			salir 1
		fi

		if [ ! -d "$(dirname "$ruta_salida")" ];then
			echo No existe la carpeta del archivo de salida: $(dirname "$ruta_salida")
			salir 1
		fi

		if [ -f "$ruta_salida" ];then
			echo Parametro ruta salida no puede ser un archivo ya existente
			salir 1
		fi

	fi

	if [ $alguncomparador -eq 0 ];then
		pcantidad_objetos=1
		cantidad_objetos="TRUE"
		pobjetos_faltantes=1
		objetos_faltantes="TRUE"
		pobjetos_validos=1
		objetos_validos="TRUE"
		pobjetos_activos=1
		objetos_activos="TRUE"
		pusuarios_faltantes=1
		usuarios_faltantes="TRUE"
		pcantidad_filas=1
		cantidad_filas="TRUE"
		ppermisos=1
		permisos="TRUE"
		alguncomparador=1
	fi

	agregar_comparadores $TEMP_PARAMETROS
fi




 
