#!/bin/bash

##########################################################################################
## ERUM cleaning lane one
##########################################################################################

/working/parchman/tapioca/src/tap_contam_analysis --db /working/parchman/contaminants/illumina_oligos --pct 20 /working/parchman/ERUM/ERMU24lib_S1_L001_R1_001.fastq > ERUM1.readstofilter.ill.txt 

echo "Illumina filtering done for lane 1"

/working/parchman/tapioca/src/tap_contam_analysis --db /working/parchman/contaminants/phix174 --pct 80 /working/parchman/ERUM/ERMU24lib_S1_L001_R1_001.fastq > ERUM1.readstofilter.phix.txt 

echo "PhiX filtering done for lane 1"


/working/parchman/tapioca/src/tap_contam_analysis --db /working/parchman/contaminants/ecoli-k-12 --pct 80 /working/parchman/ERUM/ERMU24lib_S1_L001_R1_001.fastq > ERUM1.readstofilter.ecoli.txt

echo "ecoli filtering done for lane 1"


cat /working/parchman/ERUM/ERMU24lib_S1_L001_R1_001.fastq | fqu_cull -r ERUM1.readstofilter.ill.txt ERUM1.readstofilter.phix.txt ERUM1.readstofilter.ecoli.txt > ERUM1.clean.fastq

echo "Clean copy of lane 1 done"


##########################################################################################
## ERUM cleaning lane two
##########################################################################################

/working/parchman/tapioca/src/tap_contam_analysis --db /working/parchman/contaminants/illumina_oligos --pct 20 /working/parchman/ERUM/ERMU24lib_S1_L002_R1_001.fastq > ERUM2.readstofilter.ill.txt 

echo "Illumina filtering done for lane 2"

/working/parchman/tapioca/src/tap_contam_analysis --db /working/parchman/contaminants/phix174 --pct 80 /working/parchman/ERUM/ERMU24lib_S1_L002_R1_001.fastq > ERUM2.readstofilter.phix.txt 

echo "PhiX filtering done for lane 2"

/working/parchman/tapioca/src/tap_contam_analysis --db /working/parchman/contaminants/ecoli-k-12 --pct 80 /working/parchman/ERUM/ERMU24lib_S1_L002_R1_001.fastq > ERUM2.readstofilter.ecoli.txt

echo "ecoli filtering done for lane 2"


cat /working/parchman/ERUM/ERMU24lib_S1_L002_R1_001.fastq | fqu_cull -r ERUM2.readstofilter.ill.txt ERUM2.readstofilter.phix.txt ERUM2.readstofilter.ecoli.txt > ERUM2.clean.fastq

echo "Clean copy of lane 2 done"

