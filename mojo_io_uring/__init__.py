"""mojo-io-uring: io_uring userspace interface for Mojo."""
import sysconfig
from pathlib import Path as _Path

__version__ = "0.1.0"


def mojo_packages_path() -> _Path:
    """Path to the shared mojo_packages/ directory in platlib."""
    return _Path(sysconfig.get_path("platlib")) / "mojo_packages"


def mojo_lib_path() -> _Path:
    """Path to native shared libraries."""
    return mojo_packages_path() / "lib"
