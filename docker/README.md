# SeqKit 容器、许可证和测试数据

构建必须在 app root 执行 `docker build -f docker/Dockerfile .`，与原样 canonical
Action 一致。分别构建 native amd64/arm64；禁止以 docker 子目录构建结果替代。

## 固定上游和许可

- 官方 release：v2.14.0；tag commit `facf0f7120483f9e39725c66dd83f5f14e048afd`。
- `Dockerfile` 固定双架构官方资产 SHA256 和 Debian 12 slim 多架构 digest。
- `licenses.tar.gz` 来自该 commit 的 go.mod/go.sum：54 个声明 module 均验证 Go h1，
  原样提取 LICENSE/COPYING/NOTICE/UNLICENSE/OFL 等；包含 SeqKit 和 Go 1.27.0 原始许可证。
- 两个 binary 内嵌的52个实际依赖名称、版本、h1 均与该 inventory 对齐。另两个为声明
  但未链接的依赖，保留其 notice 不代表它们是运行必需组件。内嵌字体不另行下载。
- 原始 notices 与 `modules.json` 在 `/opt/seqkit/share/licenses`；不能只保留上游 MIT
  而丢弃依赖/字体条款。官方 binary 的 `vcs.modified=true` 已在 README/release 披露。
- bundle SHA256：`54bcfae56973297dfa8f1c53aa88f58be914c2b94f2ed2f043abfaafa7b3af31`。
- 从 builder 复制的 CA bundle 同步保留 Debian ca-certificates 原始 copyright；
  不能只复制证书数据而漏掉对应 notice。

## 极小合成 fixture

`fixtures.tar.gz` 是本次包装测试生成的合成输入，不是生产/生物学验收数据：

- `reads.fq`：2条 reads，用不同质量字符验证质量值同步编辑。
- `reads.fq.bgz`：相同 FASTQ 分布在多个 BGZF block，验证跨块读取。
- `tiny.bam`：chr1 长1000、3条8碱基 primary mapped reads；含 NM 标签。
  按 BAM/BGZF 字节结构用 Python stdlib 生成，不引入 Samtools 为运行依赖。
- fixture archive SHA256：`8ee85946bcccc3d4c188ccaa83eb8019ca81feca7987077866667fe76d53d8cf`。
- reads SHA256：`0c7cb88a8ef2ae1a82b27c80315d5900e35c90a77d9e8ae46f675a517edb1e5f`；
  BGZF SHA256：`b9e6605cf8886b0ac484515922222105d0249741c9311765ad63a08f1a738608`；
  BAM SHA256：`0734613034045890db9c623dc7a8f8f282ed07ebda90b9b47099144d971879ab`。

## 运行与回归边界

`smoke.sh` 每个 mode 独立创建私有 scratch，无前序状态依赖；错误日志回放并保留非零码。
manifest combined exist、每个单探针和每条 test 均需在 fresh/offline 环境执行，再测
Docker/Podman 只读根及同 OCI 的真实只读 SIF。direct 不挂生产输入，不伪造 mounted marker。
持久输出、stdin、空格参数、faidx sidecar、只读输入及普通用户 ownership 另用真实 wrapper。

BAM `-s` 输出在 stderr；faidx 默认 `.fai`，`-f` 才是 `.seqkit.fai`，测试断言不能混淆。
`bam --exec-before/after` 隐性依赖 Bash，不能为压缩镜像删除。绘图使用内嵌 Go/font 组件。
构建期不跑完整绘图或严格时序测试；完整功能在构建后的离线 smoke 中验证。
