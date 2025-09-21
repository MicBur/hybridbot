import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Window 2.15

ApplicationWindow {
    id: window
    width: 1400
    height: 900
    visible: true
    title: "6bot Enhanced Trading Suite v2.0"
    color: "#0a0a0a"
    
    // Global color scheme properties
    property color primaryColor: "#00ffff"
    property color secondaryColor: "#ff6b6b"
    property color accentColor: "#ffd700"
    property color successColor: "#00ff00"
    property color warningColor: "#ffaa00"
    property color dangerColor: "#ff4444"
    property color surfaceColor: "#1a1a1a"
    
    // Trading settings properties
    property real tradingAggression: 0.6
    property string alpacaApiKey: ""
    property string alpacaSecret: ""
    property bool paperTrading: true
    property real maxRiskPerTrade: 0.02
    property real portfolioRiskLimit: 0.10
    
    // Mock Redis client for demo
    Item {
        id: redis
        
        signal portfolioEquityReceived(string equity)
        signal predictionMetricsReceived(string metrics)
        signal grokRecommendationsReceived(string data)
        
        function getPortfolioEquity() {
            portfolioEquityReceived("$" + (109329 + Math.random() * 1000).toFixed(2))
        }
        
        function getPredictionMetrics() {
            predictionMetricsReceived('{"accuracy": ' + (85 + Math.random() * 10).toFixed(1) + ', "confidence": ' + (90 + Math.random() * 8).toFixed(1) + '}')
        }
        
        function getGrokRecommendations() {
            grokRecommendationsReceived('[{"symbol": "NVDA", "action": "BUY", "confidence": 96.2}]')
        }
        
        function getAlpacaAccount() { console.log("Alpaca account check") }
        function triggerMLTraining() { console.log("ML training triggered") }
        function getGrokDeepersearch() { console.log("Grok deeper search") }
    }
    
    // Connection status
    Rectangle {
        id: statusBar
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 30
        color: "#111111"
        border.color: primaryColor
        border.width: 1
        
        Row {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: 10
            spacing: 20
            
            Row {
                spacing: 5
                Rectangle {
                    width: 8
                    height: 8
                    radius: 4
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
                    font.pixelSize: 10
                    font.bold: true
                }
            }
            
            Text {
                text: "Portfolio: $109,329.05 (+2.67%)"
                color: primaryColor
                font.pixelSize: 10
                font.bold: true
            }
            
            Text {
                text: "ML Accuracy: 87.3%"
                color: successColor
                font.pixelSize: 10
                font.bold: true
            }
            
            Text {
                text: "Grok Signals: 8 Active"
                color: warningColor
                font.pixelSize: 10
                font.bold: true
            }
        }
        
        Row {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.rightMargin: 10
            spacing: 15
            
            Text {
                text: new Date().toLocaleTimeString()
                color: "#ffffff"
                font.pixelSize: 10
            }
            
            Text {
                text: window.paperTrading ? "PAPER TRADING" : "LIVE TRADING"
                color: window.paperTrading ? warningColor : dangerColor
                font.pixelSize: 10
                font.bold: true
            }
        }
    }
    
    // Main navigation and content area
    Rectangle {
        anchors.top: statusBar.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        color: "#0a0a0a"
        
        // Navigation bar
        Rectangle {
            id: navBar
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: 80
            color: "#1a1a1a"
            border.color: primaryColor
            border.width: 2
            
            Row {
                anchors.centerIn: parent
                spacing: 20
                
                Repeater {
                    model: [
                        { text: "🏠 Dashboard", page: "dashboard" },
                        { text: "💼 Portfolio", page: "portfolio" },
                        { text: "🤖 ML Models", page: "ml" },
                        { text: "🧠 Grok AI", page: "grok" },
                        { text: "📈 Trading", page: "trading" },
                        { text: "⚙️ Settings", page: "settings" }
                    ]
                    
                    Button {
                        id: navButton
                        text: modelData.text
                        width: 180
                        height: 50
                        
                        property bool isActive: pageLoader.currentPage === modelData.page
                        
                        background: Rectangle {
                            color: parent.isActive ? primaryColor : (parent.hovered ? "#333333" : "#2a2a2a")
                            border.color: parent.isActive ? "#ffffff" : primaryColor
                            border.width: 2
                            radius: 10
                            
                            // Holographic effect
                            Rectangle {
                                anchors.fill: parent
                                color: "transparent"
                                border.color: primaryColor
                                border.width: 1
                                radius: 10
                                opacity: parent.parent.isActive ? 0.7 : 0.3
                                
                                SequentialAnimation on opacity {
                                    loops: Animation.Infinite
                                    running: parent.parent.isActive
                                    NumberAnimation { to: 0.3; duration: 1500 }
                                    NumberAnimation { to: 0.7; duration: 1500 }
                                }
                            }
                        }
                        
                        contentItem: Text {
                            text: parent.text
                            color: parent.isActive ? "#000000" : "#ffffff"
                            font.pixelSize: 12
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        
                        onClicked: pageLoader.loadPage(modelData.page)
                        
                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: parent.clicked()
                            onEntered: parent.hovered = true
                            onExited: parent.hovered = false
                        }
                        
                        property bool hovered: false
                    }
                }
            }
        }
        
        // Page loader
        Loader {
            id: pageLoader
            anchors.top: navBar.bottom
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            anchors.margins: 20
            width: parent.width - watchlistPanel.width - 60
            
            property string currentPage: "dashboard"
            
            function loadPage(pageName) {
                currentPage = pageName
                
                switch (pageName) {
                    case "dashboard":
                        source = "DashboardPage.qml"
                        break
                    case "portfolio":
                        source = "PortfolioPage.qml"
                        break
                    case "ml":
                        source = "MLPage.qml"
                        break
                    case "grok":
                        source = "GrokPage.qml"
                        break
                    case "trading":
                        source = "TradingPage.qml"
                        break
                    case "settings":
                        source = "SettingsPage.qml"
                        break
                    default:
                        source = ""
                }
            }
            
            // Fallback dashboard content when pages can't load
            Component.onCompleted: {
                if (source === "") {
                    source = Qt.binding(function() { return dashboardComponent })
                }
            }
            
            onStatusChanged: {
                if (status === Loader.Error) {
                    console.log("Failed to load page, showing fallback dashboard")
                    sourceComponent = dashboardComponent
                }
            }
        }
        
        // Stock watchlist grid (always visible)
        Rectangle {
            id: watchlistPanel
            anchors.top: navBar.bottom
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            width: 300
            anchors.margins: 20
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
                        width: parent.width - 20
                        height: 35
                        color: index % 2 === 0 ? "#2a2a2a" : "#1f1f1f"
                        border.color: modelData.change >= 0 ? successColor : dangerColor
                        border.width: 1
                        radius: 5
                        anchors.horizontalCenter: parent.horizontalCenter
                        
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
                                width: 80
                            }
                            
                            Text {
                                text: (modelData.change >= 0 ? "+" : "") + modelData.change.toFixed(1) + "%"
                                color: modelData.change >= 0 ? successColor : dangerColor
                                font.pixelSize: 10
                                font.bold: true
                                width: 60
                            }
                        }
                        
                        // Price animation effect
                        Timer {
                            interval: 2000 + Math.random() * 3000
                            running: true
                            repeat: true
                            onTriggered: {
                                // Simulate price updates
                                var priceChange = (Math.random() - 0.5) * 2
                                modelData.price += priceChange
                                modelData.change += priceChange * 0.1
                            }
                        }
                    }
                }
            }
        }
    }
    
    // Fallback dashboard component
    Component {
        id: dashboardComponent
        
        ScrollView {
            anchors.fill: parent
            
            Column {
                width: parent.width
                spacing: 30
                
                Text {
                    text: "🏠 DASHBOARD OVERVIEW"
                    font.pixelSize: 32
                    font.bold: true
                    color: window.primaryColor
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                
                // Key metrics
                Row {
                    width: parent.width
                    spacing: 20
                    anchors.horizontalCenter: parent.horizontalCenter
                    
                    Rectangle {
                        width: 200
                        height: 120
                        color: window.surfaceColor
                        border.color: window.primaryColor
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
                                color: window.primaryColor
                                font.pixelSize: 20
                                font.bold: true
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                            
                            Text {
                                text: "+$2,847.23 (+2.67%)"
                                color: window.successColor
                                font.pixelSize: 12
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                        }
                    }
                    
                    Rectangle {
                        width: 200
                        height: 120
                        color: window.surfaceColor
                        border.color: window.successColor
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
                                color: window.successColor
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
                        color: window.surfaceColor
                        border.color: window.warningColor
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
                                color: window.warningColor
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
                    color: window.surfaceColor
                    border.color: window.accentColor
                    border.width: 2
                    radius: 10
                    anchors.horizontalCenter: parent.horizontalCenter
                    
                    Column {
                        anchors.centerIn: parent
                        spacing: 20
                        
                        Text {
                            text: "⚡ QUICK ACTIONS"
                            color: window.accentColor
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
                                    color: window.successColor
                                    radius: 8
                                }
                                contentItem: Text {
                                    text: parent.text
                                    color: "#000000"
                                    font.bold: true
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                                onClicked: console.log("Quick buy clicked")
                            }
                            
                            Button {
                                text: "💰 Quick Sell"
                                width: 120
                                height: 40
                                background: Rectangle {
                                    color: window.dangerColor
                                    radius: 8
                                }
                                contentItem: Text {
                                    text: parent.text
                                    color: "#000000"
                                    font.bold: true
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                                onClicked: console.log("Quick sell clicked")
                            }
                            
                            Button {
                                text: "🔄 Rebalance"
                                width: 120
                                height: 40
                                background: Rectangle {
                                    color: window.primaryColor
                                    radius: 8
                                }
                                contentItem: Text {
                                    text: parent.text
                                    color: "#000000"
                                    font.bold: true
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                                onClicked: console.log("Rebalance clicked")
                            }
                        }
                    }
                }
                
                // Live updates message
                Rectangle {
                    width: parent.width * 0.6
                    height: 80
                    color: "#1a2a1a"
                    border.color: window.successColor
                    border.width: 1
                    radius: 8
                    anchors.horizontalCenter: parent.horizontalCenter
                    
                    Column {
                        anchors.centerIn: parent
                        spacing: 5
                        
                        Text {
                            text: "✨ Enhanced Trading Suite Active"
                            color: window.successColor
                            font.pixelSize: 14
                            font.bold: true
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                        
                        Text {
                            text: "Real-time data • AI-powered recommendations • Multi-page navigation"
                            color: "#cccccc"
                            font.pixelSize: 11
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                        
                        Text {
                            text: "Navigate using the tabs above to explore Portfolio, ML Models, Grok AI, Trading, and Settings"
                            color: "#999999"
                            font.pixelSize: 10
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                    }
                }
            }
        }
    }
    
    // Data update timer
    Timer {
        interval: 3000
        running: true
        repeat: true
        onTriggered: {
            redis.getPortfolioEquity()
            redis.getPredictionMetrics()
            redis.getGrokRecommendations()
        }
    }
}