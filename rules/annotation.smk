"""
###############################################################################
Rule for basic annotation
###############################################################################
"""

def input_igg(wildcards):
    igg = IGG_TREATMENT_COUPLE.get(wildcards.treatment_name,"")
    igg_path = os.path.normpath(OUTPUT_DIR + "/Peakcalling/" + igg + "/" + igg + ".bedgraph")
    return(igg_path)

rule genomecov:
    input:
        os.path.normpath(OUTPUT_DIR + "/Bam/{sample_name}/{sample_name}.bam")
    output:
        os.path.normpath(OUTPUT_DIR + "/Peakcalling/{sample_name}/{sample_name}.bedgraph")
    resources:
	    partition="mediumq"
    conda:
        CONDA_ENV_BEDTOOLS
    shell:
        """
        bedtools genomecov -bg -ibam {input} > {output}
        """  

rule seacr:
    input:
        trt = os.path.normpath(OUTPUT_DIR + "/Peakcalling/{treatment_name}/{treatment_name}.bedgraph"),
        ctl = input_igg
    output:
        os.path.normpath(OUTPUT_DIR + "/Peakcalling/{treatment_name}/SEACR/{treatment_name}.{mode}.bed")
    params:
        mode = config["seacr_parameters"]["mode"],
        norm = config["seacr_parameters"]["normalisation"],
        out = os.path.normpath(OUTPUT_DIR + "/Peakcalling/{treatment_name}/SEACR/{treatment_name}"),
        igg_presence = config["seacr_parameters"]["igg"]
    resources:
	    partition="mediumq"
    conda:
        CONDA_ENV_SEACR
    shell:
        """
        if [ "{params.igg_presence}" ]
        then 
            bash {PIPELINE_DIR}/scripts/SEACR_1.3.sh {input.trt} {input.ctl} {params.norm} {params.mode} {params.out}
        else
            bash {PIPELINE_DIR}/scripts/SEACR_1.3.sh {input.trt} 0.05 {params.norm} {params.mode} {params.out}
        fi
        """  