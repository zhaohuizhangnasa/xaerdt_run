#!/bin/bash

########################################################################
# Puopose: 
#   Driver script to loop the conversion of Himawari HSD fulldisk data over 
#   timelines of a specific hour.
#       
# Calling:
#  conv_hsd2nc_onetimeline.sh
# 
# Author:  
#       Zhaohui Zhang
#
# Usg: conv_hsd2nc_batch.sh YYYYMNDD HH (e.g., 20180831 ) [08|09]
#
########################################################################
if [ $# -lt  2 ]; then
 echo "usage: $0 YYYYMNDD[e.g. 20181001] HH  [08|09].."
 exit 1
fi

# specify time variables
PROC_TIME=`date +%Y%m%d  --date="$1"`

year=`echo ${PROC_TIME} | cut -c1-4`
month=`echo ${PROC_TIME} | cut -c5-6`
day=`echo ${PROC_TIME} | cut -c7-8`
hrs=($(seq 0 23)) ; hrs=($2)
mins=(00 10 20 30 40 50)
satn="08"
if [ -n "$3" ]; then satn="$3" ; fi

echo "Main_Start_Time = $(date)"
for hh in "${hrs[@]}"; do 
   for mm in "${mins[@]}"; do 
     if [ "${#hh}" -eq 1 ]; then
        hh=$(printf "%02d" $hh)
     fi
     #convert HSD to netcdf 
     conv_hsd2nc_onetimeline.sh \
     ${year} ${month} ${day} $hh $mm $satn
   done
done
echo "Main_End Time = $(date)"

exit 0

