from .ctypes import c_void
from linux_raw.x86_64.errno import *
from memory import UnsafePointer


@register_passable("trivial")
struct Errno(Stringable):
    """The error type for `mojix` APIs.
    It only holds an OS error number, and no extra error info.

    Linux returns negated error numbers, and we leave them in negated form, so
    they are in the range `[-4095; 0)`.
    """

    comptime EACCES = Self(errno=EACCES)
    comptime EADDRINUSE = Self(errno=EADDRINUSE)
    comptime EADDRNOTAVAIL = Self(errno=EADDRNOTAVAIL)
    comptime EADV = Self(errno=EADV)
    comptime EAFNOSUPPORT = Self(errno=EAFNOSUPPORT)
    comptime EAGAIN = Self(errno=EAGAIN)
    comptime EALREADY = Self(errno=EALREADY)
    comptime EBADE = Self(errno=EBADE)
    comptime EBADF = Self(errno=EBADF)
    comptime EBADFD = Self(errno=EBADFD)
    comptime EBADMSG = Self(errno=EBADMSG)
    comptime EBADR = Self(errno=EBADR)
    comptime EBADRQC = Self(errno=EBADRQC)
    comptime EBADSLT = Self(errno=EBADSLT)
    comptime EBFONT = Self(errno=EBFONT)
    comptime EBUSY = Self(errno=EBUSY)
    comptime ECANCELED = Self(errno=ECANCELED)
    comptime ECHILD = Self(errno=ECHILD)
    comptime ECHRNG = Self(errno=ECHRNG)
    comptime ECOMM = Self(errno=ECOMM)
    comptime ECONNABORTED = Self(errno=ECONNABORTED)
    comptime ECONNREFUSED = Self(errno=ECONNREFUSED)
    comptime ECONNRESET = Self(errno=ECONNRESET)
    comptime EDEADLK = Self(errno=EDEADLK)
    comptime EDEADLOCK = Self(errno=EDEADLOCK)
    comptime EDESTADDRREQ = Self(errno=EDESTADDRREQ)
    comptime EDOM = Self(errno=EDOM)
    comptime EDOTDOT = Self(errno=EDOTDOT)
    comptime EDQUOT = Self(errno=EDQUOT)
    comptime EEXIST = Self(errno=EEXIST)
    comptime EFAULT = Self(errno=EFAULT)
    comptime EFBIG = Self(errno=EFBIG)
    comptime EHOSTDOWN = Self(errno=EHOSTDOWN)
    comptime EHOSTUNREACH = Self(errno=EHOSTUNREACH)
    comptime EHWPOISON = Self(errno=EHWPOISON)
    comptime EIDRM = Self(errno=EIDRM)
    comptime EILSEQ = Self(errno=EILSEQ)
    comptime EINPROGRESS = Self(errno=EINPROGRESS)
    comptime EINTR = Self(errno=EINTR)
    comptime EINVAL = Self(errno=EINVAL)
    comptime EIO = Self(errno=EIO)
    comptime EISCONN = Self(errno=EISCONN)
    comptime EISDIR = Self(errno=EISDIR)
    comptime EISNAM = Self(errno=EISNAM)
    comptime EKEYEXPIRED = Self(errno=EKEYEXPIRED)
    comptime EKEYREJECTED = Self(errno=EKEYREJECTED)
    comptime EKEYREVOKED = Self(errno=EKEYREVOKED)
    comptime EL2HLT = Self(errno=EL2HLT)
    comptime EL2NSYNC = Self(errno=EL2NSYNC)
    comptime EL3HLT = Self(errno=EL3HLT)
    comptime EL3RST = Self(errno=EL3RST)
    comptime ELIBACC = Self(errno=ELIBACC)
    comptime ELIBBAD = Self(errno=ELIBBAD)
    comptime ELIBEXEC = Self(errno=ELIBEXEC)
    comptime ELIBMAX = Self(errno=ELIBMAX)
    comptime ELIBSCN = Self(errno=ELIBSCN)
    comptime ELNRNG = Self(errno=ELNRNG)
    comptime ELOOP = Self(errno=ELOOP)
    comptime EMEDIUMTYPE = Self(errno=EMEDIUMTYPE)
    comptime EMFILE = Self(errno=EMFILE)
    comptime EMLINK = Self(errno=EMLINK)
    comptime EMSGSIZE = Self(errno=EMSGSIZE)
    comptime EMULTIHOP = Self(errno=EMULTIHOP)
    comptime ENAMETOOLONG = Self(errno=ENAMETOOLONG)
    comptime ENAVAIL = Self(errno=ENAVAIL)
    comptime ENETDOWN = Self(errno=ENETDOWN)
    comptime ENETRESET = Self(errno=ENETRESET)
    comptime ENETUNREACH = Self(errno=ENETUNREACH)
    comptime ENFILE = Self(errno=ENFILE)
    comptime ENOANO = Self(errno=ENOANO)
    comptime ENOBUFS = Self(errno=ENOBUFS)
    comptime ENOCSI = Self(errno=ENOCSI)
    comptime ENODATA = Self(errno=ENODATA)
    comptime ENODEV = Self(errno=ENODEV)
    comptime ENOENT = Self(errno=ENOENT)
    comptime ENOEXEC = Self(errno=ENOEXEC)
    comptime ENOKEY = Self(errno=ENOKEY)
    comptime ENOLCK = Self(errno=ENOLCK)
    comptime ENOLINK = Self(errno=ENOLINK)
    comptime ENOMEDIUM = Self(errno=ENOMEDIUM)
    comptime ENOMEM = Self(errno=ENOMEM)
    comptime ENOMSG = Self(errno=ENOMSG)
    comptime ENONET = Self(errno=ENONET)
    comptime ENOPKG = Self(errno=ENOPKG)
    comptime ENOPROTOOPT = Self(errno=ENOPROTOOPT)
    comptime ENOSPC = Self(errno=ENOSPC)
    comptime ENOSR = Self(errno=ENOSR)
    comptime ENOSTR = Self(errno=ENOSTR)
    comptime ENOSYS = Self(errno=ENOSYS)
    comptime ENOTBLK = Self(errno=ENOTBLK)
    comptime ENOTCONN = Self(errno=ENOTCONN)
    comptime ENOTDIR = Self(errno=ENOTDIR)
    comptime ENOTEMPTY = Self(errno=ENOTEMPTY)
    comptime ENOTNAM = Self(errno=ENOTNAM)
    comptime ENOTRECOVERABLE = Self(errno=ENOTRECOVERABLE)
    comptime ENOTSOCK = Self(errno=ENOTSOCK)
    comptime ENOTSUP = Self(errno=EOPNOTSUPP)
    """On Linux, `ENOTSUP` has the same value as `EOPNOTSUPP`."""
    comptime ENOTTY = Self(errno=ENOTTY)
    comptime ENOTUNIQ = Self(errno=ENOTUNIQ)
    comptime ENXIO = Self(errno=ENXIO)
    comptime EOPNOTSUPP = Self(errno=EOPNOTSUPP)
    comptime EOVERFLOW = Self(errno=EOVERFLOW)
    comptime EOWNERDEAD = Self(errno=EOWNERDEAD)
    comptime EPERM = Self(errno=EPERM)
    comptime EPFNOSUPPORT = Self(errno=EPFNOSUPPORT)
    comptime EPIPE = Self(errno=EPIPE)
    comptime EPROTO = Self(errno=EPROTO)
    comptime EPROTONOSUPPORT = Self(errno=EPROTONOSUPPORT)
    comptime EPROTOTYPE = Self(errno=EPROTOTYPE)
    comptime ERANGE = Self(errno=ERANGE)
    comptime EREMCHG = Self(errno=EREMCHG)
    comptime EREMOTE = Self(errno=EREMOTE)
    comptime EREMOTEIO = Self(errno=EREMOTEIO)
    comptime ERESTART = Self(errno=ERESTART)
    comptime ERFKILL = Self(errno=ERFKILL)
    comptime EROFS = Self(errno=EROFS)
    comptime ESHUTDOWN = Self(errno=ESHUTDOWN)
    comptime ESOCKTNOSUPPORT = Self(errno=ESOCKTNOSUPPORT)
    comptime ESPIPE = Self(errno=ESPIPE)
    comptime ESRCH = Self(errno=ESRCH)
    comptime ESRMNT = Self(errno=ESRMNT)
    comptime ESTALE = Self(errno=ESTALE)
    comptime ESTRPIPE = Self(errno=ESTRPIPE)
    comptime ETIME = Self(errno=ETIME)
    comptime ETIMEDOUT = Self(errno=ETIMEDOUT)
    comptime E2BIG = Self(errno=E2BIG)
    comptime ETOOMANYREFS = Self(errno=ETOOMANYREFS)
    comptime ETXTBSY = Self(errno=ETXTBSY)
    comptime EUCLEAN = Self(errno=EUCLEAN)
    comptime EUNATCH = Self(errno=EUNATCH)
    comptime EUSERS = Self(errno=EUSERS)
    comptime EWOULDBLOCK = Self(errno=EWOULDBLOCK)
    comptime EXDEV = Self(errno=EXDEV)
    comptime EXFULL = Self(errno=EXDEV)

    var id: Int16
    """The error number."""

    # ===------------------------------------------------------------------=== #
    # Life cycle methods
    # ===------------------------------------------------------------------=== #

    @always_inline("nodebug")
    fn __init__(out self, *, errno: UInt16):
        """Constructs an Errno from the error number.

        Args:
            errno: The error number.
        """
        self = Self(negated_errno=-Int16(errno))

    @always_inline("nodebug")
    fn __init__(out self, *, error: Error) raises:
        """Constructs an Errno from the Error message.

        Args:
            error: The Error message.

        Raises:
            If the given Error message cannot be parsed as an integer value.
        """
        self = Self(negated_errno=Int(String(error)))

    @always_inline("nodebug")
    fn __init__(out self, *, negated_errno: Int16):
        """Constructs an Errno from the negated error number.

        Args:
            negated_errno: The negated error number.
        """
        self.id = negated_errno
        # Linux returns negated error numbers in the range `[-4095; 0)`.
        debug_assert(
            self.id >= -4095 and self.id < 0, "error number out of range"
        )

    # ===-------------------------------------------------------------------===#
    # Operator dunders
    # ===-------------------------------------------------------------------===#

    @always_inline("nodebug")
    fn __is__(self, rhs: Self) -> Bool:
        """Defines whether one Errno has the same identity as another.

        Args:
            rhs: The Errno to compare against.

        Returns:
            True if the Errnos have the same identity, False otherwise.
        """
        return self.id == rhs.id

    @always_inline("nodebug")
    fn __isnot__(self, rhs: Self) -> Bool:
        """Defines whether one Errno has a different identity than another.

        Args:
            rhs: The Errno to compare against.

        Returns:
            True if the Errnos have different identities, False otherwise.
        """
        return self.id != rhs.id

    # ===-------------------------------------------------------------------===#
    # Trait implementations
    # ===-------------------------------------------------------------------===#

    @always_inline
    fn __str__(self) -> String:
        """Converts Errno to a string representation.

        Returns:
            A String of the error number.
        """
        return String(self.id)


