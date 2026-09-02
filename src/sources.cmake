# Sources are listed rather than globbed, and this file is generated from the
# same list the autotools build used, so that a file added to src/ without
# being added here is a build error rather than a silent omission.
SET(ELMERFRONT_CORE_SRCS
  ecif_body.cpp
  ecif_body2D.cpp
  ecif_body3D.cpp
  ecif_bodyElement.cpp
  ecif_bodyElement1D.cpp
  ecif_bodyElement2D.cpp
  ecif_bodyElement3D.cpp
  ecif_bodyElementGroup.cpp
  ecif_bodyElementLoop.cpp
  ecif_bodyForce.cpp
  ecif_bodyLayer.cpp
  ecif_bodyParameter.cpp
  ecif_boundaryCondition.cpp
  ecif_boundaryParameter.cpp
  ecif_boundbox.cpp
  ecif_calculator.cpp
  ecif_const.cpp
  ecif_constant.cpp
  ecif_coordinate.cpp
  ecif_datafile.cpp
  ecif_def_trx.cpp
  ecif_equation.cpp
  ecif_equationVariables.cpp
  ecif_func.cpp
  ecif_geometry.cpp
  ecif_gridH.cpp
  ecif_gridParameter.cpp
  ecif_initialCondition.cpp
  ecif_input.cpp
  ecif_inputAbaqus.cpp
  ecif_inputEgf.cpp
  ecif_inputElmer.cpp
  ecif_inputEmf.cpp
  ecif_inputFidap.cpp
  ecif_inputFront.cpp
  ecif_inputIdeas.cpp
  ecif_inputIdeasWF.cpp
  ecif_inputIges.cpp
  ecif_inputThetis.cpp
  ecif_material.cpp
  ecif_mesh.cpp
  ecif_model_aux.cpp
  ecif_model.cpp
  ecif_modelMeshManager.cpp
  ecif_modelObject.cpp
  ecif_modelOutputManager.cpp
  ecif_modelParameter.cpp
  ecif_nurbs.cpp
  ecif_parameter.cpp
  ecif_parameterField.cpp
  ecif_process.cpp
  ecif_renderer.cpp
  ecif_simulationParameter.cpp
  ecif_solver.cpp
  ecif_solverControl.cpp
  ecif_timer.cpp
  ecif_timestep.cpp
  ecif_userSettings.cpp
  frontlib.cpp
)

# The sources that touch a specific windowing or graphics API. The other 59 are
# platform neutral, which is a property of how ElmerFront was written:
# ecif_renderer.h and ecif_userinterface.h are abstract and these are the
# implementations behind them.
#
# The abstraction is not quite airtight, which is why two files that look
# neutral are here. ecif_control.cpp includes ecif_renderer_OGL.h because
# Control constructs the renderer, and ecif_main.cpp includes
# ecif_userinterface_TCL.h because main() chooses between the batch interface
# and the Tcl one. Both therefore need OpenGL and Tcl headers despite doing
# nothing graphical themselves. Splitting the construction out behind a factory
# would make the core complete, and is left as a change upstream can judge
# rather than one made here in passing.
SET(ELMERFRONT_RENDERER_SRCS ecif_renderer_OGL.cpp ecif_control.cpp)
SET(ELMERFRONT_UI_SRCS       ecif_userinterface_TCL.cpp ecif_main.cpp)