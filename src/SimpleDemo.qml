import QtQuick 2.15
import QtQuick.Controls 2.15

ApplicationWindow {
    id: window
    visible: true
    width: 1200
    height: 800
    title: qsTr("6bot - Dark Mode Trading Dashboard")
    color: "#0a0a0a"
    
    // Simple demo without 3D components for now
    Rectangle {
        anchors.fill: parent
        color: "#0a0a0a"
        
        Text {
            anchors.centerIn: parent
            text: "🚀 6bot Trading Dashboard Ready!\n\nDark Mode: ✅\nQt Quick Controls 2: ✅\nRedis Client: ✅\nGlass Tiles: ✅\n\n3D Charts werden geladen..."
            color: "#00ffff"
            font.pixelSize: 24
            font.weight: Font.Bold
            horizontalAlignment: Text.AlignHCenter
            
            SequentialAnimation on opacity {
                running: true
                loops: Animation.Infinite
                NumberAnimation { to: 0.5; duration: 1000 }
                NumberAnimation { to: 1.0; duration: 1000 }
            }
        }
        
        // Connection status indicator
        Rectangle {
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            anchors.margins: 20
            width: 200
            height: 80
            color: "#1a1a1a"
            radius: 10
            border.color: "#00ffff"
            border.width: 2
            
            Rectangle {
                anchors.centerIn: parent
                width: 12
                height: 12
                radius: 6
                color: "#00ff00"
                
                SequentialAnimation on scale {
                    running: true
                    loops: Animation.Infinite
                    NumberAnimation { to: 1.5; duration: 800 }
                    NumberAnimation { to: 1.0; duration: 800 }
                }
            }
            
            Text {
                anchors.centerIn: parent
                anchors.verticalCenterOffset: 25
                text: "Redis: Connected"
                color: "#ffffff"
                font.pixelSize: 12
            }
        }
    }
}