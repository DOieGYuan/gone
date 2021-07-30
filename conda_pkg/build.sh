# this script creates the file with configuration paths to the easyG modules.
# this script is modified from the build.sh file of metaWRAP https://github.com/bxlab/metaWRAP
echo "# Paths to GOne scripts (dont have to modify)" > bin/config-gone
echo 'mw_path=$(which GOne)' >> bin/config-gone
echo 'bin_path=${mw_path%/*}' >> bin/config-gone
echo 'SOFT=${bin_path}/scripts-gone' >> bin/config-gone
echo 'PIPES=${bin_path}/modules-gone' >> bin/config-gone
echo '' >> bin/config-gone

echo "# Databases (see 'Databases' section of GOne README for details)" >> bin/config-gone
echo "# path to indexed human genome (see GOne website for guide). This includes files hg38.bitmask and hg38.srprism.*" >> bin/config-gone
echo "BMTAGGER_DB=/scratch/gu/BMTAGGER_DB" >> bin/config-gone
echo "" >> bin/config-gone

echo "# paths to GTDBtk database"  >> bin/config-gone
echo "" >> bin/config-gone

echo "# paths to checkM database" >> bin/config-gone

chmod +x bin/config-gone

# copying over all necessary files
mkdir -p $PREFIX/bin/
cp bin/GOne $PREFIX/bin/
cp bin/gone $PREFIX/bin/
cp bin/config-gone $PREFIX/bin/
cp -r bin/modules-gone $PREFIX/bin/
cp -r bin/scripts-gone $PREFIX/bin/
