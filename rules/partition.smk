"""
###############################################################################
Rule for counts the number of reads
###############################################################################
"""

rule partition:
    input:
        os.path.normpath(OUTPUT_DIR + "/Profiles/{sample_name}_readcounts.bed")
    output:
        os.path.normpath(OUTPUT_DIR + "/Profiles/{sample_name}_rfd.bedgraph"),
        os.path.normpath(OUTPUT_DIR + "/Profiles/{sample_name}_rfd_sm15.bedgraph"),
        os.path.normpath(OUTPUT_DIR + "/Profiles/{sample_name}_rfd_sm15.tsv")
    params:
        dir = os.path.normpath(OUTPUT_DIR + "/Profiles/"),
        sample = "{sample_name}",
        IZ = config["references"]["IZ"],
        script = os.path.normpath(PIPELINE_DIR + "/scripts/")
    resources:
	    partition="longq",
	    mem_mb=30720,
	    time_min=10079
    threads:
        20
    conda:
        CONDA_ENV_OKSEQ
    shell:
        """
        Rscript {params.script}/partition.R {input} {params.dir} {params.sample} {params.IZ} {threads}
        """

rule partition_bedgraphtobigwig:
    input:
        os.path.normpath(OUTPUT_DIR + "/Profiles/{sample_name}_rfd_sm15.bedgraph")
    output:
        os.path.normpath(OUTPUT_DIR + "/Profiles/{sample_name}_rfd_sm15.bw")
    params:
        chr_size = config["references"]["chr_size"],
        sample_dir = os.path.normpath(OUTPUT_DIR + "/Profiles/{sample_name}")
    resources:
	    partition="longq",
	    mem_mb=30720,
	    time_min=10079
    conda:
        CONDA_ENV_BEDGRAPH
    shell:
        """
        sort -k1,1 -k2,2n {input} > {params.sample_dir}_sorted.bedgraph
        bedGraphToBigWig {params.sample_dir}_sorted.bedgraph {params.chr_size} {output}
        """

rule partition_matrix:
    input:
        os.path.normpath(OUTPUT_DIR + "/Profiles/{sample_name}_rfd_sm15.bw")
    output:
        os.path.normpath(OUTPUT_DIR + "/Profiles/{sample_name}_rfd_sm15_matrix.gz")
    params:
        IZ = config["references"]["IZ"]
    threads:
        15
    resources:
	    partition="longq",
	    mem_mb=30720,
	    time_min=10079
    conda:
        CONDA_ENV_DEEPTOOLS
    shell:
        """
        computeMatrix reference-point -R {params.IZ} -S {input} -o {output} -p {threads} \
            -a 200000 -b 200000 --missingDataAsZero
        """

rule partition_heatmap:
    input:
        os.path.normpath(OUTPUT_DIR + "/Profiles/{sample_name}_rfd_sm15_matrix.gz")
    output:
        SVG = os.path.normpath(OUTPUT_DIR + "/Profiles/{sample_name}_rfd_sm15_heatmap.svg"),
        PDF = os.path.normpath(OUTPUT_DIR + "/Profiles/{sample_name}_rfd_sm15_heatmap.pdf")
    params:
        IZ = config["references"]["IZ"]
    resources:
	    partition="longq",
	    mem_mb=30720,
	    time_min=10079
    conda:
        CONDA_ENV_DEEPTOOLS
    shell:
        """
        plotHeatmap -m {input} -o {output.SVG} --colorMap RdBu --refPointLabel IZ --heatmapHeight 10 \
            --whatToShow "heatmap and colorbar"
        plotHeatmap -m {input} -o {output.PDF} --colorMap RdBu --refPointLabel IZ --heatmapHeight 10 \
            --whatToShow "heatmap and colorbar"
        """
