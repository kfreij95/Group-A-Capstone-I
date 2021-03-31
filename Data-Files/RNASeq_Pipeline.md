##SALMON
#Download compressed folder
```
wget -v -O [folder.to.download.tar.gz]
```
#If using a Mac, convert the needed plain text files from DOS/MAC format to Unix format
```
dos2unix [scriptfile.sh]
```
#FastQC
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
#



UPDATE TO FIT CYVERSE

##STAR
