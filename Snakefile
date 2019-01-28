SAMPLES, = glob_wildcards("data/input/{smp}_1.fastq.gz")


rule all:
    input:
        expand("data/output/{smp}/trimmed/{smp}_cutadapt_2_fastq.gz", smp=SAMPLES),
        expand("data/output/{smp}/trimmed/{smp}_urqt_2_fastq.gz", smp=SAMPLES),
        expand("data/output/{smp}/mapped/{smp}_quant/", smp=SAMPLES),
        #expand("data/output/{smp}/fastqc_untrimmed/", smp=SAMPLES),
        #expand("data/output/{smp}/fastqc_trimmed_cutadapt/", smp=SAMPLES),
        #expand("data/output/{smp}/fastqc_trimmed_urqt/", smp=SAMPLES),
        #expand("data/output/{smp}/featurecounts")
        #expand("data/output/{smp}/qualimap/", smp=SAMPLES)


rule trimming_cutadapt:
    input:
        r1 = "data/input/{smp}_1.fastq.gz",
        r2 = "data/input/{smp}_2.fastq.gz",
    output:
        r1_cutadapt = temp("data/output/{smp}/trimmed/{smp}_cutadapt_1_fastq.gz"),
        r2_cutadapt = temp("data/output/{smp}/trimmed/{smp}_cutadapt_2_fastq.gz")
    params:
        adaptor = config["adaptor"]
    log:
        cutadapt = "data/output/{smp}/logs/{smp}.cutadapt.log"
    shell:
       "cutadapt {params.adaptor} -o {output.r1_cutadapt} -p {output.r2_cutadapt}  {input.r1} {input.r2} > {log.cutadapt}"



rule trimming_urqt:
    input:
        r1_cutadapt = "data/output/{smp}/trimmed/{smp}_cutadapt_1_fastq.gz",
        r2_cutadapt = "data/output/{smp}/trimmed/{smp}_cutadapt_2_fastq.gz"
    output:
        r1_urqt = temp("data/output/{smp}/trimmed/{smp}_urqt_1_fastq.gz"),
        r2_urqt = temp("data/output/{smp}/trimmed/{smp}_urqt_2_fastq.gz")
    params:
        urqt = config["urqt_path"]
    log:
        cutadapt = "data/output/{smp}/logs/{smp}.urqt.log"
    shell:
       "{params.urqt} --t 20 --gz --in {input.r1_cutadapt} --inpair {input.r2_cutadapt} --out {output.r1_urqt} --outpair {output.r2_urqt} > {log}"


rule mapping:
    input:
        r1_urqt = "data/output/{smp}/trimmed/{smp}_urqt_1_fastq.gz",
        r2_urqt = "data/output/{smp}/trimmed/{smp}_urqt_2_fastq.gz",
        index = config["salmon_index"]
    output:
        "data/output/{smp}/mapped/{smp}_quant/"
    log:
        "data/output/{smp}/logs/{smp}.salmon.log"
    shell:
        "salmon quant -i {input.index} -l IU -p 1 --useVBOpt --numBootstraps 100 --seqBias --gcBias --posBias -1 {input.r1_urqt} -2 {input.r2_urqt} -o {output} > {log}"



