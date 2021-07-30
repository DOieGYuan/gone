#!/usr/bin/env bash
conda activate qc
cd $1

# Test if fastq files with valid filename are existed
sample_num=`ls *_1.fq.gz|wc -l`
if [[ sample_num -eq 0 ]]; then
  echo -e "\033[31mError: no valid fastq files found!\033[0m"
  exit 1
fi

# Make working files
test -e TruSeq3-PE.fa || ln -s ~/anaconda3/envs/qc/share/trimmomatic/adapters/TruSeq3-PE.fa .
test -e QC || mkdir QC
test -e QC/rawReads || mkdir QC/rawReads
test -e QC/unpairedReads || mkdir QC/unpairedReads
echo -e "\033[32;1mQuality control started\033[0m"
echo -e "\033[32mTrimming reads using Trimmomatic\033[0m"
declare -i now_sample=1

# Trimmomatic
for f in *_1.fq.gz;
do echo -e "\033[32mNow trimming ${f%_1.fq.gz}($now_sample of $sample_num)\033[0m"
trimmomatic PE $f ${f%_1.fq.gz}_2.fq.gz -baseout ${f%_1.fq.gz}.fq.gz ILLUMINACLIP:TruSeq3-PE.fa:2:30:10:1:true SLIDINGWINDOW:4:20 MINLEN:100 -threads $2 #-phred33 (auto detect since v0.32)
mv $f QC/rawReads/${f%_1.fq.gz}.Raw_1.fq.gz
echo -e "\033[32mRaw forward reads: ${1%/}/QC/rawReads/${f%_1.fq.gz}.Raw_1.fq.gz\033[0m"
mv ${f%_1.fq.gz}_2.fq.gz QC/rawReads/${f%_1.fq.gz}.Raw_2.fq.gz
echo -e "\033[32mRaw reverse reads: ${1%/}/QC/rawReads/${f%_1.fq.gz}.Raw_2.fq.gz\033[0m"
mv ${f%_1.fq.gz}_1U.fq.gz QC/unpairedReads/${f%_1.fq.gz}.unpaired_1.fq.gz
echo -e "\033[32mUnpaired forward reads: ${1%/}/QC/unpairedReads/${f%_1.fq.gz}.unpaired_1.fq.gz\033[0m"
mv ${f%_1.fq.gz}_2U.fq.gz QC/unpairedReads/${f%_1.fq.gz}.unpaired_2.fq.gz
echo -e "\033[32mUnpaired reverse reads: ${1%/}/QC/unpairedReads/${f%_1.fq.gz}.unpaired_2.fq.gz\033[0m"
mv ${f%_1.fq.gz}_1P.fq.gz ${f%_1.fq.gz}_1.fq.gz
echo -e "\033[32mQualified forward reads: ${1%/}/${f%_1.fq.gz}_1.fq.gz\033[0m"
mv ${f%_1.fq.gz}_2P.fq.gz ${f%_1.fq.gz}_2.fq.gz
echo -e "\033[32mQualified reverse reads: ${1%/}/${f%_1.fq.gz}_2.fq.gz\033[0m"
now_sample=$nowsample+1
done
echo ""

# Perform fastqc on raw and qualified reads
ln -s QC/rawReads/*.fq.gz .
echo -e "\033[32mEstimating fastq quality using fastqc\033[0m"
for f in *_1.fq.gz;do fastqc $f ${f%_1.fq.gz}_2.fq.gz -t $2 -o QC/ -q; done

# Summarise fastqc reports using multiQC
multiqc -q -o QC QC
echo -e "\033[32mQuality report: ${1%/}/QC/multiqc_report.html\033[0m"

# Clear work space
rm *.Raw_?.fq.gz*
rm TruSeq3-PE.fa
rm QC/*fastqc*

echo -e "\033[32;1mQuality control done\033[0m"
cd -
