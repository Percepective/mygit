if (NOT LIBCLANG_ROOT_DIR)
    set(LIBCLANG_ROOT_DIR $ENV{LIBCLANG_ROOT_DIR})
endif ()

if (NOT LIBCLANG_LLVM_CONFIG_EXECUTABLE)
    set(LIBCLANG_LLVM_CONFIG_EXECUTABLE $ENV{LIBCLANG_LLVM_CONFIG_EXECUTABLE})
    if (NOT LIBCLANG_LLVM_CONFIG_EXECUTABLE)
        if (APPLE)
            foreach(major RANGE 9 3)
                foreach(minor RANGE 9 0)
                    foreach(patch RANGE 9 0)
                        message(STATUS "trying llvm-config llvm-config${major}${minor} in /usr/local/Cellar/llvm/${major}.${minor}.${patch}/bin")
                        find_program(LIBCLANG_LLVM_CONFIG_EXECUTABLE NAMES llvm-config llvm-config${major}${minor} llvm-config-${major}${minor} llvm-config-${major} llvm-config${major} PATHS /usr/local/Cellar/llvm/${major}.${minor}.${patch}/bin)
                        if (LIBCLANG_LLVM_CONFIG_EXECUTABLE)
                            break()
                        endif ()
                    endforeach ()
                    if (LIBCLANG_LLVM_CONFIG_EXECUTABLE)
                        break()
                    endif ()
                endforeach ()
                if (LIBCLANG_LLVM_CONFIG_EXECUTABLE)
                    break()
                endif ()
            endforeach ()
        else ()
            set(llvm_config_names llvm-config)
            foreach(major RANGE 9 3)
                list(APPEND llvm_config_names "llvm-config${major}" "llvm-config-${major}")
                foreach(minor RANGE 9 0)
                    list(APPEND llvm_config_names "llvm-config${major}${minor}" "llvm-config-${major}.${minor}" "llvm-config-mp-${major}.${minor}")
                endforeach ()
            endforeach ()
            find_program(LIBCLANG_LLVM_CONFIG_EXECUTABLE NAMES ${llvm_config_names})
        endif ()
    endif ()
    if (LIBCLANG_LLVM_CONFIG_EXECUTABLE)
        message(STATUS "llvm-config executable found: ${LIBCLANG_LLVM_CONFIG_EXECUTABLE}")
    endif ()
endif ()

if (NOT LIBCLANG_CXXFLAGS)
    if (NOT LIBCLANG_LLVM_CONFIG_EXECUTABLE)
        message(FATAL_ERROR "Could NOT find llvm-config executable and LIBCLANG_CXXFLAGS is not set ")
    endif ()
    execute_process(COMMAND ${LIBCLANG_LLVM_CONFIG_EXECUTABLE} --cxxflags OUTPUT_VARIABLE LIBCLANG_CXXFLAGS OUTPUT_STRIP_TRAILING_WHITESPACE)
    if (NOT LIBCLANG_CXXFLAGS)
        find_path(LIBCLANG_CXXFLAGS_HACK_CMAKECACHE_DOT_TEXT_BULLSHIT clang-c/Index.h HINTS ${LIBCLANG_ROOT_DIR}/include NO_DEFAULT_PATH)
        if (NOT EXISTS ${LIBCLANG_CXXFLAGS_HACK_CMAKECACHE_DOT_TEXT_BULLSHIT})
            find_path(LIBCLANG_CXXFLAGS clang-c/Index.h)
            if (NOT EXISTS ${LIBCLANG_CXXFLAGS})
                message(FATAL_ERROR "Could NOT find clang include path. You can fix this by setting LIBCLANG_CXXFLAGS in your shell or as a cmake variable.")
            endif ()
        else ()
            set(LIBCLANG_CXXFLAGS ${LIBCLANG_CXXFLAGS_HACK_CMAKECACHE_DOT_TEXT_BULLSHIT})
        endif ()
        set(LIBCLANG_CXXFLAGS "-I${LIBCLANG_CXXFLAGS}")
    endif ()
    string(REGEX MATCHALL "-(D__?[a-zA-Z_]*|I([^\" ]+|\"[^\"]+\"))" LIBCLANG_CXXFLAGS "${LIBCLANG_CXXFLAGS}")
    string(REGEX REPLACE ";" " " LIBCLANG_CXXFLAGS "${LIBCLANG_CXXFLAGS}")
    set(LIBCLANG_CXXFLAGS ${LIBCLANG_CXXFLAGS} CACHE STRING "The LLVM C++ compiler flags needed to compile LLVM based applications.")
    unset(LIBCLANG_CXXFLAGS_HACK_CMAKECACHE_DOT_TEXT_BULLSHIT CACHE)
