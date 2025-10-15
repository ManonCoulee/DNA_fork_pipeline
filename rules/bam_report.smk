"""
###############################################################################
Rule for report summary
###############################################################################
"""

rule reports:
    input:
        fastq = os.path.normpath(OUTPUT_DIR + "/tmp/{sample_name}_1.fq.gz"),
        trim = os.path.normpath(OUTPUT_DIR + "/tmp/{sample_name}/{sample_name}_1_filtered.fq.gz"),
        bam = os.path.normpath(OUTPUT_DIR + "/Bam/{sample_name}/{sample_name}_unmarked.bam"),
        trim_bam = os.path.normpath(OUTPUT_DIR + "/Bam/{sample_name}/{sample_name}.bam"),
        rev = os.path.normpath(OUTPUT_DIR + "/Strand/reverse/{sample_name}/{sample_name}.bam"),
        fwd = os.path.normpath(OUTPUT_DIR + "/Strand/forward/{sample_name}/{sample_name}.bam")
    output:
        os.path.normpath(OUTPUT_DIR + "/Quality_Control/Reports/{sample_name}/{sample_name}_summary_reports.txt")
    params:
        length = config["cutadapt_parameters"]["length"],
        quality = config["cutadapt_parameters"]["quality"]
    resources:
	    partition="longq",
	    mem_mb=30720,
	    time_min=10079
    conda:
        CONDA_ENV_SAMTOOLS
    shell:
        """
        bash {PIPELINE_DIR}/scripts/summary_read_count.sh {input.fastq} \
        {input.trim} {input.bam} {input.trim_bam} {input.rev} {input.fwd} {output} {params.length} \
        {params.quality}
        """
