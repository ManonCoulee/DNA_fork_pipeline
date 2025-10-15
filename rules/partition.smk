"""
###############################################################################
Rule for counts the number of reads
###############################################################################
"""

rule partition:
    input:
        os.path.normpath(OUTPUT_DIR + "/Profiles/{sample_name}_readcounts.bed")
    output:
        os.path.normpath(OUTPUT_DIR + "/Profiles/{sample_name}_rfd.bedgraph"),
        os.path.normpath(OUTPUT_DIR + "/Profiles/{sample_name}_rfd_sm15.bedgraph"),
        os.path.normpath(OUTPUT_DIR + "/Profiles/{sample_name}_rfd_sm15.tsv")
    params:
        dir = os.path.normpath(OUTPUT_DIR + "/Profiles/"),
        sample = "{sample_name}",
        IZ = config["references"]["IZ"]
    resources:
	    partition="longq",
	    mem_mb=30720,
	    time_min=10079
    threads:
        20
    conda:
        CONDA_ENV_PARTITION
    shell:
        """
        Rscript {params.script}/partition.R {input} {params.dir} {params.sample} {params.IZ} {threads}
        """