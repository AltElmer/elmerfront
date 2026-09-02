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

So it was never developed on GitHub. It arrived with the import, was not modified once in two and a half years, and was then removed. Its real history is in Elmer's pre-GitHub version control at CSC and is not recoverable from the public repository.

The bundled `ChangeLog` gives a better sense of when it was actually alive. Its last entry is 20 October 2005:

> Compiles with gcc 4.0.x and hopefully on FreeBSD as well.

## Why it does not build

`configure.in` requires OpenGL and Tcl/Tk, and links against Elmer's MATC and EIO:

```
ACX_CHECK_GL([],[AC_MSG_ERROR([OpenGL not found.])])
ACX_TCLTK([],[AC_MSG_ERROR([Tcl/tk not found.])])
LIBS="$LIBS $MATC_LIBS $EIOC_LIBS $LIBS $GL_LIBS $GLU_LIBS $TCLTK_LIBS"
```

It is autotools rather than CMake, unlike the rest of Elmer today, and the C++ last compiled against gcc 4.0 in 2005. Making it build now would be a porting project, not a configuration change. No attempt has been made here, and there is no CI, because there is nothing yet that could pass.

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
