#!/bin/bash
echo "filename,stripe_cnt,stripe_size" > single-stripe-files.csv
rbh-find "$(pwd -P)" -size +10M -exec "./check-single.sh {}" \; >> single-stripe-files.csv 2> /dev/null
