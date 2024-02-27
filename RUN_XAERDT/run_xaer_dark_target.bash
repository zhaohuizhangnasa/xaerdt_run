#!/bin/bash
########################################################################
# Puopose: 
#  The generic driver script to generate the aerosol dark-target products 
#  from the L1 observations of the implemented sensors. Currently, the 
#  script supports AHI Himawari 8 & 9, ABI G16, G17 & G18, MODIS AQUA & Terra
#  and VIIRS SNPP provided their L1 inputs are available.
#
#  Note: AHI HSD data must be converted into netCDF format first before running
#  this script.
#  The ancillary GMAO, GFS, GDAS options are also provided. GMAO is the default.
# 
# Author:  
#       Zhaohui Zhang
#
# Usg: run_xaer_dark_target.bash Sat_Flag [GDAS|GMAO] [YYYYMNDD|YYYYJDAY] HH MM 
#
########################################################################

ScriptDIR=`pwd`
source setup_env.bash
source proc_l1b_hres.sh
source cdate.sh
source check_file_exits.sh

SID=ABI ; Sat_Flag=ABI_E

if [ $# -lt 3 ]; then
 echo "usage: $0 [AHI_H08|AHI_H09|ABI_G16|ABI_G17|ABI_G18|MODIS_AQUA|MODIS_TERRA|VIIRS_SNPP]\
  [GDAS|GMAO] [YYYYMNDD|YYYYJDAY] HH MM"
 exit 1
fi
SatFlag="$1" ; NWP_Flag="$2" ; PROC_DATE="$3"
# specify time variables
DATE=( $(mydate ${PROC_DATE}) )
year=${DATE[0]} ; month=${DATE[1]}
day=${DATE[2]}  ; jday=${DATE[3]}
sdate=${year}${jday}
pdate=${year}-${month}-${day}
case ${SatFlag} in
  ABI*)
    SID=ABI
    GAS_COEFF=ABI.LBL_GAS_COEFS.US76_TAUS.v1.dat
    CDL_FILE=ABI.cdl
    EXE_FILE=abi.exe
    npix=10848 ; kscan=10848
    hrs_list=($(seq 0 23))
    min_list=(00 10 20 30 40 50)
    #min_list=(00 10 15 20 30 40 45 50)
    DT_Flag=GOES16
    if [ "${SatFlag}" == "ABI_G16" ]; then 
       DT_Flag=GOES16 ; Sat_Flag=ABI_E
       CDL_FILE=XAERDT_L2_ABI_G16.cdl
    fi
    if [ "${SatFlag}" == "ABI_G17" ]; then 
       DT_Flag=GOES17 ; Sat_Flag=ABI_W
       CDL_FILE=XAERDT_L2_ABI_G17.cdl
    fi
    if [ "${SatFlag}" == "ABI_G18" ]; then 
       DT_Flag=GOES18 ; Sat_Flag=ABI_W
       CDL_FILE=XAERDT_L2_ABI_G18.cdl
    fi
    ;;
  AHI*)
    SID=AHI
    DT_Flag=HIMAWARI8
    Sat_Flag=AHI
    GAS_COEFF=AHI.LBL_GAS_COEFS.US76_TAUS.dat
    CDL_FILE=XAERDT_L2_AHI_H08.cdl
    if [ "${SatFlag}" == "AHI_H09" ]; then 
       DT_Flag=HIMAWARI9 ; Sat_Flag=AHI
       CDL_FILE=XAERDT_L2_AHI_H09.cdl
    fi
    EXE_FILE=ahi.exe
    npix=11000 ; kscan=11000
    hrs_list=($(seq 0 23))
    min_list=(00 10 20 30 40 50)
    ;;
  *)
    echo "Wrong Sensor ID ...."
    exit 1
    ;;
esac 
# make loop lists
if [ -n "$4" ]; then
  hrs_list=($4)
fi
if [ -n "$5" ]; then
  min_list=($5)
fi
# specify package components
if [ "${PKG_HOME}" == "" ]; then
  echo "Package home directory is not specified ... "
  exit 1
fi
SRC_DIR=${PKG_HOME}/Source
TBL_DIR=${PKG_HOME}/pkg_root/Tables
UTL_DIR=${PKG_HOME}/pkg_root

EXE_DIR=${PKG_EXE}
if [ ! -d ${EXE_DIR} ];then
  echo "error: ${EXE_DIR}  not exists ..."
  exit 2
fi

