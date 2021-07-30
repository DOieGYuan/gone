#!/usr/bin/env bash
echo -e "\033[35;1mUsage: source EasyGCMeta.sh [directory with paired-end fastq]\033[0m"
echo \
"""
####################################################################
#            Easy Genomic-Centric Metagenomics pipeline            #
#                         Author: DOieGYuan                        #
#                   github.com/DOieGYuan/easyG                     #
####################################################################
"""
# Get processors number (default: max-2)
declare -i pro_num
pro_num=$(grep "processor" /proc/cpuinfo | sort -u | wc -l)
# Get sample number
# sample_num=$(ls *_1.fq.gz | sort -u | wc -l)

# Co-assembly
echo -e "\033[32;1mAssembly pipeline\033[0m"
source assembly_wf_megahit.sh $1 $pro_num

# Binning
echo -e "\033[32;1mBinning pipeline\033[0m"
source binning_wf.sh $1 $pro_num 50 10 # Completeness>50 Contanmination<10
