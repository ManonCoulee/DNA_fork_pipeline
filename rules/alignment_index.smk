"""
###############################################################################
Rule for index with Bowtie2
###############################################################################
"""

rule bowtie_index:
    input:
        fasta = config["references"]["genome_fasta"]
    output:
        os.path.normpath(OUTPUT_DIR + "/tmp/{genome}/{genome}.1.bt2"),
        os.path.normpath(OUTPUT_DIR + "/tmp/{genome}/{genome}.2.bt2"),
        os.path.normpath(OUTPUT_DIR + "/tmp/{genome}/{genome}.3.bt2"),
        os.path.normpath(OUTPUT_DIR + "/tmp/{genome}/{genome}.4.bt2"),
        os.path.normpath(OUTPUT_DIR + "/tmp/{genome}/{genome}.rev.1.bt2"),
        os.path.normpath(OUTPUT_DIR + "/tmp/{genome}/{genome}.rev.2.bt2")
    params:
        genome = config["references"]["genome"],
        output_dir = os.path.normpath(OUTPUT_DIR + "/tmp/{genome}/{genome}")
    conda:
        CONDA_ENV_BOWTIE
    priority: 10
    shell:
        """
        bowtie2-build {input.fasta} {params.output_dir}
        """
