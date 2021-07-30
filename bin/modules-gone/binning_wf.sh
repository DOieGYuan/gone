cd $1
conda activate binning

#build alignment
ln -s assembly/${1%}.contigs.fa .
test -e bz2 || mkdir bz2
echo -e "\033[32;1mBuilding Bowtie2 alignment...\033[0m"
nuc_num=`egrep -v ">" ${1%}.contigs.fa | wc -c`
if (($nuc_num >= 4000000000)); then
	echo -e "\033[32;1mUsing large index...\033[0m"
	bowtie2-build ${1%}.contigs.fa bz2/asm --threads $2 --large-index	
else
	echo -e "\033[32;1mUsing small index...\033[0m"
	bowtie2-build ${1%}.contigs.fa bz2/asm --threads $2	
fi
echo -e "\033[32;1mDone\033[0m"

echo -e "\033[32;1mGenerating SAMs...\033[0m"
for f in *_1.fq.gz;do bowtie2 -1 $f -2 ${f%_1.fq.gz}_2.fq.gz -x bz2/asm -S ${f%_1.fq.gz}.sam -p $2; done
#rm *.fq.gz
echo -e "\033[32;1mDone\033[0m"

echo -e "\033[32;1mParsing SAMs...\033[0m"
samtools faidx ${1%}.contigs.fa
for i in *.sam
do
   samtools import ${1%}.contigs.fa $i ${i%.sam}.bam
   samtools sort ${i%.sam}.bam -o ${i%.sam}.sorted.bam -@ $2 -m 4G
   samtools index ${i%.sam}.sorted.bam -@ $2
done
echo -e "\033[32;1mDone\033[0m"

#parsing with metabat2
echo -e "\033[32;1mBinning with MetaBAT2...\033[0m"
test -e metabat2_binning || mkdir metabat2_binning
jgi_summarize_bam_contig_depths --outputDepth depth_metabat.txt *.sorted.bam
metabat2 -i ${1%}.contigs.fa -a depth_metabat.txt -o metabat2_binning/metabat -m 1500 -t $2
echo -e "\033[32;1mDone\033[0m"

#parsing with Maxbin2
echo -e "\033[32;1mBinning with MaxBin2...\033[0m"
sample_num=`ls *_1.fq.gz | wc -l`
i=1
sum=0
while ((i <= sample_num))
	do ((sum = 2*i+2))
	cut -f 1,$sum depth_metabat.txt | sed '1d' > A${i%}.coverage.tab
	((i++))
done
ls *coverage.tab > abundance.list
test -e maxbin2 ||mkdir maxbin2
run_MaxBin.pl -contig ${1%}.contigs.fa -abund_list abundance.list -out maxbin2/maxbin -thread $2 -min_contig_length 1000 -max_iteration 55
test -e maxbin2_binning || mkdir maxbin2_binning
mv maxbin2/maxbin.*.fasta maxbin2_binning
echo -e "\033[32;1mDone\033[0m"

#concoct
echo -e "\033[32;1mBinning with CONCOCT...\033[0m"
test -e concoct || mkdir concoct
cut_up_fasta.py ${1%}.contigs.fa -c 10000 -o 0 --merge_last -b contigs_10K.bed > contigs_10K.fa
concoct_coverage_table.py contigs_10K.bed *.sorted.bam > coverage_table_concoct.tsv
concoct --composition_file contigs_10K.fa --coverage_file coverage_table_concoct.tsv -b concoct/concoct -t $2
merge_cutup_clustering.py concoct/concoct_clustering_gt1000.csv > concoct/clustering_merged.csv
test -e concoct_binning || mkdir concoct_binning
extract_fasta_bins.py ${1%}.contigs.fa concoct/clustering_merged.csv --output_path concoct_binning/
# Fix headers
echo -e "\033[32;1mFixing the fasta headers\033[0m"
for f in concoct_binning/*.fa; do sed -i 's/ .*//g' $f; done
echo -e "\033[32;1mDone\033[0m"

# clean workplace
echo -e "\033[32;1mRemoved intermediate files\033[0m"
rm *.sam
#rm *.bam*
rm concoct_*
rm contigs_10K*
rm abundance.list
rm A*.coverage.tab
#rm *.fai
rm -rf bz2
rm -rf maxbin2
rm -rf concoct

# metaWrap
echo -e "\033[32;1mRefining bins with metaWRAP...\033[0m"
echo -e "\033[32;1mLow-quality bins will be discarded\033[0m"
conda deactivate
conda activate metawrap
metawrap bin_refinement -o metawrap -t $2 -m 120 -c $3 -x $4 -A maxbin2_binning -B metabat2_binning -C concoct_binning # --remove-ambiguous
mv metawrap/metawrap_*bins .
mv metawrap/figures/ metawrap_raw_binQuality
#mv metawrap/metawrap*bins.contigs . # The information of contigs in each genome
rm -rf metawrap
mv metawrap_*bins metawrap/

# refineM
cd -
echo -e "\033[32;1mRemoving contaminations in MAGs using refineM...\033[0m"
source refineM.sh ${1%}.contigs.fa $2 $1
rm *.bam
rm *.fai

echo -e "\033[32;1mReassembling the bins...\033[0m"
zcat *_1.fq.gz > comb_1.fastq
zcat *_2.fq.gz > comb_2.fastq
# if need, change numbers behind -c and -x for controlling the MAGs' quality
metawrap reassemble_bins -b refineM_bins -o reasm -1 comb_1.fastq -2 comb_2.fastq -c $3 -x $4 -t $2 -m 40 -l 500
conda deactivate
rm comb_?.fastq
rm ${1%}.contigs.fa
rm -rf reasm/work_files
rm -rf reasm/reassembled_bins.checkm
rm -rf reasm/original_bins

echo -e "\033[32;1mBinning workflow by DOieGYuan finished successfully\033[0m"

