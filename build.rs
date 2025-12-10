use cxx_qt_build::{CxxQtBuilder, QmlModule};
fn main() {
    CxxQtBuilder::new()
        .qml_module(QmlModule {
            uri: "com.kdab.todo",
            rust_files: &["src/bobbling.rs"],
            qml_files: &["qml/main.qml"],
            ..Default::default()
        })
        .qrc("resources.qrc")
        .qt_module("Network")
        .build();
}
