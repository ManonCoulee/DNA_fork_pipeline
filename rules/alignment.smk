"""
###############################################################################
Rule for aligned with Bowtie2
###############################################################################
"""

rule bowtie_alignment:
    input:
        #R1 = os.path.normpath(OUTPUT_DIR + "/tmp/{sample_name}/{sample_name}_1_val_1.fq.gz"),
        #R2 = os.path.normpath(OUTPUT_DIR + "/tmp/{sample_name}/{sample_name}_2_val_2.fq.gz")
        R1 = os.path.normpath(OUTPUT_DIR + "/tmp/{sample_name}/{sample_name}_1_filtered.fq.gz"),
        R2 = os.path.normpath(OUTPUT_DIR + "/tmp/{sample_name}/{sample_name}_2_filtered.fq.gz")
    output:
        os.path.normpath(OUTPUT_DIR + "/tmp/{sample_name}/{sample_name}.sam")
    params:
        genome = config["references"]["genome"], 
        index = INDEX_DIR
    conda:
        CONDA_ENV_BOWTIE
    threads: 15
    resources:
	    partition="longq",
	    mem_mb=30720,
	    time_min=10079
    shell:
        """
        bowtie2 -p {threads} -x {params.index}/{params.genome} -S {output} \
        -1 {input.R1} -2 {input.R2} \
        --end-to-end --very-sensitive -q
        """

rule samtools_view:
    input:
        os.path.normpath(OUTPUT_DIR + "/tmp/{sample_name}/{sample_name}.sam")
    output:
        os.path.normpath(OUTPUT_DIR + "/tmp/{sample_name}/{sample_name}_unsorted.bam")
    conda:
        CONDA_ENV_SAMTOOLS
    threads: 6
    resources:
	    partition="mediumq"
    shell:
        """
        samtools view -h -b -@ {threads} -o {output} {input}
        """

rule samtools_sort:
    input:
        os.path.normpath(OUTPUT_DIR + "/tmp/{sample_name}/{sample_name}_unsorted.bam")
    output:
        os.path.normpath(OUTPUT_DIR + "/Bam/{sample_name}/{sample_name}_unmarked.bam")
    conda:
        CONDA_ENV_SAMTOOLS
    threads: 6
    resources:
	    partition="longq",
	    mem_mb=30720,
	    time_min=10079
    shell:
        """
        samtools sort -@ {threads} -o {output} {input}
        """
