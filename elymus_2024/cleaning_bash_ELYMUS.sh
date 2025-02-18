#!/bin/bash

##########################################################################################
## ELEL1 cleaning lane one
##########################################################################################

/working/parchman/tapioca/src/tap_contam_analysis --db /working/parchman/contaminants/illumina_oligos --pct 20 /working/parchman/ELEL24/ELEL1_S1_L001_R1_001.fastq > ELEL24_1.readstofilter.ill.txt 

echo "Illumina filtering done for lane 1"

/working/parchman/tapioca/src/tap_contam_analysis --db /working/parchman/contaminants/phix174 --pct 80 /working/parchman/ELEL24/ELEL1_S1_L001_R1_001.fastq > ELEL24_1.readstofilter.phix.txt 

echo "PhiX filtering done for lane 1"


/working/parchman/tapioca/src/tap_contam_analysis --db /working/parchman/contaminants/ecoli-k-12 --pct 80 /working/parchman/ELEL24/ELEL1_S1_L001_R1_001.fastq > ELEL24_1.readstofilter.ecoli.txt

echo "ecoli filtering done for lane 1"


cat /working/parchman/ELEL24/ELEL1_S1_L001_R1_001.fastq | fqu_cull -r ELEL24_1.readstofilter.ill.txt ELEL24_1.readstofilter.phix.txt ELEL24_1.readstofilter.ecoli.txt > ELEL24_1.clean.fastq

echo "Clean copy of lane 1 done"



##########################################################################################
## ELEL24 cleaning lane two
##########################################################################################

/working/parchman/tapioca/src/tap_contam_analysis --db /working/parchman/contaminants/illumina_oligos --pct 20 /working/parchman/ELEL24/ELEL2B_S2_L002_R1_001.fastq > ELEL24_2.readstofilter.ill.txt 

echo "Illumina filtering done for lane 2"

/working/parchman/tapioca/src/tap_contam_analysis --db /working/parchman/contaminants/phix174 --pct 80 /working/parchman/ELEL24/ELEL2B_S2_L002_R1_001.fastq > ELEL24_2.readstofilter.phix.txt 

echo "PhiX filtering done for lane 2"


/working/parchman/tapioca/src/tap_contam_analysis --db /working/parchman/contaminants/ecoli-k-12 --pct 80 /working/parchman/ELEL24/ELEL2B_S2_L002_R1_001.fastq > ELEL24_2.readstofilter.ecoli.txt

echo "ecoli filtering done for lane 2"


cat /working/parchman/ELEL24/ELEL2B_S2_L002_R1_001.fastq | fqu_cull -r ELEL24_2.readstofilter.ill.txt ELEL24_2.readstofilter.phix.txt ELEL24_2.readstofilter.ecoli.txt > ELEL24_2.clean.fastq

echo "Clean copy of lane 2 done"

