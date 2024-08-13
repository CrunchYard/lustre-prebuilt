#!/bin/bash
rbh-find "$(pwd -P)" -size +10M -exec "./check-single.sh {}" \; > single-stripe-files.csv 2> /dev/null
