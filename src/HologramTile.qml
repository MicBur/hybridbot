import QtQuick 2.15
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.15

Rectangle {
    id: root
    color: "transparent"
    
    property string title: "Premium Panel"
    property string value: "0"
    property string subtitle: ""
    property color primaryColor: "#00ffff"
    property color secondaryColor: "#ff6b6b" 
    property bool hologramEffect: true
    property real cornerRadius: 15
    
    signal clicked()
    
    // Main container with advanced glassmorphism
    Rectangle {
        id: mainContainer
        anchors.fill: parent
        radius: root.cornerRadius
        color: "#1a1a1a"
        opacity: 0.85
        
        // Multi-layer border system
        Rectangle {
            anchors.fill: parent
            radius: parent.radius
            color: "transparent"
            border.color: root.primaryColor
            border.width: 2
            opacity: borderPulse.opacity
            
            NumberAnimation {
                id: borderPulse
                property real opacity: 0.6
                target: borderPulse
                property: "opacity"
                from: 0.6
                to: 1.0
                duration: 2000
                running: root.hologramEffect
                loops: Animation.Infinite
                easing.type: Easing.InOutSine
                
                onFinished: {
                    from = to
                    to = (to === 1.0) ? 0.6 : 1.0
                    restart()
                }
            }
        }
        
        // Inner glow border
        Rectangle {
            anchors.fill: parent
            anchors.margins: 2
            radius: parent.radius - 2
            color: "transparent"
            border.color: Qt.rgba(0, 1, 1, 0.3)
            border.width: 1
        }
        
        // Hologram scan lines
        Rectangle {
            id: scanLine
            width: parent.width
            height: 2
            color: root.primaryColor
            opacity: 0.4
            visible: root.hologramEffect
            
            NumberAnimation on y {
                from: 0
                to: root.height - 2
                duration: 3000
                running: root.hologramEffect
                loops: Animation.Infinite
                easing.type: Easing.InOutQuart
            }
            
            gradient: Gradient {
                GradientStop { position: 0.0; color: "transparent" }
                GradientStop { position: 0.5; color: root.primaryColor }
                GradientStop { position: 1.0; color: "transparent" }
            }
        }
    }
    
    // Drop shadow with dynamic intensity
    DropShadow {
        anchors.fill: mainContainer
        source: mainContainer
        color: root.primaryColor
        radius: shadowIntensity.radius
        samples: 16
        horizontalOffset: 0
        verticalOffset: 0
        spread: 0.4
        
        NumberAnimation {
            id: shadowIntensity
            property real radius: 12
            target: shadowIntensity
            property: "radius"
            from: 12
            to: 20
            duration: 1800
            running: root.hologramEffect
            loops: Animation.Infinite
            easing.type: Easing.InOutSine
            
            onFinished: {
                from = to
                to = (to === 20) ? 12 : 20
                restart()
            }
        }
    }
    
    // Content layout
    Column {
        anchors.centerIn: parent
        spacing: 8
        
        // Title with holographic effect
        Text {
            id: titleText
            text: root.title
            color: "#ffffff"
            font.pixelSize: 14
            font.weight: Font.Medium
            anchors.horizontalCenter: parent.horizontalCenter
            
            layer.enabled: true
            layer.effect: Glow {
                color: root.primaryColor
                radius: 6
                samples: 12
                spread: 0.2
            }
        }
        
        // Main value with pulsing glow
        Text {
            id: valueText
            text: root.value
            color: root.primaryColor
            font.pixelSize: 28
            font.weight: Font.Bold
            anchors.horizontalCenter: parent.horizontalCenter
            
            layer.enabled: true
            layer.effect: Glow {
                color: root.primaryColor
                radius: valueGlow.radius
                samples: 16
                spread: 0.3
            }
            
            NumberAnimation {
                id: valueGlow
                property real radius: 8
                target: valueGlow
                property: "radius"
                from: 8
                to: 16
                duration: 1500
                running: root.hologramEffect
                loops: Animation.Infinite
                easing.type: Easing.InOutSine
                
                onFinished: {
                    from = to
                    to = (to === 16) ? 8 : 16
                    restart()
                }
            }
        }
        
        // Subtitle
        Text {
            id: subtitleText
            text: root.subtitle
            color: "#cccccc"
            font.pixelSize: 12
            anchors.horizontalCenter: parent.horizontalCenter
            visible: text !== ""
            opacity: subtitleOpacity.opacity
            
            NumberAnimation {
                id: subtitleOpacity
                property real opacity: 0.7
                target: subtitleOpacity
                property: "opacity"
                from: 0.7
                to: 1.0
                duration: 2200
                running: root.hologramEffect && subtitleText.visible
                loops: Animation.Infinite
                easing.type: Easing.InOutSine
                
                onFinished: {
                    from = to
                    to = (to === 1.0) ? 0.7 : 1.0
                    restart()
                }
            }
        }
    }
    
    // Interactive click area with haptic feedback
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        
        onClicked: {
            clickEffect.start()
            root.clicked()
        }
        
        onEntered: {
            hoverEffect.start()
        }
        
        onExited: {
            hoverEffect.stop()
            mainContainer.scale = 1.0
        }
        
        // Hover scaling effect
        NumberAnimation {
            id: hoverEffect
            target: mainContainer
            property: "scale"
            to: 1.02
            duration: 200
            easing.type: Easing.OutQuart
        }
        
        // Click ripple effect
        Rectangle {
            id: clickRipple
            anchors.centerIn: parent
            width: 0
            height: 0
            radius: width / 2
            color: Qt.rgba(0, 1, 1, 0.3)
            visible: false
            
            ParallelAnimation {
                id: clickEffect
                
                onStarted: clickRipple.visible = true
                onFinished: clickRipple.visible = false
                
                NumberAnimation {
                    target: clickRipple
                    property: "width"
                    from: 0
                    to: root.width * 1.5
                    duration: 400
                    easing.type: Easing.OutQuart
                }
                
                NumberAnimation {
                    target: clickRipple
                    property: "height"
                    from: 0
                    to: root.height * 1.5
                    duration: 400
                    easing.type: Easing.OutQuart
                }
                
                NumberAnimation {
                    target: clickRipple
                    property: "opacity"
                    from: 0.6
                    to: 0
                    duration: 400
                }
            }
        }
    }
    
    // Data visualization bars (optional)
    Row {
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: 10
        spacing: 2
        visible: root.hologramEffect
        
        Repeater {
            model: 8
            
            Rectangle {
                width: 3
                height: Math.random() * 15 + 5
                color: root.primaryColor
                opacity: 0.6
                radius: 1
                
                NumberAnimation on height {
                    from: height
                    to: Math.random() * 15 + 5
                    duration: 1000 + (index * 200)
                    running: root.hologramEffect
                    loops: Animation.Infinite
                    easing.type: Easing.InOutSine
                    
                    onFinished: {
                        from = to
                        to = Math.random() * 15 + 5
                        restart()
                    }
                }
            }
        }
    }
}