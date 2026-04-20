"""
###############################################################################
Rule for basic annotation
###############################################################################
"""

rule macs2:
    input:
        trt = os.path.normpath(OUTPUT_DIR + "/Bam/{sample_name}/{sample_name}.bam"),
    output:
        os.path.normpath(OUTPUT_DIR + "/Peakcalling/{sample_name}/{sample_name}_summits.bed")
    params:
        genome = config["macs2_parameters"]["genome"],
        name = os.path.normpath("{sample_name}"),
        outdir = os.path.normpath(OUTPUT_DIR + "/Peakcalling/{sample_name}"),
        model = config["macs2_parameters"]["model"]
    resources:
	    partition="mediumq"
    conda:
        CONDA_ENV_MACS2
    shell:
        """
        macs2 -t {input.trt} -f BAMPE -g {params.genome} \
            --outdir {params.outdir} -n {params.name} {params.model}
        """  