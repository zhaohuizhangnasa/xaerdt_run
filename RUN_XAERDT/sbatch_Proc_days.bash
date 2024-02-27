#!/bin/sh 
########################################################################
# Puopose: 
#   A top-level driver script to generate AERDT L2 products of multiple days
#   in parallel.
#
#   Calling:
#     sbatch run_dark_target_oneday.slurm ${PROC_DATE} ${Sat_Flag}
#
# Author:  
#       Zhaohui Zhang
#
# Usg: sbatch_Proc_days.bash BEGIN_DATE END_DATE Sat_Flag
#
########################################################################

source setup_env.bash
source cdate.sh

if [ $# -lt  3 ]; then
 echo "Usage: $0 BEGIN_DATE[YYYYMNDD|YYYYJDAY] END_DATE[YYYYMMDD|YYYYJDAY] Sat_Flag  "
 echo "Sat_Flag: [AHI_H08 | AHI_H09 | ABI_G16 | ABI_G17 | ABI_G18 ]"
 exit 1
fi
DBEG=($(mydate $1))
DEND=($(mydate $2))
Sat_Flag=$3 

date1=${DBEG[0]}${DBEG[1]}${DBEG[2]}
date2=${DEND[0]}${DEND[1]}${DEND[2]}
ds1=$(date -d "$date1" +%s)
ds2=$(date -d "$date2" +%s)
dds=$(( ( $ds2 - $ds1 ) / 86400 + 1 ))
hrs_list=($(seq 0 23))
#hrs_list=(06 07 08 09 10 11 12 13 14 15 16 21 22 23)
echo "Main_Start_Time = $(date)"
for ((i = 0 ; i < $dds ; i++)); do
  jdate="${date1} +$(( $i ))days"
  PROC_DATE=$(date -d "$jdate" +%Y%m%d)
  yday=$(date -d "$jdate" +%Y/%j)
  jday=$(date -d "$jdate" +%Y%j)
  echo "Processing ${PROC_DATE} "
  sbatch run_dark_target_oneday.slurm ${PROC_DATE} ${Sat_Flag}
done
echo "Main_End Time = $(date)"

exit 0

