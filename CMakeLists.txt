cmake_minimum_required(VERSION 3.16)
project(rustBobbleHeadSimulation LANGUAGES NONE)

file(GLOB_RECURSE PROJECT_FILES
    "src/*.rs"
    "qml/*.qml"
    "Cargo.toml"
    "build.rs"
)

add_custom_target(cargo_build ALL
    COMMAND cargo build
    WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
    SOURCES ${PROJECT_FILES}
    COMMENT "Building Rust project with Cargo"
)

add_executable(rustBobbleHeadSimulation IMPORTED GLOBAL)
set_target_properties(rustBobbleHeadSimulation PROPERTIES
    IMPORTED_LOCATION "${CMAKE_SOURCE_DIR}/target/debug/rustBobbleHeadSimulation"
)

add_dependencies(rustBobbleHeadSimulation cargo_build)
