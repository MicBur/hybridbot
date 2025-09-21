import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    id: root
    
    property string title: ""
    property string value: ""
    property string subtitle: ""
    property color accentColor: "#00ffff"
    property real glowIntensity: 0.3
    property bool animated: true
    
    signal clicked()
    
    Rectangle {
        id: background
        anchors.fill: parent
        color: "#1a1a1a"
        opacity: 0.8
        radius: 12
        border.color: root.accentColor
        border.width: 1
        
        // Glow effect
        Rectangle {
            id: glow
            anchors.fill: parent
            radius: parent.radius
            color: "transparent"
            border.color: root.accentColor
            border.width: 2
            opacity: root.glowIntensity
            visible: root.animated
            
            SequentialAnimation on opacity {
                running: root.animated
                loops: Animation.Infinite
                NumberAnimation { to: 0.6; duration: 2000; easing.type: Easing.OutQuad }
                NumberAnimation { to: 0.3; duration: 2000; easing.type: Easing.InQuad }
            }
        }
        
        // Glasmorphism effect
        Rectangle {
            anchors.fill: parent
            anchors.margins: 1
            radius: parent.radius - 1
            color: Qt.rgba(1, 1, 1, 0.05)
        }
    }
    
    Column {
        anchors.centerIn: parent
        spacing: 8
        
        Text {
            id: titleText
            text: root.title
            color: "#ffffff"
            font.pixelSize: 14
            font.weight: Font.Medium
            anchors.horizontalCenter: parent.horizontalCenter
        }
        
        Text {
            id: valueText
            text: root.value
            color: root.accentColor
            font.pixelSize: 24
            font.weight: Font.Bold
            anchors.horizontalCenter: parent.horizontalCenter
        }
        
        Text {
            id: subtitleText
            text: root.subtitle
            color: "#cccccc"
            font.pixelSize: 12
            anchors.horizontalCenter: parent.horizontalCenter
            visible: text !== ""
        }
    }
    
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        
        onClicked: root.clicked()
        
        onEntered: {
            background.scale = 1.02
            root.glowIntensity = 0.6
        }
        
        onExited: {
            background.scale = 1.0
            root.glowIntensity = 0.3
        }
        
        Behavior on scale {
            NumberAnimation { duration: 150; easing.type: Easing.OutQuad }
        }
    }
    
    Behavior on glowIntensity {
        NumberAnimation { duration: 150 }
    }
}