# Processing 96 well plate data

Often, biological samples are processed in a 96 well plate format.  Output from these assays is typically stored in tab delineated files, .csv files, .xlsx files or similar, often containing meta data in addition to the raw data.  Thus, these raw files need to be processed, both for quality control and to extract the data for further processing. 

## 1. Spectrophotometer data - triglyceride assay
In the Riddle lab, one type of 96 well plate data generated derives from triglyceride assays that generate two output files per assay, an initial absorbance measure (IA) and a final absorbance measure (FA).  As we will have over 100 plates to process, we wanted a way to automatically carry out the QC and the reformatting of the data. Two R bash scripts were written to accomplish these goals.

This script requires the samples to be loaded into the 96 well plate in the layout shown 
[here.](https://github.com/kfreij95/Group-A-Capstone-I/blob/ec68855cb80191af494c2502e7c40538321b8153/96-well-plate-processing/Layout.xlsx)

*a) Standard curve and QC script*
This R script generates a standard curve and carries out some QC assessments.  The script can be found 
[here.](https://github.com/kfreij95/Group-A-Capstone-I/blob/ec68855cb80191af494c2502e7c40538321b8153/96-well-plate-processing/Triglycerides_standard_curve_v3.R)

*b) Data reformatting script*
This R script extracts the raw data from the IA and FA data files, reformats the data, calculates glycerol and triglyceride concentration for each sample and appends it to a master data file.  The script can be found 
[here.](https://github.com/kfreij95/Group-A-Capstone-I/blob/ec68855cb80191af494c2502e7c40538321b8153/96-well-plate-processing/Analysis_script.R)
