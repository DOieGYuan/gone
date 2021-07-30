# Usage source build.sh [Database directory]

# Build database directory
test -e $1 || mkdir $1
echo "easyGCM_DATABASE=$1" >> ~/.bashrc
echo "REFINEM_DATABSE=$1/refineM" >> ~/.bashrc

# Build using bioconda
# qc
conda create -n qc -c bioconda fastqc multiqc trimmomatic -y

# refineM
conda create -n refinem -c bioconda prodigal blast diamond krona -y
conda activate refinem
rm -rf ~/anaconda3/envs/refinem/opt/krona/taxonomy
mkdir ${1%}/KronaDB
ln -s ${1%}/KronaDB ~/anaconda3/envs/refinem/opt/krona/taxonomy
ktUpdateTaxonomy.sh
pip install refinem
test -e $1/refineM || mkdir $1/refineM
cd $1/refineM
wget https://data.ace.uq.edu.au/public/misc_downloads/refinem/gtdb_r80_ssu_db.2018-01-18.tar.gz
wget https://data.ace.uq.edu.au/public/misc_downloads/refinem/gtdb_r80_taxonomy.2017-12-15.tsv
wget https://data.ace.uq.edu.au/public/misc_downloads/refinem/gtdb_r95_protein_db.2020-07-30.faa.gz
wget https://data.ace.uq.edu.au/public/misc_downloads/refinem/gtdb_r95_taxonomy.2020-07-30.tsv
tar -xzf gtdb_r95_protein_db.2020-07-30.faa.gz
tar -xzf gtdb_r80_ssu_db.2018-01-18.tar.gz
diamond makedb -p 12 -d genome_db.2020-07-30.genes.faa --in genome_db.2020-07-30.genes.faa
makeblastdb -dbtype prot -in genome_db.2020-07-30.genes.faa
makeblastdb -dbtype nucl -in gtdb_r80_ssu_db.2018-01-18.fna
conda deactivate
cd -
