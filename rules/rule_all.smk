def get_targets():
    targets = {}
    if config["input_format"] == "fastq":
        #targets["bowtie_index"]=[
        #    expand(os.path.normpath(OUTPUT_DIR + "/tmp/{genome}/{genome}.1.bt2"),genome=GENOME),
        #    expand(os.path.normpath(OUTPUT_DIR + "/tmp/{genome}/{genome}.2.bt2"),genome=GENOME),
        #    expand(os.path.normpath(OUTPUT_DIR + "/tmp/{genome}/{genome}.3.bt2"),genome=GENOME),
        #    expand(os.path.normpath(OUTPUT_DIR + "/tmp/{genome}/{genome}.4.bt2"),genome=GENOME),
        #    expand(os.path.normpath(OUTPUT_DIR + "/tmp/{genome}/{genome}.rev.1.bt2"),genome=GENOME),
        #    expand(os.path.normpath(OUTPUT_DIR + "/tmp/{genome}/{genome}.rev.2.bt2"),genome=GENOME)
        #]
        targets["fastq_qc"]=[
            expand(os.path.normpath(OUTPUT_DIR + "/Quality_Control/Fastqc/{sample_name}/{sample_name}_1_fastqc.html"), sample_name=SAMPLE_NAME),
            expand(os.path.normpath(OUTPUT_DIR + "/Quality_Control/Fastqc/{sample_name}/{sample_name}_1_fastqc.html"), sample_name=SAMPLE_NAME),
        ]
        #targets["trimagalore_trim"]=[
        #    expand(os.path.normpath(OUTPUT_DIR + "/tmp/{sample_name}/{sample_name}_1_val_1.fq.gz"),sample_name=SAMPLE_NAME),
        #    expand(os.path.normpath(OUTPUT_DIR + "/tmp/{sample_name}/{sample_name}_2_val_2.fq.gz"),sample_name=SAMPLE_NAME)
        #]
        targets["cutadapt_trim"]=[
            expand(os.path.normpath(OUTPUT_DIR + "/tmp/{sample_name}/{sample_name}_1_filtered.fq.gz"),sample_name=SAMPLE_NAME),
            expand(os.path.normpath(OUTPUT_DIR + "/tmp/{sample_name}/{sample_name}_2_filtered.fq.gz"),sample_name=SAMPLE_NAME)
        ]
        targets["duplicates"]=[
            expand(os.path.normpath(OUTPUT_DIR + "/Bam/{sample_name}/{sample_name}.bam.bai"), sample_name=SAMPLE_NAME),
            expand(os.path.normpath(OUTPUT_DIR + "/Bam/{sample_name}/{sample_name}.bam"),sample_name=SAMPLE_NAME),
            expand(os.path.normpath(OUTPUT_DIR + "/Quality_Control/Duplicates/{sample_name}/{sample_name}_duplicate_metrics.txt"),sample_name=SAMPLE_NAME)
        ]
        targets["reports"]=[
            expand(os.path.normpath(OUTPUT_DIR + "/Quality_Control/Reports/{sample_name}/{sample_name}_summary_reports.txt"),sample_name = SAMPLE_NAME)
        ]
    
    if config["steps"]["split_strand_analysis"]:
        targets["strands"]=[
            expand(os.path.normpath(OUTPUT_DIR + "/Peakcalling/reverse/{sample_name}/{sample_name}.bam"), sample_name=SAMPLE_NAME),
            expand(os.path.normpath(OUTPUT_DIR + "/Peakcalling/forward/{sample_name}/{sample_name}.bam"),sample_name=SAMPLE_NAME),
            expand(os.path.normpath(OUTPUT_DIR + "/Peakcalling/{strand}/{sample_name}/{sample_name}.bam.bai"),sample_name=SAMPLE_NAME,strand=STRAND),
            expand(os.path.normpath(OUTPUT_DIR + "/Peakcalling/{strand}/{sample_name}/{sample_name}.bedgraph"),sample_name=SAMPLE_NAME,strand=STRAND),
            expand(os.path.normpath(OUTPUT_DIR + "/Peakcalling/{strand}/{sample_name}/{sample_name}.bw"),sample_name=SAMPLE_NAME,strand=STRAND),
            #expand(os.path.normpath(OUTPUT_DIR + "/Peakcalling/{strand}/SEACR/{treatment_name}/{treatment_name}.{mode}.bed"),treatment_name=TREATMENT_NAME, mode=config["seacr_parameters"]["mode"], strand=STRAND),
            #expand(os.path.normpath(OUTPUT_DIR + "/Peakcalling/{strand}/SEACR/{treatment_name}/{treatment_name}_{mode}_results.txt"),treatment_name=TREATMENT_NAME, mode=config["seacr_parameters"]["mode"],strand=STRAND)
        ]

    if config["steps"]["ratio_enrichment"]:
        targets["okseq"]=[
            expand(os.path.normpath(OUTPUT_DIR + "/OKseqHMM/{sample_name}/{sample_name}_RFD_cutoff{thresh}_bs{bin_size}_sm_{win_s}kb.bedgraph"),sample_name=SAMPLE_NAME, thresh=config["okseqhmm_parameters"]["threshold"],bin_size=BINSIZE,win_s=config["okseqhmm_parameters"]["winS"]),
            expand(os.path.normpath(OUTPUT_DIR + "/OKseqHMM/{sample_name}/{sample_name}_RFD_cutoff{thresh}_bs{bin_size}_sm_{win_s}kb.bw"),sample_name=SAMPLE_NAME, thresh=config["okseqhmm_parameters"]["threshold"],bin_size=BINSIZE,win_s=config["okseqhmm_parameters"]["winS"])
        ]
    
    if config["steps"]["annotation"]:
        targets["anno"]=[
            expand(os.path.normpath(OUTPUT_DIR + "/Peakcalling/{sample_name}/{sample_name}.bedgraph"),sample_name=SAMPLE_NAME),
            expand(os.path.normpath(OUTPUT_DIR + "/Peakcalling/{treatment_name}/SEACR/{treatment_name}.{mode}.bed"),treatment_name=TREATMENT_NAME,mode=config["seacr_parameters"]["mode"])
        ]
    #print(targets)
    return targets