@always_inline("nodebug")
fn _check_for_errors(raw: Scalar[DType.int64]) raises:
    if raw < 0:
        # Linux returns negated error numbers in the range `[-4095; 0)`.
        debug_assert(raw >= -4095, "error number out of range")
        raise String(raw)


@always_inline("nodebug")
fn _zero_result(raw: Scalar[DType.int64]):
    debug_assert(raw == 0, "non-zero result")


@always_inline("nodebug")
fn unsafe_decode_result[
    type: DType
](raw: Scalar[DType.int64]) raises -> Scalar[type]:
    """Unsafely checks for an error in the result of a syscall that encodes
    the value of the specified type on success.

    Parameters:
        type: The `DType` of the result.

    Args:
        raw: The result of a syscall.

    Returns:
        The value of the specified type.

    Raises:
        `Errno` if the syscall returned an error.

    Safety:
        This should only be used with syscalls that return a value of the given
        `type` on success.
    """
    _check_for_errors(raw)
    res = raw.cast[type]()
    debug_assert(res.cast[DType.int64]() == raw, "conversion is not lossless")
    return res


@always_inline("nodebug")
fn unsafe_decode_ptr(unsafe_ptr: UnsafePointer[c_void, StaticConstantOrigin]) raises:
    """Unsafely checks for an error in the result of a syscall that encodes
    a pointer on success.

    Args:
        unsafe_ptr: The result of a syscall.

    Raises:
        `Errno` if the syscall returned an error.

    Safety:
        This should only be used with pointers returned by a syscall.
    """
    _check_for_errors(
        Scalar[DType.int64](Int(unsafe_ptr))
    )


@always_inline("nodebug")
fn unsafe_decode_none(raw: Scalar[DType.int64]) raises:
    """Unsafely checks for an error in the result of a syscall that encodes
    a `NoneType` value on success.

    Args:
        raw: The result of a syscall.

    Raises:
        `Errno` if the syscall returned an error.

    Safety:
        This should only be used with syscalls that return a `NoneType` value
        on success.
    """
    if raw != 0:
        # Linux returns negated error numbers in the range `[-4095; 0)`.
        debug_assert(raw >= -4095 and raw < 0, "error number out of range")
        raise String(raw)
