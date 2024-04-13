#!/bin/bash

##########################################################################################
## CADE_FRVE1 cleaning lane one
##########################################################################################

/working/parchman/tapioca/src/tap_contam_analysis --db /Pedro/parchman_lab/rawdata_to_backup/contaminants/illumina_oligos --pct 20 /working/parchman/CADE_FRVE/CADE-FRVE_S1_L001_R1_001.fastq > CADE_FRVE1.readstofilter.ill.txt 

echo "Illumina filtering done for lane 1"

/working/parchman/tapioca/src/tap_contam_analysis --db /Pedro/parchman_lab/rawdata_to_backup/contaminants/phix174 --pct 80 /working/parchman/CADE_FRVE/CADE-FRVE_S1_L001_R1_001.fastq > CADE_FRVE1.readstofilter.phix.txt 

echo "PhiX filtering done for lane 1"


/working/parchman/tapioca/src/tap_contam_analysis --db /Pedro/parchman_lab/rawdata_to_backup/contaminants/ecoli-k-12 --pct 80 /working/parchman/CADE_FRVE/CADE-FRVE_S1_L001_R1_001.fastq > CADE_FRVE1.readstofilter.ecoli.txt

echo "ecoli filtering done for lane 1"


cat /working/parchman/CADE_FRVE/CADE-FRVE_S1_L001_R1_001.fastq | fqu_cull -r CADE_FRVE1.readstofilter.ill.txt CADE_FRVE1.readstofilter.phix.txt CADE_FRVE1.readstofilter.ecoli.txt > CADE_FRVE1.clean.fastq

echo "Clean copy of lane 1 done"



##########################################################################################
## CADE_FRVE1 cleaning lane two
##########################################################################################

/working/parchman/tapioca/src/tap_contam_analysis --db /archive/parchman_lab/rawdata_to_backup/contaminants/illumina_oligos --pct 20 /working/parchman/CADE_FRVE/CADE-FRVE_S1_L002_R1_001.fastq > CADE_FRVE2.readstofilter.ill.txt 

echo "Illumina filtering done for lane 2"

/working/parchman/tapioca/src/tap_contam_analysis --db /Pedro/parchman_lab/rawdata_to_backup/contaminants/phix174 --pct 80 /working/parchman/CADE_FRVE/CADE-FRVE_S1_L002_R1_001.fastq > CADE_FRVE2.readstofilter.phix.txt 

echo "PhiX filtering done for lane 2"


/working/parchman/tapioca/src/tap_contam_analysis --db /Pedro/parchman_lab/rawdata_to_backup/contaminants/ecoli-k-12 --pct 80 /working/parchman/CADE_FRVE/CADE-FRVE_S1_L002_R1_001.fastq > CADE_FRVE2.readstofilter.ecoli.txt

echo "ecoli filtering done for lane 2"


cat /working/parchman/CADE_FRVE/CADE-FRVE_S1_L002_R1_001.fastq | fqu_cull -r CADE_FRVE2.readstofilter.ill.txt CADE_FRVE2.readstofilter.phix.txt CADE_FRVE2.readstofilter.ecoli.txt > CADE_FRVE2.clean.fastq

echo "Clean copy of lane 2 done"

