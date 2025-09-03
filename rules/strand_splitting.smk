"""
###############################################################################
Rule for splitting strand
###############################################################################
"""
def input_igg(wildcards):
    igg = IGG_TREATMENT_COUPLE.get(wildcards.treatment_name,"")
    igg_path = os.path.normpath(OUTPUT_DIR + "/Peakcalling/" + wildcards.strand + "/" + igg + "/" + igg + ".bedgraph")
    return(igg_path)

rule strand_split:
    input:
        os.path.normpath(OUTPUT_DIR + "/Bam/{sample_name}/{sample_name}.bam")
    output:
        R = os.path.normpath(OUTPUT_DIR + "/Peakcalling/reverse/{sample_name}/{sample_name}.bam"),
        F = os.path.normpath(OUTPUT_DIR + "/Peakcalling/forward/{sample_name}/{sample_name}.bam")
    conda:
        CONDA_ENV_SAMTOOLS
    threads: 6
    resources:
	    partition="mediumq"
    shell:
        """
        samtools view -h -b -f 16 -@ {threads} -o {output.R} {input}
        samtools view -h -b -F 20 -@ {threads} -o {output.F} {input}
        """

rule genomecov_strand:
    input:
        os.path.normpath(OUTPUT_DIR + "/Peakcalling/{strand}/{sample_name}/{sample_name}.bam")
    output:
        os.path.normpath(OUTPUT_DIR + "/Peakcalling/{strand}/{sample_name}/{sample_name}.bedgraph")
    conda:
        CONDA_ENV_BEDTOOLS
    resources:
	    partition="mediumq"
    shell:
        """
        bedtools genomecov -bg -ibam {input} > {output}
        """  
rule index:
    input:
        os.path.normpath(OUTPUT_DIR + "/Peakcalling/{strand}/{sample_name}/{sample_name}.bam")
    output:
        os.path.normpath(OUTPUT_DIR + "/Peakcalling/{strand}/{sample_name}/{sample_name}.bam.bai")
    conda:
        CONDA_ENV_SAMTOOLS
    resources:
	    partition="longq",
	    mem_mb=30720,
	    time_min=10079
    shell:
        """
        samtools index {input} {output}
        """ 
        
rule bamtoBW:
    input:
        bam = os.path.normpath(OUTPUT_DIR + "/Peakcalling/{strand}/{sample_name}/{sample_name}.bam"),
        bai = os.path.normpath(OUTPUT_DIR + "/Peakcalling/{strand}/{sample_name}/{sample_name}.bam.bai")
    output:
        os.path.normpath(OUTPUT_DIR + "/Peakcalling/{strand}/{sample_name}/{sample_name}.bw")
    conda:
        CONDA_ENV_DEEPTOOLS
    threads: 15
    resources:
	    partition="mediumq"
    shell:
        """
        bamCoverage -b {input.bam} -o {output} -p {threads}
        """
