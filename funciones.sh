function salir {
	rm $TEMP_PARAMETROS $TEMP_WARNINGS 2> /dev/null
	exit $1
}

function agregar {
	echo "$1" >> "$2"
}

function validar_valor_inicial {
	if [[ $2 =~ --.* ]] || [ -z "$2" ] ;then
		echo El parametro $1 debe ir acompañado de un valor
		salir 1 
	fi
}

function valid_ip()
{
    local  ip=$1
    local  stat=1

    if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        OIFS=$IFS
        IFS='.'
        ip=($ip)
        IFS=$OIFS
        [[ ${ip[0]} -le 255 && ${ip[1]} -le 255 \
            && ${ip[2]} -le 255 && ${ip[3]} -le 255 ]]
        stat=$?
    fi
    return $stat
}

function agregar_comparadores()
{
	if [ $pcantidad_objetos -eq 1 ];then
		agregar "COMPARADOR_CANTIDAD_OBJETOS" $TEMP_PARAMETROS
	fi
	if [ $pobjetos_faltantes -eq 1 ];then
		agregar "COMPARADOR_OBJETOS_FALTANTES" $TEMP_PARAMETROS
	fi
	if [ $pobjetos_validos -eq 1 ];then
		agregar "COMPARADOR_OBJETOS_VALIDOS" $TEMP_PARAMETROS
	fi
	if [ $pobjetos_activos -eq 1 ];then
		agregar "COMPARADOR_OBJETOS_ACTIVOS" $TEMP_PARAMETROS
	fi
	if [ $pusuarios_faltantes -eq 1 ];then
		agregar "COMPARADOR_USUARIOS_FALTANTES" $TEMP_PARAMETROS
	fi
	if [ $pcantidad_filas -eq 1 ];then
		agregar "COMPARADOR_CANTIDAD_FILAS" $TEMP_PARAMETROS
	fi
	if [ $ppermisos -eq 1 ];then
		agregar "COMPARADOR_PERMISOS" $TEMP_PARAMETROS
	fi
}

function validar_bd()
{
	local  bd=$1
	local  stat=1
	patron="^[a-zA-Z_0-9]{2,20}@[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}:[0-9]{4}/[a-zA-Z_0-9]{2,20}$"
	if [[ ! $bd =~ $patron ]]; then
		return 1
	fi
	ip=`echo $bd |egrep -o "[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}"`
	valid_ip $ip
	if [ $? -ne 0 ];then
		return 1
	fi
	return 0
}

function validar_aliases()
{
	local aliases="$1"
	patron="^[A-Z_0-9]{3,20},[A-Z_0-9]{3,20}$"
	if [[ ! $aliases =~ $patron ]]; then
		echo "Los aliases deben estar en mayusculas"
		return 1
	fi
	if [ "`echo $aliases|cut -d , -f 1`" = "`echo $aliases|cut -d , -f 2`" ];then
		echo "Los aliases deben ser diferentes"
		return 1
	fi
	return 0
}
