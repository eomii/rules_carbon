Experimental rules for the experimental Carbon language
-------------------------------------------------------

This repository exposes ``carbon_binary`` to run Carbon files.

Since Carbon does not have a compiler yet, the ``carbon_binary`` target is a
shell wrapper around the proof-of-concept Carbon explorer. It is also only able
to take in a single source file as input.

- Examples: `rules_carbon/examples <https://github.com/eomii/rules_carbon/tree/main/examples>`_.

**Planned features**

- A full Carbon toolchain, as soon as a lowering to some form of processable IR
  (probably LLVM IR) exists.
- ``carbon_library``, as soon as ``import`` is usable.
- Carbon-C++ interop with the toolchains in
  `rules_ll <https://github.com/eomii/rules_ll>`_, as soon as this is feature is
  implemented.

Quickstart
----------

Install `bazelisk <https://bazel.build/install/bazelisk>`_.

Execute the following commands in an empty directory to set up a Bazel module
capable of using ``carbon_binary``:

.. code:: bash

   touch WORKSPACE.bazel .bazelrc
   echo cbb4eb1973a7fb49d15ced3fea6498f714f3ab0c > .bazelversion
   echo 'bazel_dep(name="rules_carbon", version="20220727.0")' > MODULE.bazel

Note that we use CI images of Bazel here because the prereleases do not include
the bugfixes we need.

Copy the following lines into the just created ``.bazelrc`` file:

.. code:: bash

   # Upstream LLVM/Clang requires C++17. This will only configure rules_cc.
   build --repo_env=BAZEL_CXXOPTS='-std=c++17'
   run --repo_env=BAZEL_CXXOPTS='-std=c++17'

   # Separate the toolchain from regular code. This will put execution artifacts
   # into bazel-out/ll_linux_exec_platform-opt-exec-<hash>.
   build --experimental_platform_in_output_dir
   run --experimental_platform_in_output_dir

   # We require bzlmod.
   build --experimental_enable_bzlmod
   run --experimental_enable_bzlmod

   # We use a custom registry.
   build --registry=https://raw.githubusercontent.com/eomii/bazel-eomii-registry/main/
   run --registry=https://raw.githubusercontent.com/eomii/bazel-eomii-registry/main/

   # Hash diff (baseline config, transition config) in bazel-out directory names.
   build --experimental_output_directory_naming_scheme=diff_against_baseline
   run --experimental_output_directory_naming_scheme=diff_against_baseline

   # Exec configuration handled by experimental_output_directory_layout.
   build --experimental_exec_configuration_distinguisher=off
   run --experimental_exec_configuration_distinguisher=off

You can now load the ``carbon_binary`` rule definition in your
``BUILD.bazel`` files. For instance:

.. code:: python

   load("@rules_carbon//carbon:defs.bzl", "carbon_binary")

   carbon_binary(
      name = "hello_world",
      srcs = ["hello_world.carbon"],
      # Uncomment the setting below to see fancy parser output.
      # This setting is also enabled by running with --compilation_mode=dbg.
      # interpreter_flags = [
      #     "--parser_debug",
      # ]
   )

See `rules_carbon/examples <https://github.com/eomii/rules_carbon/tree/main/examples>`_
for full examples.

Contributing
------------

Before you send a PR, install the ``pre-commit`` hooks::

   pip install pre-commit
   pre-commit install

and verify that all tools pass without failure on the entire repository::

   pre-commit run --all-files

License
-------

Copyright 2022 `eomii <https://eomii.org>`_, distributed under the Apache 2.0
License.

The maintainers of ``rules_carbon`` absolutely love the Carbon project, but are
not affiliated with it in any way.
