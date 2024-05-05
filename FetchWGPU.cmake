include(ExternalProject)

ExternalProject_Add(
  wgpu-native
  GIT_REPOSITORY "https://github.com/gfx-rs/wgpu-native.git"
  GIT_TAG "v0.19.4.1"

  CONFIGURE_COMMAND ""
  BUILD_COMMAND cargo build && cargo build --release
  BUILD_IN_SOURCE ON
  BUILD_ALWAYS OFF
  INSTALL_COMMAND ""
  TEST_COMMAND ""

  BUILD_BYPRODUCTS
    wgpu-native-prefix/src/wgpu-native/target/debug/wgpu_native.lib 
    wgpu-native-prefix/src/wgpu-native/target/release/wgpu_native.lib 
    wgpu-native-prefix/src/wgpu-native/target/debug/libwgpu_native.a
    wgpu-native-prefix/src/wgpu-native/target/release/libwgpu_native.a
)

ExternalProject_Get_Property(wgpu-native SOURCE_DIR)

if(WIN32)
  set(
    WGPU_LIBS
      d3dcompiler
      ws2_32
      userenv
      bcrypt
      ntdll
      opengl32
      debug ${SOURCE_DIR}/target/debug/wgpu_native.lib
      optimized ${SOURCE_DIR}/target/release/wgpu_native.lib
  )
endif()

if(UNIX AND NOT APPLE)
  set(
    WGPU_LIBS
      debug ${SOURCE_DIR}/target/debug/libwgpu_native.a
      optimized ${SOURCE_DIR}/target/release/libwgpu_native.a
  )
endif()

add_library(wgpu INTERFACE)
add_dependencies(wgpu copy_wgpu_headers wgpu-native)
target_link_libraries(
  wgpu
  INTERFACE
    ${WGPU_LIBS}
) 
target_include_directories(
  wgpu
  INTERFACE
    ${SOURCE_DIR}/include
)

add_custom_target(
  copy_wgpu_headers
  WORKING_DIRECTORY ${SOURCE_DIR}
  COMMAND
    ${CMAKE_COMMAND} -E make_directory include
  COMMAND
    ${CMAKE_COMMAND} -E make_directory include/webgpu
  COMMAND
    ${CMAKE_COMMAND} -E copy_if_different ffi/wgpu.h include/webgpu/wgpu.h
  COMMAND
    ${CMAKE_COMMAND} -E copy_if_different ffi/webgpu-headers/webgpu.h include/webgpu/webgpu.h
  BYPRODUCTS
    include/wgpu.h
    include/webgpu/webgpu.h
)
add_dependencies(copy_wgpu_headers wgpu-native)

