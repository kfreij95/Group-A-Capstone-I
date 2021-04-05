# Table of Contents
### [CyVerse](#cyverse)
### [SALMON](#salmon)
### [STAR](#star)
---
# [CyVerse](https://cyverse.atlassian.net/wiki/spaces/TUT/pages/258736224/RNA-seq+Tutorial-+HISAT2+StringTie+and+Ballgown)
## Getting Started
1. Upload genome file with appropriate name (ex. Rainbow trout genome name is [USDA_OmykA_1.1.fa.tar.gz](https://www.ncbi.nlm.nih.gov/assembly/GCF_013265735.2/)).
2. Upload data files to appropriate folder.
3. Use 'Uncompress with gunzip v1.6-2' app to decompress the files (*.fa.tar.gz --> *.fa)

## Align reads to reference genome
1. Properly name your analysis according to the file being analyzed (file1_HISAT2-index-align-2.1_analysis).
2. Designate an output folder for the analysis.
3. Select your input files (FASTQ files) under 'Read 1' and 'Read 2'.
4. Select 'forward-reverse' for Fragment Library Type.
5. File Type will be 'PE'.
6. Number of thread should be '4'.
7. Minimum intron length should be set to '20'.
8. Maximum intron length should be set to '500000'.
9. Click box to Report alignments tailored for transcript assemblers including StringTie.
10. Click box to Report alignments tailored for Cufflinks.
11. Minimum fragment length for valid paired-end alignments should be set to '0'.
12. Run the analysis and wait for results.

## Assemble transcripts via StringTie-1.3.3


## Merge all StringTie-1.3.3 transcripts into a single transcriptome annotation file using StringTie-1.3.3_merge


## Create Ballgown input files using StringTie-1.3.3


## Compare expression analysis using Ballgown

---
# SALMON<br>
## Download compressed folder or file
```
wget -v -O [folder.to.download.tar.gz]

or

curl [insertlinkhere]
```
## Uncompress file
```
gunzip [file1]
```
## If using a Mac, convert the needed plain text files from DOS/MAC format to Unix format
```
dos2unix [scriptfile.sh]
```
## FastQC
```
module load FastQC/0.11.7-Java-1.8.0_74
## FastQC
## Use --nogroup for >50bp reads to see every base represented instead of put in bins of 5
date
echo "Begin FastQC"
fastqc -t $SLURM_NTASKS --noextract --nogroup *fastq.gz
date
echo "Finished FastQC"
```
## 

---
# STAR<br>
## Download compressed folder
```
wget -v -O [folder.to.download.tar.gz]
```
