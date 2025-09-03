"""
###############################################################################
Rule for trimming and quality filtering
###############################################################################
"""

rule trimagalore_trim:
    input:
        R1 = os.path.normpath(OUTPUT_DIR + "/tmp/{sample_name}_1.fq.gz"),
        R2 = os.path.normpath(OUTPUT_DIR + "/tmp/{sample_name}_2.fq.gz")
    output:
        os.path.normpath(OUTPUT_DIR + "/tmp/{sample_name}/{sample_name}_1_val_1.fq.gz"),
        os.path.normpath(OUTPUT_DIR + "/tmp/{sample_name}/{sample_name}_2_val_2.fq.gz")
    params:
        quality = config["trimgalore_parameters"]["quality"],
        length = config["trimgalore_parameters"]["length"],
	outdir = os.path.normpath(OUTPUT_DIR + "/tmp/{sample_name}")
    threads: 6
    resources:
	    partition="longq"
    conda:
        CONDA_ENV_TRIMGALORE
    shell:
        """
        trim_galore --paired --output_dir {params.outdir} \
            --quality {params.quality} --length {params.length} --cores {threads} \
            {input.R1} {input.R2}
        """
