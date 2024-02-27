#! /bin/bash
########################################################################
# 
#  Set the top-level ENV variables to run the DT package 
#  
# 
# Author:  
#       Zhaohui Zhang
#
#
########################################################################

user=$(whoami)
export PKG_HOME=/ships19/hercules/zhzhang/DT_Package
export PKG_HOME=/ships19/hercules/zhzhang/DT_package06022023

export PKG_ROOT=${PKG_HOME}/pkg_root
export PKG_EXE=${PKG_HOME}/Executable_orchid
#working data path
export WRK_HOME=/ships19/hercules/${user}/stmp
export DATA_HOME=/ships19/hercules/${user}/DATA

#local HSD2NC archive path
export AHI_L1BNC_HOME=/ships19/hercules/${user}/DATA
#Himawari package path, don't change
export PATH=/data/zhzhang/pkg/Python/bin:$PATH
export MYPYTHON=/data/zhzhang/pkg/himawari/himawari

export GDAS_DATA_HOME=/ships19/hercules/zhzhang/DATA/ancillary/GDAS_0ZF
export GFS_DATA_HOME=/ships19/hercules/zhzhang/DATA/ancillary/GFS
export GMAO_DATA_HOME=/ships19/hercules/zhzhang/DATA/ancillary/GEOS5
 
export Anc_Dir_gdas1=/ships19/hercules/zhzhang/DATA/ancillary/GDAS_0ZF
export Anc_Dir_gfs=/ships19/hercules/zhzhang/DATA/ancillary/GFS
export Anc_Dir_GMAO=/ships19/hercules/zhzhang/DATA/ancillary/GEOS5

