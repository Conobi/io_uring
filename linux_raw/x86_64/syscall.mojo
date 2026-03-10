from sys._assembly import inlined_assembly
from sys.intrinsics import _mlirtype_is_eq

comptime AnyTrivialRegType = __mlir_type[`!kgen.type`]


# ===----------------------------------------------------------------------===#
# 0-arg
# ===----------------------------------------------------------------------===#


@always_inline("nodebug")
fn syscall[
    nr: IntLiteral,
    result_type: AnyTrivialRegType,
    /,
    *,
    has_side_effect: Bool = True,
    uses_memory: Bool = True,
]() -> result_type:
    """Generates assembly via inline for syscall with 0 args."""
    comptime has_out = not _mlirtype_is_eq[result_type, NoneType]()
    comptime out = "={rax},0" if has_out else "{rax}"
    comptime mem = ",~{rcx},~{r11},~{memory}" if uses_memory else ",~{rcx},~{r11}"
    return inlined_assembly[
        "syscall",
        result_type,
        constraints = out + mem,
        has_side_effect=has_side_effect,
    ](nr)


# ===----------------------------------------------------------------------===#
# 1-arg
# ===----------------------------------------------------------------------===#


@always_inline("nodebug")
fn syscall[
    arg0_type: AnyTrivialRegType, //,
    nr: IntLiteral,
    result_type: AnyTrivialRegType,
    /,
    *,
    has_side_effect: Bool = True,
    uses_memory: Bool = True,
](arg0: arg0_type) -> result_type:
    """Generates assembly via inline for syscall with 1 arg."""
    comptime has_out = not _mlirtype_is_eq[result_type, NoneType]()
    comptime out = "={rax},0" if has_out else "{rax}"
    comptime mem = ",~{rcx},~{r11},~{memory}" if uses_memory else ",~{rcx},~{r11}"
    return inlined_assembly[
        "syscall",
        result_type,
        constraints = out + ",{rdi}" + mem,
        has_side_effect=has_side_effect,
    ](nr, arg0)


# ===----------------------------------------------------------------------===#
# 2-arg
# ===----------------------------------------------------------------------===#


@always_inline("nodebug")
fn syscall[
    arg0_type: AnyTrivialRegType,
    arg1_type: AnyTrivialRegType, //,
    nr: IntLiteral,
    result_type: AnyTrivialRegType,
    /,
    *,
    has_side_effect: Bool = True,
    uses_memory: Bool = True,
](arg0: arg0_type, arg1: arg1_type) -> result_type:
    """Generates assembly via inline for syscall with 2 args."""
    comptime has_out = not _mlirtype_is_eq[result_type, NoneType]()
    comptime out = "={rax},0" if has_out else "{rax}"
    comptime mem = ",~{rcx},~{r11},~{memory}" if uses_memory else ",~{rcx},~{r11}"
    return inlined_assembly[
        "syscall",
        result_type,
        constraints = out + ",{rdi},{rsi}" + mem,
        has_side_effect=has_side_effect,
    ](nr, arg0, arg1)


# ===----------------------------------------------------------------------===#
# 3-arg
# ===----------------------------------------------------------------------===#


@always_inline("nodebug")
fn syscall[
    arg0_type: AnyTrivialRegType,
    arg1_type: AnyTrivialRegType,
    arg2_type: AnyTrivialRegType, //,
    nr: IntLiteral,
    result_type: AnyTrivialRegType,
    /,
    *,
    has_side_effect: Bool = True,
    uses_memory: Bool = True,
](arg0: arg0_type, arg1: arg1_type, arg2: arg2_type) -> result_type:
    """Generates assembly via inline for syscall with 3 args."""
    comptime has_out = not _mlirtype_is_eq[result_type, NoneType]()
    comptime out = "={rax},0" if has_out else "{rax}"
    comptime mem = ",~{rcx},~{r11},~{memory}" if uses_memory else ",~{rcx},~{r11}"
    return inlined_assembly[
        "syscall",
        result_type,
        constraints = out + ",{rdi},{rsi},{rdx}" + mem,
        has_side_effect=has_side_effect,
    ](nr, arg0, arg1, arg2)