CDATE=${UTL_DIR}/Routines/read_Anc/bin/cdate
WGRIB=${UTL_DIR}/Routines/read_Anc/bin/wgrib
WGRIB2=${UTL_DIR}/Routines/read_Anc/bin/wgrib2
NCGEN=/opt/netcdf4/4.7.4-gcc-6.5/bin/ncgen
NCCOPY=/opt/netcdf4/4.7.4-gcc-6.5/bin/nccopy

#SCRIPT_DIR='/home/zhzhang/iris-home/wrk/myscripts_20221114'
SCRIPT_DIR=`pwd`

# specify I/O subdirectories
PRODUCT_NAME=AERDT_L2 ; INSTRUMENT=${SatFlag}
VERSION=v001

ARCH_HOME=${DATA_HOME:-/data/zhzhang/TEST2}
L2_OUT_HOME=${ARCH_HOME}/${INSTRUMENT}/${PRODUCT_NAME}/$VERSION
L2_OUT_DIR=${L2_OUT_HOME}/$year/${jday}
if [ ! -d ${L2_OUT_DIR} ];then
   mkdir -p ${L2_OUT_DIR}
fi
LOG_HOME=${L2_OUT_HOME}/LOG
LOGDIR=${LOG_HOME}/$year
if [ ! -d ${LOGDIR} ];then
   mkdir -p ${LOGDIR}
fi

