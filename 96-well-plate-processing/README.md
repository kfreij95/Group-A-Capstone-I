# Processing 96 well plate data

Often, biological samples are processed in a 96 well plate format.  Output from these assays is typically stored in tab delineated files, .csv files, .xlsx files or similar, often containing meta data in addition to the raw data.  Thus, these raw files need to be processed, both for quality control and to extract the data for further processing. 

## 1. Spectrophotometer data - triglyceride assay
In the Riddle lab, one type of 96 well plate data generated derives from triglyceride assays that generate two output files per assay, an initial absorbance measure (IA) and a final absorbance measure (FA).  As we will have over 100 plates to process, we wanted a way to automatically carry out the QC and the reformatting of the data. Two R bash scripts were written to accomplish these goals.

This script requires the samples to be loaded into the 96 well plate in the layout shown here. 

*a) Standard curve and QC script*

*b) Data reformatting script*
