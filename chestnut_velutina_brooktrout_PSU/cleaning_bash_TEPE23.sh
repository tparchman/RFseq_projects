#!/bin/bash

##########################################################################################
## TEPE23 cleaning 
##########################################################################################

/working/jahner/tapioca/src/tap_contam_analysis --db  /archive/parchman_lab/rawdata_to_backup/contaminants/illumina_oligos --pct 20 /working/parchman/TEPE23/TEPE23_S133_L002_R1_001.fastq > TEPE23.readstofilter.ill.txt 

echo "Illumina filtering done for lane 1"

/working/jahner/tapioca/src/tap_contam_analysis --db /archive/parchman_lab/rawdata_to_backup/contaminants/phix174 --pct 80 /working/parchman/TEPE23/TEPE23_S133_L002_R1_001.fastq > TEPE23.readstofilter.phix.txt 

echo "PhiX filtering done for lane 1"


/working/jahner/tapioca/src/tap_contam_analysis --db  /archive/parchman_lab/rawdata_to_backup/contaminants/ecoli-k-12 --pct 80 /working/parchman/TEPE23/TEPE23_S133_L002_R1_001.fastq > TEPE23.readstofilter.ecoli.txt

echo "ecoli filtering done for lane 1"


cat /working/parchman/TEPE23/TEPE23_S133_L002_R1_001.fastq | fqu_cull -r TEPE23.readstofilter.ill.txt TEPE23.readstofilter.phix.txt TEPE23.readstofilter.ecoli.txt > TEPE23.clean.fastq

echo "Clean copy of lane 1 done"

