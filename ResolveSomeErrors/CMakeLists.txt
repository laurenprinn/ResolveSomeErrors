# CMakeList.txt : CMake project for ResolveSomeErrors, include source and define
# project specific logic here.
#

# Add source to this project's executable.
add_executable (ResolveSomeErrors "ResolveSomeErrors.cpp" "ResolveSomeErrors.h")

# Optional: Add the modern errors trigger (will cause warnings)
# add_executable (TriggerModernErrors "TriggerModernErrorsACTUAL.cpp")

if (CMAKE_VERSION VERSION_GREATER 3.12)
  set_property(TARGET ResolveSomeErrors PROPERTY CXX_STANDARD 20)

  # To see C5286, C5292, C5294, C5295 warnings
  if (MSVC)
    target_compile_options(ResolveSomeErrors PRIVATE
      /W4              # Warning level 4
      /w15286          # Enable warning C5286 specifically
      /w15292          # Enable warning C5292 specifically
      /w15294          # Enable warning C5294 specifically
      /Zc:enumTypes-   # Disable strict enum type checking (allows comparison)
      # /permissive-   # NOTE: This makes C5286 an ERROR, not a warning
      # /WX            # Treat warnings as errors (optional)
    )
  endif()
endif()

# TODO: Add tests and install targets if needed.
