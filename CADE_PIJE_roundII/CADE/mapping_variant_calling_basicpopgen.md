# GBS data processing for CADE.

Starting with parsed fastq files, we are conducting de novo reference assembly and careful variant calling and filtering to evaluate if we can get more signal of spatial differentiation out of this data.


## Table of Contents

 1. Denovo Assembly
    1. Prepare Directories and Files
    2. Generate Unique Sequence Sets
    3. Assemble from Sequence Sets
 8. Mapping Reads with BWA
    1. Prepare Directories and Files
    2. Map, Sort, and Index
    3. Explanation of Script
 9. Build Mpileup with bcftools
    1. Prepare Directories
    2. Pileup, Call, and Filter
    3. Understanding bcftools Parameters
10. Convert bcf to vcf
    1. Identify SNPs
    2. Understanfing vcftools Parameters
11. Filtering
    1. Filtering on Individuals
    2. Filtering on Loci
12. Uncategorized
    1. Reference-based assembly (*T. podura*)
    2. Reheader vcf files?
13. Appendices
    1. Appendix 1: Useful Commands

## Focal Species: *Calocedrus decurrens*

## Directory Structure


* The following directory structure should be made throughout the tutorial

```mermaid
flowchart TD;
    A(personal directory <br> /working/romero/) --> B(species folder <br> /romero/KRLA/)
    B --> C(assembly)
    B --> N (select_seqs)
    B --> D(bwa)
    B --> E(fastq)
    B --> F(scripts)
    E --> G(fastq files <br> e.g. *.fastq.gz)
    C --> H(de novo assembly <br> e.g. rf.*)
    C --> I(indexed assembly files <br> e.g. *.amb, *.ann, *.bwt, *.pac, *.sa)
    C --> J(alt_assemblies <br> OPTIONAL)
    J --> K(seq subset files <br> e.g. k4.i2.seqs)
    J --> L(assembly files <br> e.g. rf.4.2.92)
    D --> M(mapped/sorted reads <br> + index files <br> e.g. *.bam and *.bam.bai)
```

## DNA extraction

* Performed by AG Biotech in 5/2022
* DNA information with plate maps and IDs can be found at []

## Library preparation

* Performed in Parchman Lab in 8/2022

## Sequencing

* 1 lane of S2 chemistry NovaSeq data at UTGSAF in 03/2023
* sequence results in /archive/parchman\_lab/rawdata\_to\_backup/KRLA/KRLA\_S1\_L001\_R1\_001.fastq.gz

## Current state:

Reads were cleaned and parsed by barcode ID in early 2024. Data we are working with here can be found at:

   `/working/parchman/CALFIRE/CADE_fastqs`

## Denovo assembly

This workflow begins with the gziped .fastq files in `/working/parchman/CALFIRE/CADE_fastqs`.

### Prepare directories and files

1. Create assembly subfolders

   ```sh
   cd ..
   mkdir assembly
   ```
   * **Number of CADE individuals:** 423

### Generate unique sequence sets

1. Make a list of individual IDs from the .fastq.gz files

   ```sh
   ls *.fastq.gz | sed -e 's/.fastq.gz//g' > namelist
   ```

   * Run this in select_seqs
   * `-e` identifies the expression for sed
   * `'s/.fastq.gz//g'` substitute occurrances of '.fast.gz` with nothing, for all occurances

2. For each individual, create a file with only the unique reads from that individual (and a count of their occurances). This will speed up future steps.

   2a. Define variables to use with awk and perl:

   ```sh
   AWK1='BEGIN{P=1}{if(P==1||P==2){gsub(/^[@]/,">");print}; if(P==4)P=0; P++}'
   AWK2='!/>/'
   PERLT='while (<>) {chomp; $z{$_}++;} while(($k,$v) = each(%z)) {print "$v\t$k\n";}'
   ```

   * The first two variables will be used in an awk command. They define the text processing commands that will be applied:
      * AWK1 defines a command that will look at every chunk of 4 lines (1 read of a fastq file). It will extract/print the first 2 lines of that chunk, and replace the beginning '@' with '>'
      * AWK2 defines a command that will ignore any lines that don't begin with '>'
   * The last variable defines a perl script that will be run later
      * The first portion loops through all the lines and stores/hashes them in `%z`, while incrementing a count for each value (effectively counting the number of times the sequence has occurred within the file)
      * The second portion iterates through the hash, and prints the count and then the sequence (tab separated)

   2b. Run the awk and perl commands:

   ```sh
   nohup cat namelist | parallel --no-notice -j 8 "zcat {}.fastq | mawk '$AWK1' | mawk '$AWK2' | perl -e '$PERLT' > {}.uniq.seqs" &> /dev/null &
   ```

