#!/bin/bash
## THIS SCRIPT MUST BE SUBMITTED VIA 'sbatch'
#########################################################################
## Puopose: 
## slurm sbatch script to generate AERDT products with the selection
## of different L1 inputs(AHI, ABI, MODIS, VIIRS)  and NWP ancillaries 
## (GMAO, GFS). Currently, GMAO is the default.
##
## It calls  run_xaer_dark_target.bash 
##      
## 
## Author:  
##       Zhaohui Zhang
##
## Usg: run_dark_target_oneday.slurm YYYYMNDD(e.g., 20180831) Sat_Flag
##
########################################################################
#SBATCH --job-name=AERDT
#SBATCH --partition=all
#SBATCH --nodes=1
#SBATCH --ntasks=8
##SBATCH --mem=4GB
#SBATCH --mem-per-cpu=23GB
#SBATCH --cpus-per-task=1
#SBATCH --output=/dev/null
#SBATCH -t 4:00:00

# The "-N1 -n1" options are
# used to allocates a single core to each task.
srun="srun --exclusive -N1 -n1 "

if [ $# -lt  1 ]; then
 echo "usage: $0 YYYYMNDD[e.g. 20181001]  sat_flag"
 exit 1
fi

# specify time variables
PROC_TIME=`date +%Y%m%d  --date="$1"`

yyyy=`echo ${PROC_TIME} | cut -c1-4`
mn=`echo ${PROC_TIME} | cut -c5-6`
dd=`echo ${PROC_TIME} | cut -c7-8`

# make loop lists
ddd_list=($mn$dd)
hrs_list=($(seq 0 23))
Sat_Flag=AHI_H08
if [ -n "$2" ]; then
  Sat_Flag=($2)
fi
# Create a log director
export LOGDIR=$(pwd)/joblogs/${Sat_Flag}/${yyyy}${mn}/${SLURM_JOB_NAME}.${SLURM_JOB_ID}
if [ ! -d ${LOGDIR} ]; then
   mkdir -p ${LOGDIR}
fi
for ddd in "${ddd_list[@]}" ; do
   for hh in "${hrs_list[@]}" ; do
       year=$yyyy
       month=${ddd:0:2} ; day=${ddd:2:2}
       jday=`date -d "$year$month$day" +%j`
       sdate=$year$month$day
       hh1=$(printf "%02d" $hh)
       # each hour-group is one slurm task
       $srun run_xaer_dark_target.bash ${Sat_Flag} GMAO $sdate $hh1 > $LOGDIR/dthres_${PROC_TIME}_$hh1.log 2>&1 &
   done  #   hh
   wait
done   #  day

exit 0





