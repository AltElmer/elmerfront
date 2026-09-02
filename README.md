# ElmerFront (archive)

ElmerFront was the original graphical pre-processor for [Elmer FEM](https://github.com/ElmerCSC/elmerfem), superseded by ElmerGUI and removed from the Elmer tree in 2016.

**This is an archive, not a maintained project.** It does not build with a current toolchain, and nothing here has been ported. It exists so the code and its provenance are recoverable without digging through the history of a repository where it no longer appears.

## What this is, exactly

The contents of `front/` at `bb433abaa`, the last Elmer commit before it was deleted. 271 files: 63 `.cpp`, 70 `.h`, 54 `.tcl`, plus icons and Elmer definition files.

## History, and why there is so little of it

`front/` has exactly two commits in the whole of ElmerCSC/elmerfem:

| commit | date | what |
| --- | --- | --- |
| `ec4bb2cd5` | 2014-02-10 | the repository's initial import, which included `front/` |
| `2973e2161` | 2016-11-29 | "Remove obsolite stuff: front and old buildtools", by Peter Råback |

So it was never developed on GitHub. It arrived with the import, was not modified once in two and a half years, and was then removed.

**Its earlier history does exist, and it is public.** Elmer's pre-GitHub development is in a Subversion repository still online at [sourceforge.net/p/elmerfem](https://sourceforge.net/p/elmerfem/), where `trunk/front` has 62 revisions running from 28 April 2005 to 10 October 2012. An earlier version of this file said that history was unrecoverable; that was true of GitHub and wrong as a general claim, and it is corrected here. The snapshot in this repository has not yet been rebuilt on top of those revisions — [AltElmer/eio](https://github.com/AltElmer/eio) shows what that conversion looks like when it is done.

Note also that the 2012 date contradicts the impression the bundled `ChangeLog` gives. ElmerFront was still being touched seven years after its last ChangeLog entry.

The bundled `ChangeLog` gives a better sense of when it was actually alive. Its last entry is 20 October 2005:

> Compiles with gcc 4.0.x and hopefully on FreeBSD as well.

## Why it does not build

`configure.in` requires OpenGL and Tcl/Tk, and links against Elmer's MATC and EIO:

```
ACX_CHECK_GL([],[AC_MSG_ERROR([OpenGL not found.])])
ACX_TCLTK([],[AC_MSG_ERROR([Tcl/tk not found.])])
LIBS="$LIBS $MATC_LIBS $EIOC_LIBS $LIBS $GL_LIBS $GLU_LIBS $TCLTK_LIBS"
```

It is worth separating those, because they are not equally hard and an earlier version of this file lumped them together.

| what | how much of a problem | why |
| --- | --- | --- |
| OpenGL, Tcl/Tk | **not a blocker** | Both are ordinary dependencies, packaged on every platform this would target. What costs time is not obtaining them but the 2005-era API usage against them: immediate-mode OpenGL, and Tk idioms from 8.4. |
| autotools | **not a blocker** | Mechanical. Elmer moved the whole tree to CMake, and `eio` shows what that conversion costs for a component of this size. |
| EIO | **was a blocker, now is not** | `configure.in` links `$EIOC_LIBS`, and EIO was deleted from Elmer the day after ElmerFront. It now builds and is tested at [AltElmer/eio](https://github.com/AltElmer/eio). |
| MATC | **was a blocker, now is not** | Same story: [AltElmer/matc](https://github.com/AltElmer/matc). |
| the C++ itself | **the actual cost** | 63 `.cpp` and 70 `.h` last compiled against gcc 4.0 in 2005. Every extraction so far has turned up something in this class, and this is by far the largest body of code of the four. |

So the honest statement is not "it has blocking dependencies" but "it is a port of twenty-year-old C++ and a GUI toolkit layer, and nothing currently depends on the result". No attempt has been made here, and there is no CI, because there is nothing yet that could pass.

## What it left behind

ElmerFront's mesh input format outlived it. Files across the Elmer test suite still begin

```
!ElmerMesh input file from ElmerFront
```

and are read by `Mesh2D` to this day, including the geometry used by the test in [AltElmer/meshgen2d](https://github.com/AltElmer/meshgen2d). The tool is gone; its file format is still load bearing.

## Relationship to the other extractions

[AltElmer/matc](https://github.com/AltElmer/matc) and [AltElmer/meshgen2d](https://github.com/AltElmer/meshgen2d) are live components: the solver links MATC, and Mesh2D meshes geometries for the consistency tests. Splitting those out is maintainability work, and each builds and is tested on its own.

ElmerFront is not that. Nothing depends on it, it is already absent from Elmer, and extracting it does not reduce anything's surface area. This repository is preservation, and is labelled as such rather than dressed up as a module.

## Licence

GPL 2.0, following the Elmer repository it came from. See [ElmerCSC/elmerfem](https://github.com/ElmerCSC/elmerfem) for the project's licensing policy.