3. Check that you have a *uniq.seq file for each fastq.gz file:

   ```sh
   ls *.uniq.seqs -1 | wc -l
   ```

### Assemble from sequence sets

1. Select a value of i (number of individuals a sequence occurs in) and k (number of times a sequence appears in an individual) to filter your .uniq.seqs files. This will speed up the assembly step.

   * Values are usually between 2 and 10
   * See note below on how to iteratively repeat steps 1-3 with different parameter values

2. Generate the collection of sequences that meet your i and k criteria by running the `selectContigs.sh` script. For example when k=4 and i=2:

   ```sh
   cp /working/romero/scripts/selectContigs.sh .
   nohup bash selectContigs.sh 2 2 > k2.i2.seqs &
   nohup bash selectContigs.sh 3 2 > k3.i2.seqs &
   nohup bash selectContigs.sh 3 3 > k3.i3.seqs &
   nohup bash selectContigs.sh 4 3 > k4.i3.seqs &

   ```
   * The file k2.2.seqs will contain only sequences that meet these criteria

   * Number of seqs in each file:
   ```sh
   grep ">" k2.i2.seqs -c
   23745300
   grep ">" k3.i2.seqs -c
   9688081
   grep ">" k3.i3.seqs -c
   5574095
   grep ">" k4.i3.seqs -c
   1732356
   ```
3. Use [CD-HIT](https://github.com/weizhongli/cdhit/wiki/3.-User's-Guide#user-content-CDHITEST) to create a denovo assembly from these reads, at a chosen clustering similarity threshold (c).

   ```sh
   module load cd-hit/4.6
   ```

   ```sh
   nohup cd-hit-est -i k2.i2.seqs -o CADEdenovo_k2i2c94 -M 0 -T 0 -c 0.94 &>/dev/null &

    nohup cd-hit-est -i k2.i2.seqs -o CADEdenovo_k2i2c92 -M 0 -T 0 -c 0.92 &>/dev/null &

   nohup cd-hit-est -i k3.i2.seqs -o CADEdenovo_k3i2c92 -M 0 -T 0 -c 0.92 &>/dev/null &

   nohup cd-hit-est -i k3.i2.seqs -o CADEdenovo_k3i2c94 -M 0 -T 0 -c 0.94 &>/dev/null &

   nohup cd-hit-est -i k3.i3.seqs -o CADEdenovo_k3i3c92 -M 0 -T 0 -c 0.92 &>/dev/null &

   nohup cd-hit-est -i k3.i3.seqs -o CADEdenovo_k3i3c94 -M 0 -T 0 -c 0.94 &>/dev/null &

   nohup cd-hit-est -i k4.i3.seqs -o CADEdenovo_k4i3c92 -M 0 -T 0 -c 0.92 &>/dev/null &

   nohup cd-hit-est -i k4.i3.seqs -o CADEdenovo_k4i3c94 -M 0 -T 0 -c 0.94 &>/dev/null &
   ```

   Comparing denovo clustering results from above:

   ```sh
   grep ">" CADEdenovo_k2i2c94 -c
   4064040
   grep ">" CADEdenovo_k2i2c95 -c
   4625726
   grep ">" CADEdenovo_k3i2c92 -c
   2185790
   grep ">" CADEdenovo_k3i2c94 -c
   2450479
   grep ">" CADEdenovo_k3i3c92 -c
   1441965
   grep ">" CADEdenovo_k3i3c94 -c
   1604592
   grep ">" CADEdenovo_k4i3c94 -c
   605216
      ```

   * `<inputFile>` is your file from above (`k2.i2.seqs`)
   * `<outputFile>` is the filename you want for your output. CD-HIT will generate 2 output files:
      * 1) outputFile (no extension)
      * 2) outputFile.clstr
   * `-M` is max memory allowance, 0 sets it to unlimited, default is 800M
   * `-T` is max number of threads / CPUs, 0 sets it to unlimited (32), it may be better to set it to ~16 to not take up the entire server
   * `-c` is the clustering similarity (how similar sequences need to be to be joined together)
      * 0.95 is usually a good clustering similarity to use, but you should take into account how diverged the populations or species you are studying are
      * Higher values of c create more contigs and runs faster
      * Lower values of c create fewer contigs and runs slower

