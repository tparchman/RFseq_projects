
## Organization and Workflow for GBS of Eriogunum umbellatum 
Organizational notes and code for two sequencing sets:
8 plates, from Ag Bio

## Sample organization
- Full information on DNAs for each individual sampled across natural distribution can be found in `GitHub/RFseq_projects/ERUM/barcode_files`. 

- barcode key file: `ERUM_barcode_key.csv`


## Notes on library preparation


### R/L and PCR for plates 1-4. 

- Master mix in `ERUM_RFseq_mastermixcockatils.xlsx`.




10 ul of each PCR product into final library. Tubes in door of freezer labelled **ERUM24_LIB**.


## Data analysis: contaminant cleaning, barcode parsing, data storage, directory organization, and initial analyses.

We generated two lanes of S1 chemistry NovaSeq data at UTGSAF in June of 2024. 


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

Being executed on ponderosa using tapioca pipeline. Commands in two bash scripts (cleaning_bash_CADE_FRVE.sh), executed as below (4/12/24). This work being carried out at:

    /working/parchman/ERUM/

Decompress fastq files:

    $ gunzip ERMU24lib_S1_L001_R1_001.fastq.gz
    $ ERMU24lib_S1_L002_R1_001.fastq.gz

Number of reads **before** cleaning:

    $ nohup grep -c "^@" ERMU24lib_S1_L001_R1_001.fastq > L001_number_of_rawreads.txt &
    ## raw reads: 

    $ nohup grep -c "^@" ERMU24lib_S1_L002_R1_001.fastq > L002_number_of_rawreads.txt &
    ## raw reads: 
To run cleaning_bash* tapioca wrapper, exit conda environment, load modules, and run bash scripts.

    $ module load fqutils/0.4.1
    $ module load bowtie2/2.2.5
    
    $ nohup bash cleaning_bash_ERUM.sh &


Raw data will stay stored in: /archive/parchman_lab/rawdata_to_backup/ERUM/

Number of reads **after** cleaning:

    $ nohup grep -c "^@" ERUM1.clean.fastq > ERUM1_clean_reads.txt &
    # number of clean reads : 

    $ nohup grep -c "^@" ERUM1.clean.fastq > ERUM2_clean_reads.txt &
    # number of clean reads : 

####################################################################################
## 2. Barcode parsing:
####################################################################################

Be sure to deactivate conda environment before running the below steps. Barcode keyfiles are `/working/parchman/ERUM/ERUM_barcode_key.csv`
`
Parsing CADE_FRVE1 library:

    $ nohup perl parse_barcodes768.pl ERUM_barcode_key.csv ERUM1.clean.fastq A00 &>/dev/null &

Parsing CADE_FRVE2 library:

    $ nohup perl parse_barcodes768.pl ERUM_barcode_key.csv ERUM2.clean.fastq A00 &>/dev/null &

`NOTE`: the A00 object is the code that identifies the sequencer (first three characters after the @ in the fastq identifier).

    $ less parsereport_CADE_FRVE1.clean.fastq

    Good mids count: 644098458
    Bad mids count: 25913131
    Number of seqs with potential MSE adapter in seq: 197210
    Seqs that were too short after removing MSE and beyond: 190

    $ less parsereport_CADE_FRVE2.clean.fastq

    Good mids count: 668825901
    Bad mids count: 47552067
    Number of seqs with potential MSE adapter in seq: 648922
    Seqs that were too short after removing MSE and beyond: 4257

####################################################################################
## 3. splitting fastqs
####################################################################################

For FRLA, doing this in `/working/parchman/CADE_FRVE/splitfastqs_CADE_FRVE/` 

Concatenate the two parsed_*fastq files:

    $ nohup cat parsed_CADE_FRVE1.clean.fastq parsed_CADE_FRVE2.clean.fastq > cat_parsed_CADE_FRVE12.clean.fastq &>/dev/null &

Make ids file

    $ cut -f 3 -d "," CADE_FRVE_barcode_info_2018.csv | grep "[A-Z]" > CADE_FRVE_ids_noheader.txt


Split fastqs by individual

    $ nohup perl splitFastq_universal_regex.pl CADE_FRVE_ids_noheader.txt cat_CADE_FRVE_1and2.fastq &>/dev/null &



# DONE TO HERE &&&&&&&&&&


Zip the parsed*fastq files for now, but delete once patterns and qc are verified.

### Moving fastqs to project specific directories

Fastqs by species are located on ponderosa in:

CASDEN:
`/working/parchman/CADE_FRVE/splitfastqs_CADE_FRVE/CASDEN`

FRVE:
`/working/parchman/CADE_FRVE/splitfastqs_CADE_FRVE/FRVE`

TROUT
`/working/parchman/CADE_FRVE/splitfastqs_CADE_FRVE/TROUT`
