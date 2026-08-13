## Import package
import pandas as pd
import os

## Pipeline directory
PIPELINE_DIR = workflow.snakefile
PIPELINE_DIR = PIPELINE_DIR.replace("/Snakefile", "")

## Output directory (working directory)
OUTPUT_DIR = config["output_dir"]

## INDEX directory (working directory)
GENOME = config["references"]["genome"]
#INDEX_DIR = OUTPUT_DIR + "/tmp/" + GENOME
INDEX_DIR = config["references"]["index"]

###############################################################################
## Conda environment
CONDA_ENV_BEDTOOLS = PIPELINE_DIR + "/envs/conda/bedtools-2.31.yaml"
CONDA_ENV_FASTQC = PIPELINE_DIR + "/envs/conda/fastqc-0.12.yaml"
CONDA_ENV_CUTADAPT = PIPELINE_DIR + "/envs/conda/cutadapt-2.6.yaml"
CONDA_ENV_BOWTIE = PIPELINE_DIR + "/envs/conda/bowtie2-2.4.yaml"
CONDA_ENV_SAMTOOLS = PIPELINE_DIR + "/envs/conda/samtools-1.13.yaml"
CONDA_ENV_PICARD = PIPELINE_DIR + "/envs/conda/picard-3.4.yaml"
CONDA_ENV_MACS2 = PIPELINE_DIR + "/envs/conda/macs2-2.2.yaml"
CONDA_ENV_OKSEQ = PIPELINE_DIR + "/envs/conda/OKseqHMM.2.yaml"
CONDA_ENV_BEDGRAPH = PIPELINE_DIR + "/envs/conda/bedgraphtobigwig-482.yaml"
CONDA_ENV_DEEPTOOLS = PIPELINE_DIR + "/envs/conda/deeptools-3.5.4.yaml"
CONDA_ENV_ANNOTATION = PIPELINE_DIR + "/envs/conda/R_annotation.yaml"

###############################################################################
## Read design file
design = pd.read_table(config["design"], sep = ",")
format_design = ["sample_id"]
format_design.extend(("path_file","cell_id"))
design = design[format_design]

SAMPLE_NAME = []
IGG_NAME = []
TREATMENT_NAME = []

for line in range(0,len(design["sample_id"]),1):
    SAMPLE_NAME.append(design["sample_id"].iloc[line])

    if config["input_format"] == "fastq":
        if (os.path.exists(str(OUTPUT_DIR + "/tmp/")) == False):
            os.makedirs(str(OUTPUT_DIR + "/tmp/"))
        for rep in ["1","2"]:
            path = design["path_file"].iloc[line]
            sample = design["sample_id"].iloc[line]
            if (os.path.exists(str(OUTPUT_DIR + "/tmp/" + sample + "_" + rep + ".fq.gz")) == False):
                os.symlink(str(path + "_" + rep + ".fq.gz"), str(OUTPUT_DIR + "/tmp/" + sample + "_" + rep + ".fq.gz"))
    
#    if config["seacr_parameters"]["igg"]:
#        if design["cell_id"].iloc[line] == "input":
#            IGG_NAME.append(design["sample_id"].iloc[line])
#        else:
#            TREATMENT_NAME.append(design["sample_id"].iloc[line])
#
#        IGG_TREATMENT_COUPLE = dict(zip(TREATMENT_NAME,IGG_NAME))
#    else:
#        TREATMENT_NAME.append(design["sample_id"].iloc[line])

## Wildcard constraints
wildcard_constraints:
    sample_name = '|'.join([x for x in SAMPLE_NAME]),
    treatment_name = '|'.join([x for x in TREATMENT_NAME])

STRAND = ["reverse","forward"]

## Transform binSize in kb for OKseqHMM
bin_size = str(config["okseqhmm_parameters"]["binSize"])
BINSIZE = bin_size.replace("000","kb")

## Create a SamplePlan file
if config["steps"]["scarseq"]:
    with open(OUTPUT_DIR + "/SamplePlan.tsv", "a") as f:
        f.write("SampleID\tCellline\tStrand\tSamplePath\tBatch\tSamplePool\tSampleName")

###############################################################################
## Rule inclusion

include: "rules/rule_all.smk"
rule all:
    input:
        **get_targets(),
    message:
        "Pipeline finished!"

if config["input_format"] == "fastq":
    include: "rules/fastq_qc.smk"
    include: "rules/trimming.smk"
    include: "rules/alignment.smk"
    include: "rules/transform_bam.smk"
    include: "rules/duplicates.smk"
    include: "rules/bam_report.smk"
    include: "rules/transform_bam.smk"

if config["steps"]["scarseq"] | config["steps"]["okseq"]:
    include: "rules/strand_splitting.smk"
    include: "rules/reads_counts.smk"
    include: "rules/readcounts_TE.smk"

if config["steps"]["scarseq"]:
    include: "rules/partition.smk"

if config["steps"]["okseq"]:
    include: "rules/rfd_annotation.smk"
    include: "rules/IZ_position.smk"

if config["steps"]["cutrun"]:
    include: "rules/annotation.smk"
