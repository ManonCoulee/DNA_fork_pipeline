"""
###############################################################################
Rule for trimming and quality filtering
###############################################################################
"""

rule cutadapt_trim:
    input:
        R1 = os.path.normpath(OUTPUT_DIR + "/tmp/{sample_name}_1.fq.gz"),
        R2 = os.path.normpath(OUTPUT_DIR + "/tmp/{sample_name}_2.fq.gz")
    output:
        R1 = os.path.normpath(OUTPUT_DIR + "/tmp/{sample_name}/{sample_name}_1_filtered.fq.gz"),
        R2 = os.path.normpath(OUTPUT_DIR + "/tmp/{sample_name}/{sample_name}_2_filtered.fq.gz")
    params:
        quality = config["cutadapt_parameters"]["quality"],
        length = config["cutadapt_parameters"]["length"],
        adapters = config["references"]["adapters"]
    threads: 6
    resources:
	    mem_mb=30720,
	    time_min=10079,
	    partition="longq"
    conda:
        CONDA_ENV_CUTADAPT
    shell:
        """
        cutadapt -a "file:{params.adapters}" -A "file:{params.adapters}" \
            -o {output.R1} -p {output.R2} \
            --length {params.length} --quality-base {params.quality} --cores {threads} \
            {input.R1} {input.R2}
        """
