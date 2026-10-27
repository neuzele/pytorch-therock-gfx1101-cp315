#!/usr/bin/env bash
set -euo pipefail

RELEASE_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
TASK_ROOT="$(cd -- "$RELEASE_ROOT/../.." && pwd)"
BUILD_ENV="$TASK_ROOT/work/buildenv"
SOURCE_ROOT="$TASK_ROOT/work/TheRock/external-builds/pytorch"
export PATH="$BUILD_ENV/bin:$PATH"
export PIP_CACHE_DIR="$TASK_ROOT/work/pip-cache"
export XDG_CACHE_HOME="$TASK_ROOT/work/cache"
export TRITON_HOME="$TASK_ROOT/work/triton-cache"
export MAX_JOBS="${MAX_JOBS:-16}"
mkdir -p "$RELEASE_ROOT/artifacts" "$PIP_CACHE_DIR" "$XDG_CACHE_HOME"
mkdir -p "$TRITON_HOME"

python --version
python -m pip freeze > "$RELEASE_ROOT/artifacts/build-environment-before.txt"
for project in pytorch triton pytorch_audio pytorch_vision; do
  git -C "$SOURCE_ROOT/$project" rev-parse HEAD > "$RELEASE_ROOT/artifacts/$project.commit"
  git -C "$SOURCE_ROOT/$project" diff --binary > "$RELEASE_ROOT/artifacts/$project.patch"
done
git -C "$TASK_ROOT/work/TheRock" rev-parse HEAD > "$RELEASE_ROOT/artifacts/therock.commit"

python "$SOURCE_ROOT/build_prod_wheels.py" build \
  --pytorch-rocm-arch gfx1101 \
  --pytorch-git-ref main \
  --release-type dev \
  --root-checkout-dir "$SOURCE_ROOT" \
  --build-triton --build-pytorch-audio --build-pytorch-vision --no-build-apex \
  --output-dir "$RELEASE_ROOT/artifacts/wheels" \
  2>&1 | tee "$RELEASE_ROOT/artifacts/build.log"

python -m pip check
python "$RELEASE_ROOT/verify_gpu.py" | tee "$RELEASE_ROOT/artifacts/gpu-tests.json"
python -m pip freeze > "$RELEASE_ROOT/artifacts/build-environment-after.txt"
(
  cd "$RELEASE_ROOT/artifacts/wheels"
  sha256sum -- *.whl > ../SHA256SUMS
)
