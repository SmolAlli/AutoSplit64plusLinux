# CMake Linux defaults module

include_guard(GLOBAL)

set(CMAKE_FIND_PACKAGE_TARGETS_GLOBAL TRUE)

if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
  set(
    CMAKE_INSTALL_PREFIX
    "${CMAKE_BINARY_DIR}/install"
    CACHE PATH
    "Default plugin installation directory"
    FORCE
  )
endif()
