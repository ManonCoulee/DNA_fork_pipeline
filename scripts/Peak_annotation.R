####################################################################################################
## Libraries
####################################################################################################

rm(list = ls())
options(warn = -1, width = 150)

rlibs = c('ggplot2','svglite','GenomicRanges','ChIPseeker','ggpubr','GenomicFeatures','txdbmaker',
    'clusterProfiler','org.Mm.eg.db','TxDb.Mmusculus.UCSC.mm39.knownGene')
invisible(lapply(rlibs, function(x) suppressMessages(library(x, character.only = TRUE))))

####################################################################################################
## Initialization
####################################################################################################

args <- commandArgs(trailingOnly=TRUE)
file <- args[1]
chr_file <- args[2]
outdir <- args[3]

chr_order <- c("chr1","chr2","chr3","chr4","chr5","chr6","chr7","chr8","chr9","chr10","chr11",
  "chr12","chr13","chr14","chr15","chr16","chr17","chr18","chr19")

####################################################################################################
## File initialization
####################################################################################################

print('##### BED file initialization')
if(file.info(file)$size == 0) {
    cat("", file = paste0(outdir,"_results.txt"))
    message("BED file is empty")
    quit(save = "no", status = 0)
}
bed_file <- read.table(file.path(file), h = F, sep = '\t', stringsAsFactors = F)
colnames(bed_file) <- c("chr","start","end","total_signal","max_signal","max_signal_region")
## Remove chromosome exogene and XY and MT chromosome
bed_file$chr <- factor(bed_file$chr,levels = chr_order)
bed_file <- na.omit(bed_file)

if(nrow(bed_file) == 0) {
    cat("", file = paste0(outdir,"_results.txt"))
    message("BED file is empty")
    quit(save = "no", status = 0)
}

print('##### CHR file initialization')
chr_size = read.table(chr_file, h = F, sep = '\t')
colnames(chr_size) <- c("chr","length")
chr_size$chr <- factor(chr_size$chr,levels = chr_order)
chr_size <- na.omit(chr_size)

txmm <- TxDb.Mmusculus.UCSC.mm39.knownGene

####################################################################################################
## Quality control analysis
####################################################################################################

print("##### Quality control")

## Distribution of peak in chromosome
chr_peak  <- as.data.frame(table(bed_file$chr))
colnames(chr_peak) <- c("chr","nb_peak")
distribution <- merge(chr_peak,chr_size,by = "chr")
distribution$ratio <- distribution$nb_peak/distribution$length*100000 ## 10-5


print(paste0(outdir,"_peak_per_chr.png"))
print(head(distribution))

png(paste0(outdir,"_peak_per_chr.png"), width = 3000)
ggplot(distribution, aes(x = chr,y = ratio)) +
    geom_bar(stat = "identity") +
    scale_x_discrete(labels = chr_order) +
    ggtitle(paste0("Distribution of peak (n=",nrow(bed_file),")")) +
    xlab("") + ylab("nb peaks/chr length") +
    theme_bw() + theme(strip.background  = element_blank(),
    text = element_text(size=30, angle = 0, color = "black"),
    panel.grid.major = element_line(colour = "grey80"),
    panel.border = element_blank(),
    axis.ticks = element_blank(),
    panel.grid.minor.x=element_blank(),
    panel.grid.major.x=element_blank(),
    legend.position = "none")
dev.off()

# Ditribution peak size
bed_file$peak_length = abs(bed_file$end - bed_file$start)
png(paste0(outdir,"_peak_size_per_chr.png"), width = 2000)
ggplot(bed_file, aes(x = chr,y = peak_length)) +
    geom_violin(trim = FALSE, outlier.shape = NA) +
    geom_boxplot(width = 0.1, outlier.shape = NA) +
    scale_x_discrete(labels = chr_order) +
    ggtitle("Size of peak") +
    xlab("") + ylab("peak size (bp)") +
    theme_bw() + theme(strip.background  = element_blank(),
    text = element_text(size=30, angle = 0, color = "black"),
    panel.grid.major = element_line(colour = "grey80"),
    panel.border = element_blank(),
    axis.ticks = element_blank(),
    panel.grid.minor.x=element_blank(),
    panel.grid.major.x=element_blank(),
    legend.position = "none")
dev.off()

png(paste0(outdir,"_peak_size.png"), width = 1000)
ggplot(bed_file, aes(x = peak_length)) +
    geom_density(alpha = .1) +
    ggtitle("Size of peak") +
    xlab("peak size (bp)") + ylab("%") +
    theme_bw() + theme(strip.background  = element_blank(),
    text = element_text(size=30, angle = 0, color = "black"),
    panel.grid.major = element_line(colour = "grey80"),
    panel.border = element_blank(),
    axis.ticks = element_blank(),
    panel.grid.minor.x=element_blank(),
    panel.grid.major.x=element_blank(),
    legend.position = "none")
dev.off()

####################################################################################################
## Annotation analysis
####################################################################################################

print("##### Annotation")
peakfile <- makeGRangesFromDataFrame(bed_file, keep.extra.columns = TRUE)
peak_annotate <- annotatePeak(peakfile, tssRegion = c(-3000,3000), TxDb = txmm, annoDb = "org.Mm.eg.db")
peak_anno <- as.data.frame(peak_annotate@anno)
peak_anno$annotation_reduce <- "Intragenic"
peak_anno[grepl("Downstream",peak_anno$annotation),"annotation_reduce"] <- "Downstream"
peak_anno[grepl("Promoter",peak_anno$annotation),"annotation_reduce"] <- "Promoter"
peak_anno[grepl("Distal",peak_anno$annotation),"annotation_reduce"] <- "Distal Intergenic"

write.table(peak_anno,paste0(outdir,"_peak_annotate.txt"),sep = '\t',quote = FALSE,
   col.names = TRUE, row.names = FALSE)

# Summary
print("##### Summary")
cat(paste0("Number of annotate peaks: ",peak_annotate@peakNum), file = paste0(outdir,"_results.txt"), sep = "\n")
cat(paste0("Number of gene ENSEMBL : ", length(unique(peak_anno$ENSEMBL))), file = paste0(outdir,"_results.txt"), append = TRUE, sep = "\n")

df_anno <- data.frame(table(peak_anno$annotation_reduce))
colnames(df_anno) <- c("type_annotation","nb_peak")
df_anno$percentage <- round(df_anno$nb_peak/peak_annotate@peakNum*100,2)

cat("Number of peak in each annotation category:", file = paste0(outdir,"_results.txt"), append = TRUE, sep = "\n")
write.table(df_anno,paste0(outdir,"_results.txt"),sep = '\t',quote = FALSE,
   col.names = TRUE, row.names = FALSE, append = TRUE)


png(paste0(outdir,"_peak_annotate.png"),width = 2000)
ggplot(df_anno,aes(x = "", y = nb_peak, fill = type_annotation)) +
    geom_bar(stat = "identity", position = position_fill()) +
    coord_polar("y", start=0) + ylab("") + xlab("") +
    scale_fill_manual(values = c("#B2BABB","#BB8FCE","#E67E22","#2980B9")) +
    theme_minimal() +
    theme(text = element_text(size = 40),legend.position = "bottom",legend.title = element_blank(),
      axis.text.x = element_blank()) +
    guides(fill = guide_legend(nrow=2, byrow = T))
dev.off()