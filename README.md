Enclosed are the scripts (unix and python) to run the Dark-Target L2 package in parallel on HPC with the Slurm job scheduler. The ENV setting is based on the Hercules machine of SSEC/University of Wisconsin. 

Before running the script(s), make sure
1) compile the DT L2 package
2) check the availabiltiy of the L1 observation data
3) prepare the NWP (GMAO or GDAS) ancillary data

* The latest L2 package is under /ships19/hercules/zhzhang/DT_package06022023. 
* Use "compile_orchid.bash" under Dark_Target_Scripts to compile the package on the Hercules. You may specify where the executable file will be put, which should be the same as the "PKG_EXE" in RUN_XAERDT/setup_env.bash (see below).
* You also need to organize the NWP data in a way as shown in /ships19/hercules/zhzhang/DATA/ancillary. 



The scripts are organized in two separate subdirectories:

RUN_HSD2NC  RUN_XAERDT


1) Check and modify the  "setup_env.bash" file under these two subdirectories before running any script files.


RUN_HSD2NC/setup_env.bash
WRK_DATA_HOME
ARCH_DATA_HOME

must be the same as RUN_XAERDT/setup_env.bash
WRK_HOME
DATA_HOME

The "PKG_HOME" in RUN_XAERDT/setup_env.bash should be the home directory of the L2 package.
The "PKG_EXE"  in RUN_XAERDT/setup_env.bash should have the executable file from the compiling step.

2) The subdirectory "RUN_HSD2NC" has all the scripts to convert the Himawari HSD format to netCDF. The top-level script file is 

sbatch_proc_days.bash

Usage: ./sbatch_proc_days.bash BEGIN_DATE[YYYYMNDD|YYYYJDAY] END_DATE[YYYYMMDD|YYYYJDAY] [08|09]

You don't need run this script for ABI L2.

3) The subdirectory "RUN_XAERDT" has all the scripts to run the DT L2 package. The top-level script file is 

sbatch_Proc_days.bash

Usage: ./sbatch_Proc_days.bash BEGIN_DATE[YYYYMNDD|YYYYJDAY] END_DATE[YYYYMMDD|YYYYJDAY] Sat_Flag  
Sat_Flag: [AHI_H08 | AHI_H09 | ABI_G16 | ABI_G17 | ABI_G18 ]



After you submit the parallel jobs, you need to check/monitor "joblogs" to ensure that everything is running correctly. 
