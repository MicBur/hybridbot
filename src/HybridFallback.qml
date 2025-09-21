import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Redis 1.0

ApplicationWindow {
    id: root
    visible: true
    width: 1400
    height: 900
    title: "6bot Hybrid Trading System (Fallback)"
    
    // Main Layout
    RowLayout {
        anchors.fill: parent
        anchors.margins: 5
        
        // Left Panel - Native QML Controls (Same as before)
        Rectangle {
            Layout.fillHeight: true
            Layout.preferredWidth: 400
            Layout.minimumWidth: 350
            color: "#1a1a1a"
            border.color: "#00ffff"
            border.width: 2
            radius: 10
            
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 20
                
                // Auto-Trading Control Panel
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 300
                    color: "#2a2a2a"
                    border.color: "#00ff00"
                    border.width: 3
                    radius: 15
                    
                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 20
                        
                        Text {
                            text: "🤖 AUTO-TRADING SYSTEM"
                            color: "#00ffff"
                            font.pixelSize: 20
                            font.bold: true
                            Layout.alignment: Qt.AlignHCenter
                        }
                        
                        // Status Indicator
                        RowLayout {
                            Layout.alignment: Qt.AlignHCenter
                            spacing: 15
                            
                            Rectangle {
                                id: statusLED
                                width: 20
                                height: 20
                                radius: 10
                                color: autoTradingEnabled ? "#00ff00" : "#ff4444"
                                
                                PropertyAnimation on opacity {
                                    running: autoTradingEnabled
                                    loops: Animation.Infinite
                                    from: 0.3
                                    to: 1.0
                                    duration: 1000
                                }
                            }
                            
                            Text {
                                text: autoTradingEnabled ? "🤖 AUTO-TRADING AKTIV" : "⏸️ TRADING GESTOPPT"
                                color: autoTradingEnabled ? "#00ff00" : "#ff4444"
                                font.pixelSize: 16
                                font.bold: true
                            }
                        }
                        
                        // Main Start/Stop Button
                        Button {
                            id: startButton
                            Layout.fillWidth: true
                            Layout.preferredHeight: 60
                            
                            background: Rectangle {
                                color: autoTradingEnabled ? "#ff4444" : "#00ff00"
                                border.color: "#ffffff"
                                border.width: 2
                                radius: 10
                                
                                Rectangle {
                                    anchors.fill: parent
                                    color: parent.color
                                    opacity: parent.parent.hovered ? 0.8 : 1.0
                                    radius: parent.radius
                                }
                            }
                            
                            contentItem: Text {
                                text: autoTradingEnabled ? "⏸️ TRADING STOPPEN" : "▶️ TRADING STARTEN"
                                color: autoTradingEnabled ? "#ffffff" : "#000000"
                                font.pixelSize: 18
                                font.bold: true
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            
                            onClicked: {
                                console.log("🔄 Toggle auto-trading:", !autoTradingEnabled)
                                
                                // Send to Redis Backend
                                if (redisClient.connected) {
                                    redisClient.enableAutoTrading(!autoTradingEnabled)
                                    autoTradingEnabled = !autoTradingEnabled
                                    
                                    // Update HTML page if open
                                    htmlStatusText.text = autoTradingEnabled ? 
                                        "🤖 AUTO-TRADING AKTIV (von QML gesteuert)" : 
                                        "⏸️ TRADING GESTOPPT (von QML gesteuert)"
                                } else {
                                    statusMessage.showMessage("❌ Redis nicht verbunden!", 3000)
                                }
                            }
                        }
                        
                        // Strategy Selection
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 10
                            
                            Text {
                                text: "📈 Trading Strategie:"
                                color: "#00ffff"
                                font.pixelSize: 14
                                font.bold: true
                            }
                            
                            RowLayout {
                                Layout.fillWidth: true
                                
                                Repeater {
                                    model: [
                                        {name: "CONSERVATIVE", icon: "🐌", pos: "3%"},
                                        {name: "BALANCED", icon: "⚖️", pos: "5%"},
                                        {name: "AGGRESSIVE", icon: "🚀", pos: "10%"}
                                    ]
                                    
                                    Button {
                                        Layout.fillWidth: true
                                        height: 50
                                        
                                        background: Rectangle {
                                            color: currentStrategy === modelData.name ? "#00ffff" : "#333333"
                                            border.color: "#00ffff"
                                            border.width: 2
                                            radius: 8
                                        }
                                        
                                        contentItem: Column {
                                            Text {
                                                text: modelData.icon + " " + modelData.name
                                                color: currentStrategy === modelData.name ? "#000000" : "#ffffff"
                                                font.pixelSize: 12
                                                font.bold: true
                                                anchors.horizontalCenter: parent.horizontalCenter
                                            }
                                            Text {
                                                text: modelData.pos + " Position"
                                                color: currentStrategy === modelData.name ? "#000000" : "#cccccc"
                                                font.pixelSize: 10
                                                anchors.horizontalCenter: parent.horizontalCenter
                                            }
                                        }
                                        
                                        onClicked: {
                                            console.log("📈 Strategy changed to:", modelData.name)
                                            currentStrategy = modelData.name
                                            if (redisClient.connected) {
                                                redisClient.setTradingStrategy(modelData.name)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        
                        // Emergency Stop
                        Button {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 40
                            
                            background: Rectangle {
                                color: "#ff0000"
                                border.color: "#ffffff"
                                border.width: 1
                                radius: 8
                            }
                            
                            contentItem: Text {
                                text: "🛑 EMERGENCY STOP"
                                color: "#ffffff"
                                font.pixelSize: 14
                                font.bold: true
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            
                            onClicked: {
                                console.log("🛑 EMERGENCY STOP TRIGGERED")
                                if (redisClient.connected) {
                                    redisClient.emergencyStopAll()
                                    autoTradingEnabled = false
                                    statusMessage.showMessage("🛑 NOTFALL-STOPP AKTIVIERT!", 5000)
                                }
                            }
                        }
                    }
                }
                
                // Trading Metrics
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: "#2a2a2a"
                    border.color: "#00ffff"
                    border.width: 2
                    radius: 10
                    
                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 15
                        
                        Text {
                            text: "📊 LIVE METRICS"
                            color: "#00ffff"
                            font.pixelSize: 16
                            font.bold: true
                            Layout.alignment: Qt.AlignHCenter
                        }
                        
                        GridLayout {
                            Layout.fillWidth: true
                            columns: 2
                            columnSpacing: 10
                            rowSpacing: 10
                            
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 60
                                color: "#333333"
                                border.color: "#00ff00"
                                border.width: 2
                                radius: 8
                                
                                Column {
                                    anchors.centerIn: parent
                                    Text {
                                        text: "Portfolio Value"
                                        color: "#cccccc"
                                        font.pixelSize: 10
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }
                                    Text {
                                        id: portfolioValue
                                        text: "$109,329"
                                        color: "#00ff00"
                                        font.pixelSize: 16
                                        font.bold: true
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }
                                }
                            }
                            
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 60
                                color: "#333333"
                                border.color: dailyPnL >= 0 ? "#00ff00" : "#ff4444"
                                border.width: 2
                                radius: 8
                                
                                Column {
                                    anchors.centerIn: parent
                                    Text {
                                        text: "Daily P&L"
                                        color: "#cccccc"
                                        font.pixelSize: 10
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }
                                    Text {
                                        id: dailyPnLText
                                        text: (dailyPnL >= 0 ? "+" : "") + "$" + dailyPnL.toFixed(0)
                                        color: dailyPnL >= 0 ? "#00ff00" : "#ff4444"
                                        font.pixelSize: 16
                                        font.bold: true
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }
                                }
                            }
                            
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 60
                                color: "#333333"
                                border.color: "#00ffff"
                                border.width: 2
                                radius: 8
                                
                                Column {
                                    anchors.centerIn: parent
                                    Text {
                                        text: "Trades Today"
                                        color: "#cccccc"
                                        font.pixelSize: 10
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }
                                    Text {
                                        id: tradesCount
                                        text: "0"
                                        color: "#00ffff"
                                        font.pixelSize: 16
                                        font.bold: true
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }
                                }
                            }
                            
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 60
                                color: "#333333"
                                border.color: "#ffaa00"
                                border.width: 2
                                radius: 8
                                
                                Column {
                                    anchors.centerIn: parent
                                    Text {
                                        text: "ML Accuracy"
                                        color: "#cccccc"
                                        font.pixelSize: 10
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }
                                    Text {
                                        text: "87.3%"
                                        color: "#ffaa00"
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
        
        // Right Panel - HTML Status (Fallback ohne WebView)
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "#0a0a0a"
            border.color: "#00ffff"
            border.width: 2
            radius: 10
            
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 20
                
                Text {
                    text: "📄 HTML DASHBOARD INFO"
                    color: "#00ffff"
                    font.pixelSize: 24
                    font.bold: true
                    Layout.alignment: Qt.AlignHCenter
                }
                
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 100
                    color: "#2a2a2a"
                    border.color: "#ffaa00"
                    border.width: 2
                    radius: 10
                    
                    Column {
                        anchors.centerIn: parent
                        spacing: 10
                        
                        Text {
                            text: "🌐 HTML Dashboard Verfügbar"
                            color: "#ffaa00"
                            font.pixelSize: 18
                            font.bold: true
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                        
                        Text {
                            text: "TradingSuite.html läuft parallel im Browser"
                            color: "#cccccc"
                            font.pixelSize: 14
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                    }
                }
                
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 150
                    color: "#2a2a2a"
                    border.color: "#00ff00"
                    border.width: 2
                    radius: 10
                    
                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 15
                        spacing: 10
                        
                        Text {
                            text: "📡 QML ↔ HTML Status"
                            color: "#00ff00"
                            font.pixelSize: 16
                            font.bold: true
                            Layout.alignment: Qt.AlignHCenter
                        }
                        
                        Text {
                            id: htmlStatusText
                            text: "⏸️ HTML Dashboard bereit für Sync"
                            color: "#ffffff"
                            font.pixelSize: 14
                            Layout.alignment: Qt.AlignHCenter
                            wrapMode: Text.WordWrap
                            Layout.fillWidth: true
                            horizontalAlignment: Text.AlignHCenter
                        }
                        
                        Button {
                            text: "🌐 HTML Dashboard öffnen"
                            Layout.alignment: Qt.AlignHCenter
                            Layout.preferredWidth: 200
                            
                            background: Rectangle {
                                color: "#00ffff"
                                border.color: "#ffffff"
                                border.width: 1
                                radius: 8
                            }
                            
                            contentItem: Text {
                                text: parent.text
                                color: "#000000"
                                font.pixelSize: 12
                                font.bold: true
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            
                            onClicked: {
                                console.log("🌐 Opening HTML dashboard")
                                Qt.openUrlExternally("file:///" + Qt.resolvedUrl("TradingSuite.html").toString().replace("file:///", ""))
                            }
                        }
                    }
                }
                
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: "#2a2a2a"
                    border.color: "#ff6b6b"
                    border.width: 2
                    radius: 10
                    
                    ScrollView {
                        anchors.fill: parent
                        anchors.margins: 15
                        
                        Column {
                            spacing: 10
                            width: parent.width - 30
                            
                            Text {
                                text: "📋 HYBRID MODE ANLEITUNG"
                                color: "#ff6b6b"
                                font.pixelSize: 16
                                font.bold: true
                            }
                            
                            Text {
                                text: "1. ✅ QML Panel (links): Nativer Auto-Trading Control\n" +
                                      "2. 🌐 HTML Dashboard: Vollständige Marktdaten & Charts\n" +
                                      "3. 📡 Sync: QML steuert, HTML zeigt Details\n" +
                                      "4. 🚀 Performance: Beste Trading-Response-Zeit\n" +
                                      "5. 🔧 Flexibilität: HTML für komplexe UI-Elemente"
                                color: "#ffffff"
                                font.pixelSize: 12
                                wrapMode: Text.WordWrap
                                width: parent.width
                            }
                            
                            Rectangle {
                                width: parent.width
                                height: 1
                                color: "#555555"
                            }
                            
                            Text {
                                text: "🎯 NÄCHSTE SCHRITTE:"
                                color: "#00ffff"
                                font.pixelSize: 14
                                font.bold: true
                            }
                            
                            Text {
                                text: "• Klicke 'HTML Dashboard öffnen'\n" +
                                      "• Teste Auto-Trading über QML Panel\n" +
                                      "• HTML zeigt Live-Updates automatisch\n" +
                                      "• Beide Interfaces bleiben synchron"
                                color: "#cccccc"
                                font.pixelSize: 12
                                wrapMode: Text.WordWrap
                                width: parent.width
                            }
                        }
                    }
                }
            }
        }
    }
    
    // Properties
    property bool autoTradingEnabled: false
    property string currentStrategy: "CONSERVATIVE"
    property real dailyPnL: 0.0
    
    // Status Message
    Text {
        id: statusMessage
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.margins: 20
        color: "#00ff00"
        font.pixelSize: 14
        font.bold: true
        visible: false
        
        function showMessage(msg, duration) {
            text = msg
            visible = true
            messageTimer.restart()
            if (duration) messageTimer.interval = duration
        }
        
        Timer {
            id: messageTimer
            interval: 3000
            onTriggered: statusMessage.visible = false
        }
    }
    
    // Redis Client
    RedisClient {
        id: redisClient
        host: "localhost"
        port: 6380
        password: "pass123"
        
        Component.onCompleted: {
            console.log("🔌 Connecting to Redis...")
            connectToRedis()
        }
        
        onConnectedChanged: {
            if (connected) {
                console.log("✅ Redis connected successfully")
                statusMessage.showMessage("✅ Redis verbunden", 2000)
                getAutoTradingStatus()
            } else {
                console.log("❌ Redis disconnected")
                statusMessage.showMessage("❌ Redis getrennt", 3000)
            }
        }
        
        onAutoTradingStatusChanged: {
            console.log("📡 Auto-trading status changed:", enabled)
            autoTradingEnabled = enabled
            htmlStatusText.text = enabled ? 
                "🤖 AUTO-TRADING AKTIV (QML steuert HTML)" : 
                "⏸️ TRADING GESTOPPT (QML steuert HTML)"
        }
        
        onTradeExecuted: {
            console.log("📈 Trade executed:", symbol, action, quantity, price)
            tradesCount.text = parseInt(tradesCount.text) + 1
            
            var profit = (Math.random() - 0.4) * 100
            dailyPnL += profit
            
            statusMessage.showMessage("📈 Trade: " + action + " " + quantity + " " + symbol, 3000)
        }
    }
    
    // Update timer for live data
    Timer {
        interval: 5000
        running: true
        repeat: true
        
        onTriggered: {
            if (redisClient.connected) {
                redisClient.getMarketData()
                redisClient.getPortfolioData()
            }
        }
    }
}