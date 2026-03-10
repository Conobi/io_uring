from mojix.io_uring import IoUringSetupFlags


@nonmaterializable(NoneType)
@register_passable("trivial")
struct PollingMode(Identifiable):
    var id: UInt8
    var setup_flags: IoUringSetupFlags

    @always_inline
    fn __init__(out self, *, id: UInt8, setup_flags: IoUringSetupFlags):
        self.id = id
        self.setup_flags = setup_flags

    @always_inline
    fn __is__(self, rhs: Self) -> Bool:
        """Defines whether one PollingMode has the same identity as another.

        Args:
            rhs: The PollingMode to compare against.

        Returns:
            True if the PollingModes have the same identity, False otherwise.
        """
        return self.id == rhs.id and self.setup_flags == rhs.setup_flags

    @always_inline
    fn __isnot__(self, rhs: Self) -> Bool:
        """Defines whether one PollingMode has a different identity than another.

        Args:
            rhs: The PollingMode to compare against.

        Returns:
            True if the PollingModes have different identities, False otherwise.
        """
        return self.id != rhs.id or self.setup_flags != rhs.setup_flags


comptime NOPOLL = PollingMode(id=0, setup_flags=IoUringSetupFlags())
comptime IOPOLL = PollingMode(id=1, setup_flags=IoUringSetupFlags.IOPOLL)
comptime SQPOLL = PollingMode(id=2, setup_flags=IoUringSetupFlags.SQPOLL)
