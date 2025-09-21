import QtQuick 2.15
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.15

Button {
    id: root
    
    property string gradientStart: "#00ffff"
    property string gradientEnd: "#0099cc"
    property string glowColor: "#00ffff"
    property real cornerRadius: 12
    property bool dynamicGlow: true
    
    signal clicked()
    
    background: Rectangle {
        id: buttonBackground
        radius: root.cornerRadius
        
        gradient: Gradient {
            GradientStop { position: 0.0; color: root.pressed ? Qt.darker(root.gradientStart, 1.3) : root.gradientStart }
            GradientStop { position: 1.0; color: root.pressed ? Qt.darker(root.gradientEnd, 1.3) : root.gradientEnd }
        }
        
        // Glasmorphism layer
        Rectangle {
            anchors.fill: parent
            anchors.margins: 1
            radius: parent.radius - 1
            color: "transparent"
            border.color: Qt.rgba(1, 1, 1, 0.3)
            border.width: 1
        }
        
        // Inner glow
        Rectangle {
            anchors.fill: parent
            anchors.margins: 2
            radius: parent.radius - 2
            color: "transparent"
            border.color: Qt.rgba(1, 1, 1, 0.1)
            border.width: 1
        }
    }
    
    // Outer glow effect
    DropShadow {
        anchors.fill: buttonBackground
        source: buttonBackground
        color: root.glowColor
        radius: root.dynamicGlow ? glowAnimation.currentRadius : 8
        samples: 16
        horizontalOffset: 0
        verticalOffset: 0
        spread: 0.3
    }
    
    // Dynamic glow animation
    PropertyAnimation {
        id: glowAnimation
        property real currentRadius: 8
        target: glowAnimation
        property: "currentRadius"
        from: 8
        to: 16
        duration: 1500
        easing.type: Easing.InOutSine
        running: root.dynamicGlow
        loops: Animation.Infinite
        
        onFinished: {
            from = to
            to = (to === 16) ? 8 : 16
            restart()
        }
    }
    
    contentItem: Text {
        text: root.text
        color: "#ffffff"
        font.pixelSize: 14
        font.weight: Font.Bold
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        
        layer.enabled: true
        layer.effect: DropShadow {
            color: "#000000"
            radius: 2
            samples: 4
            horizontalOffset: 1
            verticalOffset: 1
        }
    }
    
    // Hover effects
    states: [
        State {
            name: "hovered"
            when: root.hovered
            PropertyChanges {
                target: buttonBackground
                scale: 1.05
            }
            PropertyChanges {
                target: root
                opacity: 0.9
            }
        }
    ]
    
    transitions: [
        Transition {
            from: ""; to: "hovered"
            reversible: true
            ParallelAnimation {
                NumberAnimation {
                    property: "scale"
                    duration: 200
                    easing.type: Easing.OutQuart
                }
                NumberAnimation {
                    property: "opacity"
                    duration: 200
                }
            }
        }
    ]
    
    // Click ripple effect
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        
        onClicked: {
            rippleEffect.start()
            root.clicked()
        }
        
        Rectangle {
            id: ripple
            anchors.centerIn: parent
            width: 0
            height: 0
            radius: width / 2
            color: Qt.rgba(1, 1, 1, 0.3)
            visible: false
            
            ParallelAnimation {
                id: rippleEffect
                
                onStarted: ripple.visible = true
                onFinished: ripple.visible = false
                
                NumberAnimation {
                    target: ripple
                    property: "width"
                    from: 0
                    to: root.width * 2
                    duration: 300
                    easing.type: Easing.OutQuart
                }
                
                NumberAnimation {
                    target: ripple
                    property: "height"
                    from: 0
                    to: root.height * 2
                    duration: 300
                    easing.type: Easing.OutQuart
                }
                
                NumberAnimation {
                    target: ripple
                    property: "opacity"
                    from: 0.6
                    to: 0
                    duration: 300
                }
            }
        }
    }
}