import QtQuick 2.12
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.11
import QtQuick.Window 2.12

import com.kdab.todo 1.0

ApplicationWindow {
  width: 640
  height: 480
  visible: true

  title: qsTr("Todo List")

  TodoList {
    id: todoList
  }


  Component {
    id: todoDelegate

    CheckBox {
      width: ListView.view.width
      checked: model.done

      text: model.todo
      font.strikeout: model.done
      onCheckedChanged: { 
        if (checked !== model.done) {
          todoList.setChecked(model.index, checked);
        }
      }
    }
  }

  ListView {
    anchors.fill: parent
    model: todoList
    delegate: todoDelegate
    spacing: 10
  }

  footer: RowLayout {
    TextField {
      id: newTodo
      Layout.fillWidth: true
      placeholderText: qsTr("Add new Todo")
    }
    Button {
      text: qsTr("Add")
      onClicked: {
        todoList.addTodo(newTodo.text)
      }
    }

    Button {
      text: qsTr("Clear")
      onClicked: {
        todoList.clearCompleted()
      }
    }
  }
}
