import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import com.kdab.todo 1.0

ApplicationWindow {
    id: window
    width: 800
    height: 600
    visible: true
    flags: Qt.FramelessWindowHint | Qt.Window
    color: "transparent"

    // Background removed
    
    // Platform removed

    // Bobble Head Model
    BobbleHeadModel {
        id: bobbleHeadsModel
    }

    // Bobble Head Delegate
    Component {
        id: bobbleHeadDelegate
        Item {
            // Helper properties
            property real headRadius: model.headRadius || 25
            property real headDiameter: headRadius * 2

            // Crab Body (Fixed at rest position)
            Item {
                x: model.restX - 50
                y: model.restY
                width: 100
                height: 60

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

            // Claws (Movable part - Bobbling)
            Item {
                id: clawsContainer
                x: model.x - 50 // Center relative to physics model x
                y: model.y - 30 // Center relative to physics model y
                width: 100
                height: 60
                z: 2
                rotation: model.rotation * 50 

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

                // Drag handler
                MouseArea {
                    anchors.fill: parent
                    drag.target: parent
                    drag.axis: Drag.XAndYAxis
                    
                    onPositionChanged: {
                        bobbleHeadsModel.set_bobble_head_position(index, clawsContainer.x + clawsContainer.width/2, clawsContainer.y + clawsContainer.height/2);
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

    // Button removed

    // Physics Timer
    Timer {
        interval: 16 // ~60 FPS
        running: true
        repeat: true
        onTriggered: {
            bobbleHeadsModel.update_physics(0.016);
        }
    }

    // Initial bobble head
    Component.onCompleted: {
        bobbleHeadsModel.add_bobble_head(
            window.width / 2,
            window.height - 150,
            30,
            "#FF6B6B"
        );
    }
}