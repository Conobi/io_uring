from mojix import sigset_t
from mojix.ctypes import c_void
from mojix.io_uring import EnterArg, IoUringEnterFlags, IoUringGetEventsArg
from mojix.timespec import Timespec
from sys.info import size_of
from memory import UnsafePointer


struct WaitArg[
    sigmask_origin: ImmutOrigin,
    timespec_origin: ImmutOrigin,
]:
    comptime enter_flags = IoUringEnterFlags.EXT_ARG

    var arg: IoUringGetEventsArg

    # ===------------------------------------------------------------------=== #
    # Life cycle methods
    # ===------------------------------------------------------------------=== #

    @always_inline
    fn __init__(out self):
        self.arg = IoUringGetEventsArg()

    @always_inline
    fn __init__[
        origin: ImmutOrigin
    ](
        out self: WaitArg[origin, StaticConstantOrigin],
        ref [origin]sigmask: sigset_t,
    ):
        self.arg = IoUringGetEventsArg()
        self.arg.sigmask = Int(UnsafePointer(to=sigmask))
        self.arg.sigmask_sz = size_of[sigset_t]()

    @always_inline
    fn __init__[
        origin: ImmutOrigin
    ](
        out self: WaitArg[StaticConstantOrigin, origin],
        ref [origin]timespec: Timespec,
    ):
        self.arg = IoUringGetEventsArg()
        self.arg.ts = Int(UnsafePointer(to=timespec))

    @always_inline
    fn __init__(
        out self,
        ref [Self.sigmask_origin]sigmask: sigset_t,
        ref [Self.timespec_origin]timespec: Timespec,
    ):
        self.arg = IoUringGetEventsArg()
        self.arg.sigmask = Int(UnsafePointer(to=sigmask))
        self.arg.sigmask_sz = size_of[sigset_t]()
        self.arg.ts = Int(UnsafePointer(to=timespec))

    # ===-------------------------------------------------------------------===#
    # Methods
    # ===-------------------------------------------------------------------===#

    @always_inline
    fn as_enter_arg(
        self,
    ) -> EnterArg[
        size_of[IoUringGetEventsArg](),
        Self.enter_flags,
        origin_of(self),
    ]:
        return EnterArg[
            size_of[IoUringGetEventsArg](), Self.enter_flags, origin_of(self)
        ](arg_unsafe_ptr=rebind[UnsafePointer[c_void, StaticConstantOrigin]](
            UnsafePointer(to=self.arg).bitcast[c_void]()
        ))
