#!/usr/bin/env Rscript

## Read in a spectrophotometer data file and process the data.
## This script specifically is written for a triglyceride assay.
## It will read in the file, calculate the glycerol and triglyceride
## concentration and write the sample data to a master file. 
## Note, it appends the file!!!
## Usage: print-args.R filename1 filename2 conc dilution_factor
## The filenames are formatted as follows "MMDDYYYY_Line#_Treatment_Measurement-type.xlsx"


# Reading the arguments provided by the user
args <- commandArgs(trailingOnly = TRUE)
# Making sure we have the right number of arguments
if (length(args) < 4) stop ("You need to provide two filenames, maximum standard concentration, and dilution factor to run this script.")

file_name1 <- args[1]
file_name2 <- args[2]
max_conc_standard <- as.numeric(args[3])
dilution_factor <- as.numeric(args[4])
# cat(args, sep = "\n")

# Retrieving the sample information from the first file name.
sample_info1 <- strsplit(file_name1, "_")
assay_date1 <- sample_info1 [[1]][1]
line_number1 <- sample_info1 [[1]][2]
treatment1 <- sample_info1 [[1]][3]
measurement1 <- strsplit(unlist(sample_info1 [[1]][4]), "[.]")[[1]][1]

# Retrieving the sample information from the second file name.
sample_info2 <- strsplit(file_name2, "_")
assay_date2 <- sample_info2 [[1]][1]
line_number2 <- sample_info2 [[1]][2]
treatment2 <- sample_info2 [[1]][3]
measurement2 <- strsplit(unlist(sample_info2 [[1]][4]), "[.]")[[1]][1]

# Making sure we have two matching files.
if (assay_date1 != assay_date2) stop ("These files are from different dates.  Are you sure they are a matching pair?")
if (line_number1 != line_number2) stop ("These files are from different genotypes.  You need to upload 2 matching files with IA and FA data from the same samples.")
if (treatment1 != treatment2) stop ("These files contain different samples.  You need to upload 2 matching files with IA and FA data from the same samples.")
if ((measurement1 == "IA") & (measurement2 == "FA")) {
    cat ("We've got the correct file types.")
    } else {
      stop ("Please restart.  We need two matching file types, the first providing initial measurements (IA), the second final measurements (FA).")
    }


# Reading in the two .xlsx file
suppressPackageStartupMessages(library(tidyverse))
suppressPackageStartupMessages(library(readxl))
table1 <- read_excel (file_name1)
table2 <- read_excel (file_name2)

# Checking if the correct wavelength was used
if (table1[42,15] != 540) stop ("Wavelength must be 540 nm for this assay. Please check file 1.")
if (table2[42,15] != 540) stop ("Wavelength must be 540 nm for this assay. Please check file 2.")


## Organizing the data from the standards

# Next, I need to extract the data for the standard curve.
Rep1.1 <- as.numeric(c(table1[42,3], table1[43,3], table1[44,3], table1[45,3], table1[46,3], table1[47,3]))
Rep1.2 <- as.numeric(c(table1[42,4], table1[43,4], table1[44,4], table1[45,4], table1[46,4], table1[47,4]))
Rep1.3 <- as.numeric(c(table1[42,5], table1[43,5], table1[44,5], table1[45,5], table1[46,5], table1[47,5]))

Rep2.1 <- as.numeric(c(table2[42,3], table2[43,3], table2[44,3], table2[45,3], table2[46,3], table2[47,3]))
Rep2.2 <- as.numeric(c(table2[42,4], table2[43,4], table2[44,4], table2[45,4], table2[46,4], table2[47,4]))
Rep2.3 <- as.numeric(c(table2[42,5], table2[43,5], table2[44,5], table2[45,5], table2[46,5], table2[47,5]))

# Merging the three lists into 1
OD540.1 <- append (append (Rep1.1, Rep1.2), Rep1.3)
OD540.2 <- append (append (Rep2.1, Rep2.2), Rep2.3)

# Making the list of concentrations
Conc <- c(0, max_conc_standard, max_conc_standard/dilution_factor, 
         max_conc_standard/dilution_factor^2, 
          max_conc_standard/dilution_factor^3, 
          max_conc_standard/dilution_factor^4)

Conc_list <- append (append (Conc, Conc), Conc)

# Converting my lists to a data frame
df1 <- data.frame(unlist(OD540.1), unlist(Conc))
names(df1) <- c("OD540", "Concentration")
df2 <- data.frame(unlist(OD540.2), unlist(Conc))
names(df2) <- c("OD540", "Concentration")

# Carry out blank subtraction
blanks1 <- subset (df1, Conc == 0)
blank_mean1 <- mean(blanks1[,"OD540"])

blanks2 <- subset (df2, Conc == 0)
blank_mean2 <- mean(blanks2[,"OD540"])

df1$Corrected_OD540 <- df1$OD540 - blank_mean1
df2$Corrected_OD540 <- df2$OD540 - blank_mean2


## Processing of the sample data

# First extracting just the OD data and making sure the data are numbers
OD_data1 <- data.frame(lapply(table1[42:49, 3:14], as.numeric))
OD_data2 <- data.frame(lapply(table2[42:49, 3:14], as.numeric))

