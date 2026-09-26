#!/bin/sh
# 每个 manifest mode 独立建立 scratch；失败日志在退出前回放给 Index。
set -eu
if [ "${1:-}" != --inner ]; then
    mode=${1:-identity}
    work=$(mktemp -d /tmp/taf-seqkit-smoke.XXXXXX)
    trap 'rm -rf "$work"' EXIT
    if sh "$0" --inner "$mode" "$work" >"$work/run.log" 2>&1; then
        printf 'seqkit-smoke:%s:PASS\n' "$mode"
    else
        status=$?
        printf 'seqkit-smoke:%s:FAIL exit=%s\n' "$mode" "$status" >&2
        tail -n 100 "$work/run.log" >&2
        exit "$status"
    fi
    exit 0
fi
mode=$2
cd "$3"
case "$mode" in
  identity)
    seqkit version > version.txt
    grep -Fx 'seqkit v2.14.0' version.txt
    seqkit --help > help.txt
    grep -F 'SeqKit -- a cross-platform and ultrafast toolkit' help.txt
    for cmd in faidx scat seq sliding stats subseq translate watch convert fa2fq fq2fa fx2tab tab2fx amplicon fish grep locate common duplicate head head-genome pair range rmdup sample sample2 split split2 concat mutate rename replace restart sana shuffle sort bam merge-slides sum genautocomplete version; do
        seqkit "$cmd" --help > subhelp.txt
        grep -F 'Usage:' subhelp.txt
    done
    { ldd "$(command -v seqkit)" 2>&1 || true; } > linkage.txt
    grep -E '(not a dynamic executable|statically linked)' linkage.txt
    ;;
  basic)
    printf '>chr1\nACGTACGTNNNNACGT\n>chr2\nTTAGGGTTAGGGCCCTAA\n' > ref.fa
    cp /opt/seqkit/share/fixtures/reads.fq reads.fq
    seqkit stats -T ref.fa reads.fq > stats.tsv
    grep -F 'ref.fa' stats.tsv
    grep -F 'reads.fq' stats.tsv
    seqkit fq2fa reads.fq > reads.fa
    grep -Fx '>r1' reads.fa
    seqkit seq -m 17 ref.fa > filtered.fa
    test "$(grep -c '^>' filtered.fa)" = 1
    grep -Fx '>chr2' filtered.fa
    printf '>chr2\nTTAGGGTTAGGGCCCTAA\n' > expected.fa
    cmp filtered.fa expected.fa
    seqkit seq -o new/dir/result.fa ref.fa
    cmp new/dir/result.fa ref.fa
    ;;
  search)
    printf '>chr1\nACGTACGTNNNNACGT\n>chr2\nTTAGGGTTAGGGCCCTAA\n' > ref.fa
    printf 'chr2\n' > ids.txt
    seqkit grep -f ids.txt ref.fa > selected.fa
    grep -Fx '>chr2' selected.fa
    seqkit locate -p ACGT ref.fa > locate.tsv
    grep -F 'chr1' locate.tsv
    seqkit faidx ref.fa chr1:2-5 > slice.fa
    grep -Fx 'CGTA' slice.fa
    test -s ref.fa.fai
    seqkit subseq -r 2:5 ref.fa > subseq.fa
    grep -Fx 'CGTA' subseq.fa
    ;;
  convert)
    printf '>seq1\nATGAAATAG\n>seq2\nACGTTT\n' > seqs.fa
    seqkit translate -w 0 seqs.fa > prot.fa
    grep -Fx 'MK*' prot.fa
    seqkit seq -r -p seqs.fa > rc.fa
    grep -Fx 'AAACGT' rc.fa
    seqkit fx2tab seqs.fa > seqs.tsv
    seqkit tab2fx seqs.tsv > round.fa
    cmp seqs.fa round.fa
    cp /opt/seqkit/share/fixtures/reads.fq reads.fq
    seqkit fx2tab -f reads.fq > filenames.tsv
    awk -F '\t' 'NF != 4 || $4 != "reads.fq" {exit 1} END {if(NR!=2)exit 1}' filenames.tsv
    seqkit seq -w 3 reads.fq > wrapped.fq
    printf '@r1\nACG\nTNN\n+\nABC\nDEF\n@r2\nTTA\nGGG\nTTA\nGGG\n+\nFFF\nFFF\nFFF\nFFF\n' > expected.fq
    cmp wrapped.fq expected.fq
    seqkit fq2fa reads.fq > select.fa
    seqkit fa2fq -f select.fa reads.fq > round.fq
    cmp reads.fq round.fq
    ;;
  compression)
    cp /opt/seqkit/share/fixtures/reads.fq reads.fq
    cp /opt/seqkit/share/fixtures/reads.fq.bgz reads.fq.bgz
    seqkit seq reads.fq.bgz > bgzf.fq
    cmp reads.fq bgzf.fq
    for ext in gz xz zst bz2 lz4; do
        seqkit seq reads.fq -o "reads.fq.$ext"
        test -s "reads.fq.$ext"
        seqkit seq "reads.fq.$ext" > round.fq
        cmp reads.fq round.fq
    done
    ;;
  delta)
    printf '>a\nAAAA\n>b\nAAAA\n>c\nAAAA\n>d\nAAAA\n' > equal.fa
    seqkit stats -Ta --quiet equal.fa > stats.tsv
    awk -F '\t' 'NR==2 {if($13!=4 || $14!=2)exit 1; ok=1} END {if(!ok)exit 1}' stats.tsv
    printf '>a\nACGT\n>b\nTTAA\n>c\nCCGG\n' > seqs.fa
    seqkit sample2 -n 2 -s 7 seqs.fa > sampled.fa
    test "$(grep -c '^>' sampled.fa)" = 2
    seqkit split2 -s 1 -W 2 -O parts seqs.fa
    test -s parts/seqs.part_01.fa
    test -s parts/seqs.part_03.fa
    seqkit split -s 1 -W 2 -O otherparts seqs.fa
    test -s otherparts/seqs.part_01.fa
    printf '>a\nACGU\n' > rna.fa
    printf '>a\nACGT\n' > dna.fa
    printf '>b\nACGT\n' > renamed.fa
    seqkit sum --rna2dna rna.fa > rna.sum
    seqkit sum dna.fa > dna.sum
    test "$(cut -f1 rna.sum)" = "$(cut -f1 dna.sum)"
    seqkit sum -i dna.fa > id1.sum
    seqkit sum -i renamed.fa > id2.sum
    test "$(cut -f1 id1.sum)" != "$(cut -f1 id2.sum)"
    grep -F 'seqkit.v0.1_DLS_k0_' dna.sum
    ;;
  replace)
    printf '@r1\nACGTAC\n+\nABCDEF\n' > input.fq
    seqkit replace -s -p CG -r TT input.fq > equal.fq
    printf '@r1\nATTTAC\n+\nABCDEF\n' > expected.fq
    cmp equal.fq expected.fq
    seqkit replace -s -p CG -r '' input.fq > deletion.fq
    printf '@r1\nATAC\n+\nADEF\n' > expected.fq
    cmp deletion.fq expected.fq
    if seqkit replace -s -p CG -r AAA input.fq > bad.fq 2> error.txt; then exit 1; fi
    grep -Ei 'longer|length|increas' error.txt
    if seqkit stats missing.fa > badstats.txt 2> missing.txt; then exit 1; fi
    grep -F 'missing.fa' missing.txt
    ;;
  monitor)
    printf '>a\nAAAA\n>b\nCCCC\n>c\nGGGGGG\n' > input.fa
    seqkit watch -f GCSkew -B 3 -W 0 -y -Q -x input.fa > pass.fa 2> hist.tsv
    cmp input.fa pass.fa
    if grep -F 'NaN' hist.tsv; then exit 1; fi
    grep -F 'Count' hist.tsv
    for ext in png pdf svg; do
        seqkit watch -B 3 -W 0 -O "hist.$ext" input.fa > stdout.txt 2> terminal.txt
        test -s "hist.$ext"
    done
    if seqkit watch -p 0 input.fa > invalid.txt 2>&1; then exit 1; fi
    grep -F 'must not be 0' invalid.txt
    if seqkit watch -f ReadLen,GC input.fa > invalid.txt 2>&1; then exit 1; fi
    grep -F 'exactly one field' invalid.txt
    mkdir inputs
    cp input.fa inputs/a.fna
    seqkit scat -f -i fasta --quiet inputs > concatenated.fa
    cmp input.fa concatenated.fa
    seqkit sana -i fasta --quiet input.fa input.fa > repaired.fa
    test "$(grep -c '^>' repaired.fa)" = 6
    ;;
  bam)
    cp /opt/seqkit/share/fixtures/tiny.bam input.bam
    seqkit bam -s input.bam 2> stats.tsv
    awk -F '\t' 'NR==2 {if($3!=3 || $7!=3 || $8!=3)exit 1; ok=1} END {if(!ok)exit 1}' stats.tsv
    seqkit bam -f ReadLen -Q -y -W 0 -E 'printf before > before.txt' -e 'printf after > after.txt' input.bam > stdout.txt 2> hist.tsv
    grep -Fx before before.txt
    grep -Fx after after.txt
    grep -F 'Count' hist.tsv
    seqkit bam -f ReadLen -Q -x -W 0 input.bam -o pass.bam > stdout.txt 2> report.txt
    seqkit bam -s pass.bam 2> pass.tsv
    awk -F '\t' 'NR==2 {if($7!=3)exit 1; ok=1} END {if(!ok)exit 1}' pass.tsv
    if seqkit bam -f ReadLen -p 0 input.bam > invalid.txt 2>&1; then exit 1; fi
    grep -F 'must not be 0' invalid.txt
    if seqkit bam -f ReadLen input.bam input.bam > invalid.txt 2>&1; then exit 1; fi
    grep -Ei 'single|one|multiple' invalid.txt
    ;;
  *) printf 'unknown smoke mode: %s\n' "$mode" >&2; exit 2 ;;
esac
