import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Window 2.12

ApplicationWindow {
    id: window
    width: 1400
    height: 900
    visible: true
    title: "6bot Enhanced Trading Suite v2.0"
    color: "#0a0a0a"
    
    // Global color scheme
    property color primaryColor: "#00ffff"
    property color secondaryColor: "#ff6b6b"
    property color successColor: "#00ff00"
    property color warningColor: "#ffaa00"
    property color dangerColor: "#ff4444"
    property color surfaceColor: "#1a1a1a"
    
    // Status bar
    Rectangle {
        id: statusBar
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 40
        color: "#111111"
        border.color: primaryColor
        border.width: 1
        
        Row {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: 20
            spacing: 30
            
            Row {
                spacing: 8
                Rectangle {
                    width: 10
                    height: 10
                    radius: 5
                    color: successColor
                    
                    SequentialAnimation on opacity {
                        loops: Animation.Infinite
                        NumberAnimation { to: 0.3; duration: 1000 }
                        NumberAnimation { to: 1.0; duration: 1000 }
                    }
                }
                Text {
                    text: "System Online"
                    color: successColor
                    font.pixelSize: 12
                    font.bold: true
                }
            }
            
            Text {
                text: "Portfolio: $109,329.05 (+2.67%)"
                color: primaryColor
                font.pixelSize: 12
                font.bold: true
            }
            
            Text {
                text: "ML Accuracy: 87.3%"
                color: successColor
                font.pixelSize: 12
                font.bold: true
            }
            
            Text {
                text: "Grok Signals: 8 Active"
                color: warningColor
                font.pixelSize: 12
                font.bold: true
            }
        }
        
        Row {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.rightMargin: 20
            spacing: 20
            
            Text {
                text: new Date().toLocaleTimeString()
                color: "#ffffff"
                font.pixelSize: 12
            }
            
            Text {
                text: "PAPER TRADING"
                color: warningColor
                font.pixelSize: 12
                font.bold: true
            }
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
        border.color: primaryColor
        border.width: 2
        
        Row {
            anchors.centerIn: parent
            spacing: 20
            
            Button {
                text: "🏠 Dashboard"
                width: 180
                height: 50
                background: Rectangle {
                    color: primaryColor
                    border.color: "#ffffff"
                    border.width: 2
                    radius: 10
                }
                contentItem: Text {
                    text: parent.text
                    color: "#000000"
                    font.pixelSize: 12
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                onClicked: mainContent.currentIndex = 0
            }
            
            Button {
                text: "💼 Portfolio"
                width: 180
                height: 50
                background: Rectangle {
                    color: "#2a2a2a"
                    border.color: primaryColor
                    border.width: 2
                    radius: 10
                }
                contentItem: Text {
                    text: parent.text
                    color: "#ffffff"
                    font.pixelSize: 12
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                onClicked: mainContent.currentIndex = 1
            }
            
            Button {
                text: "🤖 ML Models"
                width: 180
                height: 50
                background: Rectangle {
                    color: "#2a2a2a"
                    border.color: primaryColor
                    border.width: 2
                    radius: 10
                }
                contentItem: Text {
                    text: parent.text
                    color: "#ffffff"
                    font.pixelSize: 12
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                onClicked: mainContent.currentIndex = 2
            }
            
            Button {
                text: "🧠 Grok AI"
                width: 180
                height: 50
                background: Rectangle {
                    color: "#2a2a2a"
                    border.color: primaryColor
                    border.width: 2
                    radius: 10
                }
                contentItem: Text {
                    text: parent.text
                    color: "#ffffff"
                    font.pixelSize: 12
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                onClicked: mainContent.currentIndex = 3
            }
            
            Button {
                text: "📈 Trading"
                width: 180
                height: 50
                background: Rectangle {
                    color: "#2a2a2a"
                    border.color: primaryColor
                    border.width: 2
                    radius: 10
                }
                contentItem: Text {
                    text: parent.text
                    color: "#ffffff"
                    font.pixelSize: 12
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                onClicked: mainContent.currentIndex = 4
            }
        }
    }
    
    // Main content area
    Row {
        anchors.top: navBar.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 20
        spacing: 20
        
        // Page content
        Rectangle {
            width: parent.width - 320
            height: parent.height
            color: surfaceColor
            border.color: primaryColor
            border.width: 1
            radius: 10
            
            StackLayout {
                id: mainContent
                anchors.fill: parent
                anchors.margins: 20
                currentIndex: 0
                
                // Dashboard Page
                ScrollView {
                    Column {
                        width: parent.width
                        spacing: 30
                        
                        Text {
                            text: "🏠 DASHBOARD OVERVIEW"
                            font.pixelSize: 32
                            font.bold: true
                            color: primaryColor
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                        
                        // Key metrics
                        Row {
                            anchors.horizontalCenter: parent.horizontalCenter
                            spacing: 30
                            
                            Rectangle {
                                width: 200
                                height: 120
                                color: surfaceColor
                                border.color: primaryColor
                                border.width: 2
                                radius: 10
                                
                                Column {
                                    anchors.centerIn: parent
                                    spacing: 8
                                    
                                    Text {
                                        text: "💼 Portfolio Value"
                                        color: "#cccccc"
                                        font.pixelSize: 12
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }
                                    
                                    Text {
                                        text: "$109,329.05"
                                        color: primaryColor
                                        font.pixelSize: 20
                                        font.bold: true
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }
                                    
                                    Text {
                                        text: "+$2,847.23 (+2.67%)"
                                        color: successColor
                                        font.pixelSize: 12
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }
                                }
                            }
                            
                            Rectangle {
                                width: 200
                                height: 120
                                color: surfaceColor
                                border.color: successColor
                                border.width: 2
                                radius: 10
                                
                                Column {
                                    anchors.centerIn: parent
                                    spacing: 8
                                    
                                    Text {
                                        text: "🤖 ML Accuracy"
                                        color: "#cccccc"
                                        font.pixelSize: 12
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }
                                    
                                    Text {
                                        text: "87.3%"
                                        color: successColor
                                        font.pixelSize: 24
                                        font.bold: true
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }
                                    
                                    Text {
                                        text: "Last 1000 predictions"
                                        color: "#cccccc"
                                        font.pixelSize: 10
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }
                                }
                            }
                            
                            Rectangle {
                                width: 200
                                height: 120
                                color: surfaceColor
                                border.color: warningColor
                                border.width: 2
                                radius: 10
                                
                                Column {
                                    anchors.centerIn: parent
                                    spacing: 8
                                    
                                    Text {
                                        text: "🎯 Grok Signals"
                                        color: "#cccccc"
                                        font.pixelSize: 12
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }
                                    
                                    Text {
                                        text: "8"
                                        color: warningColor
                                        font.pixelSize: 24
                                        font.bold: true
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }
                                    
                                    Text {
                                        text: "Active recommendations"
                                        color: "#cccccc"
                                        font.pixelSize: 10
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }
                                }
                            }
                        }
                        
                        // Quick actions
                        Rectangle {
                            width: parent.width * 0.8
                            height: 200
                            color: surfaceColor
                            border.color: primaryColor
                            border.width: 2
                            radius: 10
                            anchors.horizontalCenter: parent.horizontalCenter
                            
                            Column {
                                anchors.centerIn: parent
                                spacing: 20
                                
                                Text {
                                    text: "⚡ QUICK ACTIONS"
                                    color: primaryColor
                                    font.pixelSize: 18
                                    font.bold: true
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }
                                
                                Row {
                                    spacing: 20
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    
                                    Button {
                                        text: "🛒 Quick Buy"
                                        width: 120
                                        height: 40
                                        background: Rectangle {
                                            color: successColor
                                            radius: 8
                                        }
                                        contentItem: Text {
                                            text: parent.text
                                            color: "#000000"
                                            font.bold: true
                                            horizontalAlignment: Text.AlignHCenter
                                            verticalAlignment: Text.AlignVCenter
                                        }
                                    }
                                    
                                    Button {
                                        text: "💰 Quick Sell"
                                        width: 120
                                        height: 40
                                        background: Rectangle {
                                            color: dangerColor
                                            radius: 8
                                        }
                                        contentItem: Text {
                                            text: parent.text
                                            color: "#000000"
                                            font.bold: true
                                            horizontalAlignment: Text.AlignHCenter
                                            verticalAlignment: Text.AlignVCenter
                                        }
                                    }
                                    
                                    Button {
                                        text: "🔄 Rebalance"
                                        width: 120
                                        height: 40
                                        background: Rectangle {
                                            color: primaryColor
                                            radius: 8
                                        }
                                        contentItem: Text {
                                            text: parent.text
                                            color: "#000000"
                                            font.bold: true
                                            horizontalAlignment: Text.AlignHCenter
                                            verticalAlignment: Text.AlignVCenter
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
                // Portfolio Page
                ScrollView {
                    Column {
                        width: parent.width
                        spacing: 20
                        
                        Text {
                            text: "💼 PORTFOLIO MANAGEMENT"
                            font.pixelSize: 28
                            font.bold: true
                            color: primaryColor
                        }
                        
                        Row {
                            width: parent.width
                            spacing: 20
                            
                            Rectangle {
                                width: 200
                                height: 100
                                color: surfaceColor
                                border.color: primaryColor
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
                                        color: primaryColor
                                        font.pixelSize: 18
                                        font.bold: true
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }
                                }
                            }
                            
                            Rectangle {
                                width: 200
                                height: 100
                                color: surfaceColor
                                border.color: successColor
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
                                        color: successColor
                                        font.pixelSize: 18
                                        font.bold: true
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }
                                }
                            }
                            
                            Rectangle {
                                width: 200
                                height: 100
                                color: surfaceColor
                                border.color: warningColor
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
                                        color: warningColor
                                        font.pixelSize: 18
                                        font.bold: true
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }
                                }
                            }
                        }
                        
                        Text {
                            text: "Top Holdings"
                            color: primaryColor
                            font.pixelSize: 16
                            font.bold: true
                        }
                        
                        Repeater {
                            model: [
                                { symbol: "NVDA", value: 29630, percent: 27.1, change: 5.7 },
                                { symbol: "MSFT", value: 30964, percent: 28.3, change: 2.1 },
                                { symbol: "AAPL", value: 11705, percent: 10.7, change: 1.2 },
                                { symbol: "META", value: 20238, percent: 18.5, change: 3.8 },
                                { symbol: "GOOGL", value: 4874, percent: 4.5, change: -1.8 }
                            ]
                            
                            Rectangle {
                                width: parent.width
                                height: 50
                                color: index % 2 === 0 ? "#2a2a2a" : "#1f1f1f"
                                radius: 5
                                
                                Row {
                                    anchors.fill: parent
                                    anchors.margins: 15
                                    spacing: 30
                                    
                                    Text {
                                        text: modelData.symbol
                                        color: primaryColor
                                        font.pixelSize: 14
                                        font.bold: true
                                        width: 80
                                    }
                                    
                                    Text {
                                        text: "$" + modelData.value.toLocaleString()
                                        color: "#ffffff"
                                        font.pixelSize: 12
                                        width: 100
                                    }
                                    
                                    Text {
                                        text: modelData.percent.toFixed(1) + "%"
                                        color: "#cccccc"
                                        font.pixelSize: 12
                                        width: 60
                                    }
                                    
                                    Text {
                                        text: (modelData.change >= 0 ? "+" : "") + modelData.change.toFixed(1) + "%"
                                        color: modelData.change >= 0 ? successColor : dangerColor
                                        font.pixelSize: 12
                                        font.bold: true
                                        width: 80
                                    }
                                }
                            }
                        }
                    }
                }
                
                // ML Models Page
                ScrollView {
                    Column {
                        width: parent.width
                        spacing: 20
                        
                        Text {
                            text: "🤖 MACHINE LEARNING MODELS"
                            font.pixelSize: 28
                            font.bold: true
                            color: primaryColor
                        }
                        
                        Text {
                            text: "Model Performance Overview"
                            color: "#ffffff"
                            font.pixelSize: 16
                            font.bold: true
                        }
                        
                        Grid {
                            columns: 2
                            columnSpacing: 20
                            rowSpacing: 15
                            
                            Rectangle {
                                width: 300
                                height: 120
                                color: "#1a2a1a"
                                border.color: successColor
                                border.width: 2
                                radius: 8
                                
                                Column {
                                    anchors.centerIn: parent
                                    spacing: 8
                                    
                                    Text {
                                        text: "📊 LSTM Neural Network"
                                        color: successColor
                                        font.pixelSize: 14
                                        font.bold: true
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }
                                    
                                    Text {
                                        text: "Accuracy: 89.2%"
                                        color: "#ffffff"
                                        font.pixelSize: 12
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }
                                    
                                    Text {
                                        text: "Status: Active • Predictions: 2,847"
                                        color: "#cccccc"
                                        font.pixelSize: 10
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }
                                }
                            }
                            
                            Rectangle {
                                width: 300
                                height: 120
                                color: "#1a2a1a"
                                border.color: primaryColor
                                border.width: 2
                                radius: 8
                                
                                Column {
                                    anchors.centerIn: parent
                                    spacing: 8
                                    
                                    Text {
                                        text: "🎯 Random Forest"
                                        color: primaryColor
                                        font.pixelSize: 14
                                        font.bold: true
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }
                                    
                                    Text {
                                        text: "Accuracy: 84.7%"
                                        color: "#ffffff"
                                        font.pixelSize: 12
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }
                                    
                                    Text {
                                        text: "Status: Active • Predictions: 1,923"
                                        color: "#cccccc"
                                        font.pixelSize: 10
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }
                                }
                            }
                            
                            Rectangle {
                                width: 300
                                height: 120
                                color: "#2a1a1a"
                                border.color: warningColor
                                border.width: 2
                                radius: 8
                                
                                Column {
                                    anchors.centerIn: parent
                                    spacing: 8
                                    
                                    Text {
                                        text: "🌊 Gradient Boosting"
                                        color: warningColor
                                        font.pixelSize: 14
                                        font.bold: true
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }
                                    
                                    Text {
                                        text: "Training... 67%"
                                        color: "#ffffff"
                                        font.pixelSize: 12
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }
                                    
                                    Text {
                                        text: "ETA: 12 minutes"
                                        color: "#cccccc"
                                        font.pixelSize: 10
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }
                                }
                            }
                            
                            Rectangle {
                                width: 300
                                height: 120
                                color: "#1a1a2a"
                                border.color: secondaryColor
                                border.width: 2
                                radius: 8
                                
                                Column {
                                    anchors.centerIn: parent
                                    spacing: 8
                                    
                                    Text {
                                        text: "🔮 Transformer Model"
                                        color: secondaryColor
                                        font.pixelSize: 14
                                        font.bold: true
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }
                                    
                                    Text {
                                        text: "Accuracy: 91.8%"
                                        color: "#ffffff"
                                        font.pixelSize: 12
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }
                                    
                                    Text {
                                        text: "Status: Active • Predictions: 4,156"
                                        color: "#cccccc"
                                        font.pixelSize: 10
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }
                                }
                            }
                        }
                    }
                }
                
                // Grok AI Page
                ScrollView {
                    Column {
                        width: parent.width
                        spacing: 20
                        
                        Text {
                            text: "🧠 GROK AI RECOMMENDATIONS"
                            font.pixelSize: 28
                            font.bold: true
                            color: primaryColor
                        }
                        
                        Rectangle {
                            width: parent.width
                            height: 80
                            color: surfaceColor
                            border.color: primaryColor
                            border.width: 2
                            radius: 10
                            
                            Row {
                                anchors.fill: parent
                                anchors.margins: 20
                                spacing: 40
                                
                                Column {
                                    Text {
                                        text: "🔮 AI Status"
                                        color: primaryColor
                                        font.pixelSize: 14
                                        font.bold: true
                                    }
                                    Text {
                                        text: "Online & Active"
                                        color: successColor
                                        font.pixelSize: 12
                                    }
                                }
                                
                                Column {
                                    Text {
                                        text: "📊 Confidence"
                                        color: primaryColor
                                        font.pixelSize: 14
                                        font.bold: true
                                    }
                                    Text {
                                        text: "94.7%"
                                        color: successColor
                                        font.pixelSize: 16
                                        font.bold: true
                                    }
                                }
                                
                                Column {
                                    Text {
                                        text: "🎯 Recommendations"
                                        color: primaryColor
                                        font.pixelSize: 14
                                        font.bold: true
                                    }
                                    Text {
                                        text: "8 Active"
                                        color: warningColor
                                        font.pixelSize: 16
                                        font.bold: true
                                    }
                                }
                            }
                        }
                        
                        Text {
                            text: "Top AI Recommendations"
                            color: primaryColor
                            font.pixelSize: 16
                            font.bold: true
                        }
                        
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
                                color: index % 2 === 0 ? "#2a2a2a" : "#1f1f1f"
                                border.color: modelData.action === "BUY" ? successColor : 
                                              modelData.action === "SELL" ? dangerColor : warningColor
                                border.width: 1
                                radius: 8
                                
                                Row {
                                    anchors.fill: parent
                                    anchors.margins: 15
                                    spacing: 20
                                    
                                    Column {
                                        width: 100
                                        spacing: 5
                                        
                                        Text {
                                            text: modelData.symbol
                                            color: primaryColor
                                            font.pixelSize: 16
                                            font.bold: true
                                        }
                                        
                                        Rectangle {
                                            width: 50
                                            height: 20
                                            color: modelData.action === "BUY" ? successColor : 
                                                   modelData.action === "SELL" ? dangerColor : warningColor
                                            radius: 10
                                            
                                            Text {
                                                text: modelData.action
                                                color: "#000000"
                                                font.pixelSize: 10
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
                                            font.pixelSize: 11
                                        }
                                        
                                        Text {
                                            text: "Target: $" + modelData.target
                                            color: primaryColor
                                            font.pixelSize: 11
                                            font.bold: true
                                        }
                                        
                                        Text {
                                            text: "Confidence: " + modelData.confidence + "%"
                                            color: "#cccccc"
                                            font.pixelSize: 10
                                        }
                                    }
                                    
                                    Column {
                                        width: parent.width - 270
                                        spacing: 5
                                        
                                        Text {
                                            text: "🧠 Grok Analysis:"
                                            color: primaryColor
                                            font.pixelSize: 11
                                            font.bold: true
                                        }
                                        
                                        Text {
                                            text: modelData.reason
                                            color: "#ffffff"
                                            font.pixelSize: 10
                                            wrapMode: Text.WordWrap
                                            width: parent.width
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
                // Trading Page
                ScrollView {
                    Column {
                        width: parent.width
                        spacing: 20
                        
                        Text {
                            text: "📈 TRADING TERMINAL"
                            font.pixelSize: 28
                            font.bold: true
                            color: primaryColor
                        }
                        
                        Row {
                            width: parent.width
                            spacing: 20
                            
                            Rectangle {
                                width: 150
                                height: 80
                                color: surfaceColor
                                border.color: successColor
                                border.width: 2
                                radius: 10
                                
                                Column {
                                    anchors.centerIn: parent
                                    Text {
                                        text: "Buying Power"
                                        color: "#cccccc"
                                        font.pixelSize: 10
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }
                                    Text {
                                        text: "$25,670"
                                        color: successColor
                                        font.pixelSize: 16
                                        font.bold: true
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }
                                }
                            }
                            
                            Rectangle {
                                width: 150
                                height: 80
                                color: surfaceColor
                                border.color: primaryColor
                                border.width: 2
                                radius: 10
                                
                                Column {
                                    anchors.centerIn: parent
                                    Text {
                                        text: "Day P&L"
                                        color: "#cccccc"
                                        font.pixelSize: 10
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }
                                    Text {
                                        text: "+$2,847"
                                        color: successColor
                                        font.pixelSize: 16
                                        font.bold: true
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }
                                }
                            }
                            
                            Rectangle {
                                width: 150
                                height: 80
                                color: surfaceColor
                                border.color: warningColor
                                border.width: 2
                                radius: 10
                                
                                Column {
                                    anchors.centerIn: parent
                                    Text {
                                        text: "Open Orders"
                                        color: "#cccccc"
                                        font.pixelSize: 10
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }
                                    Text {
                                        text: "3"
                                        color: warningColor
                                        font.pixelSize: 16
                                        font.bold: true
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }
                                }
                            }
                        }
                        
                        Rectangle {
                            width: parent.width
                            height: 300
                            color: surfaceColor
                            border.color: primaryColor
                            border.width: 2
                            radius: 10
                            
                            Column {
                                anchors.fill: parent
                                anchors.margins: 20
                                spacing: 15
                                
                                Text {
                                    text: "🎯 ORDER ENTRY"
                                    font.pixelSize: 16
                                    font.bold: true
                                    color: primaryColor
                                }
                                
                                Row {
                                    spacing: 20
                                    
                                    Column {
                                        spacing: 10
                                        
                                        Text {
                                            text: "Symbol: AAPL"
                                            color: "#ffffff"
                                            font.pixelSize: 12
                                        }
                                        
                                        Text {
                                            text: "Price: $234.10"
                                            color: primaryColor
                                            font.pixelSize: 14
                                            font.bold: true
                                        }
                                        
                                        Text {
                                            text: "Quantity: 10 shares"
                                            color: "#ffffff"
                                            font.pixelSize: 12
                                        }
                                    }
                                    
                                    Column {
                                        spacing: 10
                                        
                                        Button {
                                            text: "🟢 BUY"
                                            width: 100
                                            height: 40
                                            background: Rectangle {
                                                color: successColor
                                                radius: 8
                                            }
                                            contentItem: Text {
                                                text: parent.text
                                                color: "#000000"
                                                font.bold: true
                                                horizontalAlignment: Text.AlignHCenter
                                                verticalAlignment: Text.AlignVCenter
                                            }
                                        }
                                        
                                        Button {
                                            text: "🔴 SELL"
                                            width: 100
                                            height: 40
                                            background: Rectangle {
                                                color: dangerColor
                                                radius: 8
                                            }
                                            contentItem: Text {
                                                text: parent.text
                                                color: "#000000"
                                                font.bold: true
                                                horizontalAlignment: Text.AlignHCenter
                                                verticalAlignment: Text.AlignVCenter
                                            }
                                        }
                                    }
                                }
                                
                                Rectangle {
                                    width: parent.width
                                    height: 60
                                    color: "#2a1a1a"
                                    border.color: warningColor
                                    border.width: 1
                                    radius: 5
                                    
                                    Column {
                                        anchors.centerIn: parent
                                        spacing: 3
                                        
                                        Text {
                                            text: "⚠️ Risk Assessment"
                                            color: warningColor
                                            font.pixelSize: 12
                                            font.bold: true
                                            anchors.horizontalCenter: parent.horizontalCenter
                                        }
                                        
                                        Text {
                                            text: "Position Size: 2.1% of Portfolio • Risk Level: LOW"
                                            color: "#ffffff"
                                            font.pixelSize: 10
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
        
        // Live watchlist
        Rectangle {
            width: 300
            height: parent.height
            color: surfaceColor
            border.color: secondaryColor
            border.width: 2
            radius: 10
            
            Column {
                anchors.fill: parent
                anchors.margins: 15
                spacing: 10
                
                Text {
                    text: "📊 LIVE WATCHLIST"
                    color: secondaryColor
                    font.pixelSize: 14
                    font.bold: true
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                
                ScrollView {
                    width: parent.width
                    height: parent.height - 40
                    
                    Column {
                        width: parent.width
                        spacing: 5
                        
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
                                width: parent.width - 10
                                height: 35
                                color: index % 2 === 0 ? "#2a2a2a" : "#1f1f1f"
                                border.color: modelData.change >= 0 ? successColor : dangerColor
                                border.width: 1
                                radius: 5
                                
                                Row {
                                    anchors.fill: parent
                                    anchors.margins: 8
                                    spacing: 10
                                    
                                    Text {
                                        text: modelData.symbol
                                        color: primaryColor
                                        font.pixelSize: 11
                                        font.bold: true
                                        width: 50
                                    }
                                    
                                    Text {
                                        text: "$" + modelData.price.toFixed(2)
                                        color: "#ffffff"
                                        font.pixelSize: 10
                                        width: 70
                                    }
                                    
                                    Text {
                                        text: (modelData.change >= 0 ? "+" : "") + modelData.change.toFixed(1) + "%"
                                        color: modelData.change >= 0 ? successColor : dangerColor
                                        font.pixelSize: 10
                                        font.bold: true
                                        width: 50
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    // Auto-update timer
    Timer {
        interval: 5000
        running: true
        repeat: true
        onTriggered: {
            // Simulate live updates
            console.log("Updating live data...")
        }
    }
}