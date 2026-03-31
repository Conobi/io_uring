#!/usr/bin/env python3
"""Build Mojo package wheels from pre-built artifacts.

Usage:
  # Pure wheel (Type A or the mojopkg part of Type B):
  python scripts/make_wheel.py pure --version 0.1.0

  # Native wheel (Type B only):
  python scripts/make_wheel.py native --version 0.1.0 --platform manylinux_2_34_x86_64
"""
import argparse
import base64
import csv
import hashlib
import io
import os
import zipfile
from pathlib import Path

# ── Configuration (edit per project) ─────────────────────────────────────────

PROJECT_NAME = "mojo_io_uring"
DIST_NAME = "mojo-io-uring"
SUMMARY = "io_uring userspace interface for Mojo"
LICENSE = "Apache-2.0"
NATIVE_NAME = ""
NATIVE_DIST = ""

# Files to include in the pure wheel (relative to project root):
MOJOPKG_FILES = [
    "io_uring.mojopkg",
    "linux_raw.mojopkg",
    "mojix.mojopkg",
    "event_loop.mojopkg",
]

# Files to include in the native wheel (source path → install name):
NATIVE_LIBS = {}

# Runtime dependencies for the pure wheel:
PURE_DEPS = [
    "mojox",
]

# ── Helpers ──────────────────────────────────────────────────────────────────

def _sha256(data: bytes) -> str:
    d = hashlib.sha256(data).digest()
    return "sha256=" + base64.urlsafe_b64encode(d).rstrip(b"=").decode()


def _make_init(name: str, version: str) -> bytes:
    """Generate a discovery __init__.py."""
    return f'''\
"""{name}"""
import sysconfig
from pathlib import Path as _Path

__version__ = "{version}"

def mojo_packages_path() -> _Path:
    """Path to the shared mojo_packages/ directory in platlib."""
    return _Path(sysconfig.get_path("platlib")) / "mojo_packages"

def mojo_lib_path() -> _Path:
    """Path to native shared libraries."""
    return mojo_packages_path() / "lib"
'''.encode()


def _write_wheel(path: str, entries: list[tuple[str, bytes, bool]]):
    """Write a wheel zip from (arcname, data, executable) tuples."""
    dist_info = None
    for arc, _, _ in entries:
        if arc.endswith("/WHEEL"):
            dist_info = arc.rsplit("/", 1)[0]

    rec = io.StringIO()
    w = csv.writer(rec, lineterminator="\n")
    for arc, data, _ in entries:
        w.writerow((arc, _sha256(data), len(data)))
    w.writerow((f"{dist_info}/RECORD", "", ""))
    entries.append((f"{dist_info}/RECORD", rec.getvalue().encode(), False))

    os.makedirs(os.path.dirname(path) or ".", exist_ok=True)
    with zipfile.ZipFile(path, "w", zipfile.ZIP_DEFLATED) as zf:
        for arc, data, exe in entries:
            zi = zipfile.ZipInfo(arc, date_time=(1980, 1, 1, 0, 0, 0))
            zi.compress_type = zipfile.ZIP_DEFLATED
            zi.external_attr = (0o755 if exe else 0o644) << 16
            zf.writestr(zi, data)


# ── Pure wheel ───────────────────────────────────────────────────────────────

def build_pure(version: str, outdir: str) -> str:
    tag = "py3-none-any"
    dist_info = f"{PROJECT_NAME}-{version}.dist-info"
    data_dir = f"{PROJECT_NAME}-{version}.data/platlib"
    whl_name = f"{PROJECT_NAME}-{version}-{tag}.whl"

    deps = list(PURE_DEPS)
    if NATIVE_LIBS:
        deps.append(f"{NATIVE_DIST}=={version}")
    requires = "\n".join(f"Requires-Dist: {d}" for d in deps)

    metadata = f"""\
Metadata-Version: 2.1
Name: {DIST_NAME}
Version: {version}
Summary: {SUMMARY}
License: {LICENSE}
Requires-Python: >=3.10
{requires}
""".encode()

    wheel_meta = f"""\
Wheel-Version: 1.0
Generator: make_wheel.py
Root-Is-Purelib: true
Tag: {tag}
""".encode()

    entries: list[tuple[str, bytes, bool]] = []

    # Discovery module (wheel root → purelib)
    entries.append((f"{PROJECT_NAME}/__init__.py",
                    _make_init(DIST_NAME, version), False))

    # .mojopkg files (→ platlib via .data/)
    for pkg in MOJOPKG_FILES:
        data = Path(pkg).read_bytes()
        entries.append((f"{data_dir}/mojo_packages/{Path(pkg).name}", data, False))

    entries.append((f"{dist_info}/METADATA", metadata, False))
    entries.append((f"{dist_info}/WHEEL", wheel_meta, False))

    path = os.path.join(outdir, whl_name)
    _write_wheel(path, entries)
    return path


# ── Native wheel ─────────────────────────────────────────────────────────────

def build_native(version: str, platform: str, outdir: str) -> str:
    tag = f"py3-none-{platform}"
    dist_info = f"{NATIVE_NAME}-{version}.dist-info"
    data_dir = f"{NATIVE_NAME}-{version}.data/platlib"
    whl_name = f"{NATIVE_NAME}-{version}-{tag}.whl"

    metadata = f"""\
Metadata-Version: 2.1
Name: {NATIVE_DIST}
Version: {version}
Summary: Native libraries for {DIST_NAME}
License: {LICENSE}
Requires-Python: >=3.10
""".encode()

    wheel_meta = f"""\
Wheel-Version: 1.0
Generator: make_wheel.py
Root-Is-Purelib: false
Tag: {tag}
""".encode()

    entries: list[tuple[str, bytes, bool]] = []

    # Minimal Python module (wheel root → platlib since Root-Is-Purelib: false)
    entries.append((f"{NATIVE_NAME}/__init__.py",
                    f'"""{NATIVE_DIST}: native libraries."""\n'.encode(), False))

    # Native libraries (→ platlib via .data/)
    for src, install_name in NATIVE_LIBS.items():
        data = Path(src).read_bytes()
        entries.append((f"{data_dir}/mojo_packages/lib/{install_name}", data, True))

    entries.append((f"{dist_info}/METADATA", metadata, False))
    entries.append((f"{dist_info}/WHEEL", wheel_meta, False))

    path = os.path.join(outdir, whl_name)
    _write_wheel(path, entries)
    return path


# ── CLI ──────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    ap = argparse.ArgumentParser(description="Build Mojo package wheels")
    sub = ap.add_subparsers(dest="cmd", required=True)

    p_pure = sub.add_parser("pure", help="Build the pure (mojopkg) wheel")
    p_pure.add_argument("--version", required=True)
    p_pure.add_argument("--outdir", default="dist")

    p_native = sub.add_parser("native", help="Build a platform-specific native wheel")
    p_native.add_argument("--version", required=True)
    p_native.add_argument("--platform", required=True)
    p_native.add_argument("--outdir", default="dist")

    args = ap.parse_args()
    if args.cmd == "pure":
        p = build_pure(args.version, args.outdir)
    else:
        p = build_native(args.version, args.platform, args.outdir)

    sz = os.path.getsize(p)
    print(f"Built: {p} ({sz:,} bytes)")
