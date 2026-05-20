taf-seqkit 2.13.0-r1

SeqKit v2.13.0 for ultrafast FASTA/Q sequence manipulation and
lightweight BAM monitoring. The default command is the upstream seqkit CLI.

Usage:
  taf-seqkit -- --help
  taf-seqkit seqkit version
  taf-seqkit seqkit stats reads.fa reads.fq.gz
  taf-seqkit seqkit fq2fa reads.fq.gz > reads.fa

Wrapper options:
  taf-seqkit --help       Show this TAFFISH help.
  taf-seqkit --version    Show the TAFFISH package version.
  taf-seqkit --compile    Print the generated runner.
  taf-seqkit -- --help    Show upstream SeqKit help.

Default upstream command:
  seqkit

Command mode:
  SeqKit uses subcommands such as stats, seq, grep, locate, and faidx.
  Because command_mode is enabled, include the executable name:

    taf-seqkit seqkit stats reads.fa
    taf-seqkit seqkit seq -m 100 contigs.fa
    taf-seqkit seqkit grep -f ids.txt sequences.fa

  Avoid ambiguous forms such as:

    taf-seqkit stats reads.fa

Common workflows:
  Version:
    taf-seqkit seqkit version

  FASTA/FASTQ statistics:
    taf-seqkit seqkit stats genome.fa reads.fq.gz

  FASTQ to FASTA:
    taf-seqkit seqkit fq2fa reads.fq.gz > reads.fa

  Length filtering:
    taf-seqkit seqkit seq -m 100 -M 10000 contigs.fa > filtered.fa

  Record selection:
    taf-seqkit seqkit grep -f ids.txt sequences.fa > selected.fa

  FASTA interval extraction:
    taf-seqkit seqkit faidx genome.fa chr1:1000-2000 > region.fa

  Motif location:
    taf-seqkit seqkit locate -p ACGT genome.fa > motifs.tsv

  LZ4-compressed output:
    taf-seqkit seqkit seq -o sequences.fa.lz4 sequences.fa

Common subcommands:
  seq, stats, subseq, sliding, faidx, translate, watch, scat,
  fq2fa, fx2tab, fa2fq, tab2fx, convert, grep, locate, amplicon,
  fish, sample, sample2, rmdup, common, duplicate, split, split2,
  head, head-genome, range, pair, replace, rename, concat, restart,
  mutate, sana, sort, shuffle, bam, sum, merge-slides.

Input and output:
  SeqKit reads FASTA and FASTQ from files or stdin.
  It supports common compressed input/output formats through its own binary,
  including gzip, xz, zstd, bzip2, and LZ4 where supported by upstream.
  Most commands write FASTA, FASTQ, TSV, or text reports to stdout.

Packaged commands:
  seqkit

Platform:
  Uses official upstream static Linux binaries for linux/amd64 and linux/arm64.

Boundaries:
  This app packages SeqKit itself. It does not bundle Samtools, aligners,
  genome databases, shell-completion installation, or tutorial datasets.
  The bam subcommand is present, but full BAM/SAM workflows should use
  dedicated tools such as Samtools when sorting, indexing, or conversion is
  required.
  Smoke tests cover representative FASTA, FASTQ, subcommand, LZ4 compression,
  static-binary, and version paths, not every SeqKit command or format.
