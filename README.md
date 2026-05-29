# cd-hit

Source-built `cd-hit` container for clustering nucleotide and protein sequences.

## Quick Usage

```bash
docker pull docker.io/picotainers/cd-hit:latest
docker run --rm docker.io/picotainers/cd-hit:latest --help
```

## Usage

Run CD-HIT with files mounted from the current directory:

```bash
docker run --rm -v "$PWD":/data docker.io/picotainers/cd-hit:latest \
  -i input.fasta \
  -o clustered.fasta \
  -c 0.9
```

The container entrypoint is `cd-hit`, so commands can be passed directly. For compatibility with older examples, a leading `cd-hit` argument is also accepted:

```bash
docker run --rm -v "$PWD":/data docker.io/picotainers/cd-hit:latest cd-hit -i input.fasta -o clustered.fasta -c 0.9
```

## Building

```bash
docker build -t docker.io/picotainers/cd-hit:latest .
docker run --rm docker.io/picotainers/cd-hit:latest --help
```

This image is built from the upstream CD-HIT source release tag pinned in the Dockerfile.
