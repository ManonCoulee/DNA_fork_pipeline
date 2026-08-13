#!/usr/bin/env bash

## Inputs parameters
fastq=$1
fastq_trim=$2
unmarked_bam=$3
bam=$4
rev=$5
fwd=$6
file_output=$7
length=$8
quality=$9

## Count the number of reads
fastq_count=$(zcat $fastq | grep "@" | wc -l)
fastq_trim_count=$(zcat $fastq_trim | grep "@" | wc -l)

echo "FASTQ count reads (for one replicate): ${fastq_count}" > $file_output
echo "FASTQ count reads after trimming (Q > ${quality} & L > ${length}) (for one replicate): ${fastq_trim_count}" >> $file_output

unmarked_bam_count=$(samtools view -c $unmarked_bam)

echo "BAM count reads : ${unmarked_bam_count}" >> $file_output

bam_count=$(samtools view -c $bam)
mapped_count=$(samtools view -c -F 4 $bam)
unmapped_count=$(samtools view -c -f 4 $bam)

echo "BAM count reads after filtered duplicates : ${bam_count}" >> $file_output
echo "BAM count mapped reads : ${mapped_count}" >> $file_output
echo "BAM count unmapped reads : ${unmapped_count}" >> $file_output

rev_count=$(samtools view -c -F 4 $rev)
fwd_count=$(samtools view -c -F 4 $fwd)

echo "Reverse BAM count mapped reads : ${rev_count}" >> $file_output
echo "Forward BAM count mapped reads : ${fwd_count}" >> $file_output

sum_count=$((rev_count+fwd_count))

echo "Strand count mapped reads : ${sum_count}" >> $file_output