"""
###############################################################################
Rule for splitting strand
###############################################################################
"""

rule read_counts:
    input: 
        os.path.normpath(OUTPUT_DIR + "/Strand/{strand}/{sample_name}/{sample_name}.bam")
    output:
        os.path.normpath(OUTPUT_DIR + "/Profiles/{strand}/{sample_name}/{sample_name}.bed")
    params:
        bins =
    conda:
        CONDA_ENV_DEEPTOOLS
    threads:
        15
    shell:
        """
        multiBamSummary BED-file --BED {params.bin} -b {input} --outRawCounts {output} -p {threads}
        """

