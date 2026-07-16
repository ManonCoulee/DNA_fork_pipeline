"""
###############################################################################
Rule for transform BAM to other format
###############################################################################
"""

rule bamtobedgraph:
    input:
        os.path.normpath(OUTPUT_DIR + "/Bam/{sample_name}/{sample_name}.bam")
    output:
        os.path.normpath(OUTPUT_DIR + "/Bam/{sample_name}/{sample_name}.bedgraph")
    conda:
        CONDA_ENV_BEDTOOLS
    resources:
	    partition="mediumq"
    shell:
        """
        bedtools genomecov -bg -ibam {input} > {output}
        """ 

rule bamtoBW:
    input:
        bam = os.path.normpath(OUTPUT_DIR + "/Bam/{sample_name}/{sample_name}.bam"),
        bai = os.path.normpath(OUTPUT_DIR + "/Bam/{sample_name}/{sample_name}.bam.bai")
    output:
        os.path.normpath(OUTPUT_DIR + "/Bam/{sample_name}/{sample_name}.bw")
    conda:
        CONDA_ENV_DEEPTOOLS
    threads: 15
    resources:
	    partition="mediumq"
    shell:
        """
        bamCoverage -b {input.bam} -o {output} -p {threads}
        """

rule unmarked_bam_toBW:
    input:
        bam = os.path.normpath(OUTPUT_DIR + "/Bam/{sample_name}/{sample_name}_unmarked.bam"),
        bai = os.path.normpath(OUTPUT_DIR + "/Bam/{sample_name}/{sample_name}_unmarked.bam.bai")
    output:
        os.path.normpath(OUTPUT_DIR + "/Bam/{sample_name}/{sample_name}_unmarked.bw")
    conda:
        CONDA_ENV_DEEPTOOLS
    threads: 15
    resources:
	    partition="longq",
	    mem_mb=30720,
	    time_min=10079
    shell:
        """
        bamCoverage -b {input.bam} -o {output} -p {threads}
        """