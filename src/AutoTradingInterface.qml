import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

ApplicationWindow {
    id: mainWindow
    width: 1600
    height: 1000
    visible: true
    title: "6bot Autonomous Trading System v3.0"
    color: "#0a0a0a"
    
    property bool autoTradingEnabled: false
    property string tradingStrategy: "CONSERVATIVE"
    property double riskLevel: 0.5
    property int totalTrades: 847
    property double dailyPnL: 2847.23
    property double portfolioValue: 109329.05
    
    // Auto-trading status colors
    property color enabledColor: "#00ff00"
    property color disabledColor: "#ff4444"
    property color warningColor: "#ffaa00"
    property color primaryColor: "#00ffff"
    
    // Header with auto-trading status
    Rectangle {
        id: header
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 60
        color: "#111111"
        border.color: autoTradingEnabled ? enabledColor : disabledColor
        border.width: 3
        
        Row {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: 20
            spacing: 40
            
            // Auto-trading status indicator
            Row {
                spacing: 12
                Rectangle {
                    width: 16
                    height: 16
                    radius: 8
                    color: autoTradingEnabled ? enabledColor : disabledColor
                    
                    SequentialAnimation on opacity {
                        running: autoTradingEnabled
                        loops: Animation.Infinite
                        NumberAnimation { to: 0.3; duration: 800 }
                        NumberAnimation { to: 1.0; duration: 800 }
                    }
                }
                
                Column {
                    Text {
                        text: autoTradingEnabled ? "🤖 AUTO-TRADING ACTIVE" : "⏸️ TRADING PAUSED"
                        color: autoTradingEnabled ? enabledColor : disabledColor
                        font.pixelSize: 16
                        font.bold: true
                    }
                    Text {
                        text: "Strategy: " + tradingStrategy + " | Risk: " + (riskLevel * 100).toFixed(0) + "%"
                        color: "#cccccc"
                        font.pixelSize: 11
                    }
                }
            }
            
            Text {
                text: "📊 Portfolio: $" + portfolioValue.toLocaleString() + " (+" + (dailyPnL/portfolioValue * 100).toFixed(2) + "%)"
                color: primaryColor
                font.pixelSize: 14
                font.bold: true
            }
            
            Text {
                text: "🔄 Trades Today: " + totalTrades
                color: warningColor
                font.pixelSize: 14
                font.bold: true
            }
        }
        
        Row {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.rightMargin: 20
            spacing: 15
            
            // Emergency stop button
            Button {
                width: 120
                height: 40
                background: Rectangle {
                    color: "#ff0000"
                    radius: 8
                    border.color: "#ffffff"
                    border.width: 2
                }
                contentItem: Text {
                    text: "🛑 EMERGENCY STOP"
                    color: "#ffffff"
                    font.bold: true
                    font.pixelSize: 10
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                onClicked: {
                    autoTradingEnabled = false
                    console.log("EMERGENCY STOP ACTIVATED")
                }
            }
            
            Text {
                text: "LIVE TRADING"
                color: "#ff0000"
                font.pixelSize: 12
                font.bold: true
            }
        }
    }
    
    // Main trading control panel
    Rectangle {
        id: controlPanel
        anchors.top: header.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: 120
        color: "#1a1a1a"
        border.color: primaryColor
        border.width: 2
        
        Row {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 30
            
            // Auto-trading toggle
            Column {
                spacing: 10
                
                Text {
                    text: "🤖 AUTO-TRADING CONTROL"
                    color: primaryColor
                    font.pixelSize: 16
                    font.bold: true
                }
                
                Row {
                    spacing: 15
                    
                    Button {
                        width: 100
                        height: 50
                        background: Rectangle {
                            color: autoTradingEnabled ? enabledColor : "#333333"
                            radius: 10
                            border.color: "#ffffff"
                            border.width: 2
                        }
                        contentItem: Text {
                            text: autoTradingEnabled ? "🟢 ENABLED" : "▶️ START"
                            color: autoTradingEnabled ? "#000000" : "#ffffff"
                            font.bold: true
                            font.pixelSize: 12
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        onClicked: {
                            autoTradingEnabled = !autoTradingEnabled
                            console.log("Auto-trading", autoTradingEnabled ? "STARTED" : "STOPPED")
                        }
                    }
                    
                    Button {
                        width: 100
                        height: 50
                        background: Rectangle {
                            color: "#ffaa00"
                            radius: 10
                            border.color: "#ffffff"
                            border.width: 2
                        }
                        contentItem: Text {
                            text: "⏸️ PAUSE"
                            color: "#000000"
                            font.bold: true
                            font.pixelSize: 12
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        onClicked: {
                            autoTradingEnabled = false
                            console.log("Auto-trading PAUSED")
                        }
                    }
                }
            }
            
            // Strategy selection
            Column {
                spacing: 10
                
                Text {
                    text: "📈 TRADING STRATEGY"
                    color: primaryColor
                    font.pixelSize: 16
                    font.bold: true
                }
                
                Row {
                    spacing: 10
                    
                    Button {
                        width: 120
                        height: 35
                        background: Rectangle {
                            color: tradingStrategy === "CONSERVATIVE" ? enabledColor : "#333333"
                            radius: 8
                        }
                        contentItem: Text {
                            text: "🐌 CONSERVATIVE"
                            color: tradingStrategy === "CONSERVATIVE" ? "#000000" : "#ffffff"
                            font.bold: true
                            font.pixelSize: 10
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        onClicked: {
                            tradingStrategy = "CONSERVATIVE"
                            riskLevel = 0.3
                        }
                    }
                    
                    Button {
                        width: 120
                        height: 35
                        background: Rectangle {
                            color: tradingStrategy === "BALANCED" ? enabledColor : "#333333"
                            radius: 8
                        }
                        contentItem: Text {
                            text: "⚖️ BALANCED"
                            color: tradingStrategy === "BALANCED" ? "#000000" : "#ffffff"
                            font.bold: true
                            font.pixelSize: 10
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        onClicked: {
                            tradingStrategy = "BALANCED"
                            riskLevel = 0.5
                        }
                    }
                    
                    Button {
                        width: 120
                        height: 35
                        background: Rectangle {
                            color: tradingStrategy === "AGGRESSIVE" ? enabledColor : "#333333"
                            radius: 8
                        }
                        contentItem: Text {
                            text: "🚀 AGGRESSIVE"
                            color: tradingStrategy === "AGGRESSIVE" ? "#000000" : "#ffffff"
                            font.bold: true
                            font.pixelSize: 10
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        onClicked: {
                            tradingStrategy = "AGGRESSIVE"
                            riskLevel = 0.8
                        }
                    }
                }
            }
            
            // AI Strategy toggles
            Column {
                spacing: 10
                
                Text {
                    text: "🧠 AI STRATEGIES"
                    color: primaryColor
                    font.pixelSize: 16
                    font.bold: true
                }
                
                Row {
                    spacing: 8
                    
                    property bool grokEnabled: true
                    property bool mlEnabled: true
                    property bool momentumEnabled: false
                    
                    Button {
                        width: 80
                        height: 35
                        background: Rectangle {
                            color: parent.grokEnabled ? enabledColor : "#333333"
                            radius: 6
                        }
                        contentItem: Text {
                            text: "🧠 Grok"
                            color: parent.grokEnabled ? "#000000" : "#ffffff"
                            font.bold: true
                            font.pixelSize: 9
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        onClicked: parent.grokEnabled = !parent.grokEnabled
                    }
                    
                    Button {
                        width: 80
                        height: 35
                        background: Rectangle {
                            color: parent.mlEnabled ? enabledColor : "#333333"
                            radius: 6
                        }
                        contentItem: Text {
                            text: "🤖 ML"
                            color: parent.mlEnabled ? "#000000" : "#ffffff"
                            font.bold: true
                            font.pixelSize: 9
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        onClicked: parent.mlEnabled = !parent.mlEnabled
                    }
                    
                    Button {
                        width: 80
                        height: 35
                        background: Rectangle {
                            color: parent.momentumEnabled ? enabledColor : "#333333"
                            radius: 6
                        }
                        contentItem: Text {
                            text: "📈 Momentum"
                            color: parent.momentumEnabled ? "#000000" : "#ffffff"
                            font.bold: true
                            font.pixelSize: 8
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        onClicked: parent.momentumEnabled = !parent.momentumEnabled
                    }
                }
            }
            
            // Risk management
            Column {
                spacing: 8
                
                Text {
                    text: "⚠️ RISK CONTROLS"
                    color: primaryColor
                    font.pixelSize: 16
                    font.bold: true
                }
                
                Column {
                    spacing: 5
                    
                    Row {
                        spacing: 10
                        Text {
                            text: "Risk Level:"
                            color: "#ffffff"
                            font.pixelSize: 11
                            width: 70
                        }
                        Slider {
                            width: 120
                            height: 20
                            from: 0.1
                            to: 1.0
                            value: riskLevel
                            onValueChanged: riskLevel = value
                        }
                        Text {
                            text: (riskLevel * 100).toFixed(0) + "%"
                            color: warningColor
                            font.pixelSize: 11
                            font.bold: true
                            width: 40
                        }
                    }
                    
                    Row {
                        spacing: 5
                        Text {
                            text: "Max Position: " + (riskLevel * 10).toFixed(1) + "%"
                            color: "#cccccc"
                            font.pixelSize: 9
                            width: 100
                        }
                        Text {
                            text: "Stop Loss: 2%"
                            color: "#cccccc"
                            font.pixelSize: 9
                            width: 80
                        }
                    }
                }
            }
        }
    }
    
    // Main content area
    Row {
        anchors.top: controlPanel.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 20
        spacing: 20
        
        // Left panel - Live trading activity
        Rectangle {
            width: parent.width * 0.4
            height: parent.height
            color: "#1a1a1a"
            border.color: autoTradingEnabled ? enabledColor : disabledColor
            border.width: 2
            radius: 10
            
            Column {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 15
                
                Text {
                    text: "🔄 LIVE TRADING ACTIVITY"
                    color: primaryColor
                    font.pixelSize: 20
                    font.bold: true
                }
                
                // Trading metrics
                Row {
                    width: parent.width
                    spacing: 20
                    
                    Rectangle {
                        width: 140
                        height: 80
                        color: "#2a2a2a"
                        border.color: enabledColor
                        border.width: 2
                        radius: 8
                        
                        Column {
                            anchors.centerIn: parent
                            Text {
                                text: "Trades Today"
                                color: "#cccccc"
                                font.pixelSize: 11
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                            Text {
                                text: totalTrades.toString()
                                color: enabledColor
                                font.pixelSize: 20
                                font.bold: true
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                        }
                    }
                    
                    Rectangle {
                        width: 140
                        height: 80
                        color: "#2a2a2a"
                        border.color: dailyPnL >= 0 ? enabledColor : disabledColor
                        border.width: 2
                        radius: 8
                        
                        Column {
                            anchors.centerIn: parent
                            Text {
                                text: "Daily P&L"
                                color: "#cccccc"
                                font.pixelSize: 11
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                            Text {
                                text: (dailyPnL >= 0 ? "+" : "") + "$" + dailyPnL.toFixed(0)
                                color: dailyPnL >= 0 ? enabledColor : disabledColor
                                font.pixelSize: 18
                                font.bold: true
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                        }
                    }
                }
                
                Text {
                    text: "📊 Recent Trades"
                    color: primaryColor
                    font.pixelSize: 16
                    font.bold: true
                }
                
                // Live trade feed
                ScrollView {
                    width: parent.width
                    height: 400
                    
                    Column {
                        width: parent.width
                        spacing: 8
                        
                        Repeater {
                            model: [
                                { time: "14:23:15", symbol: "NVDA", action: "BUY", qty: 15, price: 1187.20, reason: "Grok AI Signal (94.2%)", pnl: "+$142.50" },
                                { time: "14:19:42", symbol: "AAPL", action: "SELL", qty: 25, price: 234.85, reason: "Take Profit Hit", pnl: "+$89.25" },
                                { time: "14:15:33", symbol: "MSFT", action: "BUY", qty: 12, price: 411.90, reason: "ML LSTM Prediction", pnl: "+$67.80" },
                                { time: "14:12:08", symbol: "GOOGL", action: "BUY", qty: 30, price: 161.75, reason: "Grok AI Signal (91.7%)", pnl: "+$225.00" },
                                { time: "14:08:44", symbol: "TSLA", action: "SELL", qty: 8, price: 249.20, reason: "Stop Loss Triggered", pnl: "-$58.40" },
                                { time: "14:05:17", symbol: "META", action: "BUY", qty: 6, price: 577.45, reason: "ML Ensemble Model", pnl: "+$134.67" },
                                { time: "14:01:55", symbol: "AMZN", action: "BUY", qty: 18, price: 185.80, reason: "Momentum Signal", pnl: "+$94.32" }
                            ]
                            
                            Rectangle {
                                width: parent.width
                                height: 50
                                color: index % 2 === 0 ? "#2a2a2a" : "#252525"
                                border.color: modelData.action === "BUY" ? enabledColor : disabledColor
                                border.width: 1
                                radius: 6
                                
                                Row {
                                    anchors.fill: parent
                                    anchors.margins: 8
                                    spacing: 10
                                    
                                    Text {
                                        text: modelData.time
                                        color: "#cccccc"
                                        font.pixelSize: 9
                                        width: 50
                                    }
                                    
                                    Rectangle {
                                        width: 35
                                        height: 18
                                        color: modelData.action === "BUY" ? enabledColor : disabledColor
                                        radius: 9
                                        
                                        Text {
                                            text: modelData.action
                                            color: "#000000"
                                            font.pixelSize: 8
                                            font.bold: true
                                            anchors.centerIn: parent
                                        }
                                    }
                                    
                                    Column {
                                        spacing: 2
                                        
                                        Text {
                                            text: modelData.qty + " " + modelData.symbol + " @ $" + modelData.price
                                            color: primaryColor
                                            font.pixelSize: 11
                                            font.bold: true
                                        }
                                        
                                        Text {
                                            text: modelData.reason
                                            color: "#ffffff"
                                            font.pixelSize: 8
                                            width: 200
                                            wrapMode: Text.WordWrap
                                        }
                                    }
                                    
                                    Text {
                                        text: modelData.pnl
                                        color: modelData.pnl.startsWith("+") ? enabledColor : disabledColor
                                        font.pixelSize: 10
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
        
        // Center panel - AI Signals
        Rectangle {
            width: parent.width * 0.35
            height: parent.height
            color: "#1a1a1a"
            border.color: primaryColor
            border.width: 2
            radius: 10
            
            Column {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 15
                
                Text {
                    text: "🧠 AI TRADING SIGNALS"
                    color: primaryColor
                    font.pixelSize: 20
                    font.bold: true
                }
                
                // Active signals
                ScrollView {
                    width: parent.width
                    height: parent.height - 50
                    
                    Column {
                        width: parent.width
                        spacing: 12
                        
                        Text {
                            text: "🔥 ACTIVE SIGNALS"
                            color: warningColor
                            font.pixelSize: 14
                            font.bold: true
                        }
                        
                        Repeater {
                            model: [
                                { symbol: "NVDA", action: "BUY", confidence: 96.2, source: "Grok AI", reason: "KI-Boom erwartet", target: 1350, current: 1187 },
                                { symbol: "AAPL", action: "BUY", confidence: 89.3, source: "ML LSTM", reason: "iPhone 16 stark", target: 260, current: 235 },
                                { symbol: "GOOGL", action: "BUY", confidence: 91.7, source: "Grok AI", reason: "Gemini Durchbruch", target: 185, current: 162 },
                                { symbol: "AMD", action: "BUY", confidence: 84.5, source: "ML Ensemble", reason: "Server-Boom", target: 180, current: 157 },
                                { symbol: "TSLA", action: "HOLD", confidence: 78.5, source: "Grok AI", reason: "Autopilot Update", target: 280, current: 249 }
                            ]
                            
                            Rectangle {
                                width: parent.width
                                height: 80
                                color: "#2a2a2a"
                                border.color: modelData.action === "BUY" ? enabledColor : 
                                              modelData.action === "SELL" ? disabledColor : warningColor
                                border.width: 2
                                radius: 8
                                
                                Row {
                                    anchors.fill: parent
                                    anchors.margins: 12
                                    spacing: 15
                                    
                                    Column {
                                        width: 80
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
                                            color: modelData.action === "BUY" ? enabledColor : 
                                                   modelData.action === "SELL" ? disabledColor : warningColor
                                            radius: 10
                                            
                                            Text {
                                                text: modelData.action
                                                color: "#000000"
                                                font.pixelSize: 9
                                                font.bold: true
                                                anchors.centerIn: parent
                                            }
                                        }
                                    }
                                    
                                    Column {
                                        spacing: 3
                                        
                                        Text {
                                            text: modelData.source
                                            color: warningColor
                                            font.pixelSize: 10
                                            font.bold: true
                                        }
                                        
                                        Text {
                                            text: "Confidence: " + modelData.confidence + "%"
                                            color: "#ffffff"
                                            font.pixelSize: 9
                                        }
                                        
                                        Text {
                                            text: "$" + modelData.current + " → $" + modelData.target
                                            color: enabledColor
                                            font.pixelSize: 9
                                        }
                                        
                                        Text {
                                            text: modelData.reason
                                            color: "#cccccc"
                                            font.pixelSize: 8
                                            width: 150
                                            wrapMode: Text.WordWrap
                                        }
                                    }
                                    
                                    // Auto-execute button
                                    Button {
                                        width: 60
                                        height: 25
                                        visible: autoTradingEnabled && modelData.confidence > 85
                                        background: Rectangle {
                                            color: enabledColor
                                            radius: 12
                                        }
                                        contentItem: Text {
                                            text: "EXECUTE"
                                            color: "#000000"
                                            font.pixelSize: 8
                                            font.bold: true
                                            horizontalAlignment: Text.AlignHCenter
                                            verticalAlignment: Text.AlignVCenter
                                        }
                                        onClicked: {
                                            console.log("Executing trade:", modelData.symbol, modelData.action)
                                            totalTrades++
                                        }
                                    }
                                }
                            }
                        }
                        
                        Rectangle {
                            width: parent.width
                            height: 100
                            color: "#1a2a1a"
                            border.color: enabledColor
                            border.width: 2
                            radius: 8
                            
                            Column {
                                anchors.centerIn: parent
                                spacing: 8
                                
                                Text {
                                    text: "🤖 AI PERFORMANCE"
                                    color: enabledColor
                                    font.pixelSize: 14
                                    font.bold: true
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }
                                
                                Row {
                                    spacing: 20
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    
                                    Column {
                                        Text {
                                            text: "Win Rate"
                                            color: "#cccccc"
                                            font.pixelSize: 10
                                            anchors.horizontalCenter: parent.horizontalCenter
                                        }
                                        Text {
                                            text: "87.3%"
                                            color: enabledColor
                                            font.pixelSize: 16
                                            font.bold: true
                                            anchors.horizontalCenter: parent.horizontalCenter
                                        }
                                    }
                                    
                                    Column {
                                        Text {
                                            text: "Avg Profit"
                                            color: "#cccccc"
                                            font.pixelSize: 10
                                            anchors.horizontalCenter: parent.horizontalCenter
                                        }
                                        Text {
                                            text: "$127.45"
                                            color: enabledColor
                                            font.pixelSize: 16
                                            font.bold: true
                                            anchors.horizontalCenter: parent.horizontalCenter
                                        }
                                    }
                                    
                                    Column {
                                        Text {
                                            text: "Signals/Hour"
                                            color: "#cccccc"
                                            font.pixelSize: 10
                                            anchors.horizontalCenter: parent.horizontalCenter
                                        }
                                        Text {
                                            text: "12.4"
                                            color: enabledColor
                                            font.pixelSize: 16
                                            font.bold: true
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
        
        // Right panel - Portfolio & Risk
        Rectangle {
            width: parent.width * 0.25
            height: parent.height
            color: "#1a1a1a"
            border.color: warningColor
            border.width: 2
            radius: 10
            
            Column {
                anchors.fill: parent
                anchors.margins: 15
                spacing: 12
                
                Text {
                    text: "📊 PORTFOLIO STATUS"
                    color: warningColor
                    font.pixelSize: 16
                    font.bold: true
                }
                
                // Portfolio metrics
                Column {
                    width: parent.width
                    spacing: 8
                    
                    Rectangle {
                        width: parent.width
                        height: 60
                        color: "#2a2a2a"
                        border.color: primaryColor
                        border.width: 2
                        radius: 8
                        
                        Column {
                            anchors.centerIn: parent
                            Text {
                                text: "Total Value"
                                color: "#cccccc"
                                font.pixelSize: 11
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                            Text {
                                text: "$" + portfolioValue.toLocaleString()
                                color: primaryColor
                                font.pixelSize: 16
                                font.bold: true
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                        }
                    }
                    
                    Row {
                        width: parent.width
                        spacing: 8
                        
                        Rectangle {
                            width: (parent.width - 8) / 2
                            height: 50
                            color: "#2a2a2a"
                            border.color: enabledColor
                            border.width: 1
                            radius: 6
                            
                            Column {
                                anchors.centerIn: parent
                                Text {
                                    text: "Buying Power"
                                    color: "#cccccc"
                                    font.pixelSize: 9
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }
                                Text {
                                    text: "$25,670"
                                    color: enabledColor
                                    font.pixelSize: 12
                                    font.bold: true
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }
                            }
                        }
                        
                        Rectangle {
                            width: (parent.width - 8) / 2
                            height: 50
                            color: "#2a2a2a"
                            border.color: warningColor
                            border.width: 1
                            radius: 6
                            
                            Column {
                                anchors.centerIn: parent
                                Text {
                                    text: "Open Positions"
                                    color: "#cccccc"
                                    font.pixelSize: 9
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }
                                Text {
                                    text: "17"
                                    color: warningColor
                                    font.pixelSize: 12
                                    font.bold: true
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }
                            }
                        }
                    }
                }
                
                Text {
                    text: "⚠️ RISK MONITOR"
                    color: warningColor
                    font.pixelSize: 14
                    font.bold: true
                }
                
                // Risk indicators
                Column {
                    width: parent.width
                    spacing: 6
                    
                    Row {
                        width: parent.width
                        
                        Text {
                            text: "Daily Risk Limit:"
                            color: "#cccccc"
                            font.pixelSize: 10
                            width: parent.width * 0.6
                        }
                        
                        Text {
                            text: "23% / 100%"
                            color: enabledColor
                            font.pixelSize: 10
                            font.bold: true
                        }
                    }
                    
                    Rectangle {
                        width: parent.width
                        height: 8
                        color: "#333333"
                        radius: 4
                        
                        Rectangle {
                            width: parent.width * 0.23
                            height: parent.height
                            color: enabledColor
                            radius: 4
                        }
                    }
                    
                    Row {
                        width: parent.width
                        
                        Text {
                            text: "Position Concentration:"
                            color: "#cccccc"
                            font.pixelSize: 10
                            width: parent.width * 0.6
                        }
                        
                        Text {
                            text: "45% / 60%"
                            color: warningColor
                            font.pixelSize: 10
                            font.bold: true
                        }
                    }
                    
                    Rectangle {
                        width: parent.width
                        height: 8
                        color: "#333333"
                        radius: 4
                        
                        Rectangle {
                            width: parent.width * 0.45
                            height: parent.height
                            color: warningColor
                            radius: 4
                        }
                    }
                }
                
                Text {
                    text: "🔄 ACTIVE POSITIONS"
                    color: primaryColor
                    font.pixelSize: 14
                    font.bold: true
                }
                
                // Active positions
                ScrollView {
                    width: parent.width
                    height: 300
                    
                    Column {
                        width: parent.width
                        spacing: 4
                        
                        Repeater {
                            model: [
                                { symbol: "NVDA", qty: 15, entry: 1185.20, current: 1187.45, pnl: 33.75 },
                                { symbol: "AAPL", qty: 25, entry: 234.10, current: 234.85, pnl: 18.75 },
                                { symbol: "MSFT", qty: 12, entry: 412.85, current: 411.90, pnl: -11.40 },
                                { symbol: "GOOGL", qty: 30, entry: 162.45, current: 163.20, pnl: 22.50 },
                                { symbol: "META", qty: 6, entry: 578.23, current: 579.15, pnl: 5.52 },
                                { symbol: "AMZN", qty: 18, entry: 186.12, current: 185.88, pnl: -4.32 }
                            ]
                            
                            Rectangle {
                                width: parent.width
                                height: 35
                                color: index % 2 === 0 ? "#2a2a2a" : "#252525"
                                border.color: modelData.pnl >= 0 ? enabledColor : disabledColor
                                border.width: 1
                                radius: 4
                                
                                Row {
                                    anchors.fill: parent
                                    anchors.margins: 6
                                    spacing: 8
                                    
                                    Text {
                                        text: modelData.symbol
                                        color: primaryColor
                                        font.pixelSize: 10
                                        font.bold: true
                                        width: 45
                                    }
                                    
                                    Column {
                                        spacing: 1
                                        
                                        Text {
                                            text: modelData.qty + " @ $" + modelData.entry
                                            color: "#ffffff"
                                            font.pixelSize: 8
                                        }
                                        
                                        Text {
                                            text: "Now: $" + modelData.current
                                            color: "#cccccc"
                                            font.pixelSize: 8
                                        }
                                    }
                                    
                                    Text {
                                        text: (modelData.pnl >= 0 ? "+" : "") + "$" + modelData.pnl.toFixed(2)
                                        color: modelData.pnl >= 0 ? enabledColor : disabledColor
                                        font.pixelSize: 9
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
    
    // Update timer for live data
    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: {
            if (autoTradingEnabled) {
                // Simulate new trades
                if (Math.random() > 0.7) {
                    totalTrades++
                    dailyPnL += (Math.random() - 0.3) * 200
                    portfolioValue = 109329.05 + dailyPnL
                }
            }
        }
    }
}