# TLP to here

4. Use [bwa index](https://bio-bwa.sourceforge.net/bwa.shtml) to index our assembly into fasta format for mapping individual reads

   ```sh
   module load bwa/0.7.17-r1188
   bwa index -p CADE_ref CADEdenovo_k3i3c94
   ```

   * `-p` lets us set the prefix name that will be attached to all output assembly files. Use something descriptive of the species you are working on.
   * `-a` (optional) allows you to choose the BWT construction algorithm
      * `is` (default) usually faster but limited to databases smaller than 2GB
      * `bwtsw` for use on large databases (e.g. whole genomes)
   * `CADEdenovo_k3i3c94` is the denovo assembly from CD-HIT that I decided to go ahead with. Less contigs will speed mapping but also funnel analyses towards better loci, perhaps. 

   The result of this step should produce 5 new files named with your chosen prefix and the following extensions: `*.amb`, `*.ann`, `*.bwt`, `.pac`, `*.sa`

* **Note:** Above we describe the process for selecting one value of i, one value of k, and one value of c. If instead you would like to compare multiple assembly options, you can:

   1. Use the genContigSets.sh script to create kn.in.seqs files for many combinations, and then run each of those files through CD-HIT and compare results. However, it is difficult to interpret the number of contigs (if it is over- or under-assembled).
   2. Use refOpt.sh (what Trevor does on pronghorn), which:

      * tests parameter effects across a subset of individuals vs all individuals
      * takes about a day of processing time
      * make be feasible on ponderosa (disk space is not that big relative to this whole pipeline)
      * could give you a more in-depth understanding of things even if we decide it's not worth it on future projects

* If you do compare results from multiple combinations of parameters, it would make sense to set your <outputFile> name to include the i, k, and c parameters (like rf4.2.92 for k = 4, i = 2, and c = 0.92, this will also allow easy detection of assembly files to compare number of contigs)
* To summarize the information from different assemblies:

   ```sh
   grep "^>" rf*[0-9] -c | awk -F"[:.]" '{print $2"\t"$3"\t"$4"\t"$5}' > assemblyComparison
   less assemblyComparison
   ```

## Mapping reads to reference genome with `bwa`

   
### Prepare Directories and Files

1. Make a new directory from the species base (e.g. `.../CADE/`) called `bwa` and go into it

   ```sh
   cd ..
   mkdir bwa
   cd bwa
   ```

2. Move **indexed** assembly files into bwa directory. 

### Map, sort and index

1. Load both `bwa` and `samtools` which are required for running the mapping script

   ```sh
   module load bwa/0.7.17-r1188
   module load samtools/1.10
   ```

2. Run the script `bwa_mem2sorted_bam.sh` using the following nohup settings. Here we are calling the bash script from within the bwa directory. Note the relative paths in 

   ```sh
   nohup bash bwa_mem2sorted_bam.sh 2> /dev/null &
   ```

   * Running the script in this way prevents the process from being interrupted (i.e. you can disconnect from the server while this runs) while also capturing progress print statements in `nohup.out`. You can re-login to the server and check the progress of mapping by going into the `bwa` directory and entering the following:

      ```sh
      tail -n 1 nohup.out
      ```

   * This step took **~6 hours** using **24 nodes** on ponderosa for **93 individuals** in the POMA dataset.

### Explanation of `bwa_mem2sorted_bam.sh`

The contents of the previous script is the following:

```sh
#!/bin/bash

ctr=1
fTotal=$(ls ../fastq/*.gz -1 | wc -l)

for file in ../fastq/*.gz
   do
   if test -f "$file"
   then
      fPrefix=$(echo "$file" | sed 's|.*/||' | cut -f1 -d ".")
      echo mapping and sorting individual "$ctr" of "$fTotal"
      bwa mem -t 24 POMA_ref "$file" | \
      samtools view -u -b - | \
      samtools sort -l0 -@24 -o "$fPrefix.sorted.bam"
      ((ctr++))
   fi
done
for sBam in *.sorted.bam
   do
   if test -f "$sBam"
   then
      samtools index -@24 "$sBam"
   fi
done
```

We should explain the steps that are happening here particularly any settings used with

* `bwa mem` - maps sequences to the reference, creating a .sam file
  * `-t` - number of threads used
* `samtools view` - converts .sam format to .bam format to save space
  * `-u` - output uncompressed data
  * `-b` - output in .bam format
* `samtools sort` - sorts .bam files by position on the reference
  * `-l` - output compression level (l0) = uncompressed
  * `-@` - number of threads used (@24 = 24 threads)
  * `-o` - output file name
* `samtools index` - indexes the .bam file for faster search, creating .bai files
  * `-@` - number of threads used (@24 = 24 threads)


## Build pileup and variant call with BCFTools

### Prepare Directoties

1. Make vcf directory

   ```sh
   cd ..
   mkdir vcf
   ```

2. Make list of bam files from, do this in the `bwa/` directory

```sh
ls *.sorted.bam | sed 's/\*//' > bam_list.txt
```

### Pileup, call, and filter

1. Lets do this in the `bwa/` directory, should now have all of the .bam and .bam.bai files as well as a copy of the reference genome, and associated index files. We will use `bcftools 1.9` and run the following:
   ```sh
   module load bcftools/1.9
   ```

   ```sh
   nohup bcftools mpileup -a DP,AD,INFO/AD -C 50 -d 250 -f rf.3.2.95 -q 30 -Q 20 -I -b bam_list.txt -o CADEdenovo.bcf 2> /dev/null &
   ```

   ```sh
   bcftools call -v -m -f GQ CADEdenovo.bcf -O z -o CADEdenovo.vcf.gz
   ```



### Understanding bcftools parameters

* -C --adjust-MQ INT     adjust mapping quality; recommended:50, disable:0 [0]
* -d --max-depth INT     max per-file depth; avoids excessive memory usage [250]
* -f --fasta-ref FILE    faidx indexed reference sequence file
* -q --min-MQ INT        skip alignments with mapQ smaller than INT [0]
* -Q --min-BQ INT        skip bases with baseQ/BAQ smaller than INT [13]
* -I --skip-indels       do not perform indel calling
* -b --bam-list FILE     list of input BAM filenames, one per line
* -O --output-type TYPE  'b' compressed BCF; 'u' uncompressed BCF; 'z' compressed VCF; 'v' uncompressed VCF [v]
* -o --output FILE       write output to FILE [standard output]

# TLP stopped here, talk to Seth.
## Preview vcf to be sure that things are looking good in terms of expected number of variants in the raw .vcf. 

Once the unfiltered vcf looks good, move to variant_filtering

   ```sh
   module load vcftools/0.1.14
   ```

Using vcftools to do the bare minimum filtering, which entails removing any indels, removing loci with more than 2 alleles, thinning by 100 (because our sampled genomic regions are 100 bases in length)

   ```sh
   vcftools \
   --remove-indels \
   --min-alleles 2 \
   --max-alleles 2 \
   --thin 100 \
   --remove-filtered-all \
   --recode \
   --recode-INFO-all \
   --gzvcf POMA.vcf.gz \
   --out 
   ```

```sh
vcftools --gzvcf POMA.vcf.gz --out POMA.vcf.gz --missing-indv

```

Below we are making a list of individuals that have too much missing data to move forward with. Here we taking individuals that have data at 50% or more of loci.

```sh
   awk '$5 > 0.5 {print $1}' POMA.imiss | tail -n +2 > indmiss50.txt
```

Running vcftools to make a vcf that contains only the individuals specified in indmiss50.txt made above. First step is making the list of individuals with TOO MUCH missing data.

```sh
   awk '$5 > 0.5 {print $1}' POMA.imiss | tail -n +2 > indmiss50.txt
```

Filter the full vcf using the `--exclude` argument and the indmiss50.txt file made above.

```sh
vcftools --gzvcf POMA.vcf.gz --exclude indmiss50.txt --maf 0.04 --max-meanDP 100 --min-meanDP 2 --minQ 20 --missing .7 --recode --recode-INFO-all --remove-filter-all --out POMA.04.maxdp100.mindp2.miss70.vcf
```


### Understanding vcftools Parameters

* -v --variants-only             output variant sites only
* -c --consensus-caller          the original calling method (conflicts with -m)
* -f --format-fields <list>      output format fields: GQ,GP (lowercase allowed) []
* -p --pval-threshold <float>    variant if P(ref|D)<FLOAT with -c [0.5]
* -P --prior <float>         mutation rate (use bigger for greater sensitivity), use with -m [1.1e-3]
* -O --output-type <b|u|z|v>     output type: 'b' compressed BCF; 'u' uncompressed BCF; 'z' compressed VCF; 'v' uncompressed VCF [v]

## Filtering

### Filtering on Individuals

* **Coverage:** Also can be thought of as depth. See 3mapping. Calculated on bam files. Average read count per locus per individual.
* **Missing:** Proportion of missing data allowed across all loci for individual. Common and high in GBS/RADseq data. Kinda an issue all around. Many methods, including PCA (all ordination methods), require a complete matrix with no missing data. Additionally, PCA will cluster by missing data with individuals with higher missing data clustering closer to the center and get this "fan" effect. Can be the same for coverage too. This (among other reasons) is why people use a variance-covariance matrix of genetic data to do ordinations. Other methods involve imputation. This can be fancy and use phased haplotype data OR simply, when you z-score, (g - mean(g))/sd(g), your genotype data across each locus, you make all missing data equal to 0 or Mean (i.e., the global allele frequency). There's more to this standardization, see [Patterson et al. 2006](https://dx.plos.org/10.1371/journal.pgen.0020190) for more info. See PCAsim_ex in examples directory for showing all these issues. This is another reason to use entropy. Entropy is a hierarchical bayesian model so it gets an updated genotype estimate for each missing value based on genotype likelihoods across loci, individuals, and the allele frequency of the cluster/deme that individual assigns to.

### Filtering on Loci

* **Biallelic:** Only keep biallelic SNPs. Multiallelic SNPs are rare at the time scale we work (Citation??) and also, mathematical nightmare and we have enough data so just ignore. Everyone does unless deep time phylogenetics.
* **thin:** Keeps one locus within a specified range. Not 100% how it decides with one to keep. I think it's on quality or depth. This is a necessary step as loci in close physical are prone to sequencing error and linkage disequalibrium (LD) confounds many different population genetic parameters. For de novo reference assemblies, we thin to 100 as contigs/reads are ~92 bp in length. This keeps one locus per contig to control for LD and sequencing error, which is really common in pop gen and necessary for many analyses.
* **max-missing** = max proportion of missing data per locus
* **MAF** = minor allele frequency. Proportion of individuals a alternate allele needs to be present in order for that locus to be kept as a SNP. (e.g. maf = 0.02 for 250 individuals means that an alternate allele needs to be present in at least 5 individuals to be kept) Many papers have shown this is a big issue in clustering and demography (Citation). We do this a second time near the end if we removed individuals during missing data filtering.
* **Mean Depth:** Average allelic depth or read depth per locus. Too low could be sequencing error, too high could be PCR replication artifact (Citation).
* **Qual:** Locus Quality. You can look up the math. Usually above 20-30 is good but given our coverage and number of individuals, we can usually go way higher.
* **Fis:** Inbreeding coefficient. This is a contentous topic. This has to do with paralogs or paralogous loci. This is where loci map to multiple regions of the genome. Issues in highly repeative genomes. Usually leads to an excess of heterozygotes. Filtering on negative Fis can help. See these two McKinney papers [1](https://onlinelibrary.wiley.com/doi/10.1111/1755-0998.12763), and [2](https://onlinelibrary.wiley.com/doi/abs/10.1111/1755-0998.12613). Katie and others in the lab use his package called HDPlot to deal with this.


## Appendices

### Appendix 1: Reference of useful commands (as far as what Parchman lab people like)

* `parallel` - easiest way to run jobs in parallel across CPUs. See [GNU Parallel tutorial](https://www.gnu.org/software/parallel/parallel_tutorial.html)
* `-j` - max jobs to run in parallel
* `--no-notice` - eliminates excessive notices printing to shell when running jobs
* `:::` - followed by list of input files to process
* `nohup <command> &> /dev/null &` - a way to run a longer background process that won't be interupted
  * `nohup` - keeps process running even if shell or terminal is exited (i.e. long jobs don't get terminated)
  * `&` - process is put in background (have access to shell while process is running)
  * `/dev/null` - essentially a black hole to direct st. output from nohup into assuming you've already captured the output of interest
  * can do similar things with `screen` but `nohup` is simpler and enough for most of the use cases here
* `time <command>` - prints the time a process takes after it completes
  * will generate 3 different times, but "real" is what you're usually interested in
  * useful for testing pararmeters of parallelization and getting idea of how long different tasks in pipeline take
* `du -sch <files/dir/etc.> | tail -n 1` - way to see how much disk space a set of files is using, useful if a lot of temporary/intermediate files are being generated
* `htop` - monitor status of jobs and CPU usage (just google for details)
