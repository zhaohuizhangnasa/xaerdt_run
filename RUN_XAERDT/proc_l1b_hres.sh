#!/bin/bash
########################################################################
# Puopose: 
#  bash functions to handle sensor L1 data files 
# 
# Author:  
#       Zhaohui Zhang
#
# Usg: source proc_l1b_hres.sh 
#
########################################################################

source setup_env.bash
Proc_ABI_L1B(){
  local year=$1 ; local month=$2 ; local day=$3
  local jday=`date -d "$year$month$day" +%j`
  local sdate=$year$jday ; local hh=$4 ; local mm=$5
  local EW='16'
  if [ "$6" == "ABI_G17" ]; then EW='17' ; fi
  if [ "$6" == "ABI_G18" ]; then EW='18' ; fi
  local DATA_HOME=/data/mattoo/ABI_input_testing
  local DATA_HOME=/data/zhzhang/DATA/ABI_L1b
  local DATA_HOME=/tis/modaps/goesr/v10/GOES-${EW}-ABI-L1B-FULLD
  local DATA_HOME=/arcdata/goes/grb/goes${EW}
  local L1B_DIR=${DATA_HOME}/$year/${year}_${month}_${day}_${jday}/abi/L1b/RadF/
  local M='6' # '6'
  local logfile=/dev/null
  if [ -n "$7" ]; then logfile="$7" ; fi
  #L1B_DIR=${DATA_HOME}/$year/$jday/$hh
  #  Idl to congrid  2 and 6 wavelength
  #  2019/01/01 to 2019/04/01  M3C 0 15 30 45
  #  after 2019/01/02   M6C 0 15 30 45
  #  2019/01/02   both  M33C and M6C
  file_count=$(ls -1 \
        ${L1B_DIR}/OR_ABI-L1b-RadF-M*C01_G${EW}_s$sdate$hh$mm*.nc \
        ${L1B_DIR}/OR_ABI-L1b-RadF-M*C02_G${EW}_s$sdate$hh$mm*.nc \
        ${L1B_DIR}/OR_ABI-L1b-RadF-M*C03_G${EW}_s$sdate$hh$mm*.nc \
        ${L1B_DIR}/OR_ABI-L1b-RadF-M*C04_G${EW}_s$sdate$hh$mm*.nc \
        ${L1B_DIR}/OR_ABI-L1b-RadF-M*C05_G${EW}_s$sdate$hh$mm*.nc \
        ${L1B_DIR}/OR_ABI-L1b-RadF-M*C06_G${EW}_s$sdate$hh$mm*.nc \
        ${L1B_DIR}/OR_ABI-L1b-RadF-M*C14_G${EW}_s$sdate$hh$mm*.nc 2>>$logfile | wc -l)

  if [ "$file_count" -ne 7 ]; then
    echo "file_count is not equal to 7 ..."
   return 1 
  fi

  ########################################################################
  # rescale B03 B05 B06 to 1Km                                           
  ########################################################################
  echo ">>>> Rescale B02 B04 B06 to 1Km resolution ...."
  files=(temp.txt Band2.nc Band14.nc Band6.nc *.sav )
  for f in "${files[@]}"; do
    if [ -e $f ]; then rm -f "$f"  ; fi
  done

  echo ${L1B_DIR}/OR_ABI-L1b-RadF-M*C04_G${EW}_s$sdate$hh$mm*.nc  > temp.txt
  echo ${L1B_DIR}/OR_ABI-L1b-RadF-M*C06_G${EW}_s$sdate$hh$mm*.nc >> temp.txt
  echo ${L1B_DIR}/OR_ABI-L1b-RadF-M*C14_G${EW}_s$sdate$hh$mm*.nc >> temp.txt
{
  idl<< eof
    .rnew ${UTL_DIR}/Routines/congrid_ABI/congrid_ABI_WAV14_4_and6.pro
    .rnew ${UTL_DIR}/Routines/congrid_ABI/write_NCFILE.pro
    exit
eof
} >>$logfile 2>&1
  
  file_count=$(ls -1 Band4.nc Band6.nc Band14.nc 2>>$logfile | wc -l)

  if [ "$file_count" -ne 3 ]; then
    echo "file_count is not equal to 3 ..."
   return 1 
  fi

  ########################################################################
  #/home/zhzhang/wrk/myscripts_new/congrid_geos.py -sensor abi
  echo ${L1B_DIR}/OR_ABI-L1b-RadF-M*C01_G${EW}_s$sdate$hh$mm*.nc  > L1_file_name
  echo ${L1B_DIR}/OR_ABI-L1b-RadF-M*C03_G${EW}_s$sdate$hh$mm*.nc >> L1_file_name
  echo ${L1B_DIR}/OR_ABI-L1b-RadF-M*C05_G${EW}_s$sdate$hh$mm*.nc >> L1_file_name
  echo ${L1B_DIR}/OR_ABI-L1b-RadF-M*C02_G${EW}_s$sdate$hh$mm*.nc >> L1_file_name
  echo 'Band4.nc' >> L1_file_name
  echo 'Band6.nc' >> L1_file_name
  echo 'Band14.nc' >> L1_file_name

  L1B_long=${L1B_DIR}/OR_ABI-L1b-RadF-M*C01_G${EW}_s$sdate$hh$mm*.nc
  echo $L1B_long> input_name_file
}

