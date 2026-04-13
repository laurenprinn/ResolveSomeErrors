# CMake project to test modern MSVC conformance errors
cmake_minimum_required(VERSION 3.10)

project(ModernErrorsTest CXX)

# C++20 required
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Create executable with ACTUAL errors/warnings
add_executable(TriggerModernErrors TriggerModernErrorsACTUAL.cpp)

# Enable strict conformance and high warning level
if (MSVC)
	target_compile_options(TriggerModernErrors PRIVATE
		/W4              # Warning level 4 (shows C5286, C5292, C5294, C5295)
		/permissive-     # Strict conformance (required for many C52xx errors)
		/std:c++20       # C++20 standard

		# Optionally treat specific warnings as errors:
		# /we5286        # Enum comparison as error
		# /we5292        # Enum/float as error
		# /we5294        # Float/enum as error
		# /we5295        # Array size as error

		# Or treat ALL warnings as errors:
		# /WX
	)

	# Show all warnings
	target_compile_options(TriggerModernErrors PRIVATE
		/Wall            # Enable all warnings (very verbose)
	)
endif()

message(STATUS "===========================================")
message(STATUS "Modern MSVC Error Test Project")
message(STATUS "===========================================")
message(STATUS "This project will generate warnings:")
message(STATUS "  - C5286 (enum comparison)")
message(STATUS "  - C5292/C5294 (enum/float ops)")
message(STATUS "  - C5295 (array size)")
message(STATUS "")
message(STATUS "Build with: cmake --build .")
message(STATUS "===========================================")
