for i in *.fa; do num=`cat $i | grep ">"| wc -l`; for f in $(seq -w ${num%}); do sed -i "0,/>[kN].*/s/>[kN].*/>${i%.fa}_${f%}/g" $i; done; done
coverm genome -d dereplicated_genomes/ -x fa -p bwa-mem -t 30 -1 *_1.fastq -2 *_2.fastq --min-covered-fraction 0.01 > coverm_relative_abundance.txt
