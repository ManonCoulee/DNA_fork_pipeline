def get_targets():
    targets = {}
    if config["input_format"] == "fastq":
        targets["fastq_qc"]=[
            expand(os.path.normpath(OUTPUT_DIR + "/Quality_Control/Fastqc/{sample_name}/{sample_name}_1_fastqc.html"), sample_name=SAMPLE_NAME),
            expand(os.path.normpath(OUTPUT_DIR + "/Quality_Control/Fastqc/{sample_name}/{sample_name}_1_fastqc.html"), sample_name=SAMPLE_NAME),
        ]
        targets["cutadapt_trim"]=[
            expand(os.path.normpath(OUTPUT_DIR + "/tmp/{sample_name}/{sample_name}_1_filtered.fq.gz"),sample_name=SAMPLE_NAME),
            expand(os.path.normpath(OUTPUT_DIR + "/tmp/{sample_name}/{sample_name}_2_filtered.fq.gz"),sample_name=SAMPLE_NAME)
        ]
        targets["alignment"]=[
            expand(os.path.normpath(OUTPUT_DIR + "/Bam/{sample_name}/{sample_name}_unmarked.bam"), sample_name=SAMPLE_NAME),
            expand(os.path.normpath(OUTPUT_DIR + "/Bam/{sample_name}/{sample_name}_unmarked.bam.bai"), sample_name=SAMPLE_NAME)
        ]
        targets["duplicates"]=[
            expand(os.path.normpath(OUTPUT_DIR + "/Bam/{sample_name}/{sample_name}.bam"),sample_name=SAMPLE_NAME),
            expand(os.path.normpath(OUTPUT_DIR + "/Bam/{sample_name}/{sample_name}.bam.bai"), sample_name=SAMPLE_NAME),
            expand(os.path.normpath(OUTPUT_DIR + "/Quality_Control/Duplicates/{sample_name}/{sample_name}_duplicate_metrics.txt"),sample_name=SAMPLE_NAME)
        ]
        targets["reports"]=[
            expand(os.path.normpath(OUTPUT_DIR + "/Quality_Control/Reports/{sample_name}/{sample_name}_summary_reports.txt"),sample_name = SAMPLE_NAME)
        ]
        targets["transform"]=[
            expand(os.path.normpath(OUTPUT_DIR + "/Bam/{sample_name}/{sample_name}.bedgraph"),sample_name=SAMPLE_NAME),
            expand(os.path.normpath(OUTPUT_DIR + "/Bam/{sample_name}/{sample_name}.bw"),sample_name=SAMPLE_NAME)
        ]
    
    if config["steps"]["scarseq"]:
        targets["strands"]=[
            expand(os.path.normpath(OUTPUT_DIR + "/Strand/reverse/{sample_name}/{sample_name}.bam"), sample_name=SAMPLE_NAME),
            expand(os.path.normpath(OUTPUT_DIR + "/Strand/forward/{sample_name}/{sample_name}.bam"),sample_name=SAMPLE_NAME),
            expand(os.path.normpath(OUTPUT_DIR + "/Strand/{strand}/{sample_name}/{sample_name}.bam.bai"),sample_name=SAMPLE_NAME,strand=STRAND),
            expand(os.path.normpath(OUTPUT_DIR + "/Strand/{strand}/{sample_name}/{sample_name}.bedgraph"),sample_name=SAMPLE_NAME,strand=STRAND),
            expand(os.path.normpath(OUTPUT_DIR + "/Strand/{strand}/{sample_name}/{sample_name}.bw"),sample_name=SAMPLE_NAME,strand=STRAND)
        ]
        targets["readcounts"]=[
            expand(os.path.normpath(OUTPUT_DIR + "/Profiles/{sample_name}_readcounts.bed"), sample_name=SAMPLE_NAME)
        ]
#        targets["partition"]=[
#            expand(os.path.normpath(OUTPUT_DIR + "/Profiles/{sample_name}_rfd.bedgraph"),sample_name=SAMPLE_NAME),
#            expand(os.path.normpath(OUTPUT_DIR + "/Profiles/{sample_name}_rfd_sm15.bedgraph"),sample_name=SAMPLE_NAME),
#            expand(os.path.normpath(OUTPUT_DIR + "/Profiles/{sample_name}_rfd_sm15.tsv"),sample_name=SAMPLE_NAME)
#        ]

    if config["steps"]["okseq"]:
        targets["okseq"]=[
            expand(os.path.normpath(OUTPUT_DIR + "/OKseqHMM/{sample_name}/{sample_name}_RFD_cutoff{thresh}_bs{bin_size}_sm_{win_s}kb.bedgraph"),sample_name=SAMPLE_NAME, thresh=config["okseqhmm_parameters"]["threshold"],bin_size=BINSIZE,win_s=config["okseqhmm_parameters"]["winS"]),
            expand(os.path.normpath(OUTPUT_DIR + "/OKseqHMM/{sample_name}/{sample_name}_RFD_cutoff{thresh}_bs{bin_size}_sm_{win_s}kb.bw"),sample_name=SAMPLE_NAME, thresh=config["okseqhmm_parameters"]["threshold"],bin_size=BINSIZE,win_s=config["okseqhmm_parameters"]["winS"])
        ]
    
    if config["steps"]["cutrun"]:
        targets["anno"]=[
            expand(os.path.normpath(OUTPUT_DIR + "/Peakcalling/{sample_name}/{sample_name}.bedgraph"),sample_name=SAMPLE_NAME)
        ]
    #print(targets)
    return targets
