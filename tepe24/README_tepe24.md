
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

    $ gunzip NEO24lib1_S1_L001_R1_001.fastq.gz
    $ gunzip NEO24lib1_S1_L002_R1_001.fastq.gz

Number of reads **before** cleaning:

    $ nohup grep -c "^@" NEO24lib1_S1_L001_R1_001.fastq > NEO241_number_of_rawreads.txt &
    ## raw reads: 

    $ nohup grep -c "^@" NEO24lib1_S1_L002_R1_001.fastq > NEO242_number_of_rawreads.txt &
    ## raw reads:

To run cleaning_bash* tapioca wrapper, exit conda environment, load modules, and run bash scripts.

    $ module load fqutils/0.4.1
    $ module load bowtie2/2.2.5
    
    $ bash cleaning_bash_NEO24.sh &



After .clean.fastq has been produced, rm raw data:

    $ rm -rf NEO24lib1_S1_L001_R1_001.fastq &
    $ rm -rf NEO24lib1_S1_L002_R1_001.fastq &


Raw data will stay stored in: /archive/parchman_lab/rawdata_to_backup/NEO24/

Before barcode parsing, cat two clean fastq files into one:

    $ cat NEO_1.clean.fastq NEO_2.clean.fastq > NEO24_all.clean.fastq &


Number of reads **after** cleaning:

    $ nohup grep -c "^@" NEO24_all.clean.fastq > NEO24_all_clean_reads.txt &
    # number of clean reads : 

####################################################################################
## 2. Barcode parsing:
####################################################################################

Be sure to deactivate conda environment before running the below steps. Barcode keyfile is `NEO24_barcode_key.csv`
`
Parsing combined NEO24 fastq files:

    $ nohup perl parse_barcodes768.pl NEO24_barcode_key.csv NEO24_all.clean.fastq A00 &>/dev/null &



`NOTE`: the A00 object is the code that identifies the sequencer (first three characters after the @ in the fastq identifier).

    $ less parsereport_NEO24_all.clean.fastq 

    Good mids count: 1222139762
    Bad mids count: 60743086
    Number of seqs with potential MSE adapter in seq: 569790
    Seqs that were too short after removing MSE and beyond: 174


####################################################################################
## 3. splitting fastqs
####################################################################################

For FRLA, doing this in `/working/parchman/NEO24_fastqs/splitfastqs`

Make ids file

    $ cut -f 3 -d "," NEO24_barcode_key.csv | grep "_" > NEO24_ids_noheader.txt


Split fastqs by individual

    $ nohup perl splitFastq_universal_regex.pl NEO24_ids_noheader.txt parsed_NEO24_all.clean.fastq &>/dev/null &



# DONE TO HERE &&&&&&&&&&


Zip the parsed*fastq files

    $ nohup gzip *fastq &>/dev/null &

### syncing fastq files to Adkins directory on pronghorn:


    $ rsync -av *fastq.gz tparchman@pronghorn.rc.unr.edu:
Fastqs by species are located on ponderosa in:

FRLA1:
`/working/parchman/FRLA`

FRLA2:
`/working/parchman/FRLA`

