"""
###############################################################################
Rule for fastq qc reports
###############################################################################
"""

rule fastq_qc:
    input:
        R1 = os.path.normpath(OUTPUT_DIR + "/tmp/{sample_name}_1.fq.gz"),
        R2 = os.path.normpath(OUTPUT_DIR + "/tmp/{sample_name}_2.fq.gz")
    output:
        os.path.normpath(OUTPUT_DIR + "/Quality_Control/Fastqc/{sample_name}/{sample_name}_1_fastqc.html"),
        os.path.normpath(OUTPUT_DIR + "/Quality_Control/Fastqc/{sample_name}/{sample_name}_1_fastqc.zip"),
        os.path.normpath(OUTPUT_DIR + "/Quality_Control/Fastqc/{sample_name}/{sample_name}_2_fastqc.html"),
        os.path.normpath(OUTPUT_DIR + "/Quality_Control/Fastqc/{sample_name}/{sample_name}_2_fastqc.zip"),
    params:
        outdir = os.path.normpath(OUTPUT_DIR + "/Quality_Control/Fastqc/{sample_name}/")
    resources:
	    partition="longq",
	    mem_mb=30720,
	    time_min=10079
    conda:
        CONDA_ENV_FASTQC
    shell:
        """
        fastqc --outdir {params.outdir} {input.R1} --quiet
        fastqc --outdir {params.outdir} {input.R2} --quiet
        """
