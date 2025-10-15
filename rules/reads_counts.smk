"""
###############################################################################
Rule for counts the number of
###############################################################################
"""

rule read_counts_bins:
    input: 
        fwd = os.path.normpath(OUTPUT_DIR + "/Strand/forward/{sample_name}/{sample_name}.bam"),
        fwd_bai = os.path.normpath(OUTPUT_DIR + "/Strand/forward/{sample_name}/{sample_name}.bam.bai"),
        rev = os.path.normpath(OUTPUT_DIR + "/Strand/reverse/{sample_name}/{sample_name}.bam"),
        rev_bai = os.path.normpath(OUTPUT_DIR + "/Strand/reverse/{sample_name}/{sample_name}.bam.bai")
    output:
        os.path.normpath(OUTPUT_DIR + "/Profiles/{sample_name}_readcounts.bed")
    params:
        bins = config["references"]["bins"]
    conda:
        CONDA_ENV_DEEPTOOLS
    threads:
        15
    shell:
        """
        multiBamSummary BED-file --BED {params.bins} -b {input.fwd} {input.rev} --outRawCounts {output} -p {threads}
        """
