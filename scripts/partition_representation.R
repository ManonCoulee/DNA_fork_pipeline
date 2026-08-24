####################################################################################################
## Libraries
####################################################################################################

rm(list = ls())
options(warn = -1, width = 150)

rlibs = c('ggplot2','RColorBrewer','introdataviz','dplyr','ggpubr','maditr')
invisible(lapply(rlibs, function(x) suppressMessages(library(x, character.only = TRUE))))

####################################################################################################
## Initialization
####################################################################################################

args <- commandArgs(trailingOnly=TRUE)
readcounts_path <- args[1]
outdir <- args[2]
sample <- args[3]
OK_path <- args[4]

####################################################################################################
## Initialization
####################################################################################################

print("## Initialization")

## Column with the specific value necessary to make plot
column <- c("chr","start","end","id","cpm","center","rfd_win","pos","distance","size_IZ","name")

## Create a color pattern associate to protein
pal <- c("grey50","#3993BD")
names(pal) <- c("OK-seq",sample)

theme <- theme_bw() + theme(
    strip.background  = element_blank(),
    axis.line = element_line(colour = "black"),
    text = element_text(size=30, angle = 0, color = "black"),
    panel.border = element_blank(),
    panel.grid.major = element_blank(), 
    panel.grid.minor = element_blank(),
    legend.position = "right")

####################################################################################################
## Generation of data file
####################################################################################################

print("## Generation of data file")

SCAR <- read.table(readcounts_path, sep = "\t", h = TRUE)
SCAR$name <- sample
SCAR <- SCAR[,column]

print("## Generation of OKseq file")
OK <- read.table(OK_path, sep = "\t", h = TRUE)
OK$name <- "OK-seq"
OK <- OK[,column]

table_rfd_ratio <- rbind(SCAR,OK)
table_rfd_ratio <- table_rfd_ratio[abs(table_rfd_ratio$rfd_win) > 0.0001,]
table_rfd_ratio <- table_rfd_ratio[abs(table_rfd_ratio$rfd_win) < 0.9999,]

####################################################################################################
## Profile representation
####################################################################################################

print("## Representation")
print("Profile representation")

df_ratio_table <- table_rfd_ratio %>% group_by(distance,name) %>% 
    summarise(mean_rfd = mean(rfd_win))
df_ratio_table <- df_ratio_table[!grepl("[0-9]500",df_ratio_table$distance),]

p <- ggplot(df_ratio_table,aes(x = distance/1000, y = mean_rfd, color = name)) +
    geom_line(size = 1) + 
    xlab("Distance (kb) from IZ center") + ylab(paste0(sample," partition/RFD")) +
    xlim(-100,100) + ylim(-.3,.3) + labs(color = "") +
    geom_vline(xintercept = 0, colour = "grey70", size = 0.5) +
    geom_hline(yintercept = 0, colour = "grey70", size = 0.5) +
    scale_color_manual(values = pal) +
    theme

ggsave(file.path(outdir,sample,paste0(sample,'_ratio_rfd.pdf')),plot = p, width = 10, 
    height = 8, device = 'pdf', dpi = 1200)
ggsave(file.path(outdir,sample,paste0(sample,'_ratio_rfd.svg')),plot = p, width = 10, 
    height = 8, device = 'svg')

####################################################################################################
## Correlation RFD with partition
####################################################################################################

print("Correlation RFD with partition")

rfd_matrix <- subset(table_rfd_ratio,sample %in% unique(table_rfd_ratio$name)) %>% data.frame %>%
    dcast(., id ~ name, value.var = "rfd_win", fun.aggregate = mean)
rfd_matrix_melt <- melt(rfd_matrix)
data_joint <- left_join(rfd_matrix_melt, rfd_matrix_melt, by=c("id"))
data_joint <- data_joint[data_joint$variable.x == "OK-seq",]
data_joint <- data_joint[data_joint$variable.y == sample,]
data_joint <- na.omit(data_joint)

p <- ggplot(data_joint,aes(x = value.x, y = value.y)) +
    geom_vline(xintercept = 0, colour = "grey80", size = 0.5) +
    geom_hline(yintercept = 0, colour = "grey80", size = 0.5) +
    geom_hex(bins = 100) +
    scale_fill_gradientn(colours = (brewer.pal(n=9,name="Blues")[1:8])) +
    stat_cor(method = "spearman", color = "black", size = 6) +
    geom_line(stat = "smooth", method = "lm", color = "red", size = .5) +
    coord_cartesian(xlim=c(-0.8,0.8), ylim=c(-0.8,0.8)) +
    xlab("RFD") + ylab(paste0(sample," partition")) +
    theme
    
ggsave(file.path(outdir,sample,paste0(sample,'_OKseq_correlation_SP.pdf')),plot = p, width = 8, 
    height = 6, device = 'pdf', dpi = 1200)
ggsave(file.path(outdir,sample,paste0(sample,'_OKseq_correlation_SP.svg')),plot = p, width = 8, 
    height = 6, device = 'svg')

####################################################################################################
## Boxplot comparison between leading/lagging
####################################################################################################

print("Boxplot comparison between leading/lagging")

table_rfd_ratio$fork <- "leading"
table_rfd_ratio[table_rfd_ratio$distance < 0, "fork"] <- "lagging"

pal <- c("leading" = "#3993BD","lagging" = "#1B465A")

p <- ggplot(table_rfd_ratio,aes(x = name, y = rfd_win, fill = fork)) +
    geom_hline(yintercept = 0, colour = "grey80", size = 0.5) +
    geom_boxplot(width = .5, outlier.shape = NA) +
    stat_compare_means(method = "wilcox.test",label = "p.signif") +
    xlab("") + ylab(paste0(sample," partition")) + labs(fill = "") +
    ylim(-0.6,0.6) +
    scale_fill_manual(values = pal) +
    theme + theme(legend.position = "top")

ggsave(file.path(outdir,sample,paste0(sample,'_ratio_leading_lagging.pdf')),plot = p, width = 5, 
    height = 4, device = 'pdf', dpi = 1200)
ggsave(file.path(outdir,sample,paste0(sample,'_ratio_leading_lagging.svg')),plot = p, width = 5, 
    height = 4, device = 'svg')
