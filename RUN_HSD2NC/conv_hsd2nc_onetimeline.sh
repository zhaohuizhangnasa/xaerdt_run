#!/bin/sh 
########################################################################
# Puopose: 
#   convert Himawari HSD fulldisk data files (10 files each band) of 
#     a specific timeline to netCDF
#       
# 
# Author:  
#       Zhaohui Zhang
#
# Usg: conv_hsd2nc_timeline.sh YYYY MONTH DAY HR MIN(e.g., 2018 08 31 10 )
#
########################################################################
#set -x 
source setup_env.bash
conv() {
 
  factor=$1
  hsdfile="$2"
  hsdpath=${hsdfile%/*}
  hsdname=${hsdfile##*/}
  filename=${hsdname}     
  output="$3"
  if [ ! -d $output ]; then
    mkdir -p $output

  fi
 
  PYTHONPATH=$MYPYTHON python -m hsd2nc  --factor=$factor \
   $hsdpath/$filename $output/${filename}.nc
}

if [ $# -lt  5 ]
 then
 echo " Usage: $0 yyyy mn dd hr mm [08|09]"
 exit 1
fi

yyyy=$1 ; mn=$2 ; dd=$3 ; hr=$4 ; mm=$5
mm=$(printf "%02d" $((10#$mm)))
ymd=$(printf "%04d%02d%02d" $1 ${2#0} ${3#0})
sdate=${yyyy}${mn}${dd}

satn="08"
if [ -n "$6" ]; then satn="$6"; fi

#ARCH_HSD=${HSD_ARCH_HOME}/AHI_H${satn}/HSD/$sdate
ARCH_HSD=${HSD_ARCH_HOME}/AHI_H${satn}/HSD/$sdate/$hr$mm

LOCAL_HSD=${WRK_DATA_HOME}/HSD${satn}/$sdate/$hr$mm
if [ ! -d ${LOCAL_HSD} ]; then 
  mkdir -p ${LOCAL_HSD}
fi 

# HS_H08_20181003_1800_B01_FLDK_R20_S0410.DAT

# loop over the bands
tlines=(1 2 3 4 5 6 14)
for index in "${tlines[@]}"; do
#for index in {1..6}; do 
  Bstr=B$(printf "%02d" $index)
  if (( $index >= 5 )); then
    Rstr=R20 ; factor=1 
    subdir=$sdate/2km
  elif (( $index == 3 )); then
    Rstr=R05 ; factor=1 
    subdir=$sdate/500m
  else 
    Rstr=R10 ; factor=1 
    subdir=$sdate/1km
  fi
 
  LOCAL_L1NC=${WRK_DATA_HOME}/L1NC${satn}/${subdir}
  ARCH_L1NC=${AHI_L1NC_HOME}/AHI_H${satn}/L1NC/${yyyy}/${subdir}

  if [ ! -d ${LOCAL_L1NC} ]; then 
    mkdir -p ${LOCAL_L1NC}
  fi 

  if [ ! -d ${ARCH_L1NC} ]; then 
    mkdir -p ${ARCH_L1NC}
  fi 

  f=HS_H08_${sdate}_${hr}${mm}_${Bstr}_FLDK_${Rstr}
  if [ -s "$LOCAL_L1NC/$f.nc" ]; then 
     #the nc file in the working directory may be the incomplete one
     #from the last abnormal system interrupting, so delete it to 
     #avoid the new data appended to the last one
     echo "${LOCAL_L1NC}/$f.nc already exits, delete ..."
     rm -f ${LOCAL_L1NC}/$f.nc
     #continue 
  fi
  if [ -s "$ARCH_L1NC/$f.nc" ]; then 
     echo "$ARCH_L1NC/$f.nc already exits, skip hsd2nc conversion ..."
     continue 
  fi

  # loop over the 10 slices 
  for j in {1..10}; do 
     Sstr=S$(printf "%02d" $j)10
     f=HS_H${satn}_${sdate}_${hr}${mm}_${Bstr}_FLDK_${Rstr}_${Sstr}.DAT
     if [ ! -s ${LOCAL_HSD}/${f} ]; then
          #echo ${files} | xargs -L100 -P2 cp -t ${wkdir}
          if [  -s ${ARCH_HSD}/$f ]; then
            #echo "cp  $f ${LOCAL_HSD}"
             cp   ${ARCH_HSD}/$f ${LOCAL_HSD}
          elif [ -s ${ARCH_HSD}/$f.bz2 ]; then
            #echo "cp  $f ${LOCAL_HSD}"
             cp   ${ARCH_HSD}/$f.bz2 ${LOCAL_HSD}
             bunzip2 -d ${LOCAL_HSD}/$f.bz2
          else
             echo "no source file ${ARCH_HSD}/$f(.bz2)..."
	     # use continue regardless of the is file
             exit 1
          fi

       fi
   done
   f=HS_H${satn}_${sdate}_${hr}${mm}_${Bstr}_FLDK_${Rstr}
   f08=HS_H08_${sdate}_${hr}${mm}_${Bstr}_FLDK_${Rstr}
   fs=($(ls ${LOCAL_HSD}/${f}*.DAT))
   if [ ${#fs[@]} -eq 10 ]; then 
       echo ">>> Convert hsd to netcdf --> ${sdate} ${hr}:${mm} band ${Bstr}"
       #echo "Conv_Start_Time = $(date)"
       time conv $factor ${LOCAL_HSD}/${f} ${LOCAL_L1NC} && rm -f ${LOCAL_HSD}/${f}*.DAT
       #mv $output/${f}.nc $output/${f}0.nc
       nccopy -d1 ${LOCAL_L1NC}/${f}.nc ${ARCH_L1NC}/${f}.nc
       #echo "Conv_End_Time = $(date)"
       rm -f ${LOCAL_L1NC}/${f}.nc
   fi

 

done 


exit 0

