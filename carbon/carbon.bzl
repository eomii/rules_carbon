#TODO: We can only create carbon_library when we have a proper toolchain :D

CARBON_RUNFILE = """#/bin/sh
{interpreter} {input_file}
"""

def _carbon_binary_impl(ctx):
    """Implementation function for carbon_binary.

    Args:
        ctx: The build context.
    """
    inputs = ctx.files.srcs
    if len(inputs) > 1:
        fail("""The srcs attribute currently only supports a single source file.
This limitation will be lifted as soon as Carbon supports the imports.
""")

    output = ctx.actions.declare_file(
        "carbon_explorer_run_{}.sh".format(ctx.label.name),
    )

    args = ctx.attr.interpreter_flags
    if ctx.var["COMPILATION_MODE"] == "dbg":
        args = args + ["--parser_debug"]

    output_content = """#!/bin/sh
{interpreter} --prelude={prelude} {args} {input}
""".format(
        interpreter = ctx.toolchains["//carbon:toolchain_type"].interpreter.short_path,
        prelude = ctx.toolchains["//carbon:toolchain_type"].prelude.path,
        args = " ".join(args),
        input = inputs[0].short_path,
    )

    ctx.actions.write(
        output = output,
        content = output_content,
        is_executable = True,
    )

    runfiles = ctx.runfiles(
        files = ctx.files.srcs + [
            ctx.toolchains["//carbon:toolchain_type"].interpreter,
            ctx.toolchains["//carbon:toolchain_type"].prelude,
        ],
    )

    return [
        DefaultInfo(
            executable = output,
            runfiles = runfiles,
        ),
    ]

carbon_binary = rule(
    implementation = _carbon_binary_impl,
    executable = True,
    attrs = {
        "srcs": attr.label_list(
            doc = """Compilable source files for this target.

            The only file extension currently allowed is `".carbon"`.
            """,
            allow_files = [".carbon"],
        ),
        "interpreter_flags": attr.string_list(
            doc = "Additional arguments for the interpreter.",
        ),
    },
    toolchains = [
        "//carbon:toolchain_type",
    ],
    doc = """
Creates a carbon executable.

This is currently just a shell script that invokes the POC carbon explorer.
As soon as an actual toolchain exists this will be changed to produce a binary
executable.

Carbon does not yet have an implementation for C++ interop. As soon as
an implementation exists the attribute section for this target will be expanded
accordingly.
""",
)
