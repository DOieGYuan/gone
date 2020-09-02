conda activate qc
cd $1

test -e TruSeq3-PE.fa || ln -s ~/anaconda3/envs/qc/share/trimmomatic/adapters/TruSeq3-PE.fa .
test -e QC || mkdir QC
test -e QC/rawReads || mkdir QC/rawReads
test -e QC/unpairedReads || mkdir QC/unpairedReads
echo -e "\033[32;1mTrimming reads using Trimmomatic\033[0m"
for f in *_1.fq.gz;
do echo -e "\033[32mNow trimming ${f%_1.fq.gz}\033[0m"
trimmomatic PE $f ${f%_1.fq.gz}_2.fq.gz -baseout ${f%_1.fq.gz}.fq.gz ILLUMINACLIP:TruSeq3-PE.fa:2:40:15:1:true SLIDINGWINDOW:4:15 MINLEN:50 -threads $2
mv $f QC/rawReads/${f%_1.fq.gz}.Raw_1.fq.gz
mv ${f%_1.fq.gz}_2.fq.gz QC/rawReads/${f%_1.fq.gz}.Raw_2.fq.gz
mv ${f%_1.fq.gz}_1U.fq.gz QC/unpairedReads/${f%_1.fq.gz}.unpaired_1.fq.gz
mv ${f%_1.fq.gz}_2U.fq.gz QC/unpairedReads/${f%_1.fq.gz}.unpaired_2.fq.gz
mv ${f%_1.fq.gz}_1P.fq.gz ${f%_1.fq.gz}_1.fq.gz
mv ${f%_1.fq.gz}_2P.fq.gz ${f%_1.fq.gz}_2.fq.gz
done

echo -e "\033[32;1mdone\033[0m"

ln -s QC/rawReads/*.fq.gz .
echo -e "\033[32;1mEstimating fastq quality using fastqc\033[0m"
for f in *_1.fq.gz;do fastqc $f ${f%_1.fq.gz}_2.fq.gz -t $2 -o QC/; done

multiqc -o QC QC
echo -e "\033[32;1mDone, the report is in QC/multiqc_report.html\033[0m"

rm *.Raw_?.fq.gz*
rm TruSeq3-PE.fa

echo -e "\033[32;1mQuality control done\033[0m"
cd -
