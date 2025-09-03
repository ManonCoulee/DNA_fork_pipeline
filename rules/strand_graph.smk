"""
###############################################################################
Rule for make graph representation
###############################################################################
"""
def input_igg(wildcards):
    igg = IGG_TREATMENT_COUPLE.get(wildcards.treatment_name,"")
    igg_path = os.path.normpath(OUTPUT_DIR + "/Peakcalling/" + wildcards.strand + "/" + igg + "/" + igg + ".bedgraph")
    return(igg_path)

rule seacr_strand:
    input:
        trt = os.path.normpath(OUTPUT_DIR + "/Peakcalling/{strand}/{treatment_name}/{treatment_name}.bedgraph"),
        ctl = input_igg
    output:
        os.path.normpath(OUTPUT_DIR + "/Peakcalling/{strand}/SEACR/{treatment_name}/{treatment_name}.{mode}.bed")
    params:
        mode = config["seacr_parameters"]["mode"],
        norm = config["seacr_parameters"]["normalisation"],
        out = os.path.normpath(OUTPUT_DIR + "/Peakcalling/{strand}/SEACR/{treatment_name}/{treatment_name}"),
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

rule peakannotation:
    input:
        os.path.normpath(OUTPUT_DIR + "/Peakcalling/{strand}/SEACR/{treatment_name}/{treatment_name}.{mode}.bed")
    output:
        os.path.normpath(OUTPUT_DIR + "/Peakcalling/{strand}/SEACR/{treatment_name}/{treatment_name}_{mode}_results.txt")
    params:
        outdir = os.path.normpath(OUTPUT_DIR + "/Peakcalling/{strand}/SEACR/{treatment_name}/{treatment_name}_{mode}"),
        chrsize = config["references"]["chr_size"],
        script = os.path.normpath(PIPELINE_DIR + "/scripts")
    resources:
	    partition="mediumq"
    conda:
        CONDA_ENV_ANNOTATION
    shell:
        """
        Rscript {params.script}/Peak_annotation.R {input} {params.chrsize} {params.outdir}
        """