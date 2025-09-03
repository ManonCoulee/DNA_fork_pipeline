#!/bin/bash
#using sbatch run.sh
#SBATCH --job-name=CUTRUN_K9me3
#SBATCH --nodes=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=1G
#SBATCH --partition=shortq

source /mnt/beegfs02/software/recherche/miniconda/25.1.1/etc/profile.d/conda.sh
conda activate /mnt/beegfs02/pipelines/bigr_rna_editing/1.1.1/envs/compiled_conda/snakemake

pipeline="/home/m_coulee/Post-doc/H3K9me3_pipeline"

snakemake --profile ${pipeline}/profiles/slurm \
	-s ${pipeline}/Snakefile \
	--configfile ${pipeline}/H3K9me3_config.yaml \
	--dag | dot -Tsvg > ${pipeline}/images/CUTRUN_dag.svg