endif ()

if (NOT EXISTS ${LIBCLANG_LIBDIR})
    if (NOT LIBCLANG_LLVM_CONFIG_EXECUTABLE)
        message(FATAL_ERROR "Could NOT find llvm-config executable and LIBCLANG_LIBDIR is not set ")
    endif ()
    execute_process(COMMAND ${LIBCLANG_LLVM_CONFIG_EXECUTABLE} --libdir OUTPUT_VARIABLE LIBCLANG_LIBDIR OUTPUT_STRIP_TRAILING_WHITESPACE)
    if (NOT EXISTS ${LIBCLANG_LIBDIR})
        message(FATAL_ERROR "Could NOT find clang libdir. You can fix this by setting LIBCLANG_LIBDIR in your shell or as a cmake variable.")
    endif ()
    set(LIBCLANG_LIBDIR ${LIBCLANG_LIBDIR} CACHE STRING "Path to the clang library.")
endif ()

if (NOT LIBCLANG_LIBRARIES)
    find_library(LIBCLANG_LIB_HACK_CMAKECACHE_DOT_TEXT_BULLSHIT NAMES clang libclang HINTS ${LIBCLANG_LIBDIR} ${LIBCLANG_ROOT_DIR}/lib NO_DEFAULT_PATH)
    if (LIBCLANG_LIB_HACK_CMAKECACHE_DOT_TEXT_BULLSHIT)
        set(LIBCLANG_LIBRARIES "${LIBCLANG_LIB_HACK_CMAKECACHE_DOT_TEXT_BULLSHIT}")
    else ()
        find_library(LIBCLANG_LIBRARIES NAMES clang libclang)
        if (NOT EXISTS ${LIBCLANG_LIBRARIES})
            set (LIBCLANG_LIBRARIES "-L${LIBCLANG_LIBDIR}" "-lclang" "-Wl,-rpath,${LIBCLANG_LIBDIR}")
        endif ()
    endif ()
    unset(LIBCLANG_LIB_HACK_CMAKECACHE_DOT_TEXT_BULLSHIT CACHE)
endif ()

set(LIBCLANG_LIBRARY ${LIBCLANG_LIBRARIES} CACHE FILEPATH "Path to the libclang library")

if (LIBCLANG_LLVM_CONFIG_EXECUTABLE)
    execute_process(COMMAND ${LIBCLANG_LLVM_CONFIG_EXECUTABLE} --version OUTPUT_VARIABLE LIBCLANG_VERSION_STRING OUTPUT_STRIP_TRAILING_WHITESPACE)
else ()
    set(LIBCLANG_VERSION_STRING "Unknown")
endif ()
message("-- Using Clang version ${LIBCLANG_VERSION_STRING} from ${LIBCLANG_LIBDIR} with CXXFLAGS ${LIBCLANG_CXXFLAGS}")

# Handly the QUIETLY and REQUIRED arguments and set LIBCLANG_FOUND to TRUE if all listed variables are TRUE
include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(LibClang DEFAULT_MSG LIBCLANG_LIBRARY LIBCLANG_CXXFLAGS LIBCLANG_LIBDIR)
mark_as_advanced(LIBCLANG_CXXFLAGS LIBCLANG_LIBRARY LIBCLANG_LLVM_CONFIG_EXECUTABLE LIBCLANG_LIBDIR)
