#!/usr/bin/env Rscript

args = commandArgs(trailingOnly = TRUE)

## Get parameters
input_file  <- args[1]
output_file <- args[2]
chromSize <- args[3]
threshold <- as.numeric(args[4])
binSize <- as.numeric(args[5])
winSize <- as.numeric(args[6])
path <- args[7]

## Launch OKseqHMM function
source(file.path(path,"OKseqHMM.R"))

print(str(winSize))
print(str(binSize))

OKseqHMM(bamfile = input_file, fileOut = output_file, 
   thresh = threshold, chrsizes = chromSize, binSize = binSize, winS = winSize)