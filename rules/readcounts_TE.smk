"""
###############################################################################
Rule for counts the number of reads in transposable elements
###############################################################################
"""

rule readcounts_TE:
    input: 
        fwd = os.path.normpath(OUTPUT_DIR + "/Strand/forward/{sample_name}/{sample_name}.bam"),
        fwd_bai = os.path.normpath(OUTPUT_DIR + "/Strand/forward/{sample_name}/{sample_name}.bam.bai"),
        rev = os.path.normpath(OUTPUT_DIR + "/Strand/reverse/{sample_name}/{sample_name}.bam"),
        rev_bai = os.path.normpath(OUTPUT_DIR + "/Strand/reverse/{sample_name}/{sample_name}.bam.bai")
    output:
        os.path.normpath(OUTPUT_DIR + "/Transposable_elements/{sample_name}_readcounts.bed")
    params:
        TE = config["references"]["TE"]
    resources:
        partition="longq",
	    mem_mb=30720,
	    time_min=10079
    conda:
        CONDA_ENV_DEEPTOOLS
    threads:
        15
    shell:
        """
        multiBamSummary BED-file --BED {params.TE} -b {input.fwd} {input.rev} --outRawCounts {output} -p {threads}
        """

rule enrichment_TE:
    input: 
        os.path.normpath(OUTPUT_DIR + "/Transposable_elements/{sample_name}_readcounts.bed")
    output:
        os.path.normpath(OUTPUT_DIR + "/Transposable_elements/{sample_name}_TE.tsv")
    params:
        TE = config["references"]["TE"],
        sample = os.path.normpath("{sample_name}"),
        OK_TE = config["TE"]["OKseq"],
        script = os.path.normpath(PIPELINE_DIR + "/scripts/")
    conda:
        CONDA_ENV_OKSEQ
    shell:
        """
        Rscript {params.script}/TE_enrichment.R {input} {params.TE} {params.sample} {params.OK_TE} {output}
        """
