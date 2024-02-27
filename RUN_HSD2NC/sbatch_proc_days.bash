#!/bin/sh 
########################################################################
# Puopose: 
#   A general driver script 
#   1) To make local links to the original HSD archive 
#      link_hsd_arcdata_nongoes.sh
#   2) To convert all available Himawari-8 HSD data files of a specific date 
#      to netcdf, by calling conv_hsd2nc_batch.slurm , which in turn calls
#      conv_hsd2nc_onetimeline.sh
#
# Author:  
#       Zhaohui Zhang
#
# Usg: sbatch_proc_days.bash BEGIN_DATE(e.g., 20180831) END_DATE [08|09]
#
########################################################################

source setup_env.bash
source cdate.sh

if [ $# -lt  2 ]; then
 echo "Usage: $0 BEGIN_DATE[YYYYMNDD|YYYYJDAY] END_DATE[YYYYMMDD|YYYYJDAY] [08|09]  "
 exit 1
fi
DBEG=($(mydate $1))
DEND=($(mydate $2))

date1=${DBEG[0]}${DBEG[1]}${DBEG[2]}
date2=${DEND[0]}${DEND[1]}${DEND[2]}
ds1=$(date -d "$date1" +%s)
ds2=$(date -d "$date2" +%s)
dds=$(( ( $ds2 - $ds1 ) / 86400 + 1 ))

satn="08"
if [ -n "$3" ]; then satn="$3" ; fi

echo "Main_Start_Time = $(date)"
for ((i = 0 ; i < $dds ; i++)); do
  jdate="${date1} +$(( $i ))days"
  PROC_DATE=$(date -d "$jdate" +%Y%m%d)
  echo "Processing ${PROC_DATE} "
  link_hsd_arcdata_nongoes.sh ${PROC_DATE} ${PROC_DATE} $satn
  sbatch conv_hsd2nc_batch.slurm ${PROC_DATE} $satn
done
echo "Main_End Time = $(date)"

exit 0

