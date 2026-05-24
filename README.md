# taf-seqkit

`taf-seqkit` packages SeqKit `2.13.0-r2`, an ultrafast toolkit for FASTA/Q sequence manipulation and lightweight BAM monitoring.

Package identity:

- name: `seqkit`
- command: `taf-seqkit`
- kind: `tool`
- TAFFISH version: `2.13.0-r2`
- container image: `ghcr.io/taffish/seqkit:2.13.0-r2`
- upstream release: `v2.13.0`
- runtime version string: `seqkit v2.13.0`
- upstream license: MIT
- Linux amd64 archive SHA256: `7d686de448464fada1b1988e2e07d693bec68768312da62846bc0e2b502bfc46`
- Linux arm64 archive SHA256: `2bce55ea352ceab56a428b2d6e06e6565485a446c17dc17cadb5dc28ab7a9cdc`

## What Is Included

This app installs the official upstream static Linux binary for the target container architecture. SeqKit itself is a single executable and does not require external aligners, databases, models, or interpreters.

SeqKit supports common FASTA/Q work including:

- statistics with `stats`
- sequence transformation with `seq`
- format conversion with `fq2fa`, `fx2tab`, and `tab2fx`
- search and motif location with `grep` and `locate`
- subsequence extraction with `subseq` and `faidx`
- set operations with `sample`, `sample2`, `rmdup`, and `common`
- splitting and ordering with `split`, `split2`, `sort`, and `shuffle`
- editing with `replace`, `rename`, `concat`, `restart`, and `mutate`
- translation with `translate`
- sequence checksums with `sum`
- lightweight BAM monitoring with `bam`

SeqKit reads and writes common compressed formats itself, including gzip, xz, zstd, bzip2, and LZ4 where supported by upstream SeqKit.

## Command Mode

`taf-seqkit --help` prints this TAFFISH app help. Use `--` only when passing option-leading arguments to the default upstream command:

```sh
taf-seqkit -- --help
```

SeqKit is a subcommand-based CLI. Because this TAFFISH app keeps `command_mode = true`, use the upstream executable name when running SeqKit subcommands:

```sh
taf-seqkit seqkit version
taf-seqkit seqkit stats reads.fa reads.fq.gz
taf-seqkit seqkit fq2fa reads.fq.gz > reads.fa
taf-seqkit seqkit grep -p chrM genome.fa
```

Avoid ambiguous forms such as `taf-seqkit stats reads.fa`; TAFFISH may treat `stats` as a container command rather than as `seqkit stats`.

## Common Workflows

Compute FASTA/FASTQ statistics:

```sh
taf-seqkit seqkit stats *.fa *.fq.gz
```

Convert FASTQ to FASTA:

```sh
taf-seqkit seqkit fq2fa reads.fq.gz > reads.fa
```

Filter by sequence length:

```sh
taf-seqkit seqkit seq -m 100 -M 10000 contigs.fa > contigs.100-10000.fa
```

Extract selected records:

```sh
taf-seqkit seqkit grep -f ids.txt sequences.fa > selected.fa
```

Extract FASTA intervals:

```sh
taf-seqkit seqkit faidx genome.fa chr1:1000-2000 > chr1.1000-2000.fa
```

Locate sequence motifs:

```sh
taf-seqkit seqkit locate -p ACGT genome.fa > motifs.tsv
```

Write LZ4-compressed output:

```sh
taf-seqkit seqkit seq -o sequences.fa.lz4 sequences.fa
```

## Boundaries

This app exposes the upstream SeqKit executable and its built-in subcommands. It does not bundle external tools such as Samtools, aligners, genome databases, shell completion installation, or tutorial datasets.

The `bam` subcommand is included because it is part of SeqKit, but this app does not turn SeqKit into a full BAM/SAM toolchain. Use dedicated TAFFISH apps such as Samtools for sorting, indexing, conversion, or alignment-centric workflows.

The smoke tests verify representative FASTA, FASTQ, subcommand, LZ4 compression, and version paths. They do not exhaustively test every SeqKit subcommand or every compression format.

## Platform

The image uses official upstream static Linux binaries and is intended for native `linux/amd64` and `linux/arm64` container platforms.

## License Boundary

The TAFFISH app packaging files are licensed under Apache-2.0. The packaged upstream SeqKit software is covered by: MIT. Bundled third-party components, datasets, models, and external resources keep their own license terms.

## Upstream

- Upstream repository: <https://github.com/shenwei356/seqkit>
- Upstream documentation: <https://bioinf.shenwei.me/seqkit/>
- Upstream release: <https://github.com/shenwei356/seqkit/releases/tag/v2.13.0>
- Upstream license: MIT

Primary citation:

- Shen W, Sipos B, Zhao L. 2024. SeqKit2: A Swiss Army Knife for Sequence and Alignment Processing. iMeta e191. DOI: `10.1002/imt2.191`.
- Shen W et al. 2016. SeqKit: A Cross-Platform and Ultrafast Toolkit for FASTA/Q File Manipulation. PLoS ONE. DOI: `10.1371/journal.pone.0163962`, PMID: `27706213`.
