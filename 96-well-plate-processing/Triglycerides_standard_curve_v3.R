#!/usr/bin/env Rscript

## Read in a spectrophotometer data file and plot a standard curve.
## This script specifically is written for a triglyceride assay.
## Usage: print-args.R filename conc dilution_factor


# Reading the arguments provided by the user
args <- commandArgs(trailingOnly = TRUE)
# Making sure we have the right number of arguments
if (length(args) < 3) stop ("You need to provide a filename, maximum standard concentration, and dilution factor to run this script.")

max_conc_standard <- as.numeric(args[2])
dilution_factor <- as.numeric(args[3])
# cat(args, sep = "\n")

# Reading in an .xlsx file
suppressPackageStartupMessages(library(tidyverse))
suppressPackageStartupMessages(library(readxl))
table1 <- read_excel (args[1])

# Checking if the correct wavelength was used
if (table1[42,15] != 540) stop ("Wavelength must be 540 nm for this assay.")

# Next, I need to extract the data for the standard curve.
Rep1 <- as.numeric(c(table1[42,3], table1[43,3], table1[44,3], table1[45,3], table1[46,3], table1[47,3]))
Rep2 <- as.numeric(c(table1[42,4], table1[43,4], table1[44,4], table1[45,4], table1[46,4], table1[47,4]))
Rep3 <- as.numeric(c(table1[42,5], table1[43,5], table1[44,5], table1[45,5], table1[46,5], table1[47,5]))

# Merging the three lists into 1
OD540 <- append (append (Rep1, Rep2), Rep3)

# Making the list of concentrations
Conc <- c(0, max_conc_standard, max_conc_standard/dilution_factor, 
         max_conc_standard/dilution_factor^2, 
          max_conc_standard/dilution_factor^3, 
          max_conc_standard/dilution_factor^4)

Conc_list <- append (append (Conc, Conc), Conc)

# Converting my lists to a data frame
df <- data.frame(unlist(OD540), unlist(Conc))
names(df) <- c("OD540", "Concentration")

# Carry out blank subtraction
blanks <- subset (df, Conc == 0)
blank_mean <- mean(blanks[,"OD540"])

df$Corrected_OD540 <- df$OD540 - blank_mean

# Getting the trendline equation and R2
# To get the equation, you need to first get the model coefficients
equation_nointercept <- coef(lm(df$Corrected_OD540~df$Concentration + 0))
label0 <- paste('y =', formatC(equation_nointercept[1], digits = 3, format = "f"), '* x')
equation_wintercept <- coef(lm(df$Corrected_OD540~df$Concentration))
labelwith <- paste('y =', formatC(equation_wintercept[2], digits = 3, format = "f"), '* x +', formatC(equation_wintercept[1], digits = 3, format = "f"))

#r squared
r20 <- formatC(as.numeric(summary(lm(df$Corrected_OD540~df$Concentration + 0))[8]), digits = 3, format = "f")
r2with <- formatC(as.numeric(summary(lm(df$Corrected_OD540~df$Concentration))[8]), digits = 3, format = "f")
#adjusted r squared
r20adj <- formatC(as.numeric(summary(lm(df$Corrected_OD540~df$Concentration + 0))[9]), digits = 3, format = "f")
r2withadj <- formatC(as.numeric(summary(lm(df$Corrected_OD540~df$Concentration))[9]), digits = 3, format = "f")

label0 <- paste(label0, "  R^2 =", formatC(r20, digits = 3, format = "f"), " R^2 adj =", r20adj)
labelwith <- paste(labelwith, "  R^2 =", formatC(r2with, digits = 3, format = "f"), " R^2 adj =", r2withadj)

# Plotting and getting a standard curve with equation
p <- ggplot(df, aes(x=Concentration, y=OD540)) + 
         geom_point(size=2, shape=23) +
         geom_smooth(method=lm, formula = y ~ x + 0, se=FALSE, color = "blue") +
         geom_smooth(method=lm, formula = y ~ x, se=FALSE, color = "red") +
         annotate ("text", x = 2, y = 1.75, label = label0, color = "blue") +
         annotate ("text", x = 3, y = 0.25, label = labelwith, color = "red")


# Producing a pdf of the plot
library(ggpubr)
Output_file_name <- paste0(args[1], ".pdf")
pdf(Output_file_name, height = 5, width = 7)
ggarrange(p)
dev.off()

# Output statement
cat("Model without intercept:", label0, "\n")
cat("Model with intercept:", labelwith, "\n")
if (r20 > 0.95) cat ("Looks like you have a nice standard curve.", "\n")
if (r20 < 0.95) cat ("You might want to inspect your data for outliers or possibly consider re-running the assay.")


# Checking if all data points are within the standard curve

# First extracting just the OD data and making sure the data are numbers
OD_data <- data.frame(lapply(table1[42:49, 3:14], as.numeric))

# Checking the lower end of the curve
if (any(OD_data[!is.na(OD_data)] < min(blanks$OD540)) == "TRUE") {
        cat ("Some values are outside the range of the standard curve.", "\n")
       } else {
        cat ("All sample measurements are higher than the blank.", "\n")
         }
# Checking the upper end of the curve
highest_value <- subset (df, Conc == max_conc_standard)
if (any(OD_data[!is.na(OD_data)] > max(highest_value$OD540)) == "TRUE") {
        cat ("Some values are outside the range of the standard curve.", "\n")
        } else {
          cat ("All sample measurements are lower than the most concentrated standard sample.", "\n")
        }

