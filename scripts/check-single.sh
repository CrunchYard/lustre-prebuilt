#!/bin/bash

if [ $# -eq 0 ]; then
    echo "Please use get-single-stripe-files.sh"
    exit 1
fi

export FILE=$1

rbh-report -e $FILE | gawk -F'\t' 'START{print("filename,stripe_cnt,stripe_size");}{split($1,field,","); split($2,value,","); gsub(/ /,"",value[1]); gsub(/ /,"",value[2]); stripe_cnt=value[1]; stripe_size=value[2]; if(field[1]=="stripe_cnt"&&stripe_cnt<2) printf("%s,%s,%s", ENVIRON["FILE"], stripe_cnt, stripe_size);}'
