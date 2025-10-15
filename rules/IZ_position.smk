
rule rfd:
    input:
        os.path.normpath(OUTPUT_DIR + "/Profiles/{sample_name}_readcounts.bed")
    output:
        os.path.normpath(OUTPUT_DIR + "/IZ_calcul/{sample_name}_rfd_sm15.bedgraph"),
        os.path.normpath(OUTPUT_DIR + "/IZ_calcul/{sample_name}_rfd_sm15.tsv"),
        os.path.normpath(OUTPUT_DIR + "/IZ_calcul/{sample_name}_IZ_position_raw.bed")
    params:
        dir = os.path.normpath(OUTPUT_DIR + "/IZ_calcul/{sample_name}")
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
        Rscript {params.script}/rfd.R {input} {params.dir} {threads}
        """

rule rfd_bedgraphtobigwig:
    input:
        os.path.normpath(OUTPUT_DIR + "/IZ_calcul/{sample_name}_rfd_sm15.bedgraph")
    output:
        os.path.normpath(OUTPUT_DIR + "/Profiles/{sample_name}_rfd_sm15.bw")
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

rule rfd_matrix:
    input:
        os.path.normpath(OUTPUT_DIR + "/Profiles/{sample_name}_rfd_sm15.bw")
    output:
        os.path.normpath(OUTPUT_DIR + "/Profiles/{sample_name}_rfd_sm15_matrix.gz")
    params:
        IZ = config["references"]["IZ"]
    threads:
        15
    resources:
	    partition="mediumq"
    conda:
        CONDA_ENV_DEEPTOOLS
    shell:
        """
        computeMatrix reference-point -R {params.IZ} -S {input} -o {output} -p {threads} \
            -a 200000 -b 200000 --missingDataAsZero
        """

rule rfd_heatmap:
    input:
        os.path.normpath(OUTPUT_DIR + "/Profiles/{sample_name}_rfd_sm15_matrix.gz")
    output:
        SVG = os.path.normpath(OUTPUT_DIR + "/Profiles/{sample_name}_rfd_sm15_profil.svg"),
        PDF = os.path.normpath(OUTPUT_DIR + "/Profiles/{sample_name}_rfd_sm15_profil.pdf")
    params:
        IZ = config["references"]["IZ"]
    resources:
	    partition="short"
    conda:
        CONDA_ENV_DEEPTOOLS
    shell:
        """
        plotHeatmap -m {input} -o {output.SVG} --colorMap RdBU --refPointLabel IZ
        plotHeatmap -m {input} -o {output.PDF} --colorMap RdBU --refPointLabel IZ
        """
