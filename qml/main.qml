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
                y: model.restY - 80 // Moved closer
                width: controlsRow.width + 20
                height: controlsRow.height + 20

                Rectangle {
                    anchors.fill: parent
                    color: "#80000000"
                    radius: 5
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: hideTimer.stop()
                    onExited: hideTimer.start()
                }

                Row {
                    id: controlsRow
                    anchors.centerIn: parent
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

            // Crab Body (Fixed at rest position)
            Item {
                x: model.restX - 50
                y: model.restY
                width: 100
                height: 60

                // Ferris Body
                Item {
                    visible: bobbleType === "ferris"
                    anchors.fill: parent

                    // Legs
                    Repeater {
                        model: 6 // 3 legs per side
                        delegate: Rectangle {
                            x: index < 3 ? -10 : parent.width - 10
                            y: 20 + (index % 3) * 10
                            width: 30
                            height: 8
                            color: "#FF6B6B" // Crab red
                            rotation: index < 3 ? -20 : 20
                            radius: 4
                        }
                    }

                    // Main Shell
                    Rectangle {
                        anchors.fill: parent
                        color: "#FF6B6B"
                        radius: 30
                        border.color: "#cc0000"
                        border.width: 2
                    }
                    
                    // Eyes (Now fixed on body)
                    Item {
                        anchors.horizontalCenter: parent.horizontalCenter
                        y: -20
                        width: parent.width * 0.6
                        height: 30

                        // Eye stalks
                        Rectangle {
                            x: parent.width * 0.2
                            y: 10
                            width: 5
                            height: 20
                            color: "#FF6B6B"
                        }
                        Rectangle {
                            x: parent.width * 0.8
                            y: 10
                            width: 5
                            height: 20
                            color: "#FF6B6B"
                        }

                        // Eyes
                        Rectangle {
                            x: parent.width * 0.15
                            y: 0
                            width: 15
                            height: 15
                            radius: 7.5
                            color: "white"
                            border.color: "black"
                            Rectangle {
                                anchors.centerIn: parent
                                width: 5
                                height: 5
                                radius: 2.5
                                color: "black"
                            }
                        }
                        Rectangle {
                            x: parent.width * 0.75
                            y: 0
                            width: 15
                            height: 15
                            radius: 7.5
                            color: "white"
                            border.color: "black"
                            Rectangle {
                                anchors.centerIn: parent
                                width: 5
                                height: 5
                                radius: 2.5
                                color: "black"
                            }
                        }
                    }
                }

                // Cat Body
                Item {
                    visible: bobbleType === "cat"
                    anchors.fill: parent
                    Rectangle {
                        anchors.centerIn: parent
                        width: 80
                        height: 60
                        color: "#FFA500"
                        radius: 30
                        border.color: "#CC8400"
                        border.width: 2
                    }
                    // Tail
                    Rectangle {
                        x: 70
                        y: 20
                        width: 40
                        height: 10
                        color: "#FFA500"
                        radius: 5
                        rotation: -20
                    }
                }

                // Player Body
                Item {
                    visible: bobbleType === "player"
                    anchors.fill: parent
                    Rectangle {
                        anchors.centerIn: parent
                        width: 80
                        height: 60
                        color: "#4169E1" // Royal Blue Jersey
                        radius: 20
                        border.color: "#000080"
                        border.width: 2
                    }
                    // Number
                    Text {
                        anchors.centerIn: parent
                        text: "10"
                        color: "white"
                        font.bold: true
                        font.pixelSize: 24
                    }
                }
            }

            // Claws (Movable part - Bobbling)
            Item {
                id: clawsContainer
                x: model.x - 50 // Center relative to physics model x
                y: model.y - 30 // Center relative to physics model y
                width: 100
                height: 60
                z: 2
                rotation: model.rotation * 50 

                // Ferris Claws
                Item {
                    visible: bobbleType === "ferris"
                    anchors.fill: parent
                    // Left Claw
                    Rectangle { 
                        x: -25
                        y: -20
                        width: 40
                        height: 30
                        radius: 15
                        color: "#FF6B6B"
                        border.color: "#cc0000"
                        border.width: 2
                        rotation: -30
                    }
                    // Right Claw
                    Rectangle { 
                        x: parent.width - 15
                        y: -20
                        width: 40
                        height: 30
                        radius: 15
                        color: "#FF6B6B"
                        border.color: "#cc0000"
                        border.width: 2
                        rotation: 30
                    }
                }

                // Cat Head
                Item {
                    visible: bobbleType === "cat"
                    anchors.centerIn: parent
                    width: 60
                    height: 60
                    
                    // Ears
                    Rectangle { x: 0; y: 0; width: 20; height: 20; color: "#FFA500"; rotation: -15 }
                    Rectangle { x: 40; y: 0; width: 20; height: 20; color: "#FFA500"; rotation: 15 }
                    
                    // Face
                    Rectangle {
                        anchors.fill: parent
                        radius: 30
                        color: "#FFA500"
                        border.color: "#CC8400"
                        border.width: 2
                    }
                    
                    // Eyes
                    Rectangle { x: 15; y: 20; width: 8; height: 8; radius: 4; color: "black" }
                    Rectangle { x: 37; y: 20; width: 8; height: 8; radius: 4; color: "black" }
                    
                    // Nose
                    Rectangle { x: 27; y: 35; width: 6; height: 4; radius: 2; color: "pink" }
                }

                // Player Head
                Item {
                    visible: bobbleType === "player"
                    anchors.centerIn: parent
                    width: 50
                    height: 50
                    
                    // Head
                    Rectangle {
                        anchors.fill: parent
                        radius: 25
                        color: "#FFCCAA" // Skin tone
                        border.color: "#D4A080"
                        border.width: 1
                    }
                    
                    // Cap
                    Rectangle {
                        x: -5
                        y: -5
                        width: 60
                        height: 20
                        radius: 5
                        color: "#4169E1"
                    }
                    Rectangle {
                        x: 0
                        y: -10
                        width: 50
                        height: 25
                        radius: 25
                        color: "#4169E1"
                    }
                    
                    // Eyes
                    Rectangle { x: 12; y: 20; width: 6; height: 6; radius: 3; color: "black" }
                    Rectangle { x: 32; y: 20; width: 6; height: 6; radius: 3; color: "black" }
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