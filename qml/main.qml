import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import com.kdab.todo 1.0

ApplicationWindow {
    id: window
    width: 600
    height: 600
    visible: true
    flags: Qt.FramelessWindowHint | Qt.Window
    color: "transparent"

    property alias menu: startupMenu

    // Menu
    Rectangle {
        id: startupMenu
        anchors.fill: parent
        color: "transparent"
        z: 200
        visible: true

        Rectangle {
            anchors.centerIn: parent
            width: 300
            height: 250
            color: "white"
            radius: 10

            ColumnLayout {
                anchors.centerIn: parent
                spacing: 20

                Text {
                    text: "Choose your Bobble Head"
                    font.pixelSize: 20
                    font.bold: true
                    Layout.alignment: Qt.AlignHCenter
                }

                Button {
                    text: "Ferris the Rustacean"
                    Layout.preferredWidth: 200
                    Layout.alignment: Qt.AlignHCenter
                    onClicked: {
                        bobbleHeadsModel.add_bobble_head(window.width / 2, window.height - 150, 30, "#FF6B6B", "ferris");
                        startupMenu.visible = false;
                    }
                }
                Button {
                    text: "Cat"
                    Layout.preferredWidth: 200
                    Layout.alignment: Qt.AlignHCenter
                    onClicked: {
                        bobbleHeadsModel.add_bobble_head(window.width / 2, window.height - 150, 30, "#FFD700", "cat");
                        startupMenu.visible = false;
                    }
                }
                Button {
                    text: "Baseball Player"
                    Layout.preferredWidth: 200
                    Layout.alignment: Qt.AlignHCenter
                    onClicked: {
                        bobbleHeadsModel.add_bobble_head(window.width / 2, window.height - 150, 30, "#87CEEB", "player");
                        startupMenu.visible = false;
                    }
                }
            }
        }
    }

    // Bobble Head Model
    BobbleHeadModel {
        id: bobbleHeadsModel
    }

    // Bobble Head Delegate
    Component {
        id: bobbleHeadDelegate
        Item {
            id: delegateRoot
            // Helper properties
            property real headRadius: model.headRadius || 25
            property real headDiameter: headRadius * 2
            property string bobbleType: model.bobbleType || "ferris"
            property bool controlsVisible: false

            Timer {
                id: showTimer
                interval: 1000
                onTriggered: delegateRoot.controlsVisible = true
            }

            Timer {
                id: hideTimer
                interval: 1000 // Increased time to reach buttons
                onTriggered: delegateRoot.controlsVisible = false
            }

            // Controls Overlay
            Item {
                id: controlsOverlay
                visible: delegateRoot.controlsVisible
                z: 100
                x: model.restX - width / 2
                y: model.restY - 90 
                width: controlsRow.width + 20
                height: controlsRow.height + 30

                Rectangle {
                    anchors.fill: parent
                    color: "#80000000"
                    radius: 5
                }

                // Drag Handle
                Rectangle {
                    id: dragHandle
                    width: parent.width
                    height: 20
                    color: "#AA000000"
                    radius: 5
                    anchors.top: parent.top
                    
                    Text {
                        anchors.centerIn: parent
                        text: ":::"
                        color: "white"
                        font.bold: true
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.SizeAllCursor
                        onPressed: {
                            window.startSystemMove();
                        }
                        onEntered: hideTimer.stop()
                        onExited: hideTimer.start()
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    anchors.topMargin: 20
                    hoverEnabled: true
                    onEntered: hideTimer.stop()
                    onExited: hideTimer.start()
                }

                Row {
                    id: controlsRow
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 5
                    spacing: 5

                    Button {
                        text: "Menu"
                        width: 60
                        height: 30
                        onClicked: {
                            window.menu.visible = true;
                            bobbleHeadsModel.clear_bobble_heads();
                        }
                    }

                    Button {
                        text: "X"
                        width: 30
                        height: 30
                        onClicked: Qt.quit()
                    }
                }
            }

            // Body Container
            Item {
                property int w: bobbleType === "ferris" ? 150 : (bobbleType === "cat" ? 100 : 100)
                property int h: bobbleType === "ferris" ? 90 : (bobbleType === "cat" ? 100 : 60)
                x: model.restX - w/2
                y: model.restY - h/2
                width: w
                height: h

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.SizeAllCursor
                    onPressed: {
                        window.startSystemMove();
                    }
                }

                // Ferris Body
                Item {
                    visible: bobbleType === "ferris"
                    anchors.fill: parent

                    Image {
                        anchors.fill: parent
                        source: "qrc:/images/rustacean-body.svg"
                        fillMode: Image.PreserveAspectFit
                        smooth: true
                    }
                }

                // Cat Body
                Item {
                    visible: bobbleType === "cat"
                    anchors.fill: parent
                    Image {
                        anchors.fill: parent
                        source: "qrc:/images/kitty-body.svg"
                        fillMode: Image.PreserveAspectFit
                        smooth: true
                    }
                }

                // Player Body
                Item {
                    visible: bobbleType === "player"
                    anchors.fill: parent
                    Image {
                        anchors.fill: parent
                        source: "qrc:/images/baseball-player-body.svg"
                        fillMode: Image.PreserveAspectFit
                        smooth: true
                    }
                }
            }

            // Claws (Movable part - Bobbling)
            Item {
                id: clawsContainer
                property int w: bobbleType === "ferris" ? 150 : (bobbleType === "cat" ? 100 : 100)
                property int h: bobbleType === "ferris" ? 90 : (bobbleType === "cat" ? 100 : 60)
                x: model.x - w/2 // Center relative to physics model x
                y: model.y - h/2 // Center relative to physics model y
                width: w
                height: h
                z: bobbleType === "ferris" ? -1 : 2
                rotation: model.rotation * 50 

                // Ferris Claws
                Item {
                    visible: bobbleType === "ferris"
                    anchors.fill: parent
                    
                    Image {
                        anchors.fill: parent
                        source: "qrc:/images/rustacean-claws.svg"
                        fillMode: Image.PreserveAspectFit
                        smooth: true
                    }
                }

                // Cat Head
                Item {
                    visible: bobbleType === "cat"
                    anchors.fill: parent
                    
                    Image {
                        width: parent.width
                        height: parent.height
                        anchors.centerIn: parent
                        source: "qrc:/images/kitty-head.svg"
                        fillMode: Image.PreserveAspectFit
                        smooth: true
                        // Offset slightly to the right and up
                        anchors.horizontalCenterOffset: 35
                        anchors.verticalCenterOffset: -15
                    }
                }

                // Player Head
                Item {
                    visible: bobbleType === "player"
                    anchors.fill: parent

                    //Make head slightly larger
                    scale: 1.5
                    
                    Image {
                        width: parent.width
                        height: parent.height
                        anchors.centerIn: parent
                        source: "qrc:/images/baseball-player-head.svg"
                        fillMode: Image.PreserveAspectFit
                        smooth: true
                        // Center horizontal, slightly above body
                        anchors.verticalCenterOffset: -40
                        anchors.horizontalCenterOffset: -2
                    }
                }

                // Drag handler
                MouseArea {
                    anchors.fill: parent
                    drag.target: parent
                    drag.axis: Drag.XAndYAxis
                    hoverEnabled: true
                    
                    onEntered: {
                        hideTimer.stop();
                        showTimer.start();
                        // Apply a small random force when mouse enters to simulate bobbling
                        bobbleHeadsModel.apply_force(index, (Math.random() - 0.5) * 10, (Math.random() - 0.5) * 5);
                    }

                    onExited: {
                        showTimer.stop();
                        hideTimer.start();
                    }
                    
                    onPositionChanged: {
                        if (drag.active) {
                            bobbleHeadsModel.set_bobble_head_position(index, clawsContainer.x + clawsContainer.width/2, clawsContainer.y + clawsContainer.height/2);
                        }
                    }
                }
            }
        }
    }

    // Bobble Heads ListView
    Repeater {
        model: bobbleHeadsModel
        delegate: bobbleHeadDelegate
    }

    // Physics Timer
    Timer {
        interval: 16 // ~60 FPS
        running: true
        repeat: true
        onTriggered: {
            bobbleHeadsModel.update_physics(0.016);
        }
    }
}