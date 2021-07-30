# Usage: source refineM.sh [contig.fa] [threads] [workDirectory]
cd $3
conda activate refinem
test -e refineM_workfile || mkdir refineM_workfile

# Get sample number
sample_num=$(ls *_1.fq.gz | sort -u | wc -l)

# Removing contamination based on genomic properties
refinem scaffold_stats -c $2 -x fa $1 metawrap refineM_workfile/scaffold_stats *.sorted.bam

refinem outliers refineM_workfile/scaffold_stats/scaffold_stats.tsv refineM_workfile/outlier --cov_corr 0.8 --cov_perc $((sample_num*50)) # 0.5*sampleNUM*100

refinem filter_bins metawrap refineM_workfile/outlier/outliers.tsv refineM_workfile/filtered_output_params -x fa

# Removing contamination based on taxonomic assignments
refinem call_genes -c $2 refineM_workfile/filtered_output_params refineM_workfile/gene_output -x fa

refinem taxon_profile -c $2 refineM_workfile/gene_output refineM_workfile/scaffold_stats/scaffold_stats.tsv ${REFINEM_DATABASE}/genome_db.2020-07-30.genes.faa.dmnd ${REFINEM_DATABASE}/gtdb_r95_taxonomy.2020-07-30.tsv  refineM_workfile/taxon_profile

refinem taxon_filter -c $2 refineM_workfile/taxon_profile refineM_workfile/taxon_filter.tsv

refinem filter_bins refineM_workfile/filtered_output_params refineM_workfile/taxon_filter.tsv refineM_bins -x fa
echo -e "\033[32;1mrefined bins in refineM_bins\033[0m"
echo -e "\033[32;1mPlease manually filter potential incongruent 16S rRNA genes\033[0m"
# Removing contigs with incongruent 16S rRNA genes
refinem ssu_erroneous -c $2 -x fa refineM_bins refineM_workfile/taxon_profile ${REFINEM_DATABASE}/gtdb_r80_ssu_db.2018-01-18.fna ${REFINEM_DATABASE}/gtdb_r80_taxonomy.2017-12-15.tsv ssu_output
echo -e "\033[32;1mSee information in ssu_output\033[0m"
#rm -rf refineM_workfile
for f in refineM_bins/*.fa; do mv $f `echo $f | sed 's/filtered\.filtered\.//g'`;done
cd -