## OD_data has all the data - I will need to extract just the sample data
# Grabbing the parts of the table that I need
Group1 <- OD_data1[7:8, 1:3]
Group2 <- OD_data1[1:8, 4:6]
Group3 <- OD_data1[1:8, 7:9]
Group4 <- OD_data1[1:2, 10:12]
# Making the column names the same so I can merge the parts
colnames(Group2) <- colnames(Group1)
colnames(Group3) <- colnames(Group1)
colnames(Group4) <- colnames(Group1)

# Merging the parts
Sample_data1 <- rbind(rbind(rbind(Group1, Group2), Group3), Group4)
# Naming our columns
Sample_data1 <- Sample_data1 %>% 
  rename(
    Replicate1 = ...3,
    Replicate2 = ...4,
    Replicate3 = ...5
  )
#colnames(Sample_data)

# Next, I need to append the sample ID info
Sample_data1$Line <- line_number1
Sample_data1$Assay_date <- assay_date1
Sample_data1$Treatment <- treatment1
Sample_data1$Sex <- c(rep("F", 10), rep("M", 10))
Sample_data1$Location_plate <- c("G1-3", "H1-3", "A4-6", "B4-6", "C4-6",
                                 "D4-6", "E4-6", "F4-6", "G4-6", "H4-6", 
                                 "A7-9", "B7-9", "C7-9", "D7-9", "E7-9", 
                                 "F7-9", "G7-9", "H7-9", "A10-12", "B10-12")


# Moving things around, so that the reps are each their own line rather than columns
Sample_data1.2 <- pivot_longer(Sample_data1, cols=c(Replicate1, Replicate2, Replicate3), names_to = "Replicate", values_to = "OD540_IA")

# Next, I need to do the blank subtraction.
Sample_data1.2$adjOD540_IA <- Sample_data1.2$OD540_IA - blank_mean1

# Getting the second (FA) dataset to the same point.
rm(Group1, Group2, Group3, Group4)
# Grabbing the parts of the table that I need
Group1 <- OD_data2[7:8, 1:3]
Group2 <- OD_data2[1:8, 4:6]
Group3 <- OD_data2[1:8, 7:9]
Group4 <- OD_data2[1:2, 10:12]
# Making the column names the same so I can merge the parts
colnames(Group2) <- colnames(Group1)
colnames(Group3) <- colnames(Group1)
colnames(Group4) <- colnames(Group1)

# Merging the parts
Sample_data2 <- rbind(rbind(rbind(Group1, Group2), Group3), Group4)
# Naming our columns
Sample_data2 <- Sample_data2 %>% 
  rename(
    Replicate1 = ...3,
    Replicate2 = ...4,
    Replicate3 = ...5
  )

# Next, I need to append the sample ID info
Sample_data2$Line <- line_number2
Sample_data2$Assay_date <- assay_date2
Sample_data2$Treatment <- treatment2
Sample_data2$Sex <- c(rep("F", 10), rep("M", 10))
Sample_data2$Location_plate <- c("G1-3", "H1-3", "A4-6", "B4-6", "C4-6",
                                 "D4-6", "E4-6", "F4-6", "G4-6", "H4-6", 
                                 "A7-9", "B7-9", "C7-9", "D7-9", "E7-9", 
                                 "F7-9", "G7-9", "H7-9", "A10-12", "B10-12")


# Moving things around, so that the reps are each their own line rather than columns
Sample_data2.2 <- pivot_longer(Sample_data2, cols=c(Replicate1, Replicate2, Replicate3), names_to = "Replicate", values_to = "OD540_FA")

# Next, I need to do the blank subtraction.
Sample_data2.2$adjOD540_FA <- Sample_data2.2$OD540_FA - blank_mean2

# Next, I need to get the IA and FA measurements into the samee data frame.
Sample_data_all <- Sample_data1.2
Sample_data_all$OD540_FA <- Sample_data2.2$OD540_FA
Sample_data_all$adjOD540_FA <- Sample_data2.2$adjOD540_FA


# Calculating the glyerol concentration from IA
# Measurement for the 2.5 standard
standard2.5_df1 <- subset (df1, Conc == 2.5)
standard2.5_IA <- mean(standard2.5_df1[,"Corrected_OD540"])
Sample_data_all$glycerol_conc <- Sample_data_all$adjOD540_IA/standard2.5_IA*2.5

# Calculating the triglyceride concentration from IA and FA
standard2.5_df2 <- subset (df2, Conc == 2.5)
standard2.5_FA <- mean(standard2.5_df2[,"OD540"])
Sample_data_all$triglyceride_conc <- (Sample_data_all$OD540_FA - (Sample_data_all$OD540_IA*0.8))/(standard2.5_FA - (blank_mean1*0.8)) * 2.5


# Writing the complete dataframe to a  file. 
write.table(Sample_data_all, "Triglyceride_data_all.csv", row.names = FALSE, col.names=!file.exists("Triglyceride_data_all.csv"), sep = ",", append = TRUE)



