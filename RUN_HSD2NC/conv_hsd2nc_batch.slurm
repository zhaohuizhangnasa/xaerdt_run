#!/bin/bash
## THIS SCRIPT MUST BE SUBMITTED VIA 'sbatch'
########################################################################
## Puopose: 
##  slurm sbatch script file to convert Himawari HSD fulldisk data files 
##  to netCDF with mutltiple processors/CPUs
##  
##  Calling Squence:
##    conv_hsd2nc_batch.sh  to loop over hours of one specific date
##    conv_hsd2nc_onetimeline.sh to convert the files at a specific timeline 
##     
##       
## 
## Author:  
##       Zhaohui Zhang
##
## Usg: conv_hsd2nc_batch.slurm  YYYYMNDD 
##
########################################################################

#SBATCH --job-name=hsd2nct
#SBATCH --partition=all
##SBATCH --nodes=1
#SBATCH --ntasks=4
##SBATCH --ntasks=8
#SBATCH --mem-per-cpu=20000
#SBATCH --cpus-per-task=1
##SBATCH --output=/home/%u/output/joblog/my-serial-output-%A.txt
#SBATCH --output=/dev/null
#SBATCH -t 3:00:00

#export OPENBLAS_NUM_THREADS=3

srun="srun --exclusive -N1 -n1 "
# The "-N1 -n1" options are
# used to allocates a single core to each task.
#srun="srun "

# Create a log director
export LOGDIR=$(pwd)/joblogs/${SLURM_JOB_NAME}.${SLURM_JOB_ID}
if [ ! -d ${LOGDIR} ]; then
   mkdir -p ${LOGDIR}
fi


source setup_env.bash

if [ $# -lt  1 ]; then
 echo "usage: $0 YYYYMNDD[e.g. 20181001] [08|09] .."
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

satn="08"
if [ -n "$2" ]; then satn="$2" ; fi

for ddd in "${ddd_list[@]}" ; do
   for hh in "${hrs_list[@]}" ; do
       year=$yyyy
       month=${ddd:0:2} ; day=${ddd:2:2}
       jday=`date -d "$year$month$day" +%j`
       sdate=$year$month$day
       hh1=$(printf "%02d" $hh)
       # each hour-group is one slurm task
       if [ ! -d ${LOGDIR}/${PROC_TIME} ]; then
         mkdir -p ${LOGDIR}/${PROC_TIME}
       fi
       $srun conv_hsd2nc_batch.sh $sdate $hh1 $satn \
          > $LOGDIR/${PROC_TIME}/hsd2nc_$hh1.log 2>&1 &
   done  #   hh
   wait
done   #  day

exit 0





