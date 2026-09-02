# Start ElmerFront in a directory where it cannot find its Tcl scripts, and
# require that it says so and exits non-zero.
#
# This is not a test of the failure path for its own sake. Everything before
# that point is real work: main() initialises MATC through mtc_init, sets up
# the MATC formatting hooks, copies and parses the command line, and searches
# three locations for the main script. A binary that could not link MATC, or
# that crashed in start-up, would not reach the message this test looks for.
#
# It is written this way because ElmerFront is a Tcl/Tk program: given its
# scripts it opens a window and runs an event loop, which a CI runner has no
# display for and no way to end. This exercises start-up without one.

IF(EXISTS "${EF_WORKDIR}")
  FILE(REMOVE_RECURSE "${EF_WORKDIR}")
ENDIF()
FILE(MAKE_DIRECTORY "${EF_WORKDIR}")

EXECUTE_PROCESS(COMMAND "${EF_EXE}" batch=1
                WORKING_DIRECTORY "${EF_WORKDIR}"
                RESULT_VARIABLE rc
                OUTPUT_VARIABLE out
                ERROR_VARIABLE err
                TIMEOUT 60)

MESSAGE("exit code: ${rc}")
MESSAGE("stdout:\n${out}")
MESSAGE("stderr:\n${err}")

IF(rc STREQUAL "Process terminated due to timeout")
  MESSAGE(FATAL_ERROR
    "ElmerFront did not exit. With no scripts to load it should report the "
    "missing script and stop, not wait for anything.")
ENDIF()

IF(rc EQUAL 0)
  MESSAGE(FATAL_ERROR
    "ElmerFront exited 0 with no Tcl scripts available. It cannot have done "
    "anything, so reporting success is wrong.")
ENDIF()

# Assert on what it said, not only on the exit code: a binary that failed to
# start at all would also exit non-zero.
STRING(FIND "${out}${err}" "ecif_tcl_mainScript.tcl" found_script)
IF(found_script EQUAL -1)
  MESSAGE(FATAL_ERROR
    "ElmerFront never mentioned the script it was looking for, so it did not "
    "reach the script search. Something earlier in start-up failed.")
ENDIF()

STRING(FIND "${out}${err}" "not found" found_msg)
IF(found_msg EQUAL -1)
  MESSAGE(FATAL_ERROR "ElmerFront did not report the missing script.")
ENDIF()

MESSAGE("ELMERFRONT STARTUP OK")
