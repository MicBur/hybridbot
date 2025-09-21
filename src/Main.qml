import QtQuick 2.15
import QtQuick.Controls 2.15
import QtCharts 2.15

ApplicationWindow {
    id: window
    visible: true
    width: 1400
    height: 900
    title: qsTr("6bot - Dark Mode Trading Dashboard")
    color: "#0a0a0a"
    
    // Dark theme configuration
    Material.theme: Material.Dark
    Material.primary: "#00ffff"
    Material.accent: "#00ffff"
    Material.background: "#0a0a0a"
    Material.foreground: "#ffffff"
    
    property alias stackView: stackView
    
    header: ToolBar {
        background: Rectangle {
            color: "#1a1a1a"
            border.color: "#00ffff"
            border.width: 1
        }
        
        Row {
            anchors.left: parent.left
            anchors.leftMargin: 20
            anchors.verticalCenter: parent.verticalCenter
            spacing: 30
            
            Button {
                text: "Premium"
                flat: true
                font.pixelSize: 14
                onClicked: stackView.replace("PremiumDashboard.qml")
                
                background: Rectangle {
                    color: parent.pressed ? "#00ffff" : "transparent"
                    opacity: parent.pressed ? 0.3 : 1.0
                }
                
                contentItem: Text {
                    text: parent.text
                    color: "#ffffff"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
            
            Button {
                text: "Charts"
                flat: true
                font.pixelSize: 14
                onClicked: stackView.replace("ChartsView.qml")
                
                background: Rectangle {
                    color: parent.pressed ? "#00ffff" : "transparent"
                    opacity: parent.pressed ? 0.3 : 1.0
                }
                
                contentItem: Text {
                    text: parent.text
                    color: "#ffffff"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
            
            Button {
                text: "Portfolio"
                flat: true
                font.pixelSize: 14
                onClicked: stackView.replace("PortfolioView.qml")
                
                background: Rectangle {
                    color: parent.pressed ? "#00ffff" : "transparent"
                    opacity: parent.pressed ? 0.3 : 1.0
                }
                
                contentItem: Text {
                    text: parent.text
                    color: "#ffffff"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
            
            Button {
                text: "Trades"
                flat: true
                font.pixelSize: 14
                onClicked: stackView.replace("TradesView.qml")
                
                background: Rectangle {
                    color: parent.pressed ? "#00ffff" : "transparent"
                    opacity: parent.pressed ? 0.3 : 1.0
                }
                
                contentItem: Text {
                    text: parent.text
                    color: "#ffffff"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
        
        Text {
            anchors.right: parent.right
            anchors.rightMargin: 20
            anchors.verticalCenter: parent.verticalCenter
            text: "6bot Trading System"
            color: "#00ffff"
            font.pixelSize: 16
            font.weight: Font.Bold
        }
    }
    
    StackView {
        id: stackView
        anchors.fill: parent
        initialItem: PremiumDashboard {}
        
        pushEnter: Transition {
            PropertyAnimation {
                property: "opacity"
                from: 0
                to: 1
                duration: 300
            }
        }
        
        pushExit: Transition {
            PropertyAnimation {
                property: "opacity"
                from: 1
                to: 0
                duration: 300
            }
        }
    }
}
