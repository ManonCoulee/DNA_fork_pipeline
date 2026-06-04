####################################################################################################
## Libraries
####################################################################################################

rm(list = ls())
options(warn = -1, width = 150)

rlibs = c('parallel')
invisible(lapply(rlibs, function(x) suppressMessages(library(x, character.only = TRUE))))

####################################################################################################
## Initialization
####################################################################################################

args <- commandArgs(trailingOnly=TRUE)
sample <- args[1]
outdir <- args[2]
ncore <- args[3]
chrom <- args[4]

# chr_order = c("chr1","chr2","chr3","chr4","chr5","chr6","chr7","chr8","chr9","chr10","chr11",
#     "chr12","chr13","chr14","chr15","chr16","chr17","chr18","chr19","chrX","chrY")
win <- 15000

chr <- read.table(chrom, sep = "\t", h = FALSE)
chr_order <- chr$V1

####################################################################################################
## RFD 
####################################################################################################

print("## RFD calcul")

readcounts <- read.table(sample, sep = "\t", h = FALSE)
colnames(readcounts) <- c("chr","start","end","fwd","rev")
readcounts$id <- paste0(readcounts$chr,":",readcounts$start,"-",readcounts$end)
readcounts$cpm_rev <- (readcounts$rev / sum(readcounts$rev))*1000000
readcounts$cpm_fwd <- (readcounts$fwd / sum(readcounts$fwd))*1000000
readcounts$cpm <- readcounts$cpm_rev + readcounts$cpm_fwd
readcounts <- readcounts[readcounts$cpm > .3,]
readcounts$center <- (readcounts$start + readcounts$end)/2

readcounts$rfd <- (readcounts$rev - readcounts$fwd)/(readcounts$rev + readcounts$fwd)
readcounts <- na.omit(readcounts)

print("## RFD smooth calcul")

df <- lapply(chr_order, function(chr,RFD,win,ncore){
    print(chr)
    RFD <- RFD[RFD$chr == chr,]
    list_pos <- split(seq_len(nrow(RFD)),rep_len(seq_len(ncore),nrow(RFD)))
    RFD_chr <- do.call("rbind",mclapply(list_pos,function(positions,RFD,win){
        RFD[positions,"rfd_win"] <- unlist(lapply(positions,function(pos,RFD,win){
            RFD_pos <- RFD[pos,]
            RFD <- RFD[RFD$center < RFD_pos$center + win,]
            RFD <- RFD[RFD$center > RFD_pos$center - win,]
            return(mean(RFD$rfd))
        },RFD = RFD,win = win))
        return(na.omit(RFD))
    },RFD = RFD,win = win, mc.cores = ncore))
    return(RFD_chr)
},RFD = readcounts, win = win, ncore = ncore)

readcounts_sm <- do.call("rbind",df)

write.table(paste0(outdir,"_rfd_sm15.bedgraph"),x = readcounts_sm[,c(1:3,12)], sep = "\t", col.names = FALSE, row.names = FALSE, quote = FALSE)
write.table(paste0(outdir,"_rfd_sm15.tsv"),x = readcounts_sm, sep = "\t", col.names = TRUE, row.names = FALSE, quote = FALSE)

####################################################################################################
## Estimation of IZ position
####################################################################################################

print("## Estimation of IZ position")

IZ_pos <- lapply(chr_order, function(chr,RFD,win,ncore){
    print(chr)
    RFD <- RFD[RFD$chr == chr,]
    list_pos <- split(seq_len(nrow(RFD)),rep_len(seq_len(ncore),nrow(RFD)))
    IZ_chr <- do.call("rbind",mclapply(list_pos,function(positions,RFD,win){
        IZ <- do.call("rbind",lapply(positions,function(pos,RFD,win){
            RFD_pos <- RFD[pos,]
            RFD <- RFD[RFD$center < RFD_pos$center + win,]
            RFD <- RFD[RFD$center > RFD_pos$center - win,]
            rfd_max <- max(RFD$rfd_win)
            rfd_min <- min(RFD$rfd_win)
            dist_min <- sum(RFD$rfd_win < 0) * 1000
            dist_max <- sum(RFD$rfd_win > 0) * 1000
            if(rfd_max > 0 & rfd_min < 0){
                pos_start <- RFD[RFD$rfd_win == rfd_min,"start"][1]
                pos_end <- RFD[RFD$rfd_win == rfd_max,"end"][1]
                delta <- rfd_max - rfd_min
                size <- pos_end - pos_start
                return(data.frame(chr = unique(RFD$chr), start = pos_start, end = pos_end, 
                    size = size, delta = delta, rfd_min = rfd_min, rfd_max = rfd_max,
                    dist_min = dist_min,dist_max = dist_max))
            }
        },RFD = RFD,win = win))
        return(IZ)
    },RFD = RFD,win = win,mc.cores = ncore))
    return(IZ_chr)
},RFD = readcounts_sm, win = win, ncore = ncore)

IZ <- unique(do.call("rbind",IZ_pos))
IZ$center <- (IZ$start + IZ$end)/2
IZ <- IZ[IZ$size > 0,]

print("Reduce duplicated")

IZ_position <- unique(do.call("rbind",lapply(unique(IZ$chr), function(chr,RFD){
    print(chr)
    RFD <- RFD[RFD$chr == chr,]
    RFD <- RFD[order(RFD$center),]
    IZ <- do.call("rbind",lapply(1:nrow(RFD),function(pos,RFD,win){
        RFD_pos <- RFD[pos,]
        start <- RFD_pos$start - win
        end <- RFD_pos$end + win
        df <- RFD[(RFD$start >= start & RFD$start <= end) | (RFD$end >= start & RFD$end <= end),]
        return(data.frame(chr = df$chr,start = min(df$start,na.rm = TRUE), 
            end = max(df$end,na.rm = TRUE), delta = mean(df$delta)))
    },RFD = RFD,win = 3000))
    return(IZ)
},RFD = IZ)))

IZ_position$size <- abs(IZ_position$start - IZ_position$end)
IZ_position$center <- (IZ_position$start + IZ_position$end)/2
write.table(paste0(outdir,"_IZ_position_raw.bed"),x = IZ_position, sep = "\t", col.names = FALSE, row.names = FALSE, quote = FALSE)

IZ_position <- IZ_position[IZ_position$size > 10000,]
write.table(paste0(outdir,"_IZ_position_L10000.bed"),x = IZ_position, sep = "\t", col.names = FALSE, row.names = FALSE, quote = FALSE)

IZ_position <- IZ_position[IZ_position$delta > 0.1,]
write.table(paste0(outdir,"_IZ_position_L10000_D0.1.bed"),x = IZ_position, sep = "\t", col.names = FALSE, row.names = FALSE, quote = FALSE)

IZ_position <- IZ_position[IZ_position$delta > 0.2,]
write.table(paste0(outdir,"_IZ_position_L10000_D0.2.bed"),x = IZ_position, sep = "\t", col.names = FALSE, row.names = FALSE, quote = FALSE)
