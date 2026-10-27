"""Validate AMD inference primitives in the installed community wheel."""
import json
import platform

import torch
import torch.nn.functional as F


def main():
    assert torch.version.hip, "This is not a ROCm-enabled PyTorch build"
    assert torch.cuda.is_available(), "No GPU is accessible"
    props = torch.cuda.get_device_properties(0)
    assert "gfx1101" in props.gcnArchName, props.gcnArchName
    torch.manual_seed(123)
    checks = {}
    for dtype in (torch.float32, torch.float16, torch.bfloat16):
        x = torch.randn(256, 256, dtype=dtype)
        expected = x.float() @ x.float().T
        actual = (x.cuda() @ x.cuda().T).float().cpu()
        torch.testing.assert_close(actual, expected, rtol=0.03, atol=0.3)
        checks[str(dtype)] = "matmul passed"
    image = torch.randn(1, 16, 64, 64, device="cuda", dtype=torch.float16)
    weight = torch.randn(32, 16, 3, 3, device="cuda", dtype=torch.float16)
    assert torch.isfinite(F.conv2d(image, weight)).all().item()
    q = torch.randn(1, 4, 128, 64, device="cuda", dtype=torch.float16)
    actual = F.scaled_dot_product_attention(q, q, q)
    expected = F.scaled_dot_product_attention(q.cpu().float(), q.cpu().float(), q.cpu().float())
    torch.testing.assert_close(actual.cpu().float(), expected, rtol=0.03, atol=0.03)
    torch.cuda.synchronize()
    checks.update(conv2d="passed", sdpa="passed")
    print(json.dumps({"python": platform.python_version(), "torch": torch.__version__,
                      "hip": torch.version.hip, "gpu": props.name,
                      "architecture": props.gcnArchName, "checks": checks}, indent=2))


if __name__ == "__main__":
    main()
