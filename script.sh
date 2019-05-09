#! /usr/bin/env bash
#!/bin/bash
# Arreglo de CSV para QUERY SQL

hello_world () {
   echo 'hello, world'
}

AgregarFilasHaTodosLasEstaciones(){
    mkdir temporal
    mkdir procesadoSed
for i in ./estaciones/*.csv
do
    echo "Processing $i"
    b=$(basename $i)
    filename="${b%.*}"
    echo $filename
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
    echo 'hello, world'
}
ConsultaSQL(){
    mkdir ConsultaSQL
    for i in ./procesadoSed/*.csv
    do
    b=$(basename $i)
    filename="${b%.*}"
    csvsql  -v --query "select NAME ,strftime('%m', FECHA) as Mes,AVG(VEL) as Velocidad from $filename  GROUP BY  NAME,MES"  $i > ConsultaSQL/$filename"mes.csv"
    csvcut -n $i
    done
}


AgregarFilasHaTodosLasEstaciones
ConsultaSQL
