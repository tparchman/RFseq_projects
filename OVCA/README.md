
## Organization and Workflow for desert bighorn (5/24) 
Organizational notes and code for one sequencing sets:
- Plates shipped from Epps lab, Rachel Crowhurst shipped in February

 ![GELIMAGE](md_images/plate_setup.jpg)

## Sample organization
- Full information on DNAs for each individual sampled across natural distribution can be found in `GitHub/RFseq_projects/OVCA/Bighorn_samples_ddRAD_pllate_map_16Feb24.xlsx`. This file also has the updated plate maps with specified IDs.

- barcode key file corresponds with CADE_FRVELib:


## Notes on library preparation


### R/L and PCR for plates 1-4. 

- Master mix in `CADE_FRVE_RFseq_mastermixcockatils.xlsx`.
- Restriction done on 1/2/24
- Ligation complete on 1/3/24
- PCR done on: 1/5/24



10 ul of each PCR product into final library. Tubes in door of freezer labelled **CADE_FRVE_LIB**.


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

    /working/parchman/OVCA/

Decompress fastq files:

    $ gunzip OC-2024_S1_L004_R1_001.fastq.gz

Number of reads **before** cleaning:

    $ nohup grep -c "^@" OC-2024_S1_L004_R1_001.fastq > OVCA_number_of_rawreads.txt &
    ## raw reads: 2,895,918,782

To run cleaning_bash* tapioca wrapper, exit conda environment, load modules, and run bash scripts.

    $ module load fqutils/0.4.1
    $ module load bowtie2/2.2.5
    
    $ bash cleaning_bash_OVCA.sh &


After .clean.fastq has been produced, moved OC-2024_S1_L004_R1_001.fastq to /backups/rawdata_to_backup/OVCA


Raw data will stay stored in: /backups/rawdata_to_backup/OVCA

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

    $ less parsereport_OVCA.clean.fastq

    Good mids count: 1946083275
    Bad mids count: 77139598
    Number of seqs with potential MSE adapter in seq: 349029
    Seqs that were too short after removing MSE and beyond: 404


####################################################################################
## 3. splitting fastqs
####################################################################################

For OVCA, doing this in `/working/parchman/OVCA/splitfastqs_OVCA/` 


Make ids file

    $ cut -f 3 -d "," OVCA_barcode_key.csv > OVCA_ids_noheader.txt


Split fastqs by individual

    $ nohup perl dash_alt_splitFastq_universal_regex.pl OVCA_ids_noheader.txt parsed_OVCA.clean.fastq &>/dev/null &



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
