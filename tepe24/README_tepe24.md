
## Tepe, piper and solanum, 4 plates, 2024


## Sample organization
- see `~/Documents/GitHub/RFseq_projects/tepe24`
- Plate maps: ``
- barcode key file: `TEPE24_barcode_key.csv`


## Notes on library preparation

### R/L and PCR for plates 1-4. 

- Master mix in `TEPE_2024_RFseq_mastermixcockatils.xlsx`.
- Restriction done on 4/2/24
- Ligation complete on 4/3/24
- PCR done on: 4/5/24

## Data analysis: contaminant cleaning, barcode parsing, data storage, directory organization, and initial analyses.

We generated two lanes of S1 chemistry NovaSeq data at UTGSAF in May of 2023. 


## This file contains code and notes for
1) cleaning contaminants using tapioca
2) parsing barcodes
3) splitting fastqs 
4) de novo assembly
5) reference based assembly
6) calling variants
7) filtering
8) entropy for genotype probabilities.

## 1. Cleaning contaminants

Being executed on ponderosa using tapioca pipeline. Commands in bash script (cleaning_bash_NEO24.sh), executed as below.

Decompress fastq file:

    $ gunzip TEPE24_S1_L001_R1_001.fastq.gz

Number of reads **before** cleaning:

    $ nohup grep -c "^@" TEPE24_S1_L001_R1_001.fastq > TEPE24_number_of_rawreads.txt &
    ## raw reads:1,012,467,102 



To run cleaning_bash* tapioca wrapper, exit conda environment, load modules, and run bash scripts.

    $ module load fqutils/0.4.1
    $ module load bowtie2/2.2.5
    
    $ bash cleaning_bash_TEPE24.sh &


After .clean.fastq has been produced, rm raw data:

    $ rm -rf TEPE24_S1_L001_R1_001.fastq &


Raw data will stay stored in: /archive/parchman_lab/rawdata_to_backup/NEO24/


Number of reads **after** cleaning:

    $ nohup grep -c "^@" TEPE24.clean.fastq > TEPE24_clean_reads.txt &
    # number of clean reads : 

####################################################################################
## 2. Barcode parsing:
####################################################################################

Be sure to deactivate conda environment before running the below steps. Barcode keyfile is `TEPE_barcodekey.csv`
`
Parsing TEPE24 fastq files:

    $ nohup perl parse_barcodes768.pl TEPE24_barcodekey.csv TEPE24.clean.fastq A00 &>/dev/null &



`NOTE`: the A00 object is the code that identifies the sequencer (first three characters after the @ in the fastq identifier).

    $ less parsereport_TEPE24.clean.fastq 

    Good mids count: 676468496
    Bad mids count: 27924977
    Number of seqs with potential MSE adapter in seq: 206191
    Seqs that were too short after removing MSE and beyond: 120
####################################################################################
## 3. splitting fastqs
####################################################################################

For FRLA, doing this in `/working/parchman/TEPE24/splitfastqs`

Make ids file

    $ cut -f 3 -d "," TEPE24_barcodekey.csv | grep "_" > TEPE24_ids_noheader.txt


Split fastqs by individual

    $ nohup perl splitFastq_universal_regex.pl TEPE24_ids_noheader.txt parsed_TEPE24.clean.fastq &>/dev/null &



# DONE TO HERE &&&&&&&&&&


Zip the parsed*fastq files

    $ nohup gzip *fastq &>/dev/null &

Moved raw data to `/backups/rawdata_to_backup/TEPE24_GBS`

### syncing fastq files to Adkins directory on pronghorn:


    $ rsync -av *fastq.gz tparchman@pronghorn.rc.unr.edu:
Fastqs by species are located on ponderosa in:

FRLA1:
`/working/parchman/FRLA`

FRLA2:
`/working/parchman/FRLA`

