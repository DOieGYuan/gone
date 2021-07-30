#Usage: soure code.sh [directory with paired-end fastq] [threads]
cd $1
echo -e "\033[32;1mMerge forward sequences to comb_1.fastq\033[0m"
zcat *_1.fq.gz > comb_1.fastq
echo -e "\033[32;1mMerge reverse sequences to comb_2.fastq\033[0m"
zcat *_2.fq.gz > comb_2.fastq

echo -e "\033[32;1mAssembly reads into contigs using (meta)spades...\033[0m"

conda activate assembly

spades.py -1 comb_1.fastq -2 comb_2.fastq -o assembly --meta -t $2 -m 768

# Rename assembly files
mv assembly/contigs.fasta assembly/${1%}.raw.contigs.fa
#mv assembly/scaffolds.fasta assembly/${1%}.raw.scaffolds.fa

# Simplified headers
cat assembly/${1%}.raw.contigs.fa | sed 's/_length.*//g' > assembly/${1%}.contigs.fa

cd -
conda deactivate
echo -e "\033[32;1mAssembly finished\033[0m"
