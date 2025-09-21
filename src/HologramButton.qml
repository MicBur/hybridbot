import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    id: root
    width: 300
    height: 200
    
    property alias title: titleText.text
    property alias subtitle: subtitleText.text
    property color accentColor: "#00ffff"
    property bool animated: true
    
    signal clicked()
    
    Rectangle {
        id: mainButton
        anchors.fill: parent
        color: "transparent"
        radius: 20
        border.width: 0
        
        // Holographic gradient background
        Rectangle {
            anchors.fill: parent
            radius: parent.radius
            opacity: 0.8
            
            gradient: Gradient {
                GradientStop { 
                    position: 0.0
                    color: Qt.rgba(0, 1, 1, 0.15)
                }
                GradientStop { 
                    position: 0.3
                    color: Qt.rgba(0.2, 0.2, 0.2, 0.3)
                }
                GradientStop { 
                    position: 0.7
                    color: Qt.rgba(0.1, 0.1, 0.1, 0.4)
                }
                GradientStop { 
                    position: 1.0
                    color: Qt.rgba(1, 0, 0.42, 0.1)
                }
            }
        }
        
        // Animated border rings
        Repeater {
            model: 3
            Rectangle {
                anchors.fill: parent
                anchors.margins: index * 3
                radius: parent.radius - (index * 2)
                color: "transparent"
                border.width: 1
                border.color: root.accentColor
                opacity: 0.6 - (index * 0.2)
                
                SequentialAnimation on opacity {
                    running: root.animated
                    loops: Animation.Infinite
                    NumberAnimation { 
                        to: 0.9 - (index * 0.1)
                        duration: 1500 + (index * 300)
                        easing.type: Easing.InOutQuad
                    }
                    NumberAnimation { 
                        to: 0.3 - (index * 0.1)
                        duration: 1500 + (index * 300)
                        easing.type: Easing.InOutQuad
                    }
                }
            }
        }
        
        // Content area
        Column {
            anchors.centerIn: parent
            spacing: 15
            
            Text {
                id: titleText
                text: "PREMIUM BUTTON"
                color: "#ffffff"
                font.pixelSize: 18
                font.weight: Font.Bold
                font.family: "Arial"
                anchors.horizontalCenter: parent.horizontalCenter
                
                // Text glow simulation
                Rectangle {
                    anchors.fill: parent
                    anchors.margins: -2
                    color: "transparent"
                    border.width: 1
                    border.color: root.accentColor
                    opacity: 0.3
                    radius: 2
                    z: -1
                }
            }
            
            Text {
                id: subtitleText
                text: "Enhanced Edition"
                color: root.accentColor
                font.pixelSize: 14
                font.family: "Arial"
                anchors.horizontalCenter: parent.horizontalCenter
                opacity: 0.8
            }
        }
        
        // Hover glow effect
        Rectangle {
            id: hoverGlow
            anchors.fill: parent
            anchors.margins: -5
            radius: parent.radius + 5
            color: "transparent"
            border.width: 2
            border.color: root.accentColor
            opacity: 0
            
            Behavior on opacity {
                NumberAnimation { duration: 300 }
            }
        }
    }
    
    // Interactive area
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        
        onClicked: {
            // Click animation
            mainButton.scale = 0.95
            scaleBackTimer.start()
            root.clicked()
        }
        
        onEntered: {
            hoverGlow.opacity = 0.6
            mainButton.scale = 1.05
        }
        
        onExited: {
            hoverGlow.opacity = 0
            mainButton.scale = 1.0
        }
        
        Timer {
            id: scaleBackTimer
            interval: 150
            onTriggered: mainButton.scale = 1.05
        }
        
        Behavior on scale {
            NumberAnimation { duration: 200 }
        }
    }
    
    Behavior on scale {
        NumberAnimation { duration: 200 }
    }
}