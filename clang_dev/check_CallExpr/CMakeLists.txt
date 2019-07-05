cmake_minimum_required(VERSION 3.9)
project(check_test)

set(CMAKE_CXX_STANDARD 11)

set(SOURCE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/source_file")

set(func_name_to_be_checked Wrapper)
set(return_type_to_be_checked Maybe)
include_directories(include)

find_package( PythonInterp 2.7 REQUIRED )

add_executable(check_test ${SOURCE_PATH}/test1.cpp)

file(GLOB_RECURSE oneflow_all_src "${SOURCE_PATH}/*.cpp")

add_custom_target(run_check)

foreach(source_file ${oneflow_all_src})
	add_custom_command(TARGET run_check PRE_BUILD
	COMMAND ${PYTHON_EXECUTABLE} ${CMAKE_CURRENT_SOURCE_DIR}/test3.py ${source_file} func_name_to_be_checked return_type 
	COMMENT "Checking...${source_file}"
	)
endforeach()

add_dependencies(check_test run_check)
