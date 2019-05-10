#! /usr/bin/env bash
#!/bin/bash
# Arreglo de CSV para QUERY SQL

AgregarFilasHaTodosLasEstaciones(){
    mkdir temporal
    mkdir procesadoSed
for i in ./estaciones/*.csv
do
    echo "Processing $i"
    b=$(basename $i)
    filename="${b%.*}"
    sed -i '1s/^\xEF\xBB\xBF//' $i
    sed 's#,#.#g' $i > temporal/out2.csv
    sed 's#;#,#g' temporal/out2.csv > temporal/out3.csv
    sed 's#/#-#g' temporal/out3.csv > temporal/out4.csv
    sed 's#^\([0-9]\)-#0\1-#' temporal/out4.csv > temporal/out5.csv
    sed 's#\([0-9][0-9]\)#20\1#' temporal/out5.csv > temporal/out6.csv 
    sed "s#^\([0-9][0-9][0-9][0-9]\)#$filename,\1#" temporal/out6.csv > temporal/out7.csv
    sed "s#^\(FECHA\)#NAME,\1#" temporal/out7.csv > procesadoSed/$filename"Procesado.csv"
done
   rm -r temporal
}

JuntarArchivos(){
    contador=0
    rm -f $2
    touch $2
    echo $1
    echo $@
    for i in $1/*.csv
    do 
    b=$(basename $i)
    filename="${b%.*}"
    if(($contador < 1))
        then
        cat $i  >> $2
    else
        tail -n+2 $i > temporal.cvs
        cat  temporal.cvs >> $2
    fi
    contador=$(($contador + 1))
    done 
   rm temporal.cvs
    
}
ConsultaSQL(){
    mkdir ConsultaSQL
    mkdir ConsultaSQL/mes
    mkdir ConsultaSQL/year
    mkdir ConsultaSQL/hora
    for i in ./procesadoSed/*.csv
    do
    b=$(basename $i)
    filename="${b%.*}"
    csvsql  -v --snifflimit 100  --query "select NAME ,strftime('%m', FECHA) as Mes,AVG(VEL) as Velocidad from $filename  GROUP BY  NAME,MES"  $i > ConsultaSQL/mes/$filename".csv"
    csvsql  -v --snifflimit 100  --query  "select NAME ,strftime('%Y', FECHA) as Ano,AVG(VEL) as Velocidad from $filename  GROUP BY  NAME,Ano"  $i > ConsultaSQL/year/$filename".csv"
    csvsql  -v --snifflimit 100  --query  "select NAME, strftime('%H', HHMMSS)  as Hora,AVG(VEL) as Velocidad from $filename  GROUP BY  NAME,Hora"  $i > ConsultaSQL/hora/$filename".csv"
    done
}

AgregarFilasHaTodosLasEstaciones
ConsultaSQL
JuntarArchivos ./ConsultaSQL/mes  velocidad-por-mes.csv
JuntarArchivos ./ConsultaSQL/year velocidad-por-ano.csv
JuntarArchivos ./ConsultaSQL/hora  velocidad-por-hora.csv
