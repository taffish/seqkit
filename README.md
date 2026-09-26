# taf-seqkit

SeqKit **2.14.0-r1**: the official SeqKit FASTA/FASTQ toolkit, including lightweight
BAM inspection, terminal histograms and static plots. This is a thin tool app,
not a workflow or an alignment suite.

## Identity and installation

- TAFFISH package: `seqkit 2.14.0-r1`; command: `taf-seqkit`.
- Upstream/runtime: `v2.14.0` / `seqkit v2.14.0`.
- Image: `ghcr.io/taffish/seqkit:2.14.0-r1`.
- Native container platforms: `linux/amd64`, `linux/arm64`.
- Packaging license: Apache-2.0; SeqKit: MIT; embedded dependencies retain their terms.

After the maintainer publishes this candidate, install with `taf install seqkit`.
`taf-seqkit --help` is the concise installed usage manual; it is also available
in [docs/help.md](docs/help.md).

## Use

```sh
taf-seqkit seqkit version
taf-seqkit seqkit stats reads.fa reads.fq.gz
taf-seqkit seqkit fq2fa reads.fq.gz -o reads.fa
taf-seqkit seqkit grep -f ids.txt sequences.fa -o selected.fa
taf-seqkit seqkit faidx genome.fa chr1:1000-2000 -o region.fa
taf-seqkit seqkit split2 -s 1000 -W 4 -O parts reads.fa
taf-seqkit seqkit fx2tab -f reads.fq.gz -o records.tsv
```

The app preserves automatic command mode. Include `seqkit` before subcommands;
`taf-seqkit stats` can be interpreted as a container executable named `stats`.
`taf-seqkit -- --help` reaches the upstream default command's help; wrapper
`--help`, `--version` and `--compile` remain TAFFISH options. Shell-sensitive
arguments require quoting for the generated shell, e.g.
`taf-seqkit seqkit stats '"input sequences.fa"'`.

## Scope and dependencies

The complete official static binary is retained, including all 41 subcommands:
FASTA/Q statistics, sequence edits and transforms, selection, motif search,
translation, sampling, splitting, checksums, compression, BAM inspection,
`watch`, `scat` and `sana`. Compressed I/O uses embedded Go libraries, including
gzip, BGZF input, xz, zstd, bzip2 and LZ4. No separate compressor is required.
PNG/PDF/SVG rendering and the necessary fonts are embedded; it does not invoke
an external viewer or require an X server.

Bash is retained because BAM `--exec-before` / `--exec-after` run shell commands
inside the container. This does not supply arbitrary commands named by the user:
Samtools, aligners and other analysis suites are not bundled. SeqKit BAM support
is not a replacement for those tools. BAM `-s` statistics are written to stderr.

The official source, installation documentation, command registry and linked
tutorials were checked for optional UI/plugins/companions. `watch` is a terminal
histogram or static plot; `scat` watches sequence files. Neither is a browser or
desktop GUI. The linked sandbox.bio tutorial is an external learning site, not
an installable SeqKit UI component. No GUI service, noVNC stack, port forwarding
or GPU integration is applicable to this package.

## Inputs, resources and write map

FASTA/FASTQ/BAM, BED/GTF and references are project-specific user inputs, not a
versioned downloadable database/model artifact. SeqKit has no required database,
model or taxonomy downloader. A personal/system-wide resource installer,
automatic discovery/override and shared model-cache policy are therefore N/A.
Small built-in fonts remain inside the read-only image with their notices.
Administrators may share reference files read-only using normal backend binds;
the app does not change their ownership or permissions.

| Location | Runtime behavior |
| --- | --- |
| `/opt/seqkit`, executable, fonts/notices | Read-only installation; no runtime writes |
| Working directory / explicit output | Actual host bind; output ownership follows the invoking user in validated ordinary-user tests |
| Input FASTA sidecar | `faidx` creates `file.fa.fai`, or `file.fa.seqkit.fai` with `-f`; a matching existing index can be reused read-only |
| `/tmp` | Scratch only; smoke creates a unique private directory and removes it on exit |
| stdout/stderr | Sequences/reports and diagnostics; BAM `-s` uses stderr |

For read-only references, prepare the matching index beforehand or copy the
reference to writable storage. `faidx -U` requires a writable index directory.
Most `-o` outputs can overwrite an existing file; choose fresh names/directories
when preservation is required. Help includes separate Docker/Podman/Apptainer
commands for external read-only binds. No background download occurs in normal
analysis; the explicitly requested `seqkit version -u` update check needs HTTPS.
A CA bundle is retained for that opt-in path, which is not an offline smoke test.

## Backends and plots

