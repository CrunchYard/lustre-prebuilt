#!/bin/bash

if [ $# -eq 0 ]; then
    echo "Please use get-large-files-on-ost.sh"
    exit 1
fi

export FILE=$1
export OST=$2

rbh-report -e $FILE | gawk -F'\t' 'BEGIN{print("filename");}{ost=sprintf("ost#%s:",ENVIRON["OST"]); if(substr($1,0,7)=="stripes"&&index($2,ost)) printf("%s ", ENVIRON["FILE"]);}'
