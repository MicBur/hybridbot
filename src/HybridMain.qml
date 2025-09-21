import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtWebEngine 1.10
import Redis 1.0

ApplicationWindow {
    id: root
    visible: true
    width: 1400
    height: 900
    title: "6bot Advanced Trading System v2.0"
    
    // Main Layout
    RowLayout {
        anchors.fill: parent
        anchors.margins: 5
        
        // Left Panel - Native QML Controls
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
                                redisClient.enableAutoTrading(!autoTradingEnabled)
                                autoTradingEnabled = !autoTradingEnabled
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
                                            redisClient.setTradingStrategy(modelData.name)
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
                                redisClient.emergencyStopAll()
                                autoTradingEnabled = false
                            }
                        }
                    }
                }
                
                // Trading Metrics - Native QML
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
                            
                            // Portfolio Value
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
                            
                            // Daily P&L
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
                            
                            // Trades Today
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
                            
                            // ML Accuracy
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
        
        // Right Panel - HTML WebView
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "#0a0a0a"
            border.color: "#00ffff"
            border.width: 2
            radius: 10
            
            WebEngineView {
                id: webView
                anchors.fill: parent
                anchors.margins: 2
                
                // Load your HTML dashboard
                url: Qt.resolvedUrl("TradingSuite.html")
                
                // Enable developer tools
                settings.developmentToolsEnabled: true
                settings.javascriptEnabled: true
                
                onLoadingChanged: {
                    if (loadRequest.status === WebEngineView.LoadSucceededStatus) {
                        console.log("✅ HTML Dashboard loaded successfully")
                        
                        // Setup bidirectional communication
                        setupWebChannelCommunication()
                    }
                }
                
                // Setup two-way communication between QML and HTML
                function setupWebChannelCommunication() {
                    // Inject QML bridge functions into HTML
                    runJavaScript(`
                        // QML-HTML Communication Bridge
                        window.qmlBridge = {
                            // Data from QML
                            autoTradingEnabled: ${autoTradingEnabled},
                            currentStrategy: '${currentStrategy}',
                            dailyPnL: ${dailyPnL},
                            
                            // Functions to call QML from HTML  
                            toggleAutoTrading: function() {
                                console.log('📡 HTML calling QML: toggleAutoTrading');
                                // This will be handled by QML
                            },
                            
                            setStrategy: function(strategy) {
                                console.log('📡 HTML calling QML: setStrategy', strategy);
                                // This will be handled by QML
                            },
                            
                            emergencyStop: function() {
                                console.log('📡 HTML calling QML: emergencyStop');
                                // This will be handled by QML
                            }
                        };
                        
                        // Notify HTML that QML bridge is ready
                        if (typeof onQMLBridgeReady === 'function') {
                            onQMLBridgeReady(window.qmlBridge);
                        }
                        
                        console.log('✅ QML-HTML Bridge established');
                    `)
                }
                
                // Function to update HTML from QML
                function updateHTMLFromQML() {
                    runJavaScript(`
                        if (window.qmlBridge) {
                            window.qmlBridge.autoTradingEnabled = ${autoTradingEnabled};
                            window.qmlBridge.currentStrategy = '${currentStrategy}';
                            window.qmlBridge.dailyPnL = ${dailyPnL};
                            
                            // Update HTML UI if function exists
                            if (typeof updateFromQML === 'function') {
                                updateFromQML(window.qmlBridge);
                            }
                        }
                    `)
                }
            }
        }
    }
    
    // Properties
    property bool autoTradingEnabled: false
    property string currentStrategy: "CONSERVATIVE"
    property real dailyPnL: 0.0
    
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
                // Get initial trading status
                getAutoTradingStatus()
            } else {
                console.log("❌ Redis disconnected")
            }
        }
        
        onAutoTradingStatusChanged: {
            console.log("📡 Auto-trading status changed:", enabled)
            autoTradingEnabled = enabled
        }
        
        onTradeExecuted: {
            console.log("📈 Trade executed:", symbol, action, quantity, price)
            tradesCount.text = parseInt(tradesCount.text) + 1
            
            // Update P&L (simplified)
            var profit = (Math.random() - 0.4) * 100
            dailyPnL += profit
        }
    }
    
    // Update timer for live data
    Timer {
        interval: 5000  // 5 seconds
        running: true
        repeat: true
        
        onTriggered: {
            if (redisClient.connected) {
                redisClient.getMarketData()
                redisClient.getPortfolioData()
                
                // Update HTML dashboard with live data
                if (webView.loadProgress === 100) {
                    webView.updateHTMLFromQML()
                }
            }
        }
    }
}