#!/bin/bash

##########################################################################################
## OVCA1 cleaning lane one
##########################################################################################

/working/parchman/tapioca/src/tap_contam_analysis --db /working/parchman/contaminants/illumina_oligos --pct 20 /working/parchman/OVCA/OC-2024_S1_L004_R1_001.fastq > OVCA.readstofilter.ill.txt 

echo "Illumina filtering done for lane 1"

/working/parchman/tapioca/src/tap_contam_analysis --db /working/parchman/contaminants/phix174 --pct 80 /working/parchman/OVCA/OC-2024_S1_L004_R1_001.fastq > OVCA.readstofilter.phix.txt 

echo "PhiX filtering done for lane 1"


/working/parchman/tapioca/src/tap_contam_analysis --db /working/parchman/contaminants/ecoli-k-12 --pct 80 /working/parchman/OVCA/OC-2024_S1_L004_R1_001.fastq > OVCA.readstofilter.ecoli.txt

echo "ecoli filtering done for lane 1"


cat /working/parchman/OVCA/OC-2024_S1_L004_R1_001.fastq | fqu_cull -r OVCA.readstofilter.ill.txt OVCA.readstofilter.phix.txt OVCA.readstofilter.ecoli.txt > OVCA.clean.fastq

echo "Clean copy of lane 1 done"


