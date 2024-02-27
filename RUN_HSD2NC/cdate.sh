#!/bin/bash

mydate(){
  local PROC_TIME
  usg_msg="usage: $0 YYYYMNDD[e.g. 20181001] |\
           YYYYJDAY[e.g.,2018274]  "
  if [ $# -lt 1 ]; then
    echo "${usg_msg} "
    exit 1
  fi
  if [ ${#1} -eq 8 ]; then
    PROC_TIME=`date +%Y%m%d  --date="$1"`
  elif [ ${#1} -eq 7 ]; then
    local jdate="${1:0:4}0101 +$((10#${1:4:3} - 1 ))days"
    PROC_TIME=$(date -d "$jdate" +%Y%m%d)
  else
    echo "${usg_msg} "
    exit 2
  fi
  local year=`echo ${PROC_TIME} | cut -c1-4`
  local month=`echo ${PROC_TIME} | cut -c5-6`
  local day=`echo ${PROC_TIME} | cut -c7-8`
  local jday=`date -d "$year$month$day" +%j`
  local darry=($year $month $day $jday)
  echo "${darry[@]}"
}

