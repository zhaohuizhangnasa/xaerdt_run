#!/bin/bash
########################################################################
# Puopose: 
#   Make local links to the archived Himawari HSD data files of specific 
#   dates.
#   
# Author:  
#       Zhaohui Zhang
#
# Usg: link_hsd_arcdata_nongoes.sh  \
#      BEGIN_DATE[YYYYMNDD|YYYYJDAY] END_DATE[YYYYMMDD|YYYYJDAY] 
#
########################################################################
source setup_env.bash
source cdate.sh

make_link(){
  PROC_DATE=$1  
  # specify time variables
  DATE=( $(mydate ${PROC_DATE}) )
  year=${DATE[0]} ; month=${DATE[1]}
  day=${DATE[2]}  ; jday=${DATE[3]}
  satn="08"
  if [ -n "$2" ]; then satn="$2" ; fi

  ARCH_HOME=/arcdata/nongoes/japan/himawari$satn
  LOCAL_HOME=${HSD_ARCH_HOME}/AHI_H${satn}/HSD
  ARCH_DIR=${ARCH_HOME}/${year}_${month}/${year}_${month}_${day}_${jday}
  ARCH_DIR=${ARCH_HOME}/${year}/${year}_${month}_${day}_${jday}
  LOCAL_DIR=${LOCAL_HOME}/${year}${month}${day}
  LOCAL_DIR=${LOCAL_HOME}
  if [ ! -d ${LOCAL_DIR} ]; then 
        mkdir -p ${LOCAL_DIR}
  fi 
  if [ -L ${LOCAL_DIR}/${year}${month}${day} ] ; then
    rm -f ${LOCAL_DIR}/${year}${month}${day}
  fi
  ln -s ${ARCH_DIR} ${LOCAL_DIR}/${year}${month}${day}
}

if [ $# -lt  2 ]; then
 echo "Usage: $0 BEGIN_DATE[YYYYMNDD|YYYYJDAY] END_DATE[YYYYMMDD|YYYYJDAY]  [08|09]"
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
for ((i = 0 ; i < $dds ; i++)); do
  jdate="${date1} +$(( $i ))days"
  PROC_DATE=$(date -d "$jdate" +%Y%m%d)
  make_link ${PROC_DATE} $satn
done

