"""
###############################################################################
Rule for OKseq HMM and RFD annotation
###############################################################################
"""

rule okseqhmm:
    input:
        bam = os.path.normpath(OUTPUT_DIR + "/Bam/{sample_name}/{sample_name}.bam"),
        bai = os.path.normpath(OUTPUT_DIR + "/Bam/{sample_name}/{sample_name}.bam.bai")
    output:
        os.path.normpath(OUTPUT_DIR + "/OKseqHMM/{sample_name}/{sample_name}_RFD_cutoff{thresh}_bs{bin_size}_sm_{win_s}kb.bedgraph")
    params:
        threshold = config["okseqhmm_parameters"]["threshold"],
        binsize = config["okseqhmm_parameters"]["binSize"],
        wins = config["okseqhmm_parameters"]["winS"],
        chr_size = config["references"]["chr_size"],
        outname = os.path.normpath(OUTPUT_DIR + "/OKseqHMM/{sample_name}/{sample_name}"),
        script = os.path.normpath(PIPELINE_DIR + "/scripts")
    resources:
        partition="longq",
	    mem_mb=30720,
	    time_min=10079
    conda:
        CONDA_ENV_OKSEQ
    shell:
        """
        Rscript {params.script}/launchOKseqHMM.R {input.bam} {params.outname} {params.chr_size} {params.threshold} {params.binsize} {params.wins} {params.script}
        """

rule bedgraphtobigwig:
    input:
        os.path.normpath(OUTPUT_DIR + "/OKseqHMM/{sample_name}/{sample_name}_RFD_cutoff{thresh}_bs{bin_size}_sm_{win_s}kb.bedgraph")
    output:
        os.path.normpath(OUTPUT_DIR + "/OKseqHMM/{sample_name}/{sample_name}_RFD_cutoff{thresh}_bs{bin_size}_sm_{win_s}kb.bw")
    params:
        chr_size = config["references"]["chr_size"]
    resources:
	    partition="mediumq"
    conda:
        CONDA_ENV_BEDGRAPH
    shell:
        """
        bedGraphToBigWig {input} {params.chr_size} {output}
        """