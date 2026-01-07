# CMake Linux helper functions module

include_guard(GLOBAL)

include(helpers_common)

function(set_target_properties_plugin target)
  set(options "")
  set(oneValueArgs "")
  set(multiValueArgs PROPERTIES)
  cmake_parse_arguments(PARSE_ARGV 0 _STPO "${options}" "${oneValueArgs}" "${multiValueArgs}")

  message(DEBUG "Setting additional properties for target ${target}...")

  while(_STPO_PROPERTIES)
    list(POP_FRONT _STPO_PROPERTIES key value)
    set_property(TARGET ${target} PROPERTY ${key} "${value}")
  endwhile()

  set_target_properties(${target} PROPERTIES PREFIX "")
  
  install(TARGETS ${target} LIBRARY DESTINATION ".")
endfunction()

function(target_install_resources target)
  # No-op for now or implement if needed
endfunction()

function(target_add_resource target resource)
  # No-op for now or implement if needed
endfunction()