Proc_AHI_L1B(){
  local year=$1 ; local month=$2 ; local day=$3
  local jday=`date -d "$year$month$day" +%j`
  local sdate=$year$month$day ; local hh=$4 ; local mm=$5
  local satn='08'
  if [ "$6" == "AHI_H09" ]; then satn='09' ; fi
  local DATA_HOME=${AHI_L1BNC_HOME}/AHI_H${satn}/L1NC
  local L1B_DIR=${DATA_HOME}/$year/$sdate
  local logfile=/dev/null
  if [ -n "$7" ]; then logfile="$7" ; fi
  #  Idl to congrid  2 and 6 wavelength
  echo ${L1B_DIR}/500m/HS_H${satn}_${sdate}_${hh}${mm}_B03*.nc
  file_count=$(ls -1 \
    ${L1B_DIR}/500m/HS_H${satn}_${sdate}_${hh}${mm}_B03*.nc  \
    ${L1B_DIR}/2km/HS_H${satn}_${sdate}_${hh}${mm}_B05*.nc \
    ${L1B_DIR}/2km/HS_H${satn}_${sdate}_${hh}${mm}_B06*.nc \
    ${L1B_DIR}/1km/HS_H${satn}_${sdate}_${hh}${mm}_B01*.nc \
    ${L1B_DIR}/1km/HS_H${satn}_${sdate}_${hh}${mm}_B02*.nc \
    ${L1B_DIR}/1km/HS_H${satn}_${sdate}_${hh}${mm}_B04*.nc \
    ${L1B_DIR}/2km/HS_H${satn}_${sdate}_${hh}${mm}_B14*.nc 2>>$logfile | wc -l )

  if [ "$file_count" -ne 7 ]; then
    echo "file_count is not equal to 7 ..."
    return 1
  fi
  #######################################################################
  # rescale B03 B05 B06 to 1Km
  ########################################################################
  echo ">>>> Rescale B05 B06 to 1Km resolution ...."
  files=(temp.txt Band5.nc Band6.nc Band14.nc *.sav )
  for f in "${files[@]}"; do
    if [ -e $f ]; then rm -f "$f"  ; fi
  done

  echo ${L1B_DIR}/2km/HS_H${satn}_${sdate}_${hh}${mm}_B05*.nc > temp.txt
  echo ${L1B_DIR}/2km/HS_H${satn}_${sdate}_${hh}${mm}_B06*.nc >> temp.txt
  echo ${L1B_DIR}/2km/HS_H${satn}_${sdate}_${hh}${mm}_B14*.nc >> temp.txt
{
  idl<< eof
    .rnew ${UTL_DIR}/Routines/congrid_AHI/congrid_AHI_WAV14_5_and6.pro
    .rnew ${UTL_DIR}/Routines/congrid_AHI/write_NCFILE.pro
    exit
eof
} >>$logfile 2>&1

  file_count=$(ls -1 Band5.nc Band6.nc Band14.nc 2>>$logfile | wc -l)

  if [ "$file_count" -ne 3 ]; then
   echo "file_count is not equal to 3 ..."
   return 1 
  fi
  echo ${L1B_DIR}/1km/HS_H${satn}_${sdate}_${hh}${mm}_B01*.nc  > L1_file_name
  echo ${L1B_DIR}/1km/HS_H${satn}_${sdate}_${hh}${mm}_B02*.nc >> L1_file_name
  echo ${L1B_DIR}/1km/HS_H${satn}_${sdate}_${hh}${mm}_B04*.nc >> L1_file_name
  echo ${L1B_DIR}/500m/HS_H${satn}_${sdate}_${hh}${mm}_B03*.nc >> L1_file_name
  echo 'Band5.nc' >> L1_file_name
  echo 'Band6.nc' >> L1_file_name
  echo 'Band14.nc' >> L1_file_name

  L1B_long=${L1B_DIR}/1km/HS_H${satn}_${sdate}_${hh}${mm}_B01*.nc
  echo $L1B_long> input_name_file
}


