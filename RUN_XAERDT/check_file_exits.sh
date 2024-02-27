#!/bin/bash
########################################################################
# Puopose: 
#  Shell functions to check if the required files are available 
#  for runing the DT package
# 
# Author:  
#       Zhaohui Zhang
#
#
########################################################################


Check_Ancillary(){
  local year=$1 ; local month=$2 ; local day=$3
  local hh=$4 ; local mm=$5
  local jday=`date -d "$year$month$day" +%j`
  local DATA_HOME=/ships19/hercules/zhzhang/DATA/ancillary/GDAS_0ZF
  #ancillary=${data_dir}/gdas1.PGrbF00.${yy}${month}${day}.${hh}z 
  local mydir=/home/zhzhang/iris-home/wrk/myscripts_orchid
  tt=$(python $mydir/ancillary_time_gdas1.py $year$month$day $hh $mm 6)
  local ddate=`echo ${tt} | cut -d'.' -f3`
  local dhh=`echo ${tt} | cut -d'.' -f4 | cut -c1-2`
  local dyear=`date -d "$ddate" +%Y`
  local djday=`date -d "$ddate" +%j`
  local data_dir=${DATA_HOME}/$dyear/${djday}
  local webhome='https://sips-data.ssec.wisc.edu/files/ancillary/GDAS_0ZF'
  ancillary=${data_dir}/$tt
  if [ ! -f $ancillary ]; then
    #if [ ! -d ${data_dir} ]; then mkdir -p ${data_dir} ;fi
    wget -P ${data_dir} $webhome/$dyear/$djday/gdas1.PGrbF00.${ddate}.${dhh}z 
  fi
  if [ ! -f $ancillary ]; then
    return 1
  fi
}

Check_Ancillary_GMAO(){
  local year=$1 ; local month=$2 ; local day=$3
  local hh=$4 ; local mm=$5
  local jday=`date -d "$year$month$day" +%j`
  local DATA_HOME=/ships19/hercules/zhzhang/DATA/ancillary/GEOS5
  #ancillary=${data_dir}/gdas1.PGrbF00.${yy}${month}${day}.${hh}z 
  local mydir=/home/zhzhang/iris-home/wrk/myscripts_orchid.2
  tt=$(python $mydir/ancillary_time_GMAO.py  $year$month$day $hh $mm 3)
  echo $tt
  local ddate=`echo ${tt} | cut -d'.' -f6 | cut -d'_' -f1`
  local dhh=`echo ${tt} | cut -d'.' -f6 | cut -d'_' -f2 | cut -c1-2`
  local dyear=`date -d "$ddate" +%Y`
  local djday=`date -d "$ddate" +%j`
  local data_dir=${DATA_HOME}/$dyear/${djday}
  local webhome='https://sips-data.ssec.wisc.edu/files/ancillary/GEOS5'
  ancillary=${data_dir}/$tt
  echo $ancillary
  if [ ! -f $ancillary ]; then
    if [ ! -d ${data_dir} ]; then mkdir -p ${data_dir} ;fi
    wget  $webhome/$dyear/$djday/$tt -O $ancillary 
  fi
  if [ ! -f $ancillary ]; then
    return 1
  fi
}

Check_ABI_L1B(){
  local year=$1 ; local month=$2 ; local day=$3
  local jday=`date -d "$year$month$day" +%j`
  local sdate=$year$jday ; local hh=$4 ; local mm=$5
  local EW='16'
  if [ "$6" == "ABI_G17" ]; then EW='17' ; fi
  local DATA_HOME=/data/mattoo/ABI_input_testing
  local DATA_HOME=/data/zhzhang/DATA/ABI_L1b
  local DATA_HOME=/tis/modaps/goesr/v10/GOES-${EW}-ABI-L1B-FULLD
  local DATA_HOME=/arcdata/goes/grb/goes${EW}
  local L1B_DIR=${DATA_HOME}/$year/${year}_${month}_${day}_${jday}/abi/L1b/RadF/
  local M='6' # '6'
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
        ${L1B_DIR}/OR_ABI-L1b-RadF-M*C14_G${EW}_s$sdate$hh$mm*.nc 2>/dev/null | wc -l)

  if [ "$file_count" -ne 7 ]; then
   #echo "file_count is not equal to 7 ..."
   return 1 
  fi

}

Check_AHI_L1B(){
  local year=$1 ; local month=$2 ; local day=$3
  local jday=`date -d "$year$month$day" +%j`
  local sdate=$year$month$day ; local hh=$4 ; local mm=$5
  
  local DATA_HOME=${AHI_L1BNC_HOME}/L1NC
  local L1B_DIR=${DATA_HOME}/$year/$sdate
  #  Idl to congrid  2 and 6 wavelength
  echo ${L1B_DIR}/500m/HS_H08_${sdate}_${hh}${mm}_B03*.nc
  file_count=$(ls -1 \
    ${L1B_DIR}/500m/HS_H08_${sdate}_${hh}${mm}_B03*.nc  \
    ${L1B_DIR}/2km/HS_H08_${sdate}_${hh}${mm}_B05*.nc \
    ${L1B_DIR}/2km/HS_H08_${sdate}_${hh}${mm}_B06*.nc \
    ${L1B_DIR}/1km/HS_H08_${sdate}_${hh}${mm}_B01*.nc \
    ${L1B_DIR}/1km/HS_H08_${sdate}_${hh}${mm}_B02*.nc \
    ${L1B_DIR}/1km/HS_H08_${sdate}_${hh}${mm}_B04*.nc \
    ${L1B_DIR}/2km/HS_H08_${sdate}_${hh}${mm}_B14*.nc 2>/dev/null | wc -l)

  if [ "$file_count" -ne 7 ]; then
    #echo "file_count is not equal to 7 ..."
    return 1
  fi

}

#Check_Ancillary_GMAO 2019 01 01 13 10
