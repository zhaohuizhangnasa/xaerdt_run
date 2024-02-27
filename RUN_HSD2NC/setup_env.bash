#! /bin/bash
########################################################################
# 
#  Set the top-level ENV variables to run the HSD2NC package 
#  
# 
# Author:  
#       Zhaohui Zhang
#
#
########################################################################

user=$(whoami)
#working data path
export WRK_DATA_HOME=/ships19/hercules/${user}/stmp
export ARCH_DATA_HOME=/ships19/hercules/zhzhang/DATA
#local HSD archive path
export HSD_ARCH_HOME=${ARCH_DATA_HOME}
export AHI_L1NC_HOME=${ARCH_DATA_HOME}
#Himawari package path, don't change
export PATH=/ships19/hercules/zhzhang/Python/bin:$PATH
export PATH=/ships19/hercules/zhzhang/apps/4.3.3-gcc-4.9.2/bin:$PATH
export MYPYTHON=/ships19/hercules/zhzhang/hsd2nc/himawari 
