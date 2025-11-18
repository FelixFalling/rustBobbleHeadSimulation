mod bobbling;

use cxx_qt_lib::{QGuiApplication, QQmlApplicationEngine, QUrl};

fn main() {

    //Making new table??
    let mut app = QGuiApplication::new();
    let mut engine = QQmlApplicationEngine::new();

    if let Some(engine) = engine.as_mut() {
        engine.load(&QUrl::from("qrc:/qt/qml/com/kdab/todo/qml/main.qml"));
    }

    if let Some(app) = app.as_mut() {
        app.exec();
    }
}
