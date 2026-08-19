####################################################################################################
## Libraries
####################################################################################################

rm(list = ls())
options(warn = -1, width = 150)

rlibs = c('ggplot2','RColorBrewer','dplyr','ggpubr','introdataviz','edgeR','RIdeogram')
invisible(lapply(rlibs, function(x) suppressMessages(library(x, character.only = TRUE))))

####################################################################################################
## Initialization
####################################################################################################

args <- commandArgs(trailingOnly=TRUE)
sample <- args[1]
TE_path <- args[2]
sample_id <- args[3]
OKseq_TE_file <- args[4]
outfile <- args[5]

####################################################################################################
## Initialization
####################################################################################################

print("## Initialization")

TE <- read.table(TE_path, sep  ="\t", h = FALSE)
colnames(TE) <- c("chr","start","end","distancetoTSS","TE_strand","TE_id","TE_grp","TE_cat")
TE$id <- paste0(TE$chr,":",TE$start,"-",TE$end)

OK_TE <- read.table(OKseq_TE_file, sep = "\t", h = TRUE)

#####################################################################################################
## Data file generation
#####################################################################################################

print("## Data file generation")

TE_reads <- read.table(sample, sep = "\t", h = FALSE)
colnames(TE_reads) <- c("chr","start","end","fwd","rev")
TE_reads$id <- paste0(TE_reads$chr,":",TE_reads$start,"-",TE_reads$end)

TE_reads <- merge(TE, TE_reads[,c("id","fwd","rev")], by = "id")
TE_reads$name <- sample_id

TE_reads$ratio <- (TE_reads$rev-TE_reads$fwd)/(TE_reads$rev+TE_reads$fwd)
TE_reads$TE_size <- abs(TE_reads$start - TE_reads$end)

TE_reads$reads <- TE_reads$rev + TE_reads$fwd
TE_reads$fpkm <- TE_reads$reads / TE_reads$TE_size
TE_reads$fpkm_norm <- TE_reads$fpkm / mean(TE_reads$fpkm)

TE_reads$cpm <- (TE_reads$reads / sum(TE_reads$reads))*1000000

#####################################################################################################
## Cross relation with OKseq file TE
#####################################################################################################

TE_reads <- na.omit(TE_reads)

TE_reads$partition <- "partition+"
TE_reads[TE_reads$ratio < 0, "partition"] <- "partition-"

TE_reads$strand_dir <- "old strand"
TE_reads[TE_reads$ratio > 0 & TE_reads$TE_strand == "+","strand_dir"] <- "new strand"
TE_reads[TE_reads$ratio < 0 & TE_reads$TE_strand == "-","strand_dir"] <- "new strand"

TE_reads <- merge(TE_reads,OK_TE[,c("id","rfd","rfd_dir")], by = "id")

TE_reads$fork_dir <- "co-directional"
TE_reads[TE_reads$rfd_dir == "rfd-" & TE_reads$TE_strand == "+","fork_dir"] <- "head-on"
TE_reads[TE_reads$rfd_dir == "rfd+" & TE_reads$TE_strand == "-","fork_dir"] <- "head-on"


#####################################################################################################
## Save file
#####################################################################################################

print("## Save datafile")
write.table(outfile, x = TE_reads, quote = FALSE, row.names = FALSE, col.names = TRUE, sep = "\t")