# The core library is exercised by ElmerFront linking against it, so there is
# no separate test for it here. What these check is that the executable starts.

IF(NOT ELMERFRONT_BUILD_GUI)
  RETURN()
ENDIF()

ADD_TEST(NAME elmerfront_starts
         COMMAND ${CMAKE_COMMAND}
                 -DEF_EXE=$<TARGET_FILE:ElmerFront>
                 -DEF_WORKDIR=${CMAKE_CURRENT_BINARY_DIR}/startup-run
                 -P ${CMAKE_CURRENT_SOURCE_DIR}/run_startup.cmake)

SET_TESTS_PROPERTIES(elmerfront_starts PROPERTIES
  PASS_REGULAR_EXPRESSION "ELMERFRONT STARTUP OK"
  TIMEOUT 120)
