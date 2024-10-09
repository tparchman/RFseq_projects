#!/bin/bash

##########################################################################################
## UNM241 cleaning lane one
##########################################################################################

/working/parchman/tapioca/src/tap_contam_analysis --db /working/parchman/contaminants/illumina_oligos --pct 20 /working/parchman/UNM24/EN-AC24_S2_L002_R1_001.fastq > UNM24.readstofilter.ill.txt 

echo "Illumina filtering done for lane 1"

/working/parchman/tapioca/src/tap_contam_analysis --db /working/parchman/contaminants/phix174 --pct 80 /working/parchman/UNM24/EN-AC24_S2_L002_R1_001.fastq > UNM24.readstofilter.phix.txt 

echo "PhiX filtering done for lane 1"


/working/parchman/tapioca/src/tap_contam_analysis --db /working/parchman/contaminants/ecoli-k-12 --pct 80 /working/parchman/UNM24/EN-AC24_S2_L002_R1_001.fastq > UNM24.readstofilter.ecoli.txt

echo "ecoli filtering done for lane 1"


cat /working/parchman/UNM24/EN-AC24_S2_L002_R1_001.fastq | fqu_cull -r UNM24.readstofilter.ill.txt UNM24.readstofilter.phix.txt UNM24.readstofilter.ecoli.txt > UNM24.clean.fastq

echo "Clean copy of lane 1 done"


