use cxx_qt_build::{CxxQtBuilder, QmlModule};
fn main() {
    // This main function was initially taken from https://www.youtube.com/watch?v=uR4RzDjctm4
    CxxQtBuilder::new()
        .qml_module(QmlModule {
            uri: "com.kdab.todo",
            rust_files: &["src/lib.rs"],
            qml_files: &["qml/main.qml"],
            ..Default::default()
        })
        .qrc("resources.qrc")
        .qt_module("Network")
        .build();
}
