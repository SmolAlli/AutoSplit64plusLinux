# CMake Linux compiler configuration module

include_guard(GLOBAL)

include(compiler_common)

add_compile_options(
  -Wall
  -Wextra
  -Wno-unused-parameter
  -fPIC
)

if(CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang")
  add_compile_definitions(_GNU_SOURCE)
endif()