Run from a writable directory containing the input. These produce a host file
to open with a local image viewer; use `.pdf` or `.svg` to change format:

```sh
TAFFISH_CONTAINER_BACKEND=docker taf-seqkit seqkit watch -O lengths.png reads.fa
TAFFISH_CONTAINER_BACKEND=podman taf-seqkit seqkit watch -O lengths.png reads.fa
TAFFISH_CONTAINER_BACKEND=apptainer taf-seqkit seqkit watch -O lengths.png reads.fa
```

Apptainer requires Linux. Docker/Podman provide the container path on macOS.
No app-specific backend arguments, devices, ports or emulation settings are
needed for these two native architectures. Without `scat -f`, file monitoring
continues until interrupted; the app does not add a separate service helper.

Candidate tests completed on 2026-09-25:

| Native platform / backend | Offline direct + read-only tests | Real wrapper / host outputs |
| --- | --- | --- |
| arm64 Docker | 46/46 PASS | 24/24 PASS |
| arm64 Podman | 46/46 PASS | 24/24 PASS |
| amd64 Docker (xjp) | 46/46 PASS | 24/24 PASS |
| amd64 Podman (xjp) | 46/46 PASS | 24/24 PASS |
| amd64 Apptainer (xjp) | 23/23 PASS, actual read-only SIF from the same candidate OCI | 24/24 PASS |
| arm64 Apptainer | Not separately validated: no native ARM Linux/SIF runner | Not separately validated |

Each combined/individual existence probe and each manifest test ran independently,
offline, without production binds. Docker/Podman repeated the same commands with
a read-only root and only `/tmp` scratch. Wrapper checks used actual writable
host binds plus read-only input binds and ordinary-user ownership checks.
Local Podman transport/startup timeouts were preserved and retried without
changing the 120-second limit; all required commands ultimately passed against
the same final image identity. This app has no architecture/backend coupling
that requires the remaining ARM Apptainer combination; it is not claimed PASS.
Publication and subsequent Action/GHCR/Index checks remain separate steps.

## Reproducible source and license boundary

The Dockerfile uses the official release assets without changing SeqKit code:

| Asset | SHA256 |
| --- | --- |
| `seqkit_linux_amd64.tar.gz` | `3d664ffb48438d1fbd3f3cfc060c71d00368a26435f1c876944aea7fcdff86b5` |
| `seqkit_linux_arm64.tar.gz` | `f0f68f3b595c9fa2ef7185a93a6f16a83d7411f9027318e8987031b8646d56bf` |

Tag commit: `facf0f7120483f9e39725c66dd83f5f14e048afd`. Both official binaries
embed this revision, Go `1.27.0`, `CGO_ENABLED=0`, and **`vcs.modified=true`**.
The asset hashes fix exactly what is packaged; this is not a claim that the
binary was reproduced from a clean tag checkout. All 52 embedded module
versions/hashes match the fixed source's Go inventory. Original notices for the
54 declared modules, SeqKit, Go and fonts are retained under
`/opt/seqkit/share/licenses`; `/opt/seqkit/share/source.txt` records asset identity.
See [container and fixture notes](docker/README.md).

## Validation and maintenance

`[smoke]` has 13 existence probes and nine independent modes: identity/all
subcommand help, basic FASTA/Q, search/indexing, conversion, all listed compressed
formats, 2.14 delta regressions, FASTQ edits/errors, terminal/static monitoring,
and BAM/shell hooks. This is packaging regression evidence, not an exhaustive
scientific benchmark or a large-data performance validation.

The build uses app-root context (`docker build -f docker/Dockerfile .`), matching
the unmodified fresh canonical Action. Build-time self-tests are limited to
version, help, static identity and a tiny sequence copy; rendering and full
regressions are runtime tests, not architecture-sensitive build gates.
The final image excludes downloader/development tooling and package caches from
the builder. Docker-reported sizes are 91.38 MiB (amd64) and 111.51 MiB (arm64);
the installed SeqKit tree is approximately 22/21 MiB. Package caches are empty
apart from directory metadata. No further obvious non-runtime bulk remains to
remove safely without discarding functionality or notices.
Never overwrite a published image tag/release to apply a fix.

## Upstream and citations

- [Repository](https://github.com/shenwei356/seqkit)
- [Manual](https://bioinf.shenwei.me/seqkit/usage/)
- [Release v2.14.0](https://github.com/shenwei356/seqkit/releases/tag/v2.14.0)
- Shen, Sipos and Zhao (2024), SeqKit2. DOI: `10.1002/imt2.191`.
- Shen et al. (2016), SeqKit. DOI: `10.1371/journal.pone.0163962`; PMID: `27706213`.
