# PyTorch / TheRock for gfx1101 and CPython 3.15

Community build workspace for AMD Radeon RX 7700 XT / 7800 XT on Ubuntu 26.04 x86-64.

## Status

TheRock SDK 10.3.0a20261027 is installed in an isolated build environment. Its 27 SDK tests passed with access to the RX 7700 XT. PyTorch and companion source checkouts are being prepared. **No successful PyTorch wheel build or GPU inference test is claimed yet.**

Sources are taken from upstream `main`, with exact commits recorded for each build. No older interpreter or ROCm release is substituted automatically.

## Build

The local `build-and-verify.sh` uses the prepared TheRock checkout and CPython 3.15.2 environment under this task's `work/` directory. It records build logs, source revisions and dependency versions alongside wheels in `artifacts/`.

Run GPU verification outside restricted sandboxes which hide `/dev/kfd`:

```bash
PATH="/path/to/buildenv/bin:$PATH" python verify_gpu.py
```

## Distribution scope

Wheels built directly on Ubuntu 26.04 are **not certified manylinux wheels**. Do not rename their platform tags or claim compatibility with older distributions. A portable manylinux build is a separate build-and-test target.

The AMD runtime is supplied by the matching TheRock packages. These are AMD HIP/ROCm builds, not CUDA builds. Python wheels are not portable across CPython ABI versions.

## Upstream projects and licensing

- https://github.com/ROCm/TheRock
- https://github.com/pytorch/pytorch
- https://github.com/ROCm/triton
- https://github.com/pytorch/audio
- https://github.com/pytorch/vision

This repository is an unofficial community distribution. Upstream software and bundled third-party components retain their respective licenses. Include wheel license notices, source revisions, local patches, dependency metadata, test results and SHA-256 checksums in any release. Do not publish build environments, credentials or unreviewed cache contents.
