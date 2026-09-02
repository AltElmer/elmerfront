CMAKE_MINIMUM_REQUIRED(VERSION 3.16)
# C as well as C++: ElmerFront itself is C++, but matc is C and, as a
# subdirectory, it takes its enabled languages from here rather than from its
# own standalone block.
PROJECT(ElmerFront VERSION 5.4.0 LANGUAGES C CXX)

# ElmerFront was an autotools project when Elmer removed it in 2016. Elmer had
# already moved to CMake by then and deleted front's autotools files alongside
# eio's, so this is the build system the project itself chose, not a preference
# imposed here.

SET(CMAKE_CXX_STANDARD 17)
SET(CMAKE_CXX_STANDARD_REQUIRED ON)

IF(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
  SET(CMAKE_BUILD_TYPE Release CACHE STRING "" FORCE)
ENDIF()

OPTION(ELMERFRONT_BUILD_GUI
       "Build the ElmerFront executable, which needs OpenGL and Tcl/Tk" ON)

# --------------------------------------------------------------------------
# Dependencies that used to be siblings in the Elmer tree
#
# configure.in required libeioc and libmatc through ACX_EIOC and ACX_MATC, and
# both were removed from Elmer within a day of ElmerFront itself. They are
# submodules here, so a clone brings its own dependencies rather than needing a
# copy of Elmer that no longer contains them.
# --------------------------------------------------------------------------

IF(NOT EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/eio/CMakeLists.txt"
   OR NOT EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/matc/CMakeLists.txt")
  MESSAGE(FATAL_ERROR
    "The eio and matc submodules are not checked out. Clone with\n"
    "  git clone --recurse-submodules <url>\n"
    "or run\n"
    "  git submodule update --init")
ENDIF()

# matc is built as a static library here. The default is a shared library
# aimed at its own CLI, which would mean shipping a DLL next to a program that
# is the only thing using it.
SET(MATC_STATIC_CLI ON CACHE BOOL "" FORCE)
ADD_SUBDIRECTORY(matc)

# eio's Fortran binding is for Elmer's solver. ElmerFront only ever linked the
# C++ one, so building eiof here would be work for nothing.
SET(EIO_WITH_FORTRAN OFF CACHE BOOL "" FORCE)
SET(EIO_BUILD_TESTS OFF CACHE BOOL "" FORCE)
ADD_SUBDIRECTORY(eio)

# --------------------------------------------------------------------------
# Configuration header
# --------------------------------------------------------------------------

INCLUDE(CheckIncludeFiles)
INCLUDE(CheckLibraryExists)

CHECK_INCLUDE_FILES(inttypes.h HAVE_INTTYPES_H)
CHECK_INCLUDE_FILES(stdint.h HAVE_STDINT_H)
CHECK_INCLUDE_FILES(unistd.h HAVE_UNISTD_H)
CHECK_INCLUDE_FILES(strings.h HAVE_STRINGS_H)

SET(HAVE_EIOC 1)
SET(HAVE_MATC 1)

CHECK_LIBRARY_EXISTS(m sin "" HAVE_LIBM)
CHECK_LIBRARY_EXISTS(dl dlopen "" HAVE_LIBDL)

SET(ELMER_FRONT_PREFIX "${CMAKE_INSTALL_PREFIX}")

CONFIGURE_FILE(config.h.cmake "${CMAKE_CURRENT_BINARY_DIR}/config.h")

ADD_SUBDIRECTORY(src)

INCLUDE(CTest)
IF(BUILD_TESTING)
  ADD_SUBDIRECTORY(tests)
ENDIF()

# --------------------------------------------------------------------------
# Data files
#
# ElmerFront reads its element definitions, field definitions and Tcl scripts
# from disk at run time. Without them the program starts and then cannot do
# anything, so they are part of the build, not an afterthought.
# --------------------------------------------------------------------------

INSTALL(DIRECTORY src/lib/ DESTINATION share/elmerfront/lib)
INSTALL(DIRECTORY src/tcl/ DESTINATION share/elmerfront/tcl)

MESSAGE(STATUS "ElmerFront ${PROJECT_VERSION}")
MESSAGE(STATUS "  core library : always")
IF(ELMERFRONT_BUILD_GUI)
  MESSAGE(STATUS "  GUI          : yes (OpenGL + Tcl/Tk)")
ELSE()
  MESSAGE(STATUS "  GUI          : no (ELMERFRONT_BUILD_GUI=OFF)")
ENDIF()
