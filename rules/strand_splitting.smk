"""
###############################################################################
Rule for splitting strand
###############################################################################
"""
def input_igg(wildcards):
    igg = IGG_TREATMENT_COUPLE.get(wildcards.treatment_name,"")
    igg_path = os.path.normpath(OUTPUT_DIR + "/Strand/" + wildcards.strand + "/" + igg + "/" + igg + ".bedgraph")
    return(igg_path)

rule strand_split:
    input:
        os.path.normpath(OUTPUT_DIR + "/Bam/{sample_name}/{sample_name}.bam")
    output:
        R = os.path.normpath(OUTPUT_DIR + "/Strand/reverse/{sample_name}/{sample_name}.bam"),
        F = os.path.normpath(OUTPUT_DIR + "/Strand/forward/{sample_name}/{sample_name}.bam")
    params:
        outdir = os.path.normpath(OUTPUT_DIR + "/Strand/{sample_name}")
    conda:
        CONDA_ENV_SAMTOOLS
    threads: 6
    resources:
	    partition="mediumq"
    shell:
        """
        samtools view -h -b -f 83 -@ {threads} -o {params.outdir}.rev1.bam {input}
        samtools view -h -b -f 163 -@ {threads} -o {params.outdir}.rev2.bam {input}
        samtools view -h -b -f 99 -@ 6 -o {params.outdir}.fwd1.bam {input}
        samtools view -h -b -f 147 -@ 6 -o {params.outdir}.fwd2.bam {input}
        samtools merge -f {output.F} {params.outdir}.fwd1.bam {params.outdir}.fwd2.bam
        samtools merge -f {output.R} {params.outdir}.rev1.bam {params.outdir}.rev2.bam
        rm {params.outdir}.fwd*.bam
        rm {params.outdir}.rev*.bam
        """

rule index:
    input:
        os.path.normpath(OUTPUT_DIR + "/Strand/{strand}/{sample_name}/{sample_name}.bam")
    output:
        os.path.normpath(OUTPUT_DIR + "/Strand/{strand}/{sample_name}/{sample_name}.bam.bai")
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

rule bamtobedgraph_strand:
    input:
        os.path.normpath(OUTPUT_DIR + "/Strand/{strand}/{sample_name}/{sample_name}.bam")
    output:
        os.path.normpath(OUTPUT_DIR + "/Strand/{strand}/{sample_name}/{sample_name}.bedgraph")
    conda:
        CONDA_ENV_BEDTOOLS
    resources:
	    partition="mediumq"
    shell:
        """
        bedtools genomecov -bg -ibam {input} > {output}
        """  
        
rule bamtoBW_strand:
    input:
        bam = os.path.normpath(OUTPUT_DIR + "/Strand/{strand}/{sample_name}/{sample_name}.bam"),
        bai = os.path.normpath(OUTPUT_DIR + "/Strand/{strand}/{sample_name}/{sample_name}.bam.bai")
    output:
        os.path.normpath(OUTPUT_DIR + "/Strand/{strand}/{sample_name}/{sample_name}.bw")
    conda:
        CONDA_ENV_DEEPTOOLS
    threads: 15
    resources:
	    partition="mediumq"
    shell:
        """
        bamCoverage -b {input.bam} -o {output} -p {threads}
        """
