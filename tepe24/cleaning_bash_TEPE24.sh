#!/bin/bash

##########################################################################################
## TEPE241 cleaning lane one
##########################################################################################

/working/parchman/tapioca/src/tap_contam_analysis --db /working/parchman/contaminants/illumina_oligos --pct 20 /working/parchman/TEPE24/TEPE24_S1_L001_R1_001.fastq > TEPE24.readstofilter.ill.txt 

echo "Illumina filtering done for lane 1"

/working/parchman/tapioca/src/tap_contam_analysis --db /working/parchman/contaminants/phix174 --pct 80 /working/parchman/TEPE24/TEPE24_S1_L001_R1_001.fastq > TEPE24.readstofilter.phix.txt 

echo "PhiX filtering done for lane 1"


/working/parchman/tapioca/src/tap_contam_analysis --db /working/parchman/contaminants/ecoli-k-12 --pct 80 /working/parchman/TEPE24/TEPE24_S1_L001_R1_001.fastq > TEPE24.readstofilter.ecoli.txt

echo "ecoli filtering done for lane 1"


cat /working/parchman/TEPE24/TEPE24_S1_L001_R1_001.fastq | fqu_cull -r TEPE24.readstofilter.ill.txt TEPE24.readstofilter.phix.txt TEPE24.readstofilter.ecoli.txt > TEPE24.clean.fastq

echo "Clean copy of lane 1 done"


