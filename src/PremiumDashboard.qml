import QtQuick 2.15
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.15
import QtCharts 2.15

Rectangle {
    id: root
    color: "transparent"
    
    property alias title: titleText.text
    property color primaryColor: "#00ffff"
    property color secondaryColor: "#ff6b6b"
    property real animationSpeed: 1.0
    
    // Main container with premium glass effect
    Rectangle {
        id: premiumContainer
        anchors.fill: parent
        radius: 20
        color: "#0f0f0f"
        opacity: 0.9
        border.color: root.primaryColor
        border.width: 2
        
        // Premium gradient background
        gradient: Gradient {
            GradientStop { position: 0.0; color: Qt.rgba(0.05, 0.05, 0.05, 0.95) }
            GradientStop { position: 0.3; color: Qt.rgba(0.1, 0.1, 0.1, 0.9) }
            GradientStop { position: 0.7; color: Qt.rgba(0.08, 0.08, 0.08, 0.9) }
            GradientStop { position: 1.0; color: Qt.rgba(0.03, 0.03, 0.03, 0.95) }
        }
        
        // Inner glow effect
        Rectangle {
            anchors.fill: parent
            anchors.margins: 2
            radius: parent.radius - 2
            color: "transparent"
            border.color: Qt.rgba(0, 1, 1, 0.4)
            border.width: 1
        }
    }
    
    // Advanced drop shadow
    DropShadow {
        anchors.fill: premiumContainer
        source: premiumContainer
        color: root.primaryColor
        radius: 20
        samples: 32
        horizontalOffset: 0
        verticalOffset: 5
        spread: 0.3
        opacity: 0.8
    }
    
    // Content area
    Column {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 15
        
        // Premium title with glow
        Text {
            id: titleText
            text: "Premium Dashboard"
            color: "#ffffff"
            font.pixelSize: 18
            font.weight: Font.Bold
            anchors.horizontalCenter: parent.horizontalCenter
            
            layer.enabled: true
            layer.effect: Glow {
                color: root.primaryColor
                radius: 8
                samples: 16
                spread: 0.3
            }
        }
        
        // Stats grid with holographic effects
        Grid {
            anchors.horizontalCenter: parent.horizontalCenter
            columns: 2
            spacing: 15
            
            // Profit tile
            HologramTile {
                width: 120
                height: 80
                title: "PROFIT"
                value: "+€2,847"
                subtitle: "+12.4%"
                primaryColor: "#00ff88"
                hologramEffect: true
                
                onClicked: {
                    console.log("Profit clicked")
                }
            }
            
            // Volume tile  
            HologramTile {
                width: 120
                height: 80
                title: "VOLUME"
                value: "€45.2K"
                subtitle: "24h"
                primaryColor: "#ff6b6b"
                hologramEffect: true
                
                onClicked: {
                    console.log("Volume clicked")
                }
            }
            
            // Trades tile
            HologramTile {
                width: 120
                height: 80
                title: "TRADES"
                value: "127"
                subtitle: "Active"
                primaryColor: "#ffd700"
                hologramEffect: true
                
                onClicked: {
                    console.log("Trades clicked")
                }
            }
            
            // Performance tile
            HologramTile {
                width: 120
                height: 80
                title: "WIN RATE"
                value: "78.5%"
                subtitle: "Success"
                primaryColor: "#00ffff"
                hologramEffect: true
                
                onClicked: {
                    console.log("Performance clicked")
                }
            }
        }
        
        // Premium dynamic chart
        Rectangle {
            width: parent.width
            height: 200
            color: "transparent"
            
            DynamicChart {
                anchors.fill: parent
                chartTitle: "Real-time Performance"
                primaryColor: root.primaryColor
                secondaryColor: root.secondaryColor
            }
        }
        
        // Action buttons row
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 20
            
            PremiumButton {
                width: 100
                height: 40
                text: "TRADE"
                primaryColor: "#00ff88"
                icon: "▶"
                glowEffect: true
                
                onClicked: {
                    console.log("Trade button clicked")
                }
            }
            
            PremiumButton {
                width: 100
                height: 40
                text: "ANALYZE"
                primaryColor: "#00ffff"
                icon: "📊"
                glowEffect: true
                
                onClicked: {
                    console.log("Analyze button clicked")
                }
            }
            
            PremiumButton {
                width: 100
                height: 40
                text: "SETTINGS"
                primaryColor: "#ff6b6b"
                icon: "⚙"
                glowEffect: true
                
                onClicked: {
                    console.log("Settings button clicked")
                }
            }
        }
    }
    
    // Floating holographic particles
    Repeater {
        model: 15
        
        Rectangle {
            width: Math.random() * 4 + 2
            height: width
            radius: width / 2
            color: root.primaryColor
            opacity: Math.random() * 0.6 + 0.2
            
            x: Math.random() * root.width
            y: Math.random() * root.height
            
            NumberAnimation on x {
                from: x
                to: Math.random() * root.width
                duration: (Math.random() * 8000 + 4000) / root.animationSpeed
                running: true
                loops: Animation.Infinite
                easing.type: Easing.InOutSine
                
                onFinished: {
                    from = to
                    to = Math.random() * root.width
                    restart()
                }
            }
            
            NumberAnimation on y {
                from: y
                to: Math.random() * root.height
                duration: (Math.random() * 6000 + 3000) / root.animationSpeed
                running: true
                loops: Animation.Infinite
                easing.type: Easing.InOutSine
                
                onFinished: {
                    from = to
                    to = Math.random() * root.height
                    restart()
                }
            }
            
            NumberAnimation on opacity {
                from: opacity
                to: Math.random() * 0.8 + 0.1
                duration: (Math.random() * 3000 + 2000) / root.animationSpeed
                running: true
                loops: Animation.Infinite
                easing.type: Easing.InOutSine
                
                onFinished: {
                    from = to
                    to = Math.random() * 0.8 + 0.1
                    restart()
                }
            }
        }
    }
    
    // Connection status indicator
    Rectangle {
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: 15
        width: 12
        height: 12
        radius: 6
        color: "#00ff88"
        
        layer.enabled: true
        layer.effect: Glow {
            color: "#00ff88"
            radius: 8
            samples: 16
            spread: 0.4
        }
        
        NumberAnimation on opacity {
            from: 0.6
            to: 1.0
            duration: 1000
            running: true
            loops: Animation.Infinite
            easing.type: Easing.InOutSine
            
            onFinished: {
                from = to
                to = (to === 1.0) ? 0.6 : 1.0
                restart()
            }
        }
    }
}