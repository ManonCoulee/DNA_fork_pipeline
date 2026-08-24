#!/bin/bash
#using sbatch run.sh
#SBATCH --job-name=SCARseq_H3K9me3
#SBATCH --nodes=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=1G
#SBATCH --partition=longq

source /mnt/beegfs02/software/recherche/miniconda/25.1.1/etc/profile.d/conda.sh
conda activate /mnt/beegfs02/pipelines/bigr_rna_editing/1.0.0/envs/conda/snakemake/

pipeline="/home/m_coulee/DNA_fork_pipeline"

snakemake --profile ${pipeline}/profiles/slurm \
	-s ${pipeline}/Snakefile \
	--configfile /mnt/beegfs01/scratch/m_coulee/H3K9me3_analysis/H3K9me3_config.yaml