WRKHOME=${WRK_HOME}/${SatFlag}
# make loop lists
ddd_list=($month$day)
#hrs_list=($hh) ; min_list=($mm)
for ddd in "${ddd_list[@]}" ; do
   for hh in "${hrs_list[@]}" ; do
     for mm in "${min_list[@]}"; do
       hh=$(printf "%02d" $((10#$hh)))
       OUTFILE1=X${PRODUCT_NAME}_${INSTRUMENT}.A$sdate.$hh$mm.001
       flist1=($(ls ${L2_OUT_DIR}/${OUTFILE1}*.nc 2>/dev/null ))
       if [ ${#flist1[@]} -ge 1 ]; then 
	  echo "$OUTFILE1 exist, skipping ..." 
	  continue 
       fi
       
       WORKDIR=${WRKHOME}/${sdate}${hh}${mm}
       TMP_DIR=${WORKDIR}/Temp_directory
       if [ ! -d ${TMP_DIR} ];then
         echo "making temp outdirectory',${TMP_DIR}"
         mkdir -p ${TMP_DIR}
       fi
       if [ ! -f ${WORKDIR}/cdate ]; then 
         cp $CDATE ${WORKDIR}/cdate       
         chmod 755 ${WORKDIR}/cdate
       fi
       cp -f $CDATE ${WORKDIR}/
       cp -f $WGRIB ${WORKDIR}/
       cp -f $WGRIB2 ${WORKDIR}/
       logfile=$LOGDIR/${SatFlag}.$year$month$day.$hh$mm.error.log
       [[ -f $logfile ]] && rm -f $logfile
       #echo $year,$month,$day,$hh,$mm,$jday
       cd $WORKDIR
       Proc_${SID}_L1B $year $month $day $hh $mm ${SatFlag} $logfile 
       l1b_status=$?
       if [[ ${l1b_status} -ne 0 ]]; then
         cd ${WRKHOME} && rm -fR $sdate${hh}${mm}
	 echo "L1B error ..."
	 echo "Error log: $logfile "
	 continue 
       fi
       ########################################################################
       # processing ancillary data
       ########################################################################
       echo ">>>> Processing ancillary data...."
       #echo $year $month $day $jday $hh $mm ${DT_Flag} $NWP_Flag > input_file_date
       echo $year $month $day $jday $hh $mm ${Sat_Flag} ${DT_Flag} $NWP_Flag > input_file_date
       # Get the right Names  for GDAS File based on time
       if [ -f ${TMP_DIR}/GDAS_Out ]; then  rm ${TMP_DIR}/GDAS_Out ; fi
       echo "$year,$month,$day,$hh,$mm,$jday"

       ########################################################################
       # Use file names of Ancillary data and extract files to be used in main prog.#
       ########################################################################
       
       if [ ${NWP_Flag} ==  "GDAS" ] ; then
         echo ">>>> Processing GDAS data...."
         Check_Ancillary $year $month $day $hh $mm
         if [[ $? -ne 0 ]]; then echo "No ancillary data ..." ; fi
         python ${UTL_DIR}/Routines/read_Anc/ancillary_time_gdas1.iris.py \
                $year$month$day $hh $mm 6
         gdas_base_file=`head -1 gdas_basename`
         gdas_input_file=${GDAS_DATA_HOME}/$gdas_base_file
	 echo $gdas_input_file> input_anc_file
         ${UTL_DIR}/Routines/read_Anc/bin/extract_ncep_gdas1.csh \
                   $gdas_input_file GDAS_Out
         mv  GDAS_Out  ${TMP_DIR}/GDAS_Out

       elif [ ${NWP_Flag} ==  "GFS" ] ; then
         echo ">>>> Processing GFS data...."
         hh2=$(printf "%02d" $(( ($((10#$hh))+3)/6*6 )) )
         GFSDATE=$(date -d "$year$month$day" +%Y-%m-%d)T${hh2}:00:00
         if [[ "$hh2" == "24" ]]; then
           GFSDATE=$(date -d "$year$month$day + 1day" +%Y-%m-%d)T00:00:00
         fi
         gfsprod=gfs.pgrb2.1p00.f012
         gfsfile=$(sips_search --download ./ -a ${GFSDATE} ${GFSDATE} $gfsprod )
         gfs_input_file=${gfsfile##*/}

         ${UTL_DIR}/Routines/read_Anc/bin/extract_ncep_gfs.csh \
                $gfs_input_file GDAS_Out
         mv  GDAS_Out  ${TMP_DIR}/GDAS_Out
         #if [ -f "$gfs_input_file" ]; then echo $gfs_input_file ; fi

       elif [ ${NWP_Flag} == "GMAO" ]; then
         python3 ${UTL_DIR}/Routines/read_Anc/ancillary_time_GMAO.py \
             ${GMAO_DATA_HOME} $year$month$day $hh $mm 3

         anc_file=$(grep "GEOS" input_anc_file)
	 if [[ ! -f $anc_file ]]; then
            echo "Error: No ancillary data ... ${GMAO_DATA_HOME} $year$month$day $hh $mm" >> $logfile
            echo "${GMAO_DATA_HOME} $year$month$day $hh $mm" >> $logfile
	    echo "Error log: $logfile "
	    continue
         fi 
       else
         echo ">>>>gdasfile not available",$gdas_input_file
         continue 
       fi

       # Get the GAS correction coeff. Files 
       ########################################################################
       cd $WORKDIR ;echo ">>>> Get the GAS correction coeff. Files...."
       cp ${TBL_DIR}/MODIS_VIIRS_GLI_LUTs/${GAS_COEFF} ${TMP_DIR}/Gas_corrction.dat
 
       echo ${TMP_DIR}/Gas_corrction.dat

       echo $kscan $npix >>input_file_date

       cd  $WORKDIR
       $NCGEN -o vnpaerdt_output.nc ${UTL_DIR}/CDL/${CDL_FILE}
       echo ">>>> Run Retrieval model ...."
       ${EXE_DIR}/${EXE_FILE} 2>>$logfile
       if [ $? -ne 0 ]; then
	  echo "run time error ... ${EXE_DIR}/${EXE_FILE}"
          cd ${WRKHOME} && rm -fR $sdate${hh}${mm}
	  echo "Error log: $logfile "
	  continue 
       fi 
       
       ########################################################################
       # NetCDF file is put into Outfile directory with right satellite name.
       ########################################################################
       if [ ! -d ${L2_OUT_DIR} ]; then
          mkdir ${L2_OUT_DIR}
       fi
       ptime=`date +%Y%j%H%M%S`
       pstime=$(date -d "$pdate ${hh}:${mm}")
       time_coverage_start=$(date -d "${pstime}" "+%Y-%m-%d %H:%M:%SZ" )
       time_coverage_end=$(date -d "${pstime} +10mins" "+%Y-%m-%d %H:%M:%SZ")
       OUTFILE=X${PRODUCT_NAME}_${INSTRUMENT}.A$sdate.$hh$mm.001.${ptime}
       OUTFILE1=X${PRODUCT_NAME}_${INSTRUMENT}.A$sdate.$hh$mm.001
       flist1=($(ls ${L2_OUT_DIR}/${OUTFILE1}*.nc 2>/dev/null ))
       if [ ${#flist1[@]} -ge 1 ] && [  -L ${flist1[0]} ]; then
          rm ${flist1[0]}
       fi
 
       $NCCOPY -d2 vnpaerdt_output.nc ${OUTFILE}.nc
       mv ${OUTFILE}.nc ${L2_OUT_DIR}
       cd ${WRKHOME} && rm -fR $sdate${hh}${mm}
       rm -f $logfile
  
     done #   mm
   done  #   hh
done   #  day

exit 0





