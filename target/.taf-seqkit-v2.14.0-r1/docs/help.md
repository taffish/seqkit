taf-seqkit 2.14.0-r1

Manipulate FASTA/FASTQ sequences and inspect BAM alignments with SeqKit.

Quick start:
  taf-seqkit seqkit stats reads.fa reads.fq.gz
  taf-seqkit seqkit fq2fa reads.fq.gz -o reads.fa
  taf-seqkit seqkit seq -m 100 -M 10000 contigs.fa -o filtered.fa
  taf-seqkit seqkit grep -f ids.txt sequences.fa -o selected.fa
  taf-seqkit seqkit locate -p ACGT genome.fa -o motifs.tsv

Help and versions:
  taf-seqkit --help                 This usage help.
  taf-seqkit --version              TAFFISH package version.
  taf-seqkit --compile              Generated runner.
  taf-seqkit -- --help              Upstream help.
  taf-seqkit seqkit version         Upstream version.
  taf-seqkit seqkit replace --help  Subcommand help.
  Include "seqkit" before subcommands; "taf-seqkit stats" is ambiguous.

Backends (Linux amd64/arm64 images):
  TAFFISH_CONTAINER_BACKEND=docker taf-seqkit seqkit stats reads.fa
  TAFFISH_CONTAINER_BACKEND=podman taf-seqkit seqkit stats reads.fa
  TAFFISH_CONTAINER_BACKEND=apptainer taf-seqkit seqkit stats reads.fa
  Apptainer requires Linux; on macOS use Docker or Podman.

Files, pipes and indexes:
  Run from a writable working directory; it is mounted into the container.
  Input paths must be visible there or through an explicit read-only bind.
  Most commands read stdin and write stdout; prefer -o for named outputs.
  taf-seqkit seqkit seq -r -p - < reads.fa > reverse-complement.fa
  taf-seqkit seqkit seq reads.fa -o compressed.fa.lz4
  Existing -o files can be overwritten; choose a new output path to keep them.
  taf-seqkit seqkit faidx genome.fa chr1:1000-2000 -o region.fa
  faidx writes genome.fa.fai beside its input (-f uses genome.fa.seqkit.fai).
  For read-only input, prepare a matching index first, or copy the reference
  to writable storage. Do not request -U index updates on a read-only bind.
  For paths with spaces, quote the argument for the generated shell as well:
    taf-seqkit seqkit stats '"input sequences.fa"'

Read a directory outside the working directory:
  TAFFISH_DOCKER_RUN_ARGS='-v /data/references:/input:ro' \
    TAFFISH_CONTAINER_BACKEND=docker taf-seqkit seqkit stats /input/ref.fa
  TAFFISH_PODMAN_RUN_ARGS='-v /data/references:/input:ro' \
    TAFFISH_CONTAINER_BACKEND=podman taf-seqkit seqkit stats /input/ref.fa
  TAFFISH_APPTAINER_RUN_ARGS='--bind /data/references:/input:ro' \
    TAFFISH_CONTAINER_BACKEND=apptainer taf-seqkit seqkit stats /input/ref.fa

Monitoring and plots (terminal output or static files, not a browser GUI):
  taf-seqkit seqkit bam -s alignments.bam 2> bam-stats.tsv
  taf-seqkit seqkit watch -B 20 -W 0 -O lengths.png reads.fq.gz
  Use .pdf or .svg instead of .png for those formats; open on the host.
  TAFFISH_CONTAINER_BACKEND=docker taf-seqkit seqkit watch -O lengths.png reads.fa
  TAFFISH_CONTAINER_BACKEND=podman taf-seqkit seqkit watch -O lengths.png reads.fa
  TAFFISH_CONTAINER_BACKEND=apptainer taf-seqkit seqkit watch -O lengths.png reads.fa
  taf-seqkit seqkit scat -f -i fasta input-directory -o combined.fa
  scat -f finishes after existing files; without -f it keeps watching (Ctrl-C).
  BAM --exec-before/--exec-after run Bash commands inside this container;
  external aligners and Samtools are not included.

Version-specific notes:
  Explicit seq -w also wraps FASTQ sequence and quality lines in 2.14.0.
  replace -s supports deletion/equal-length FASTQ edits; expansion is rejected.
  stats/monitor errors are not successful empty results; check the exit code.
  No database/model download is needed. Reference sequences are user inputs.

More commands and options: taf-seqkit seqkit --help
Manual: https://bioinf.shenwei.me/seqkit/usage/
Packaging, licenses and validation scope: repository README and release notes.
