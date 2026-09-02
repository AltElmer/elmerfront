INCLUDE(${CMAKE_CURRENT_SOURCE_DIR}/sources.cmake)

# The platform neutral part: everything except the OpenGL renderer and the
# Tcl/Tk user interface. Built as its own library so that it can be compiled
# and checked on a machine or a CI runner that has no windowing system, which
# is most of them.
ADD_LIBRARY(elmerfront_core STATIC ${ELMERFRONT_CORE_SRCS})

TARGET_INCLUDE_DIRECTORIES(elmerfront_core PUBLIC
  "${CMAKE_CURRENT_SOURCE_DIR}/../include"
  "${CMAKE_CURRENT_BINARY_DIR}/.."
  "${CMAKE_CURRENT_SOURCE_DIR}")

TARGET_LINK_LIBRARIES(elmerfront_core PUBLIC eioc matc)

IF(WIN32)
  # ecif_def.h defines UNIX when WIN32 is absent, and the UNIX path pulls in
  # <X11/Xlib.h>. On Windows that header does not exist and is not wanted.
  TARGET_COMPILE_DEFINITIONS(elmerfront_core PUBLIC WIN32)
ENDIF()

IF(MSVC)
  TARGET_COMPILE_DEFINITIONS(elmerfront_core PUBLIC _CRT_SECURE_NO_WARNINGS)
ENDIF()

IF(HAVE_LIBM)
  TARGET_LINK_LIBRARIES(elmerfront_core PUBLIC m)
ENDIF()
IF(HAVE_LIBDL)
  TARGET_LINK_LIBRARIES(elmerfront_core PUBLIC dl)
ENDIF()

IF(NOT ELMERFRONT_BUILD_GUI)
  RETURN()
ENDIF()

# --------------------------------------------------------------------------
# The GUI: OpenGL for the renderer, Tcl/Tk for the interface
# --------------------------------------------------------------------------

SET(OpenGL_GL_PREFERENCE GLVND)
FIND_PACKAGE(OpenGL REQUIRED)
FIND_PACKAGE(TCL REQUIRED)

IF(NOT TK_LIBRARY OR NOT TK_INCLUDE_PATH)
  MESSAGE(FATAL_ERROR
    "Tk was not found. ElmerFront's user interface is Tcl/Tk, so this is not "
    "optional for the executable. Configure with -DELMERFRONT_BUILD_GUI=OFF "
    "to build only the core library.")
ENDIF()

ADD_EXECUTABLE(ElmerFront
  ${ELMERFRONT_RENDERER_SRCS}
  ${ELMERFRONT_UI_SRCS})

TARGET_LINK_LIBRARIES(ElmerFront PRIVATE
  elmerfront_core
  OpenGL::GL
  OpenGL::GLU
  ${TCL_LIBRARY}
  ${TK_LIBRARY})

TARGET_INCLUDE_DIRECTORIES(ElmerFront PRIVATE
  ${TCL_INCLUDE_PATH}
  ${TK_INCLUDE_PATH})

# UNIX, including APPLE. This was written "UNIX AND NOT APPLE" when macOS was
# thought to be out of reach, which excluded exactly the platform that needs
# it most: on Linux libX11 sits in a default search path and would very nearly
# be found anyway, while on macOS it comes from XQuartz under /opt/X11 and
# nothing finds it by accident. X11::X11 carries both the include directory
# and the library path, so it works on either.
IF(UNIX)
  FIND_PACKAGE(X11 REQUIRED)
  TARGET_LINK_LIBRARIES(ElmerFront PRIVATE X11::X11)
  TARGET_LINK_LIBRARIES(elmerfront_core PUBLIC X11::X11)
ENDIF()

INSTALL(TARGETS ElmerFront RUNTIME DESTINATION bin)
