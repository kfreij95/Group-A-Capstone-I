# Table of Contents
- [Cyverse](#cyverse)
- [SALMON](#salmon)
- [STAR](#star)
- [GO Expression Analysis](#go-expression-analysis)
---
# [Cyverse](https://cyverse.atlassian.net/wiki/spaces/TUT/pages/258736224/RNA-seq+Tutorial-+HISAT2+StringTie+and+Ballgown)
- [Table of Contents](#table-of-contents)
- [SALMON](#salmon)
- [STAR](#star)
- [GO Expression Analysis](#go-expression-analysis)
## Getting Started
**Purpose:** This section is to get the appropriate files ready for RNASeq analysis via Cyverse and the programs it provides.
1. Upload genome file with appropriate name (ex. rainbow trout genome name is [USDA_OmykA_1.1.fa.tar.gz](https://www.ncbi.nlm.nih.gov/assembly/GCF_013265735.2/)).
2. Upload data files to appropriate folder.
3. Files can be compressed (\*.fa.tar.gz) or uncompressed (\*.fa)

## Align reads to reference genome via HISAT2 (v2.1.0)
**Purpose:** This section will allow the user to align the FASTQ files to the reference genome for later steps.
1. Properly name your analysis according to the file being analyzed (file1_HISAT2-index-align-2.1_analysis).
2. Designate an output folder for the analysis.
3. Select your input files (FASTQ files) under 'Read 1' and 'Read 2'.
4. Select 'forward-reverse' for Fragment Library Type.
5. File Type will be 'PE'.
9. Click box to Report alignments tailored for transcript assemblers including StringTie.
10. Click box to Report alignments tailored for Cufflinks.
11. All other parameters should be set to default (i.e., do not input new values).
12. Run the analysis and wait for results.

Input: read1 fastq directory, read2 fastq directory, & genome FASTA file<br>
Output: bam_output directory

## Assemble transcripts via StringTie-1.3.3
**Purpose:** 
1. Access StringTie-1.3.3 via Apps.
2. Select bam_output directory in 'Select Input data' section.
3. Select reference annotation file (*.gtf) in 'Reference Annotation' section.
4. Run StringTie-1.3.3

Input: bam_output directory<br>
Output: gtf_files directory, StringTie_output directory (assembled transcripts, tab-delimited format for gene abundance, transcripts that match the reference annotation), ballgown_input_files directory, and logs directory

## Merge all StringTie-1.3.3 transcripts into a single transcriptome annotation file using StringTie-1.3.3_merge
**Purpose:** 
1. Access StringTie-1.3.3_merge via Apps.
2. Input gtf_out and select GTF files as the input.
3. Select reference annotation file as the above section.
4. Run analysis.

Input: gtf_out<br>
Output: logs directory, merged.out.gtf

## Create [Ballgown](https://github.com/alyssafrazee/ballgown) input files using StringTie-1.3.3
**Purpose:** This section will show how to assemble transcripts but with the consolidated annotation file from the merge step.
1. Access StringTie-1.3.3 via Apps.
2. Select options '-B, e' of StringTie-1.3.3 by clicking the boxes at the bottom of the 'analysis option' section (creates *ctab files).
3. Run analysis.

Input: merged.out.gtf<br>
Output: Ballgown_input_files 
- e_data.ctab: exon-level expression measurements.
- i_data.ctab: intron-(i.e., junction-) level expression measurements
- t_data.ctab: transcript-level expression measurements
- e2t.ctab: table with two columns, e_id and t_id, denoting which exons belong to which transcripts
- i2t.ctab: table with two columns, i_id and t_id, denoting which introns belong to which transcripts

## Compare expression analysis using Ballgown
**Purpose:** This section will show the user how to analyze differential expression at the gene, transcript, exon, and/or junction level.
1. Select Ballgown in Apps.
2. Provide a experiment design matrix file in .txt format. This file will define samples, groups, and replicates. 
3. Upload the design matrix file, Ballgown_input_files directory, and provide experimental covariate which should match column in the design matrix file.
4. Run the analysis.
5. Examine output.

Input: design matrix file, Ballgown_input_files directory<br>
Output: output directory
- Rplots.pdf - Boxplot of FPKM distribution of each smaple
- results_gene.tsv - Gene level Differential expression with no filtering
- results_gene_filter.sig.tsv - Identify genes with p value < 0.05
- results_gene_filter.tsv - Filter low-abundance genes, here we remove all genes with a variance across samples less than one
- results_trans.tsv - transcript level Differential expression with no filtering
- results_trans_filter.sig.tsv - Identify transcripts with p value < 0.05
- results_trans_filter.tsv - Filter low-abundance genes, here we remove all transcript with a variance across samples less than one

## Run Ballgown for differential gene expression and visualize in Atmosphere (or alternatively, use the DESeq2 guide below in either [SALMON](#salmon-deseq2) or [STAR](#star-deseq2)).
**Purpose:** 
1. Connect to an Atmosphere Image instance and launch it after [logging in](https://atmo.cyverse.org/application/images).
2. Click on images. Search ["Ubuntu 16_04 GUI XFCE Base v2"](https://atmo.cyverse.org/application/projects/5308/instances/33557) on the search space. Click on ["Ubuntu 16_04 GUI XFCE Base v2"](https://atmo.cyverse.org/application/projects/5308/instances/33557) image.
3. Launch application (add to existing projects if already created).
4. Select the size of the instance "tiny 2(CPU:1,Mem: 8, Disk: 60Gb)". Click on Launch instance. This will launch a instance of the image.
5. Log into Atmosphere via puTTY or Terminal and use the provided IP address and password to access your account.
6. Use the following code to create a directory to house Ballgown analysis files and download files created in above steps:
```
$ mkdir ballgown_analysis
$ iget -PVr /path/to/ballgown_input_files
$ iget -PV /path/to/design_matrix
```
7. View your files in the ballgown_input_files directory via:
```
$ ls -lh
```
8. Start a RStudio session via:
```
$ sudo apt-get update && sudo apt-get -y install gdebi-core r-base libxml2-dev
$ wget https://download2.rstudio.org/rstudio-server-1.0.136-amd64.deb
$ sudo gdebi -n rstudio-server-1.0.136-amd64.deb
$ echo My RStudio Web server is running at: http://$(hostname):8787/
```
9. Copy and paste the link into the web browser and enter Cyverse credentials to launch RStudio.
10. Start a new RScript.R and [paste the following commands for analysis](http://rpubs.com/upendra_35/466542):
```
#Set working directory
setwd("/de-app-work/")

#Install Libraries
library(ballgown)
library(ggplot2)
install.packages("gplots")
library(gplots)
library(genefilter)
library(GenomicRanges)
library(plyr)

#Read in design matrix file
pheno_data = read.table(file ="design_matrix", header = TRUE, sep = "\t")

#Create path to sample directory
sample_full_path <- paste("ballgown_input_files",pheno_data[,1], sep = '/')

#Load in ballgown data structure
bg = ballgown(samples=as.vector(sample_full_path),pData=pheno_data)

#Describe your data (number of genes and samples)

#Filter out genes. Here, we remove all transcripts with a variance across the samples of less than one.
bg_filt = subset(bg,"rowVars(texpr(bg)) >1",genomesubset=TRUE)

#Set up table for easy access to gene names
bg_table = texpr(bg_filt, 'all')
bg_gene_names = unique(bg_table[, 9:10])

#Pull gene_expression dataframe fro ballgown object.
gene_expression = as.data.frame(gexpr(bg_filt))

#View first five lines in each column of the created dataframe.
head(gene_expression)

#Change column names to sample names.
colnames(gene_expression) <- c("IS20351_DS_1_1","IS20351_DS_2_1","IS20351_DS_3_1","IS20351_WW_1_1","IS20351_WW_2_1","IS20351_WW_3_1")

#Assign colors to each. You can specify color by RGB, Hex code, or name To get a list of color names:
data_colors=c("tomato1","tomato2","tomato3","wheat1","wheat2","wheat3")

#View expression values for the transcripts of a particular gene e.g “MSTRG.27571”, then display only those rows of the data.frame
i = row.names(gene_expression) == "MSTRG.27571"
gene_expression[i,]

#What if we want to view values for a list of genes of interest all at once? e,g: “MSTRG.28956” “MSTRG.28959” “MSTRG.2896” “MSTRG.28962”
genes_of_interest = c("MSTRG.28956", "MSTRG.28959", "MSTRG.2896", "MSTRG.28962")
i = which(row.names(gene_expression) %in% genes_of_interest)
gene_expression[i,]

#Load the transcript to gene index from the ballgown object
transcript_gene_table = indexes(bg)$t2g
head(transcript_gene_table)

#Each row of data represents a transcript. Many of these transcripts represent the same gene. Determine the numbers of transcripts and unique genes
length(row.names(transcript_gene_table)) #Transcript count
length(unique(transcript_gene_table[,"g_id"])) #Unique Gene count

Plot #1 - the number of transcripts per gene.
Many genes will have only 1 transcript, some genes will have several transcripts Use the ‘table()’ command to count the number of times 
each gene symbol occurs (i.e. the # of transcripts that have each gene symbol) Then use the ‘hist’ command to create a 
histogram of these counts How many genes have 1 transcript? More than one transcript? 
What is the maximum number of transcripts for a single gene?

counts=table(transcript_gene_table[,"g_id"])
c_one = length(which(counts == 1))
c_more_than_one = length(which(counts > 1))
c_max = max(counts)
hist(counts, breaks=50, col="bisque4", xlab="Transcripts per gene", main="Distribution of transcript count per gene")
legend_text = c(paste("Genes with one transcript =", c_one), paste("Genes with more than one transcript =", c_more_than_one), paste("Max transcripts for single gene = ", c_max))
legend("topright", legend_text, lty=NULL)

Plot #2 - the distribution of transcript sizes as a histogram In this analysis we supplied StringTie with transcript models so the lengths will be those of known transcripts.
However, if we had used a de novo transcript discovery mode, this step would give us some idea of how well transcripts were being assembled.
If we had a low coverage library, or other problems, we might get short ‘transcripts’ that are actually only pieces of real transcripts
full_table <- texpr(bg , 'all').

hist(full_table$length, breaks=50, xlab="Transcript length (bp)", main="Distribution of transcript lengths", col="steelblue")


#Summarize FPKM values for all samples What are the minimum and maximum FPKM values for a particular library?
min(gene_expression[,"IS20351_DS_1_1"])
## [1] 0
max(gene_expression[,"IS20351_DS_2_1"])
## [1] 39919.22
min(gene_expression[,"IS20351_DS_3_1"])
## [1] 0
max(gene_expression[,"IS20351_WW_1_1"])
## [1] 12070.91
min(gene_expression[,"IS20351_WW_2_1"])
## [1] 0
max(gene_expression[,"IS20351_WW_3_1"])
## [1] 30315.73

#Set the minimum non-zero FPKM values for use later. Do this by grabbing a copy of all data values, 
coverting 0’s to NA, and calculating the minimum or all non NA values.
min_nonzero=1

#Set the columns for finding FPKM and create shorter names for figures
data_columns=c(1:6)
short_names=c("sen_DS_1","sen_DS_2","sen_DS_3","sen_WW_1","sen_WW_2","sen_WW_3")

Plot #3 - View the range of values and general distribution of FPKM values for all libraries Create boxplots for this purpose Display on a log2 scale and add the minimum non-zero value to avoid log2(0).

boxplot(log2(gene_expression[,data_columns]+min_nonzero), col=data_colors, names=short_names, las=2, ylab="log2(FPKM)", main="Distribution of FPKMs for all 6 libraries")
**Note:** that the bold horizontal line on each boxplot is the median

Plot #4 - plot a pair of replicates to assess reproducibility of technical replicates.
Tranform the data by converting to log2 scale after adding an arbitrary small value to avoid log2(0).

x = gene_expression[,"IS20351_DS_1_1"]
y = gene_expression[,"IS20351_DS_2_1"]
plot(x=log2(x+min_nonzero), y=log2(y+min_nonzero), pch=16, col="blue", cex=0.25, xlab="FPKM (IS20351_DS, Replicate 1)", ylab="FPKM (IS20351_DS, Replicate 2)", main="Comparison of expression values for a pair of replicates")
abline(a=0,b=1)
rs=cor(x,y)^2
legend("topleft", paste("R squared = ", round(rs, digits=3), sep=""), lwd=1, col="black")


Plot #5 - Scatter plots with a large number of data points can be misleading … regenerate this figure as a density scatter plot.
colors = colorRampPalette(c("white", "blue", "#007FFF", "cyan","#7FFF7F", "yellow", "#FF7F00", "red", "#7F0000"))
smoothScatter(x=log2(x+min_nonzero), y=log2(y+min_nonzero), xlab="FPKM (IS20351_DS, Replicate 1)", ylab="FPKM (IS20351_DS, Replicate 2)", main="Comparison of expression values for a pair of replicates", colramp=colors, nbin=200)


Compare the correlation ‘distance’ between all replicates Do we see the expected pattern for all libraries (i.e. replicates most similar, then DS vs. WW)? 
Calculate the FPKM sum for all 6 libraries.

gene_expression[,"sum"]=apply(gene_expression[,data_columns], 1, sum)
Identify the genes with a grand sum FPKM of at least 5 - we will filter out the genes with very low expression across the board
i = which(gene_expression[,"sum"] > 5)
Calculate the correlation between all pairs of data
r=cor(gene_expression[i,data_columns], use="pairwise.complete.obs", method="pearson")
r
##                IS20351_DS_1_1 IS20351_DS_2_1 IS20351_DS_3_1 IS20351_WW_1_1
## IS20351_DS_1_1      1.0000000      0.9942428      0.9840948      0.8211440
## IS20351_DS_2_1      0.9942428      1.0000000      0.9915486      0.8122250
## IS20351_DS_3_1      0.9840948      0.9915486      1.0000000      0.7987260
## IS20351_WW_1_1      0.8211440      0.8122250      0.7987260      1.0000000
## IS20351_WW_2_1      0.9775692      0.9777724      0.9772803      0.8317814
## IS20351_WW_3_1      0.9614445      0.9617983      0.9727414      0.8210495
##                IS20351_WW_2_1 IS20351_WW_3_1
## IS20351_DS_1_1      0.9775692      0.9614445
## IS20351_DS_2_1      0.9777724      0.9617983
## IS20351_DS_3_1      0.9772803      0.9727414
## IS20351_WW_1_1      0.8317814      0.8210495
## IS20351_WW_2_1      1.0000000      0.9825595
## IS20351_WW_3_1      0.9825595      1.0000000

Plot #8 - Convert correlation to ‘distance’, and use ‘multi-dimensional scaling’ to display the relative differences between libraries.
This step calculates 2-dimensional coordinates to plot points for each library Libraries with similar expression patterns (highly correlated to each other) 
should group together. What pattern do we expect to see, given the types of libraries we have (technical replicates, biologal replicates, DS/WW)?

d=1-r
mds=cmdscale(d, k=2, eig=TRUE)
par(mfrow=c(1,1))
plot(mds$points, type="n", xlab="", ylab="", main="MDS distance plot (all non-zero genes) for all libraries", xlim=c(-0.15,0.15), ylim=c(-0.15,0.15))
points(mds$points[,1], mds$points[,2], col="grey", cex=2, pch=16)
text(mds$points[,1], mds$points[,2], short_names, col=data_colors)


#Calculate the differential expression results including significance
results_genes = stattest(bg_filt, feature="gene", covariate="group", getFC=TRUE, meas="FPKM")
results_genes = merge(results_genes,bg_gene_names,by.x=c("id"),by.y=c("gene_id"))

Plot #9 - View the distribution of differential expression values as a histogram Display only those that are significant according to Ballgown.

sig=which(results_genes$pval<0.05)
results_genes[,"de"] = log2(results_genes[,"fc"])
hist(results_genes[sig,"de"], breaks=50, col="seagreen", xlab="log2(Fold change) Sen_DS vs Sen_WW", main="Distribution of differential expression values")
abline(v=-2, col="black", lwd=2, lty=2)
abline(v=2, col="black", lwd=2, lty=2)
legend("topleft", "Fold-change > 4", lwd=2, lty=2)

Plot #10 - Display the grand expression values from UHR and HBR and mark those that are significantly differentially expressed.

gene_expression[,"Sen_DS"]=apply(gene_expression[,c(1:3)], 1, mean)
gene_expression[,"Sen_WW"]=apply(gene_expression[,c(3:6)], 1, mean)
x=log2(gene_expression[,"Sen_DS"]+min_nonzero)
y=log2(gene_expression[,"Sen_WW"]+min_nonzero)
plot(x=x, y=y, pch=16, cex=0.25, xlab="Sen_DS FPKM (log2)", ylab="Sen_WW FPKM (log2)", main="Sen_DS vs Sen_WW FPKMs")
abline(a=0, b=1)
xsig=x[sig]
ysig=y[sig]
points(x=xsig, y=ysig, col="magenta", pch=16, cex=0.5)
legend("topleft", "Significant", col="magenta", pch=16)

#Write a simple table of differentially expressed transcripts to an output file Each should be significant with a log2 fold-change >= 2

sigpi = which(results_genes[,"pval"]<0.05)
sigp = results_genes[sigpi,]
sigde = which(abs(sigp[,"de"]) >= 2)
sig_tn_de = sigp[sigde,]
Order the output by or p-value and then break ties using fold-change
o = order(sig_tn_de[,"qval"], -abs(sig_tn_de[,"de"]), decreasing=FALSE)
output = sig_tn_de[o,c("gene_name","id","fc","pval","qval","de")]
write.table(output, file="SigDE.txt", sep="\t", row.names=FALSE, quote=FALSE)

#View selected columns of the first 25 lines of output
output[1:10,c(1,4,5)]
```
---
# SALMON
- [Table of Contents](#table-of-contents)
- [Cyverse](#cyverse)
- [STAR](#star)
- [GO Expression Analysis](#go-expression-analysis)
## Download compressed folder or file
```
wget -v -O [file1.tar.gz] -L linktopaste.com

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
## SALMON FastQC
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


## SALMON DESeq2


---
# STAR
- [Table of Contents](#table-of-contents)
- [Cyverse](#cyverse)
- [SALMON](#salmon)
- [GO Expression Analysis](#go-expression-analysis)
## Download compressed folder
```
wget -v -O [folder.to.download.tar.gz]
```

##


## STAR DESeq2


---
# GO Expression Analysis
- [Table of Contents](#table-of-contents)
- [Cyverse](#cyverse)
- [SALMON](#salmon)
- [STAR](#star)
## Panther Gene Ontology
1. Map your organism's genes to the human genome (or other model organism) with the biomaRt tool in RStudio like the example below:
```
if(interactive()){
human = useMart("ensembl", dataset = "hsapiens_gene_ensembl")
mouse = useMart("ensembl", dataset = "mmusculus_gene_ensembl") 
getLDS(attributes = c("hgnc_symbol","chromosome_name", "start_position"), filters = "hgnc_symbol", values = "TP53", 
mart = human, attributesL = c("chromosome_name","start_position"), martL = mouse)
}
```
2. Using the Panther Gene Ontology online tool, upload the entire gene list that meets a log2 fold change ≥ +/- 1 and q-value < 0.05. This will come from the SALMON/STAR --> HTSeq-Count --> DESeq2 pipeline or the HISAT2 --> StringTie --> Ballgown --> DESeq2 pipeline.
3. Select your model organism that you've matched in the biomaRt step.
4. Select the analysis and submit.
5. When writing your methods, inlcude the steps taken, versions used, categorical numbers, and other details to better navigate yourself and others to your results.

