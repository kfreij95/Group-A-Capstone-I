# RRBS Pipeline <br>
## [Bismark](https://github.com/FelixKrueger/Bismark/tree/master/Docs) <br>
The typical flow of Bismark can be found below (original User's Guide can be found via the link above): <br>
### 1. Prepare the genome by creating a path to the aligner which is either Bowtie2 (default) or HISAT2. <br>

USAGE: <br>
```
bismark_genome_preparation [options] &lt;path_to_genome_folder&gt;
```

Example: <br>
```
/bismark/bismark_genome_preparation --path_to_aligner /usr/bin/bowtie2/ --verbose /data/genomes/homo_sapiens/GRCh37/
```

### 2. Running Bismark <br>

USAGE: <br>
```
bismark [options] --genome <genome_folder> {-1 <mates1> -2 <mates2> | <singles>}
```

Example: <br>
```
bismark --genome /data/genomes/homo_sapiens/GRCh37/ test_dataset.fastq
```

Output files: <br>
<code>test_dataset_bismark_bt2.bam</code> (contains all alignments plus methylation call strings) <br>
<code>test_dataset_bismark_SE_report.txt</code> (contains alignment and methylation summary)

**NOTE:** The files being analyzed must be within the current working directory, or Bismark will not run properly.

### 3. Deduplication on Bismark

USAGE: <br>
```
deduplicate_bismark --bam [options] &lt;filenames&gt;
```

This will remove duplications within the files as only one read will be match to each position and orientation.

### 4. Methylation Extraction

USAGE: <br>
```
bismark_methylation_extractor [options] &lt;filenames&gt;
```


<p>A typical command to extract context-dependent (CpG/CHG/CHH) methylation could look like this:
<code>
bismark_methylation_extractor --gzip --bedGraph test_dataset_bismark_bt2.bam
</code></p>

This will produce three methytlation output files as well as ```bedGraph```/```coverage``` files:</p>

<ul>
<li><code>CpG_context_test_dataset_bismark_bt2.txt.gz</code>
</li>
<li><code>CHG_context_test_dataset_bismark_bt2.txt.gz</code>
</li>
<li><code>CHH_context_test_dataset_bismark_bt2.txt.gz</code>
</li>
</ul>

<ul>
<li>For <code> bedGraph </code> files: <code>bismark2bedGraph</code>
</li>
<li>For <code> coverage </code> files: <code>Import Data &gt; Bismark (cov)</code>
</li>
</ul>

This step is optional but the methylation information extracted allows for different analyses to be ran based on where the methylation occurs within the genome (strand-specific methylation) as well as filter options based on specific methylation focus (e.g., CpG islands, etc.). The ```bedGraph```/```coverage``` files can be gathered from this data or further processed to investigate genome-wide cytosine methylation reports.

### 5. Bismark Report

USAGE: <br>
```
bismark2report [options]
```

This report is generated as a graphical HTML report of the Bismark alignment, deduplication, methylation extraction (splitting) reports, and M-bias files.

### 6. Bismark Summary

USAGE: <br>
```
bismark2summary [options]
```

This command scans the current working directory for different Bismark alignment, deduplication, and methylation extraction (splitting) reports to produce a graphical summary HTML report, as well as a data table, for all files in a directory. Single sample reports are found via the ```bismark2report``` command.