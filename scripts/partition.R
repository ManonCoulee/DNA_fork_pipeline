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
readcounts_path <- args[1]
outdir <- args[2]
sample <- args[3]
IZ_path <- args[4]
ncore <- args[5]

####################################################################################################
## Initialization
####################################################################################################

print("## Initialization")
winS <- 15000
min_expression <- .3

chr_order <- c("chr1","chr2","chr3","chr4","chr5","chr6","chr7","chr8","chr9","chr10","chr11",
    "chr12","chr13","chr14","chr15","chr16","chr17","chr18","chr19","chrX","chrY")

## Generation of IZ file
IZ <- read.table(IZ_path, h = FALSE, sep = "\t")
colnames(IZ) <- c("chr","start","end","delta","size","pos")

## Generation of readcounts file
readcounts <- read.table(readcounts_path, sep = "\t", h = FALSE)
colnames(readcounts) <- c("chr","start","end","fwd","rev")
readcounts$id <- paste0(readcounts$chr,":",readcounts$start,"-",readcounts$end)
readcounts$cpm_rev <- (readcounts$rev / sum(readcounts$rev))*1000000
readcounts$cpm_fwd <- (readcounts$fwd / sum(readcounts$fwd))*1000000
readcounts$cpm <- readcounts$cpm_rev + readcounts$cpm_fwd
readcounts <- readcounts[readcounts$cpm > .3,]
readcounts$center <- (readcounts$start + readcounts$end)/2

####################################################################################################
## RFD calcul
####################################################################################################

print("## RFD calcul")

readcounts$rfd <- (readcounts$rev - readcounts$fwd)/(readcounts$rev + readcounts$fwd)

print("Generation of file")

df <- na.omit(readcounts[,c("chr","start","end","rfd")])
write.table(file.path(outdir,paste0(sample,'_rfd.bedgraph')), x = df, sep = "\t",row.names = FALSE,
    quote = FALSE, col.names = FALSE)

####################################################################################################
## Smooth RFD calcuk
####################################################################################################

print("## Smooth RFD calcul")
print(paste0("It will take time (cores used : ",ncore,")"))

chrom_table <- lapply(chr_order, function(chr,counts,win,ncore){
    print(chr)
    counts <- counts[counts$chr == chr,]
    list_pos <- split(seq_len(nrow(counts)),rep_len(seq_len(ncore),nrow(counts)))
    counts_chr <- do.call("rbind",mclapply(list_pos,function(positions,counts,win){
        counts[positions,"rfd_win"] <- unlist(lapply(positions,function(pos,RFD,win){
            counts_pos <- counts[pos,]
            counts <- counts[counts$center < counts_pos$center + win,]
            counts <- counts[counts$center > counts_pos$center - win,]
            return(mean(counts$rfd))
        },counts = counts,win = win))
        return(na.omit(counts))
    },counts = counts,win = win, mc.cores = ncore))
    return(counts_chr)
},counts = readcounts,win = winS,ncore = ncore)

readcounts_sm <- do.call("rbind",chrom_table)

####################################################################################################
## Distance from IZ
####################################################################################################

# Divide ratio_table in different group to multithreading
list_pos <- split(seq_len(nrow(readcounts_sm)),rep_len(seq_len(ncore),nrow(readcounts_sm)))

print(paste0("It will take time (cores used : ",ncore,")"))
distance <- do.call("rbind",parallel::mclapply(list_pos, function(positions,table,iz){
    distance <- do.call("rbind",lapply(positions,function(pos,table,iz){
        peak <- table[pos,]
        IZ_peak <- iz[iz$chr == peak$chr,]
        IZ_peak$distance <- peak$center - IZ_peak$pos
        IZ_peak$distance_abs <- abs(IZ_peak$distance)
        dist <- IZ_peak[IZ_peak$distance_abs == min(IZ_peak$distance_abs),"distance"]
        size <- IZ_peak[IZ_peak$distance_abs == min(IZ_peak$distance_abs),"size"]
        return(data.frame(pos = pos, distance = unique(min(dist)),size_IZ = unique(min(size))))
    },table = table, iz = iz))
    return(distance)
}, table = readcounts_sm, iz = IZ, mc.cores = ncore))

## Associated to position the distance associated
rownames(distance) <- distance$pos
distance <- distance[order(distance$pos),]
readcounts_sm <- cbind(readcounts_sm,distance)

####################################################################################################
## Generate final file
####################################################################################################

df <- na.omit(readcounts_sm[,c("chr","start","end","rfd_win")])
write.table(file.path(outdir,paste0(sample,'_rfd_sm15.bedgraph')), x = df, sep = "\t",row.names = FALSE,
    quote = FALSE, col.names = FALSE)

write.table(file.path(outdir,paste0(sample,'_rfd_sm15.tsv')), x = readcounts_sm, sep = "\t",row.names = FALSE,
    quote = FALSE, col.names = TRUE)