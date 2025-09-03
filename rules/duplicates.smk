"""
###############################################################################
Rule for remove duplicates with MarkDuplicates
###############################################################################
"""

rule readgroup:
    input: 
        os.path.normpath(OUTPUT_DIR + "/Bam/{sample_name}/{sample_name}_unmarked.bam")
    output:
        os.path.normpath(OUTPUT_DIR + "/tmp/{sample_name}/{sample_name}_unmarked_RG.bam"),
    resources:
	    partition="longq",
	    mem_mb=30720,
	    time_min=10079
    conda:
        CONDA_ENV_SAMTOOLS
    shell:
        """
        samtools addreplacerg -r "@RG\tID:RG1\tSM:SampleName\tPL:Illumina\tLB:Library.fa" \
        -o {output} {input}
        """

rule markduplicates:
    input: 
        os.path.normpath(OUTPUT_DIR + "/tmp/{sample_name}/{sample_name}_unmarked_RG.bam")
    output:
        bam = os.path.normpath(OUTPUT_DIR + "/Bam/{sample_name}/{sample_name}.bam"),
        report = os.path.normpath(OUTPUT_DIR + "/Quality_Control/Duplicates/{sample_name}/{sample_name}_duplicate_metrics.txt")
    resources:
	    partition="longq",
	    mem_mb=30720,
	    time_min=10079
    conda:
        CONDA_ENV_PICARD
    shell:
        """
        picard MarkDuplicates I={input} O={output.bam} \
            M={output.report} \
            REMOVE_DUPLICATES=TRUE
        """

rule samtools_index:
    input:
        os.path.normpath(OUTPUT_DIR + "/Bam/{sample_name}/{sample_name}.bam")
    output:
        os.path.normpath(OUTPUT_DIR + "/Bam/{sample_name}/{sample_name}.bam.bai")
    resources:
	    partition="mediumq"
    conda:
        CONDA_ENV_SAMTOOLS
    shell:
        """
        samtools index {input} {output}
        """
