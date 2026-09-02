# ElmerFront

ElmerFront was the original graphical pre-processor for [Elmer FEM](https://github.com/ElmerCSC/elmerfem): a Tcl/Tk interface over an OpenGL renderer for building models, defining bodies and boundaries, meshing them and writing solver input. It was superseded by ElmerGUI and removed from the Elmer tree on 29 November 2016.

**It builds and runs again.** Not as an archive of source, which is what this repository held until now, but as a program: CMake instead of autotools, its two deleted dependencies restored as submodules, and a start-up test that runs in CI on Linux, macOS and Windows across five compilers.

To be clear about what that does and does not mean: the C++ compiles, the program links, starts, initialises MATC, loads its Tcl scripts and opens its interface. Nobody has sat down and modelled anything with it. There is a difference between *revived* and *vindicated*, and only the first is claimed here.

## Why it stopped building, and what it took

Four things stood between the 2016 snapshot and a working build. Two turned out not to be the obstacles they looked like.

| | verdict |
| --- | --- |
| **autotools** | Not an obstacle. Elmer had already moved to CMake, and Peter Råback deleted front's autotools files in the same 2016 sweep. Porting the build was mechanical. |
| **OpenGL and Tcl/Tk** | Not an obstacle. Both are packaged everywhere. The only work was four uses of `interp->result`, a field Tcl deprecated in 8.0 and removed by 8.6; `Tcl_GetStringResult()` is the documented replacement. |
| **libeioc and libmatc** | Real, and now solved. `configure.in` required both through `ACX_EIOC` and `ACX_MATC`, and Elmer deleted both within a day of deleting front. They are submodules here. |
| **twenty year old C++** | Real, and much smaller than expected: **four distinct problems in 63,806 lines**. |

Those four, in full, because "we modernised the C++" is the kind of claim that deserves an itemised bill:

- **`ecif_parameter.cpp` wrote a null pointer past the end of an array.** The line was `data_strings[old_len + len + 2] = '\0';` where `data_strings` is a `char**` and the intended target was the `char*` buffer allocated three lines earlier. In C++98 `'\0'` is an integer constant expression with value zero, so it converted to a null pointer and compiled without complaint; it has been corrupting whatever followed that array since 2005. C++11 stopped allowing the conversion, which is the only reason anyone found out. The `delete` on the adjacent line is also a `delete[]` now, matching the `new char[]` it frees and the sibling branch six lines below.
- **`ecif_renderer_OGL.cpp` declared three colours as the wrong type.** `Color4` is `int[4]` and `Color4f` is `float[4]`; the locals were `Color4`, initialised with float literals, and copied into members the renderer declares as `Color4f` and passes to `glMaterialfv`. It survived only because `0.0` and `1.0` round-trip through `int` exactly. Any other colour written there would have been silently truncated.
- **`frontlib.cpp` returned a stream where a `bool` was wanted.** C++98 gave streams an implicit conversion to `void*`; C++11 replaced it with an explicit `operator bool`.
- **`ecif_userinterface_TCL.cpp` read `interp->result` in four places**, and threw away a `const` in a fifth.

That is the whole list. Sixty-three files of 2005 C++, and four things wrong with it. Whoever wrote this wrote it carefully.

## The cross-component break that only appeared once both halves were built together

ElmerFront calls `eio_get_mesh_element_conns` with six arguments. On 7 March 2014, elmerfem commit `3a5b171ee`, "Corrected EIO mesh reading.", changed EIO's `eio_api.h` to declare seven — adding a `part` parameter, and dropping the terminating semicolon in the same edit.

EIO's C binding was never changed. It still takes six arguments and discards the partition internally. The seven argument form belongs to the *Fortran* binding, and the header was edited to describe the wrong one of the two.

So for twelve years the header declared a function the C library does not define, and did it in a form no compiler could parse anyway. Nothing noticed, because nothing included the header: EIO's own sources include the individual agent headers, and ElmerFront — the one real consumer — had already been dead for two years. **ElmerFront's call site was correct the entire time.** The header was fixed in [AltElmer/eio](https://github.com/AltElmer/eio), where the round-trip test now reads element connectivity through it, so a declaration that disagrees with the binding is a link error.

A defect that requires two components to be built together, in a repository where they never were, is a fair description of what monorepo modularization is for.

The same exercise turned up a second one in [AltElmer/matc](https://github.com/AltElmer/matc): its C99 requirement was set inside its standalone CMake block, so a project adding it with `add_subdirectory` inherited the parent's C standard and got 105 errors from GCC 15. Moved to a target property, with a CI job that builds MATC inside a parent deliberately asking for C23.

## History

62 Subversion revisions from 28 April 2005 to 10 October 2012, recovered from Elmer's pre-GitHub repository at [sourceforge.net/p/elmerfem](https://sourceforge.net/p/elmerfem/) and grafted under the 2014 GitHub import, whose tree hash matches the last Subversion state exactly. GitHub alone shows two commits for this directory, which is why an earlier version of this file wrongly said the history was unrecoverable.

Author names are Subversion handles mapped to `<handle>@users.sourceforge.net`; guessing real identities from a handle would put wrong names on other people's commits.

Worth noting against the bundled `ChangeLog`, whose last entry is October 2005: ElmerFront was still being modified in 2012.

## Building

```
git clone --recurse-submodules https://github.com/AltElmer/elmerfront
cd elmerfront
cmake -S . -B build
cmake --build build
ctest --test-dir build --output-on-failure
```

Needs CMake 3.16, a C and a C++ compiler, OpenGL, GLU and Tcl/Tk. On Debian and Ubuntu that is `libgl1-mesa-dev libglu1-mesa-dev tcl-dev tk-dev libx11-dev`; on macOS `brew install tcl-tk`; under MSYS2 UCRT64, `mingw-w64-ucrt-x86_64-tcl` and `-tk`.

`-DELMERFRONT_BUILD_GUI=OFF` builds only `elmerfront_core`, the 59 platform-neutral sources, with no OpenGL or Tcl/Tk needed at all.

### Which compilers

| | |
| --- | --- |
| GCC, Clang, **Intel `icpx`**, MinGW-w64 | full program, tested |
| MSVC, clang-cl | core library only |

MSVC and clang-cl build the core cleanly and are not excluded on merit: neither has a Tcl/Tk development package installable in a CI job without building Tcl first. That is a gap, and it is listed as its own CI job rather than quietly dropped from the matrix.

## Tests

One, and it is honest about being one. ElmerFront is a Tcl/Tk program: given its scripts it opens a window and runs an event loop, which no CI runner has a display for or a way to end. So the test starts it in a directory where it cannot find its scripts and requires that it names the script it wanted and exits non-zero.

That sounds thin and is not. Everything before that point is real: `main()` initialises MATC through `mtc_init`, installs the MATC formatting hooks, copies and parses the command line, and searches three locations for the main script. A binary that failed to link MATC, or crashed on start-up, never reaches the message the test looks for. The test asserts on that message and not only on the exit code, because a binary that died immediately would also exit non-zero.

The core library needs no separate test: the executable links against it.

## Structure

The split into `elmerfront_core` and the executable follows the code's own design. `ecif_renderer.h` and `ecif_userinterface.h` are abstract; `ecif_renderer_OGL` and `ecif_userinterface_TCL` are the implementations. That was a good decision in 2005 and it is why 59 of 63 sources compile with no windowing system present.

The abstraction is not quite airtight. `ecif_control.cpp` includes the OpenGL renderer's header because `Control` constructs it, and `ecif_main.cpp` includes the Tcl interface's header because `main()` chooses between the batch and Tcl interfaces. Both are on the GUI side of the split as a result, despite doing nothing graphical. Moving the construction behind a factory would finish the job; that is a design change for upstream to weigh, not one to slip in during a port.

## Licence

GPL 2.0, following the Elmer repository this came from. `eio` is LGPL 2.1 and `matc` is LGPL; both are submodules and keep their own licences.

## Related

Part of an effort to make Elmer's components separable, discussed upstream in [ElmerCSC/elmerfem#202](https://github.com/ElmerCSC/elmerfem/issues/202). Its siblings: [AltElmer/eio](https://github.com/AltElmer/eio), [AltElmer/matc](https://github.com/AltElmer/matc), [AltElmer/meshgen2d](https://github.com/AltElmer/meshgen2d).

This is not an official CSC distribution.
