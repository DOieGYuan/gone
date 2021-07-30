#concoct
echo -e "\033[32;1mBinning with CONCOCT...\033[0m"
test -e concoct || mkdir concoct
cut_up_fasta.py ${1%}.contigs.fa -c 10000 -o 0 --merge_last -b contigs_10K.bed > contigs_10K.fa
concoct_coverage_table.py contigs_10K.bed *.sorted.bam > coverage_table_concoct.tsv
concoct --composition_file contigs_10K.fa --coverage_file coverage_table_concoct.tsv -b concoct/concoct -t $2
merge_cutup_clustering.py concoct/concoct_clustering_gt1000.csv > concoct/clustering_merged.csv
test -e concoct_binning || mkdir concoct_binning
extract_fasta_bins.py ${1%}.contigs.fa concoct/clustering_merged.csv --output_path concoct_binning/

echo -e "\033[32;1mRemoved intermediate files\033[0m"
rm concoct_*
rm contigs_10K*
rm -rf concoct
