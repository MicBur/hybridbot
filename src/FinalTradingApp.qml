import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Window 2.12

Window {
    id: window
    width: 1400
    height: 900
    visible: true
    title: "6bot Enhanced Trading Suite - Portfolio Management"
    color: "#0a0a0a"
    
    flags: Qt.Window | Qt.WindowTitleHint | Qt.WindowMinMaxButtonsHint | Qt.WindowCloseButtonHint
    
    // Ensure window is visible and in foreground
    Component.onCompleted: {
        window.show()
        window.raise()
        window.requestActivate()
    }
    
    // Status bar at top
    Rectangle {
        id: statusBar
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 50
        color: "#111111"
        border.color: "#00ffff"
        border.width: 2
        
        Row {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: 20
            spacing: 40
            
            Row {
                spacing: 10
                Rectangle {
                    width: 12
                    height: 12
                    radius: 6
                    color: "#00ff00"
                    
                    SequentialAnimation on opacity {
                        loops: Animation.Infinite
                        NumberAnimation { to: 0.3; duration: 1000 }
                        NumberAnimation { to: 1.0; duration: 1000 }
                    }
                }
                Text {
                    text: "System ONLINE"
                    color: "#00ff00"
                    font.pixelSize: 14
                    font.bold: true
                }
            }
            
            Text {
                text: "Portfolio: $109,329.05 (+2.67%)"
                color: "#00ffff"
                font.pixelSize: 14
                font.bold: true
            }
            
            Text {
                text: "ML Accuracy: 87.3%"
                color: "#00ff00"
                font.pixelSize: 14
                font.bold: true
            }
            
            Text {
                text: "Grok Signals: 8 Active"
                color: "#ffaa00"
                font.pixelSize: 14
                font.bold: true
            }
        }
        
        Text {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.rightMargin: 20
            text: "PAPER TRADING MODE"
            color: "#ffaa00"
            font.pixelSize: 12
            font.bold: true
        }
    }
    
    // Navigation bar
    Rectangle {
        id: navBar
        anchors.top: statusBar.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: 80
        color: "#1a1a1a"
        border.color: "#00ffff"
        border.width: 2
        
        Row {
            anchors.centerIn: parent
            spacing: 30
            
            Button {
                text: "🏠 Dashboard"
                width: 200
                height: 60
                background: Rectangle {
                    color: mainStack.currentIndex === 0 ? "#00ffff" : "#333333"
                    border.color: "#ffffff"
                    border.width: 2
                    radius: 10
                }
                contentItem: Text {
                    text: parent.text
                    color: mainStack.currentIndex === 0 ? "#000000" : "#ffffff"
                    font.pixelSize: 14
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                onClicked: mainStack.currentIndex = 0
            }
            
            Button {
                text: "💼 Portfolio"
                width: 200
                height: 60
                background: Rectangle {
                    color: mainStack.currentIndex === 1 ? "#00ffff" : "#333333"
                    border.color: "#ffffff"
                    border.width: 2
                    radius: 10
                }
                contentItem: Text {
                    text: parent.text
                    color: mainStack.currentIndex === 1 ? "#000000" : "#ffffff"
                    font.pixelSize: 14
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                onClicked: mainStack.currentIndex = 1
            }
            
            Button {
                text: "🤖 ML Models"
                width: 200
                height: 60
                background: Rectangle {
                    color: mainStack.currentIndex === 2 ? "#00ffff" : "#333333"
                    border.color: "#ffffff"
                    border.width: 2
                    radius: 10
                }
                contentItem: Text {
                    text: parent.text
                    color: mainStack.currentIndex === 2 ? "#000000" : "#ffffff"
                    font.pixelSize: 14
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                onClicked: mainStack.currentIndex = 2
            }
            
            Button {
                text: "🧠 Grok AI"
                width: 200
                height: 60
                background: Rectangle {
                    color: mainStack.currentIndex === 3 ? "#00ffff" : "#333333"
                    border.color: "#ffffff"
                    border.width: 2
                    radius: 10
                }
                contentItem: Text {
                    text: parent.text
                    color: mainStack.currentIndex === 3 ? "#000000" : "#ffffff"
                    font.pixelSize: 14
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                onClicked: mainStack.currentIndex = 3
            }
            
            Button {
                text: "📈 Trading"
                width: 200
                height: 60
                background: Rectangle {
                    color: mainStack.currentIndex === 4 ? "#00ffff" : "#333333"
                    border.color: "#ffffff"
                    border.width: 2
                    radius: 10
                }
                contentItem: Text {
                    text: parent.text
                    color: mainStack.currentIndex === 4 ? "#000000" : "#ffffff"
                    font.pixelSize: 14
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                onClicked: mainStack.currentIndex = 4
            }
        }
    }
    
    // Main content area with sidebar
    Row {
        anchors.top: navBar.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 20
        spacing: 20
        
        // Main page content
        Rectangle {
            width: parent.width - 320
            height: parent.height
            color: "#1a1a1a"
            border.color: "#00ffff"
            border.width: 2
            radius: 10
            
            StackLayout {
                id: mainStack
                anchors.fill: parent
                anchors.margins: 30
                currentIndex: 0
                
                // Dashboard Page
                Rectangle {
                    color: "transparent"
                    
                    Column {
                        anchors.fill: parent
                        spacing: 40
                        
                        Text {
                            text: "🏠 DASHBOARD OVERVIEW"
                            font.pixelSize: 36
                            font.bold: true
                            color: "#00ffff"
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                        
                        // Main metrics
                        Row {
                            anchors.horizontalCenter: parent.horizontalCenter
                            spacing: 40
                            
                            Rectangle {
                                width: 250
                                height: 150
                                color: "#2a2a2a"
                                border.color: "#00ffff"
                                border.width: 3
                                radius: 15
                                
                                Column {
                                    anchors.centerIn: parent
                                    spacing: 10
                                    
                                    Text {
                                        text: "💼 Portfolio Value"
                                        color: "#cccccc"
                                        font.pixelSize: 14
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }
                                    
                                    Text {
                                        text: "$109,329.05"
                                        color: "#00ffff"
                                        font.pixelSize: 28
                                        font.bold: true
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }
                                    
                                    Text {
                                        text: "+$2,847.23 (+2.67%)"
                                        color: "#00ff00"
                                        font.pixelSize: 14
                                        font.bold: true
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }
                                }
                            }
                            
                            Rectangle {
                                width: 250
                                height: 150
                                color: "#2a2a2a"
                                border.color: "#00ff00"
                                border.width: 3
                                radius: 15
                                
                                Column {
                                    anchors.centerIn: parent
                                    spacing: 10
                                    
                                    Text {
                                        text: "🤖 ML Performance"
                                        color: "#cccccc"
                                        font.pixelSize: 14
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }
                                    
                                    Text {
                                        text: "87.3%"
                                        color: "#00ff00"
                                        font.pixelSize: 32
                                        font.bold: true
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }
                                    
                                    Text {
                                        text: "Accuracy (LSTM)"
                                        color: "#cccccc"
                                        font.pixelSize: 12
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }
                                }
                            }
                            
                            Rectangle {
                                width: 250
                                height: 150
                                color: "#2a2a2a"
                                border.color: "#ffaa00"
                                border.width: 3
                                radius: 15
                                
                                Column {
                                    anchors.centerIn: parent
                                    spacing: 10
                                    
                                    Text {
                                        text: "🎯 Grok Signals"
                                        color: "#cccccc"
                                        font.pixelSize: 14
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }
                                    
                                    Text {
                                        text: "8"
                                        color: "#ffaa00"
                                        font.pixelSize: 32
                                        font.bold: true
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }
                                    
                                    Text {
                                        text: "Active Recommendations"
                                        color: "#cccccc"
                                        font.pixelSize: 12
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }
                                }
                            }
                        }
                        
                        Rectangle {
                            width: parent.width * 0.9
                            height: 150
                            color: "#2a2a2a"
                            border.color: "#00ffff"
                            border.width: 2
                            radius: 15
                            anchors.horizontalCenter: parent.horizontalCenter
                            
                            Column {
                                anchors.centerIn: parent
                                spacing: 20
                                
                                Text {
                                    text: "⚡ QUICK ACTIONS"
                                    color: "#00ffff"
                                    font.pixelSize: 20
                                    font.bold: true
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }
                                
                                Row {
                                    spacing: 30
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    
                                    Button {
                                        text: "🛒 Quick Buy"
                                        width: 150
                                        height: 50
                                        background: Rectangle {
                                            color: "#00ff00"
                                            radius: 10
                                        }
                                        contentItem: Text {
                                            text: parent.text
                                            color: "#000000"
                                            font.bold: true
                                            font.pixelSize: 14
                                            horizontalAlignment: Text.AlignHCenter
                                            verticalAlignment: Text.AlignVCenter
                                        }
                                    }
                                    
                                    Button {
                                        text: "💰 Quick Sell"
                                        width: 150
                                        height: 50
                                        background: Rectangle {
                                            color: "#ff4444"
                                            radius: 10
                                        }
                                        contentItem: Text {
                                            text: parent.text
                                            color: "#000000"
                                            font.bold: true
                                            font.pixelSize: 14
                                            horizontalAlignment: Text.AlignHCenter
                                            verticalAlignment: Text.AlignVCenter
                                        }
                                    }
                                    
                                    Button {
                                        text: "🔄 Rebalance"
                                        width: 150
                                        height: 50
                                        background: Rectangle {
                                            color: "#00ffff"
                                            radius: 10
                                        }
                                        contentItem: Text {
                                            text: parent.text
                                            color: "#000000"
                                            font.bold: true
                                            font.pixelSize: 14
                                            horizontalAlignment: Text.AlignHCenter
                                            verticalAlignment: Text.AlignVCenter
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
                // Portfolio Page - Top Holdings
                Rectangle {
                    color: "transparent"
                    
                    Column {
                        anchors.fill: parent
                        spacing: 30
                        
                        Text {
                            text: "💼 PORTFOLIO MANAGEMENT"
                            font.pixelSize: 32
                            font.bold: true
                            color: "#00ffff"
                        }
                        
                        Row {
                            width: parent.width
                            spacing: 30
                            
                            Rectangle {
                                width: 200
                                height: 100
                                color: "#2a2a2a"
                                border.color: "#00ffff"
                                border.width: 2
                                radius: 10
                                
                                Column {
                                    anchors.centerIn: parent
                                    Text {
                                        text: "Total Value"
                                        color: "#cccccc"
                                        font.pixelSize: 12
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }
                                    Text {
                                        text: "$109,329.05"
                                        color: "#00ffff"
                                        font.pixelSize: 18
                                        font.bold: true
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }
                                }
                            }
                            
                            Rectangle {
                                width: 200
                                height: 100
                                color: "#2a2a2a"
                                border.color: "#00ff00"
                                border.width: 2
                                radius: 10
                                
                                Column {
                                    anchors.centerIn: parent
                                    Text {
                                        text: "Available Cash"
                                        color: "#cccccc"
                                        font.pixelSize: 12
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }
                                    Text {
                                        text: "$25,670.45"
                                        color: "#00ff00"
                                        font.pixelSize: 18
                                        font.bold: true
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }
                                }
                            }
                            
                            Rectangle {
                                width: 200
                                height: 100
                                color: "#2a2a2a"
                                border.color: "#ffaa00"
                                border.width: 2
                                radius: 10
                                
                                Column {
                                    anchors.centerIn: parent
                                    Text {
                                        text: "Open Positions"
                                        color: "#cccccc"
                                        font.pixelSize: 12
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }
                                    Text {
                                        text: "17"
                                        color: "#ffaa00"
                                        font.pixelSize: 18
                                        font.bold: true
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }
                                }
                            }
                        }
                        
                        Text {
                            text: "🏆 Top Holdings"
                            color: "#00ffff"
                            font.pixelSize: 18
                            font.bold: true
                        }
                        
                        Column {
                            width: parent.width
                            spacing: 8
                            
                            // Header
                            Rectangle {
                                width: parent.width
                                height: 40
                                color: "#333333"
                                radius: 5
                                
                                Row {
                                    anchors.fill: parent
                                    anchors.margins: 15
                                    spacing: 50
                                    
                                    Text { text: "Symbol"; color: "#00ffff"; font.bold: true; width: 80 }
                                    Text { text: "Value"; color: "#00ffff"; font.bold: true; width: 100 }
                                    Text { text: "Weight"; color: "#00ffff"; font.bold: true; width: 80 }
                                    Text { text: "Change"; color: "#00ffff"; font.bold: true; width: 80 }
                                }
                            }
                            
                            Repeater {
                                model: [
                                    { symbol: "NVDA", value: 29630, percent: 27.1, change: 5.7 },
                                    { symbol: "MSFT", value: 30964, percent: 28.3, change: 2.1 },
                                    { symbol: "META", value: 20238, percent: 18.5, change: 3.8 },
                                    { symbol: "AAPL", value: 11705, percent: 10.7, change: 1.2 },
                                    { symbol: "GOOGL", value: 4874, percent: 4.5, change: -1.8 }
                                ]
                                
                                Rectangle {
                                    width: parent.width
                                    height: 50
                                    color: index % 2 === 0 ? "#2a2a2a" : "#252525"
                                    radius: 5
                                    
                                    Row {
                                        anchors.fill: parent
                                        anchors.margins: 15
                                        spacing: 50
                                        
                                        Text {
                                            text: modelData.symbol
                                            color: "#00ffff"
                                            font.pixelSize: 16
                                            font.bold: true
                                            width: 80
                                        }
                                        
                                        Text {
                                            text: "$" + modelData.value.toLocaleString()
                                            color: "#ffffff"
                                            font.pixelSize: 14
                                            width: 100
                                        }
                                        
                                        Text {
                                            text: modelData.percent.toFixed(1) + "%"
                                            color: "#cccccc"
                                            font.pixelSize: 14
                                            width: 80
                                        }
                                        
                                        Text {
                                            text: (modelData.change >= 0 ? "+" : "") + modelData.change.toFixed(1) + "%"
                                            color: modelData.change >= 0 ? "#00ff00" : "#ff4444"
                                            font.pixelSize: 14
                                            font.bold: true
                                            width: 80
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
                // ML Models Page
                Rectangle {
                    color: "transparent"
                    
                    Column {
                        anchors.fill: parent
                        spacing: 30
                        
                        Text {
                            text: "🤖 MACHINE LEARNING MODELS"
                            font.pixelSize: 32
                            font.bold: true
                            color: "#00ffff"
                        }
                        
                        Text {
                            text: "Model Performance Dashboard"
                            color: "#ffffff"
                            font.pixelSize: 18
                            font.bold: true
                        }
                        
                        Grid {
                            columns: 2
                            columnSpacing: 30
                            rowSpacing: 20
                            
                            Rectangle {
                                width: 350
                                height: 120
                                color: "#1a2a1a"
                                border.color: "#00ff00"
                                border.width: 3
                                radius: 10
                                
                                Column {
                                    anchors.centerIn: parent
                                    spacing: 8
                                    
                                    Text {
                                        text: "📊 LSTM Neural Network"
                                        color: "#00ff00"
                                        font.pixelSize: 16
                                        font.bold: true
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }
                                    
                                    Text {
                                        text: "Accuracy: 89.2%"
                                        color: "#ffffff"
                                        font.pixelSize: 14
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }
                                    
                                    Text {
                                        text: "Status: Active • Predictions: 2,847"
                                        color: "#cccccc"
                                        font.pixelSize: 11
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }
                                }
                            }
                            
                            Rectangle {
                                width: 350
                                height: 120
                                color: "#1a1a2a"
                                border.color: "#00ffff"
                                border.width: 3
                                radius: 10
                                
                                Column {
                                    anchors.centerIn: parent
                                    spacing: 8
                                    
                                    Text {
                                        text: "🎯 Random Forest"
                                        color: "#00ffff"
                                        font.pixelSize: 16
                                        font.bold: true
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }
                                    
                                    Text {
                                        text: "Accuracy: 84.7%"
                                        color: "#ffffff"
                                        font.pixelSize: 14
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }
                                    
                                    Text {
                                        text: "Status: Active • Predictions: 1,923"
                                        color: "#cccccc"
                                        font.pixelSize: 11
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }
                                }
                            }
                            
                            Rectangle {
                                width: 350
                                height: 120
                                color: "#2a1a1a"
                                border.color: "#ffaa00"
                                border.width: 3
                                radius: 10
                                
                                Column {
                                    anchors.centerIn: parent
                                    spacing: 8
                                    
                                    Text {
                                        text: "🌊 Gradient Boosting"
                                        color: "#ffaa00"
                                        font.pixelSize: 16
                                        font.bold: true
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }
                                    
                                    Text {
                                        text: "Training... 67%"
                                        color: "#ffffff"
                                        font.pixelSize: 14
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }
                                    
                                    Text {
                                        text: "ETA: 12 minutes remaining"
                                        color: "#cccccc"
                                        font.pixelSize: 11
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }
                                }
                            }
                            
                            Rectangle {
                                width: 350
                                height: 120
                                color: "#1a1a2a"
                                border.color: "#ff6b6b"
                                border.width: 3
                                radius: 10
                                
                                Column {
                                    anchors.centerIn: parent
                                    spacing: 8
                                    
                                    Text {
                                        text: "🔮 Transformer Model"
                                        color: "#ff6b6b"
                                        font.pixelSize: 16
                                        font.bold: true
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }
                                    
                                    Text {
                                        text: "Accuracy: 91.8%"
                                        color: "#ffffff"
                                        font.pixelSize: 14
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }
                                    
                                    Text {
                                        text: "Status: Active • Predictions: 4,156"
                                        color: "#cccccc"
                                        font.pixelSize: 11
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }
                                }
                            }
                        }
                    }
                }
                
                // Grok AI Page
                Rectangle {
                    color: "transparent"
                    
                    Column {
                        anchors.fill: parent
                        spacing: 30
                        
                        Text {
                            text: "🧠 GROK AI RECOMMENDATIONS"
                            font.pixelSize: 32
                            font.bold: true
                            color: "#00ffff"
                        }
                        
                        Rectangle {
                            width: parent.width
                            height: 80
                            color: "#2a2a2a"
                            border.color: "#00ffff"
                            border.width: 2
                            radius: 10
                            
                            Row {
                                anchors.fill: parent
                                anchors.margins: 20
                                spacing: 50
                                
                                Column {
                                    Text {
                                        text: "🔮 AI Status"
                                        color: "#00ffff"
                                        font.pixelSize: 16
                                        font.bold: true
                                    }
                                    Text {
                                        text: "Online & Processing"
                                        color: "#00ff00"
                                        font.pixelSize: 14
                                    }
                                }
                                
                                Column {
                                    Text {
                                        text: "📊 Confidence"
                                        color: "#00ffff"
                                        font.pixelSize: 16
                                        font.bold: true
                                    }
                                    Text {
                                        text: "94.7%"
                                        color: "#00ff00"
                                        font.pixelSize: 18
                                        font.bold: true
                                    }
                                }
                                
                                Column {
                                    Text {
                                        text: "🎯 Active Signals"
                                        color: "#00ffff"
                                        font.pixelSize: 16
                                        font.bold: true
                                    }
                                    Text {
                                        text: "8 Recommendations"
                                        color: "#ffaa00"
                                        font.pixelSize: 18
                                        font.bold: true
                                    }
                                }
                            }
                        }
                        
                        Text {
                            text: "🚀 Top AI Recommendations"
                            color: "#00ffff"
                            font.pixelSize: 18
                            font.bold: true
                        }
                        
                        Column {
                            width: parent.width
                            spacing: 12
                            
                            Repeater {
                                model: [
                                    { symbol: "NVDA", action: "BUY", confidence: 96.2, reason: "KI-Boom und starke Quartalszahlen erwartet", target: 1350, current: 1185 },
                                    { symbol: "AAPL", action: "BUY", confidence: 89.3, reason: "iPhone 16 Launch läuft gut, Services stabil", target: 260, current: 234 },
                                    { symbol: "GOOGL", action: "BUY", confidence: 91.7, reason: "Bard/Gemini KI-Fortschritte, Werbemarkt erholt", target: 185, current: 162 },
                                    { symbol: "TSLA", action: "HOLD", confidence: 78.5, reason: "Autopilot Updates positiv, aber Bewertung hoch", target: 280, current: 249 }
                                ]
                                
                                Rectangle {
                                    width: parent.width
                                    height: 100
                                    color: index % 2 === 0 ? "#2a2a2a" : "#252525"
                                    border.color: modelData.action === "BUY" ? "#00ff00" : 
                                                  modelData.action === "SELL" ? "#ff4444" : "#ffaa00"
                                    border.width: 2
                                    radius: 10
                                    
                                    Row {
                                        anchors.fill: parent
                                        anchors.margins: 20
                                        spacing: 30
                                        
                                        Column {
                                            width: 120
                                            spacing: 8
                                            
                                            Text {
                                                text: modelData.symbol
                                                color: "#00ffff"
                                                font.pixelSize: 18
                                                font.bold: true
                                            }
                                            
                                            Rectangle {
                                                width: 60
                                                height: 25
                                                color: modelData.action === "BUY" ? "#00ff00" : 
                                                       modelData.action === "SELL" ? "#ff4444" : "#ffaa00"
                                                radius: 12
                                                
                                                Text {
                                                    text: modelData.action
                                                    color: "#000000"
                                                    font.pixelSize: 12
                                                    font.bold: true
                                                    anchors.centerIn: parent
                                                }
                                            }
                                        }
                                        
                                        Column {
                                            width: 150
                                            spacing: 5
                                            
                                            Text {
                                                text: "Current: $" + modelData.current
                                                color: "#ffffff"
                                                font.pixelSize: 12
                                            }
                                            
                                            Text {
                                                text: "Target: $" + modelData.target
                                                color: "#00ffff"
                                                font.pixelSize: 12
                                                font.bold: true
                                            }
                                            
                                            Text {
                                                text: "Confidence: " + modelData.confidence + "%"
                                                color: "#cccccc"
                                                font.pixelSize: 11
                                            }
                                        }
                                        
                                        Column {
                                            width: parent.width - 300
                                            spacing: 5
                                            
                                            Text {
                                                text: "🧠 Grok Analysis:"
                                                color: "#00ffff"
                                                font.pixelSize: 12
                                                font.bold: true
                                            }
                                            
                                            Text {
                                                text: modelData.reason
                                                color: "#ffffff"
                                                font.pixelSize: 11
                                                wrapMode: Text.WordWrap
                                                width: parent.width
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
                // Trading Page
                Rectangle {
                    color: "transparent"
                    
                    Column {
                        anchors.fill: parent
                        spacing: 30
                        
                        Text {
                            text: "📈 TRADING TERMINAL"
                            font.pixelSize: 32
                            font.bold: true
                            color: "#00ffff"
                        }
                        
                        Row {
                            width: parent.width
                            spacing: 30
                            
                            Rectangle {
                                width: 180
                                height: 80
                                color: "#2a2a2a"
                                border.color: "#00ff00"
                                border.width: 2
                                radius: 10
                                
                                Column {
                                    anchors.centerIn: parent
                                    Text {
                                        text: "Buying Power"
                                        color: "#cccccc"
                                        font.pixelSize: 12
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }
                                    Text {
                                        text: "$25,670"
                                        color: "#00ff00"
                                        font.pixelSize: 18
                                        font.bold: true
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }
                                }
                            }
                            
                            Rectangle {
                                width: 180
                                height: 80
                                color: "#2a2a2a"
                                border.color: "#00ffff"
                                border.width: 2
                                radius: 10
                                
                                Column {
                                    anchors.centerIn: parent
                                    Text {
                                        text: "Day P&L"
                                        color: "#cccccc"
                                        font.pixelSize: 12
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }
                                    Text {
                                        text: "+$2,847"
                                        color: "#00ff00"
                                        font.pixelSize: 18
                                        font.bold: true
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }
                                }
                            }
                            
                            Rectangle {
                                width: 180
                                height: 80
                                color: "#2a2a2a"
                                border.color: "#ffaa00"
                                border.width: 2
                                radius: 10
                                
                                Column {
                                    anchors.centerIn: parent
                                    Text {
                                        text: "Open Orders"
                                        color: "#cccccc"
                                        font.pixelSize: 12
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }
                                    Text {
                                        text: "3"
                                        color: "#ffaa00"
                                        font.pixelSize: 18
                                        font.bold: true
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }
                                }
                            }
                        }
                        
                        Rectangle {
                            width: parent.width
                            height: 300
                            color: "#2a2a2a"
                            border.color: "#00ffff"
                            border.width: 2
                            radius: 10
                            
                            Column {
                                anchors.fill: parent
                                anchors.margins: 30
                                spacing: 20
                                
                                Text {
                                    text: "🎯 ORDER ENTRY SYSTEM"
                                    font.pixelSize: 20
                                    font.bold: true
                                    color: "#00ffff"
                                }
                                
                                Row {
                                    spacing: 40
                                    
                                    Column {
                                        spacing: 15
                                        
                                        Text {
                                            text: "Symbol: AAPL"
                                            color: "#ffffff"
                                            font.pixelSize: 16
                                            font.bold: true
                                        }
                                        
                                        Text {
                                            text: "Current Price: $234.10"
                                            color: "#00ffff"
                                            font.pixelSize: 14
                                            font.bold: true
                                        }
                                        
                                        Text {
                                            text: "Quantity: 10 shares"
                                            color: "#ffffff"
                                            font.pixelSize: 14
                                        }
                                        
                                        Text {
                                            text: "Order Value: $2,341.00"
                                            color: "#cccccc"
                                            font.pixelSize: 12
                                        }
                                    }
                                    
                                    Column {
                                        spacing: 15
                                        
                                        Button {
                                            text: "🟢 BUY ORDER"
                                            width: 150
                                            height: 50
                                            background: Rectangle {
                                                color: "#00ff00"
                                                radius: 10
                                            }
                                            contentItem: Text {
                                                text: parent.text
                                                color: "#000000"
                                                font.bold: true
                                                font.pixelSize: 14
                                                horizontalAlignment: Text.AlignHCenter
                                                verticalAlignment: Text.AlignVCenter
                                            }
                                        }
                                        
                                        Button {
                                            text: "🔴 SELL ORDER"
                                            width: 150
                                            height: 50
                                            background: Rectangle {
                                                color: "#ff4444"
                                                radius: 10
                                            }
                                            contentItem: Text {
                                                text: parent.text
                                                color: "#000000"
                                                font.bold: true
                                                font.pixelSize: 14
                                                horizontalAlignment: Text.AlignHCenter
                                                verticalAlignment: Text.AlignVCenter
                                            }
                                        }
                                    }
                                }
                                
                                Rectangle {
                                    width: parent.width
                                    height: 80
                                    color: "#1a1a1a"
                                    border.color: "#ffaa00"
                                    border.width: 2
                                    radius: 8
                                    
                                    Column {
                                        anchors.centerIn: parent
                                        spacing: 5
                                        
                                        Text {
                                            text: "⚠️ Risk Assessment"
                                            color: "#ffaa00"
                                            font.pixelSize: 14
                                            font.bold: true
                                            anchors.horizontalCenter: parent.horizontalCenter
                                        }
                                        
                                        Text {
                                            text: "Position Size: 2.1% of Portfolio • Risk Level: LOW"
                                            color: "#ffffff"
                                            font.pixelSize: 12
                                            anchors.horizontalCenter: parent.horizontalCenter
                                        }
                                        
                                        Text {
                                            text: "Grok AI Recommendation: BUY (89.3% Confidence)"
                                            color: "#00ff00"
                                            font.pixelSize: 11
                                            anchors.horizontalCenter: parent.horizontalCenter
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        
        // Live watchlist sidebar
        Rectangle {
            width: 300
            height: parent.height
            color: "#1a1a1a"
            border.color: "#ff6b6b"
            border.width: 2
            radius: 10
            
            Column {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 15
                
                Text {
                    text: "📊 LIVE WATCHLIST"
                    color: "#ff6b6b"
                    font.pixelSize: 16
                    font.bold: true
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                
                Column {
                    width: parent.width
                    spacing: 8
                    
                    Repeater {
                        model: [
                            { symbol: "AAPL", price: 234.10, change: 1.2 },
                            { symbol: "NVDA", price: 1185.20, change: 5.7 },
                            { symbol: "MSFT", price: 412.85, change: 2.1 },
                            { symbol: "GOOGL", price: 162.45, change: -1.8 },
                            { symbol: "TSLA", price: 248.75, change: -2.3 },
                            { symbol: "AMZN", price: 186.12, change: 0.9 },
                            { symbol: "META", price: 578.23, change: 3.4 },
                            { symbol: "NFLX", price: 492.88, change: -0.5 },
                            { symbol: "CRM", price: 234.56, change: 2.8 },
                            { symbol: "AMD", price: 156.78, change: 4.2 }
                        ]
                        
                        Rectangle {
                            width: parent.width
                            height: 40
                            color: index % 2 === 0 ? "#2a2a2a" : "#252525"
                            border.color: modelData.change >= 0 ? "#00ff00" : "#ff4444"
                            border.width: 1
                            radius: 6
                            
                            Row {
                                anchors.fill: parent
                                anchors.margins: 10
                                spacing: 15
                                
                                Text {
                                    text: modelData.symbol
                                    color: "#00ffff"
                                    font.pixelSize: 12
                                    font.bold: true
                                    width: 50
                                }
                                
                                Text {
                                    text: "$" + modelData.price.toFixed(2)
                                    color: "#ffffff"
                                    font.pixelSize: 11
                                    width: 80
                                }
                                
                                Text {
                                    text: (modelData.change >= 0 ? "+" : "") + modelData.change.toFixed(1) + "%"
                                    color: modelData.change >= 0 ? "#00ff00" : "#ff4444"
                                    font.pixelSize: 11
                                    font.bold: true
                                    width: 60
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    // Update timer for live data
    Timer {
        interval: 3000
        running: true
        repeat: true
        onTriggered: {
            console.log("Live data updated...")
        }
    }
}