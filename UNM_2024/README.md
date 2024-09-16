# UNM GBS data processing

Library prep started on 12/14, 3.25 plates total.


Sample orientation and sample ID information illustrated in `UNM_plate_maps_working.xlsx`.


**CRITICAL NOTE: mistake made in barcode pipetting on plate 2. Row E of DNA got barcode from row D, so corrected by putting barcode from E with row D of DNA. To fix, switch sample IDs in the plate maps/barcode keys.

## Notes on cleaning NovaSeq flow cell from 12/22, barcode parsing, splitting fastqs, directory organization, and initial analyses.


We generated one lanes of S2 chemistry NovaSeq data at UTGSAF in December of 2022.



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

Being executed on ponderosa using tapioca pipeline. Commands in bash script (cleaning_bash_UNM.sh), executed as below (2/10/23). This was for one S2 NovaSeq lanes generated in December 2022.



Contam cleaning being executed on ponderosa using tapioca pipeline. Commands in bash script (cleaning_bash_RALU.sh), executed as below (12/16/22). This was for one S1 NovaSeq lanes generated in December 2022. Contaminant cleaning and barcode parsing are being done in:

    /working/parchman/UNM_ERNA/


Decompress fastq file:

    $ gunzip *fastq


Number of reads **before** cleaning:

    $ grep -c "^@" UNM_S2_L002_R1_001.fastq > UNM_ERNA_number_of_rawreads.txt

The S2 lane produced 2,397,857,739 reads.



Contaminant cleaning using tapioca steps below. On ponderosa or contorta, be sure to first deactivate the conda environment. `cleaning_bash_UNM.sh` bash script uses `bowtie` and several contaminant data bases to match reads with suspected contaminant presence and writes a clean.fastq file with those sequences removed.

    $ conda deactivate

    $ module load fqutils/0.4.1
    $ module load bowtie2/2.2.5
    
    $ nohup bash cleaning_bash_UNM.sh &>/dev/null &


After .clean.fastq has been produced, delete copy of raw data:

    $ rm -rf RALU_S1_L001_R1_001.fastq

Raw data will stay stored in: /archive/parchman_lab/rawdata_to_backup/RALU_GSAF/

Number of reads **before** cleaning:

    $ grep -c "^@" UNM_S2_L002_R1_001.fastq > UNM_ERNA_number_of_rawreads.txt

The S2 lane produced 2,397,857,739 reads.


Number of reads **after** cleaning:

    $ grep "^@" UNM_ERNA.clean.fastq -c > UNM_ERNA_No_ofcleanreads.txt &
    $ less UNM_ERNA_No_ofcleanreads.txt
    #  

After contam cleaning: 1,870,796,668 reads remain

####################################################################################
## 2. Barcode parsing:
####################################################################################

Barcode keyfile is `/working/parchman/UNM_ERNA/UNM_barcode_key.csv`

Parsing commands:

    $ nohup perl parse_barcodes768.pl UNM_barcode_key.csv UNM_ERNA.clean.fastq A00 &>/dev/null &



`NOTE`: the A00 object is the code that identifies the sequencer (first three characters after the @ in the fastq identifier).

    $ less parsereport_UNM_ERNA.clean.fastq
    Good mids count: 1764643859
    Bad mids count: 106152661
    Number of seqs with potential MSE adapter in seq: 380601
    Seqs that were too short after removing MSE and beyond: 148


Cleaning up the RALU_round2 directory:

    $ rm UNM_ERNA.clean.fastq
    $ rm miderrors_UNM_ERNA.clean.fastq
    $ rm parsereport_UNM_ERNA.clean.fastq


####################################################################################
## 3. splitting fastqs
####################################################################################

These steps are being conducted in `/working/parchman/UNM_ERNA/splitfastqs`

Make ids file 

    $ cut -f 3 -d "," UNM_barcode_key.csv | grep "_" > UNM_ERNA_ids_noheader.txt

Split fastqs by individual

    $ nohup perl splitFastq_universal_regex.pl UNM_ERNA_ids_noheader.txt parsed_UNM_ERNA.clean.fastq &>/dev/null &

    # DONE TO HERE 

************************************

Zip the parsed*fastq files for now, but delete once patterns and qc are verified:

    $ gzip parsed_UNM_ERNA.clean.fastq

Total reads for muricata, radiata, and attenuata


### Moving fastqs to project specific directories