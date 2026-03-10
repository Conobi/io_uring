from bit import byte_swap
from sys.info import align_of, is_big_endian, size_of
from linux_raw.utils import DTypeArray


comptime StaticMutOrigin = __mlir_attr[
    `#lit.origin.field<`,
    `#lit.static.origin : !lit.origin<1>`,
    `, "__constants__"> : !lit.origin<1>`,
]


@always_inline("nodebug")
fn _aligned_u64[T: AnyType]():
    # [Linux]: https://github.com/torvalds/linux/blob/v6.7/include/uapi/linux/types.h#L47.
    constrained[align_of[T]() >= 8]()


@always_inline("nodebug")
fn _size_eq[T: AnyType, I: AnyType]():
    constrained[size_of[T]() == size_of[I]()]()


@always_inline("nodebug")
fn _size_eq[T: AnyType, size: IntLiteral]():
    constrained[size_of[T]() == size]()


@always_inline("nodebug")
fn _size_eq[T: AnyType](size: Int):
    debug_assert(size_of[T]() == size, "size mismatch")


@always_inline("nodebug")
fn _align_eq[T: AnyType, I: AnyType]():
    constrained[align_of[T]() == align_of[I]()]()


@always_inline("nodebug")
fn _align_eq[T: AnyType, align: IntLiteral]():
    constrained[align_of[T]() == align]()


@always_inline("nodebug")
fn _align_eq[T: AnyType](align: Int):
    debug_assert(align_of[T]() == align, "alignment mismatch")


@always_inline("nodebug")
fn _to_be[type: DType, size: Int](value: SIMD[type, size]) -> SIMD[type, size]:
    @parameter
    if is_big_endian():
        return value
    else:
        return byte_swap(value)
