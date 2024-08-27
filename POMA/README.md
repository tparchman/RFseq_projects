
## Organization and Workflow for POMA (8/24) 
Organizational notes and code for one sequencing sets:
- 1 plus plates in the first freezer door have DNAs in order as loaded into 96 well plates. See also `plate_map.csv` 

## Sample organization
- Full information on DNAs for each individual sampled across natural distribution can be found in `GitHub/RFseq_projects/POMA/plate_map.csv`. This file also has the updated plate maps with specified IDs.

- barcode key file corresponds with POMA:


## Notes on library preparation


### R/L and PCR for plates 1-4. 

- Master mix in `PM_skipper_RFseq_mastermixcockatils.xlsx`.
- Restriction done on 5/2/24
- Ligation complete on 5/3/24
- PCR done on: 5/5/24



10 ul of each PCR product into final library. Tubes in door of freezer labelled **POMA**.


## Data analysis: contaminant cleaning, barcode parsing, data storage, directory organization, and initial analyses.

We generated two lanes of S1 chemistry NovaSeq data at UTGSAF in March of 2024. 


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

    /working/parchman/POMA/

Decompress fastq files:

    $ nohup gunzip POMA_S110_L002_R1_001.fastq.gz &
Number of reads **before** cleaning:

    $ nohup grep -c "^@" POMA_S110_L002_R1_001.fastq > POMA.txt &
    ## raw reads: 

To run cleaning_bash* tapioca wrapper, exit conda environment, load modules, and run bash scripts.

    $ module load fqutils/0.4.1
    $ module load bowtie2/2.2.5
    
    $ bash cleaning_bash_POMA.sh &


Raw data (POMA_S110_L002_R1_001.fastq) will stay stored in: /backups/rawdata_to_backup/POMA

Number of reads **after** cleaning:

    $ nohup grep -c "^@" OVCA.clean.fastq > OVCA_clean_reads.txt &
    # number of clean reads : 


####################################################################################
## 2. Barcode parsing:
####################################################################################

Be sure to deactivate conda environment before running the below steps. Barcode keyfile is `/working/parchman/OVCA/OVCA_barcode_key.csv`
`
Parsing OVCA library:

    $ nohup perl parse_barcodes768.pl OVCA_barcode_key.csv OVCA.clean.fastq A00 &>/dev/null &


    $ less parsereport_CADE_FRVE1.clean.fastq

    Good mids count: 644098458
    Bad mids count: 25913131
    Number of seqs with potential MSE adapter in seq: 197210
    Seqs that were too short after removing MSE and beyond: 190

    $ less parsereport_OVCA.clean.fastq

    Good mids count: 
    Bad mids count: 
    Number of seqs with potential MSE adapter in seq: 
    Seqs that were too short after removing MSE and beyond: 

####################################################################################
## 3. splitting fastqs
####################################################################################

For OVCA, doing this in `/working/parchman/OVCA/splitfastqs_OVCA/` 

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
