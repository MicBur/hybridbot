import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    id: root
    
    property string title: ""
    property string value: ""
    property string subtitle: ""
    property color primaryColor: "#00ffff"
    property color secondaryColor: "#ff006b"
    property real animationSpeed: 2000
    property bool premium: true
    
    signal clicked()
    
    Rectangle {
        id: background
        anchors.fill: parent
        color: "transparent"
        radius: 16
        
        // Premium gradient background
        Rectangle {
            id: gradientBg
            anchors.fill: parent
            radius: parent.radius
            gradient: Gradient {
                GradientStop { position: 0.0; color: Qt.rgba(0, 1, 1, 0.1) }
                GradientStop { position: 0.5; color: Qt.rgba(1, 0, 0.42, 0.05) }
                GradientStop { position: 1.0; color: Qt.rgba(0, 1, 1, 0.1) }
            }
            
            // Animated gradient rotation
            RotationAnimation on rotation {
                running: root.premium
                loops: Animation.Infinite
                duration: root.animationSpeed * 3
                from: 0
                to: 360
            }
        }
        
        // Holographic scan lines
        Rectangle {
            id: scanLines
            anchors.fill: parent
            anchors.margins: 2
            radius: parent.radius - 2
            color: "transparent"
            clip: true
            
            Repeater {
                model: 8
                Rectangle {
                    width: parent.width
                    height: 2
                    y: index * (parent.height / 8)
                    color: root.primaryColor
                    opacity: 0.3
                    
                    SequentialAnimation on opacity {
                        running: root.premium
                        loops: Animation.Infinite
                        NumberAnimation { 
                            to: 0.8; 
                            duration: root.animationSpeed / 4 
                        }
                        NumberAnimation { 
                            to: 0.1; 
                            duration: root.animationSpeed / 4 
                        }
                        PauseAnimation { duration: index * 100 }
                    }
                }
            }
        }
        
        // Premium border with glow
        Rectangle {
            anchors.fill: parent
            color: "transparent"
            radius: parent.radius
            border.width: 2
            border.color: root.primaryColor
            
            // Animated border color
            SequentialAnimation on border.color {
                running: root.premium
                loops: Animation.Infinite
                ColorAnimation { 
                    to: root.secondaryColor; 
                    duration: root.animationSpeed 
                }
                ColorAnimation { 
                    to: root.primaryColor; 
                    duration: root.animationSpeed 
                }
            }
        }
        
        // Glow effect
        Rectangle {
            anchors.fill: parent
            anchors.margins: -4
            radius: parent.radius + 4
            color: "transparent"
            border.width: 1
            border.color: root.primaryColor
            opacity: 0.4
            
            SequentialAnimation on opacity {
                running: root.premium
                loops: Animation.Infinite
                NumberAnimation { to: 0.8; duration: 1000 }
                NumberAnimation { to: 0.2; duration: 1000 }
            }
        }
    }
    
    // Content with enhanced typography
    Column {
        anchors.centerIn: parent
        spacing: 12
        
        Text {
            id: titleText
            text: root.title
            color: "#ffffff"
            font.pixelSize: 16
            font.weight: Font.Medium
            font.family: "Segoe UI"
            anchors.horizontalCenter: parent.horizontalCenter
        }
        
        Text {
            id: valueText
            text: root.value
            color: root.primaryColor
            font.pixelSize: 28
            font.weight: Font.Bold
            font.family: "Consolas"
            anchors.horizontalCenter: parent.horizontalCenter
            
            // Number animation effect
            NumberAnimation on scale {
                running: root.premium
                loops: Animation.Infinite
                from: 0.98
                to: 1.02
                duration: 2000
                easing.type: Easing.InOutQuad
            }
        }
        
        Text {
            id: subtitleText
            text: root.subtitle
            color: "#cccccc"
            font.pixelSize: 14
            font.family: "Segoe UI"
            anchors.horizontalCenter: parent.horizontalCenter
            visible: text !== ""
        }
    }
    
    // Interactive hover effects
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        
        onClicked: root.clicked()
        
        onEntered: {
            root.scale = 1.05
            root.animationSpeed = 1000
            background.opacity = 0.9
        }
        
        onExited: {
            root.scale = 1.0
            root.animationSpeed = 2000
            background.opacity = 0.8
        }
        
        Behavior on scale {
            NumberAnimation { 
                duration: 200; 
                easing.type: Easing.OutCubic 
            }
        }
    }
    
    // Corner particles effect
    Repeater {
        model: 4
        Rectangle {
            width: 6
            height: 6
            radius: 3
            color: root.primaryColor
            opacity: 0.7
            
            x: index < 2 ? 10 : parent.width - 16
            y: (index % 2 === 0) ? 10 : parent.height - 16
            
            SequentialAnimation on opacity {
                running: root.premium
                loops: Animation.Infinite
                NumberAnimation { to: 1.0; duration: 800 }
                NumberAnimation { to: 0.3; duration: 800 }
                PauseAnimation { duration: index * 200 }
            }
        }
    }
}