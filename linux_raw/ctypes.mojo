# Currently only x86_64 platform is supported.

# The signedness of `char` is platform-specific.
comptime c_char = c_schar

# The following assumes that Linux is always either ILP32 or LP64,
# and char is always 8-bit.
#
# In theory, `c_long` and `c_ulong` could be `Int` and `UInt`
# respectively, however in practice Linux doesn't use them in that way
# consistently. So stick with the convention followed by `libc` and
# others and use the fixed-width types.

comptime c_schar = Int8
comptime c_uchar = UInt8
comptime c_short = Int16
comptime c_ushort = UInt16
comptime c_int = Int32
comptime c_uint = UInt32
comptime c_long = Int64
comptime c_ulong = UInt64
comptime c_longlong = Int64
comptime c_ulonglong = UInt64
comptime c_float = Float32
comptime c_double = Float64

comptime c_void = Int8
