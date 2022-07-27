def _carbon_toolchain_impl(ctx):
    prelude = ctx.actions.declare_file("prelude.carbon")
    ctx.actions.symlink(
        output = prelude,
        target_file = ctx.file.prelude,
    )

    return [
        platform_common.ToolchainInfo(
            interpreter = ctx.executable.interpreter,
            driver = ctx.executable.driver,
            prelude = prelude,
        ),
    ]

carbon_toolchain = rule(
    implementation = _carbon_toolchain_impl,
    executable = False,
    attrs = {
        "interpreter": attr.label(
            doc = """An interpreter. This is currently the carbon explorer.
            As soon as we have a compiler we can remove this.""",
            default = "@carbon//explorer:explorer",
            executable = True,
            cfg = "exec",
        ),
        "driver": attr.label(
            doc = """The carbon driver. Currently stops at the semantic AST,
            since we do not have AST->LLVMIR yet.
            """,
            default = "@carbon//toolchain/driver:carbon",
            executable = True,
            cfg = "exec",
        ),
        "prelude": attr.label(
            doc = """The prelude.carbon file required by the interpreter.""",
            default = "@carbon//explorer:standard_libraries",
            allow_single_file = True,
        ),
    },
)
