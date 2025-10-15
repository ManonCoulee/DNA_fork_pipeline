"""
###############################################################################
Rule for splitting strand
###############################################################################
"""

rule read_counts_bins:
    input: 
        os.path.normpath(OUTPUT_DIR + "/Strand/{strand}/{sample_name}/{sample_name}.bam")
    output:
        os.path.normpath(OUTPUT_DIR + "/Profiles/{sample_name}_{strand}.bed")
    params:
        bins = config["references"]["bins"]
    conda:
        CONDA_ENV_DEEPTOOLS
    threads:
        15
    shell:
        """
        multiBamSummary BED-file --BED {params.bins} -b {input} --outRawCounts {output} -p {threads}
        """

    