# ===----------------------------------------------------------------------===#
# 4-arg
# ===----------------------------------------------------------------------===#


@always_inline("nodebug")
fn syscall[
    arg0_type: AnyTrivialRegType,
    arg1_type: AnyTrivialRegType,
    arg2_type: AnyTrivialRegType,
    arg3_type: AnyTrivialRegType, //,
    nr: IntLiteral,
    result_type: AnyTrivialRegType,
    /,
    *,
    has_side_effect: Bool = True,
    uses_memory: Bool = True,
](
    arg0: arg0_type, arg1: arg1_type, arg2: arg2_type, arg3: arg3_type
) -> result_type:
    """Generates assembly via inline for syscall with 4 args."""
    comptime has_out = not _mlirtype_is_eq[result_type, NoneType]()
    comptime out = "={rax},0" if has_out else "{rax}"
    comptime mem = ",~{rcx},~{r11},~{memory}" if uses_memory else ",~{rcx},~{r11}"
    return inlined_assembly[
        "syscall",
        result_type,
        constraints = out + ",{rdi},{rsi},{rdx},{r10}" + mem,
        has_side_effect=has_side_effect,
    ](nr, arg0, arg1, arg2, arg3)


# ===----------------------------------------------------------------------===#
# 5-arg
# ===----------------------------------------------------------------------===#


@always_inline("nodebug")
fn syscall[
    arg0_type: AnyTrivialRegType,
    arg1_type: AnyTrivialRegType,
    arg2_type: AnyTrivialRegType,
    arg3_type: AnyTrivialRegType,
    arg4_type: AnyTrivialRegType, //,
    nr: IntLiteral,
    result_type: AnyTrivialRegType,
    /,
    *,
    has_side_effect: Bool = True,
    uses_memory: Bool = True,
](
    arg0: arg0_type,
    arg1: arg1_type,
    arg2: arg2_type,
    arg3: arg3_type,
    arg4: arg4_type,
) -> result_type:
    """Generates assembly via inline for syscall with 5 args."""
    comptime has_out = not _mlirtype_is_eq[result_type, NoneType]()
    comptime out = "={rax},0" if has_out else "{rax}"
    comptime mem = ",~{rcx},~{r11},~{memory}" if uses_memory else ",~{rcx},~{r11}"
    return inlined_assembly[
        "syscall",
        result_type,
        constraints = out + ",{rdi},{rsi},{rdx},{r10},{r8}" + mem,
        has_side_effect=has_side_effect,
    ](nr, arg0, arg1, arg2, arg3, arg4)


# ===----------------------------------------------------------------------===#
# 6-arg
# ===----------------------------------------------------------------------===#


@always_inline("nodebug")
fn syscall[
    arg0_type: AnyTrivialRegType,
    arg1_type: AnyTrivialRegType,
    arg2_type: AnyTrivialRegType,
    arg3_type: AnyTrivialRegType,
    arg4_type: AnyTrivialRegType,
    arg5_type: AnyTrivialRegType, //,
    nr: IntLiteral,
    result_type: AnyTrivialRegType,
    /,
    *,
    has_side_effect: Bool = True,
    uses_memory: Bool = True,
](
    arg0: arg0_type,
    arg1: arg1_type,
    arg2: arg2_type,
    arg3: arg3_type,
    arg4: arg4_type,
    arg5: arg5_type,
) -> result_type:
    """Generates assembly via inline for syscall with 6 args."""
    comptime has_out = not _mlirtype_is_eq[result_type, NoneType]()
    comptime out = "={rax},0" if has_out else "{rax}"
    comptime mem = ",~{rcx},~{r11},~{memory}" if uses_memory else ",~{rcx},~{r11}"
    return inlined_assembly[
        "syscall",
        result_type,
        constraints = out + ",{rdi},{rsi},{rdx},{r10},{r8},{r9}" + mem,
        has_side_effect=has_side_effect,
    ](nr, arg0, arg1, arg2, arg3, arg4, arg5)
