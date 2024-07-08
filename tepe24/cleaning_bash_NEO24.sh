#!/bin/bash

##########################################################################################
## NEO1 cleaning 
##########################################################################################

/working/parchman/tapioca/src/tap_contam_analysis --db  /Pedro/parchman_lab/rawdata_to_backup/contaminants/illumina_oligos --pct 20 /working/parchman/NEO24_fastqs/NEO24lib1_S1_L001_R1_001.fastq > NEO_1.readstofilter.ill.txt 

echo "Illumina filtering done for lane 1"

/working/parchman/tapioca/src/tap_contam_analysis --db /Pedro/parchman_lab/rawdata_to_backup/contaminants/phix174 --pct 80 /working/parchman/NEO24_fastqs/NEO24lib1_S1_L001_R1_001.fastq > NEO_1.readstofilter.phix.txt 

echo "PhiX filtering done for lane 1"


/working/parchman/tapioca/src/tap_contam_analysis --db  /Pedro/parchman_lab/rawdata_to_backup/contaminants/ecoli-k-12 --pct 80 /working/parchman/NEO24_fastqs/NEO24lib1_S1_L001_R1_001.fastq > NEO_1.readstofilter.ecoli.txt

echo "ecoli filtering done for lane 1"


cat /working/parchman/NEO24_fastqs/NEO24lib1_S1_L001_R1_001.fastq | fqu_cull -r NEO_1.readstofilter.ill.txt NEO_1.readstofilter.phix.txt NEO_1.readstofilter.ecoli.txt > NEO_1.clean.fastq

echo "Clean copy of lane 1 done"


##########################################################################################
## NEO2 cleaning 
##########################################################################################

/working/parchman/tapioca/src/tap_contam_analysis --db  /Pedro/parchman_lab/rawdata_to_backup/contaminants/illumina_oligos --pct 20 /working/parchman/NEO24_fastqs/NEO24lib1_S1_L002_R1_001.fastq > NEO_2.readstofilter.ill.txt 

echo "Illumina filtering done for lane 2"

/working/parchman/tapioca/src/tap_contam_analysis --db /Pedro/parchman_lab/rawdata_to_backup/contaminants/phix174 --pct 80 /working/parchman/NEO24_fastqs/NEO24lib1_S1_L002_R1_001.fastq > NEO_2.readstofilter.phix.txt 

echo "PhiX filtering done for lane 2"


/working/parchman/tapioca/src/tap_contam_analysis --db  /Pedro/parchman_lab/rawdata_to_backup/contaminants/ecoli-k-12 --pct 80 /working/parchman/NEO24_fastqs/NEO24lib1_S1_L002_R1_001.fastq > NEO_2.readstofilter.ecoli.txt

echo "ecoli filtering done for lane 2"


cat /working/parchman/NEO24_fastqs/NEO24lib1_S1_L002_R1_001.fastq | fqu_cull -r NEO_2.readstofilter.ill.txt NEO_2.readstofilter.phix.txt NEO_2.readstofilter.ecoli.txt > NEO_2.clean.fastq

echo "Clean copy of lane 2 done"
