cmake_minimum_required(VERSION 3.9)
project(check_test)

set(CMAKE_CXX_STANDARD 11)

include_directories(include)

find_package( PythonInterp 2.7 REQUIRED )
find_package( PythonLibs 2.7 REQUIRED )

add_executable(check_test test1.cpp)

add_custom_command(
	TARGET run
	PRE_BUILD
	COMMAND ${PYTHON_EXECUTABLE} ${CMAKE_CURRENT_SOURCE_DIR}/test3.py ${CMAKE_CURRENT_SOURCE_DIR}/test1.cpp
	COMMENT "Checking..."
)

add_dependencies(check_test run)
