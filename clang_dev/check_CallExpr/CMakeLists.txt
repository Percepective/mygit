cmake_minimum_required(VERSION 3.9)
project(check_test)

set(CMAKE_CXX_STANDARD 11)

set(SOURCE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/source_file")

#设置检错脚本参数

#clang.so所在路径
set(clang_lib_dir ./)
#待检源文件依赖头文件所在路径
set(include_dir ./include)
#待检包装函数名
set(func_name_to_be_checked Wrapper)
#待检返回值类型
set(return_type_to_be_checked Maybe)

include_directories(include)

find_package( PythonInterp 2.7 REQUIRED )

add_executable(check_test ${SOURCE_PATH}/test1.cpp)
#待检源文件
file(GLOB_RECURSE oneflow_all_src "${SOURCE_PATH}/*.cpp")

add_custom_target(run_check)

foreach(source_file ${oneflow_all_src})
	add_custom_command(TARGET run_check PRE_BUILD
	COMMAND ${PYTHON_EXECUTABLE} ${CMAKE_CURRENT_SOURCE_DIR}/test3.py ${source_file} ${func_name_to_be_checked} ${return_type_to_be_checked} ${clang_lib_dir} ${include_dir}
	COMMENT "Checking...${source_file}"
	)
endforeach()

add_dependencies(check_test run_check)
