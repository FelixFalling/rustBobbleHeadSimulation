cmake_minimum_required(VERSION 3.16)
project(rustBobbleHeadSimulation LANGUAGES NONE)

# 1. Define the files you want to see in the Project tree
file(GLOB_RECURSE PROJECT_FILES
    "src/*.rs"
    "qml/*.qml"
    "Cargo.toml"
    "build.rs"
)

# 2. Create a custom target that runs 'cargo build'
add_custom_target(cargo_build ALL
    COMMAND cargo build
    WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
    SOURCES ${PROJECT_FILES}
    COMMENT "Building Rust project with Cargo"
)

# 3. Tell Qt Creator where the executable will be
add_executable(rustBobbleHeadSimulation IMPORTED GLOBAL)
set_target_properties(rustBobbleHeadSimulation PROPERTIES
    IMPORTED_LOCATION "${CMAKE_SOURCE_DIR}/target/debug/rustBobbleHeadSimulation"
)

# Ensure cargo runs before trying to run the executable
add_dependencies(rustBobbleHeadSimulation cargo_build)
