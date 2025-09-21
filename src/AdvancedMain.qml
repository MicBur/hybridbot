import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Redis 1.0

ApplicationWindow {
    id: window
    visible: true
    width: 1600
    height: 1000
    title: "6bot Premium Trading Suite - Advanced Dashboard"
    
    // Dark theme
    color: "#0a0a0a"
    
    // Global properties
    property color primaryColor: "#00ffff"
    property color secondaryColor: "#ff6b6b" 
    property color accentColor: "#4ecdc4"
    property color warningColor: "#ffff00"
    property color successColor: "#00ff00"
    property color backgroundColor: "#1a1a1a"
    property color surfaceColor: "#2a2a2a"
    
    // Trading settings
    property real tradingAggression: 0.5
    property string alpacaApiKey: ""
    property string alpacaSecret: ""
    property bool paperTrading: true
    property real maxRiskPerTrade: 0.02
    property real portfolioRiskLimit: 0.10
    
    // Current page
    property string currentPage: "dashboard"
    
    // Redis client instance
    RedisClient {
        id: redis
        host: "localhost"
        port: 6380
        password: "pass123"
        
        Component.onCompleted: {
            connectToRedis()
        }
        
        onConnectedChanged: {
            if (connected) {
                statusIndicator.color = successColor
                statusText.text = "✅ Connected to Redis"
                // Load all data
                getPortfolioData()
                getAlpacaAccount()
                getGrokRecommendations()
                getMLStatus()
                getPredictionMetrics()
            } else {
                statusIndicator.color = secondaryColor
                statusText.text = "❌ Disconnected"
            }
        }
    }
    
    // Auto-refresh timer
    Timer {
        interval: 3000
        running: true
        repeat: true
        onTriggered: {
            if (redis.connected) {
                redis.getPortfolioData()
                redis.getAlpacaAccount()
                if (Math.random() > 0.7) { // Reduce API calls
                    redis.getGrokRecommendations()
                }
            }
        }
    }
    
    // Top navigation bar
    Rectangle {
        id: topBar
        width: parent.width
        height: 60
        color: backgroundColor
        border.color: primaryColor
        border.width: 1
        z: 100
        
        Row {
            anchors.left: parent.left
            anchors.leftMargin: 20
            anchors.verticalCenter: parent.verticalCenter
            spacing: 30
            
            Text {
                text: "6BOT PREMIUM"
                font.pixelSize: 24
                font.bold: true
                color: primaryColor
                anchors.verticalCenter: parent.verticalCenter
            }
            
            // Navigation buttons
            Row {
                spacing: 5
                anchors.verticalCenter: parent.verticalCenter
                
                Button {
                    text: "Dashboard"
                    flat: true
                    checkable: true
                    checked: currentPage === "dashboard"
                    onClicked: currentPage = "dashboard"
                    background: Rectangle {
                        color: parent.checked ? primaryColor : "transparent"
                        border.color: primaryColor
                        border.width: 1
                        radius: 3
                    }
                    contentItem: Text {
                        text: parent.text
                        color: parent.checked ? "#000000" : primaryColor
                        font.pixelSize: 12
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }
                
                Button {
                    text: "Portfolio"
                    flat: true
                    checkable: true
                    checked: currentPage === "portfolio"
                    onClicked: currentPage = "portfolio"
                    background: Rectangle {
                        color: parent.checked ? primaryColor : "transparent"
                        border.color: primaryColor
                        border.width: 1
                        radius: 3
                    }
                    contentItem: Text {
                        text: parent.text
                        color: parent.checked ? "#000000" : primaryColor
                        font.pixelSize: 12
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }
                
                Button {
                    text: "ML Models"
                    flat: true
                    checkable: true
                    checked: currentPage === "ml"
                    onClicked: currentPage = "ml"
                    background: Rectangle {
                        color: parent.checked ? primaryColor : "transparent"
                        border.color: primaryColor
                        border.width: 1
                        radius: 3
                    }
                    contentItem: Text {
                        text: parent.text
                        color: parent.checked ? "#000000" : primaryColor
                        font.pixelSize: 12
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }
                
                Button {
                    text: "Grok AI"
                    flat: true
                    checkable: true
                    checked: currentPage === "grok"
                    onClicked: currentPage = "grok"
                    background: Rectangle {
                        color: parent.checked ? primaryColor : "transparent"
                        border.color: primaryColor
                        border.width: 1
                        radius: 3
                    }
                    contentItem: Text {
                        text: parent.text
                        color: parent.checked ? "#000000" : primaryColor
                        font.pixelSize: 12
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }
                
                Button {
                    text: "Trading"
                    flat: true
                    checkable: true
                    checked: currentPage === "trading"
                    onClicked: currentPage = "trading"
                    background: Rectangle {
                        color: parent.checked ? primaryColor : "transparent"
                        border.color: primaryColor
                        border.width: 1
                        radius: 3
                    }
                    contentItem: Text {
                        text: parent.text
                        color: parent.checked ? "#000000" : primaryColor
                        font.pixelSize: 12
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }
                
                Button {
                    text: "Settings"
                    flat: true
                    checkable: true
                    checked: currentPage === "settings"
                    onClicked: currentPage = "settings"
                    background: Rectangle {
                        color: parent.checked ? primaryColor : "transparent"
                        border.color: primaryColor
                        border.width: 1
                        radius: 3
                    }
                    contentItem: Text {
                        text: parent.text
                        color: parent.checked ? "#000000" : primaryColor
                        font.pixelSize: 12
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }
        }
        
        // Status indicator
        Row {
            anchors.right: parent.right
            anchors.rightMargin: 20
            anchors.verticalCenter: parent.verticalCenter
            spacing: 10
            
            Rectangle {
                id: statusIndicator
                width: 12
                height: 12
                radius: 6
                color: warningColor
                
                SequentialAnimation on opacity {
                    loops: Animation.Infinite
                    NumberAnimation { to: 0.3; duration: 1000 }
                    NumberAnimation { to: 1.0; duration: 1000 }
                }
            }
            
            Text {
                id: statusText
                text: "🔄 Connecting..."
                color: "#ffffff"
                font.pixelSize: 12
            }
            
            Text {
                text: new Date().toLocaleTimeString()
                color: "#cccccc"
                font.pixelSize: 10
                
                Timer {
                    interval: 1000
                    running: true
                    repeat: true
                    onTriggered: parent.text = new Date().toLocaleTimeString()
                }
            }
        }
    }
    
    // Main content area
    Rectangle {
        anchors.top: topBar.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        color: "#0a0a0a"
        
        // Page loader
        Loader {
            id: pageLoader
            anchors.fill: parent
            anchors.margins: 10
            
            source: {
                switch(currentPage) {
                    case "dashboard": return "DashboardPage.qml"
                    case "portfolio": return "PortfolioPage.qml"
                    case "ml": return "MLPage.qml"
                    case "grok": return "GrokPage.qml"
                    case "trading": return "TradingPage.qml"
                    case "settings": return "SettingsPage.qml"
                    default: return "DashboardPage.qml"
                }
            }
            
            onStatusChanged: {
                if (status === Loader.Error) {
                    console.log("Failed to load page:", source)
                    // Fallback to inline dashboard
                    sourceComponent: dashboardComponent
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
                    spacing: 20
                    
                    // Portfolio overview
                    Rectangle {
                        width: parent.width
                        height: 200
                        color: surfaceColor
                        border.color: primaryColor
                        border.width: 2
                        radius: 10
                        
                        Column {
                            anchors.fill: parent
                            anchors.margins: 20
                            spacing: 15
                            
                            Text {
                                text: "📊 PORTFOLIO OVERVIEW"
                                font.pixelSize: 20
                                color: primaryColor
                                font.bold: true
                            }
                            
                            Row {
                                spacing: 40
                                
                                Column {
                                    Text { text: "Portfolio Value"; color: "#ffffff"; font.pixelSize: 14 }
                                    Text { text: "$109,329.05"; color: successColor; font.pixelSize: 24; font.bold: true }
                                }
                                
                                Column {
                                    Text { text: "Daily P&L"; color: "#ffffff"; font.pixelSize: 14 }
                                    Text { text: "+$2,340.80"; color: successColor; font.pixelSize: 24; font.bold: true }
                                }
                                
                                Column {
                                    Text { text: "Buying Power"; color: "#ffffff"; font.pixelSize: 14 }
                                    Text { text: "$45,680.75"; color: warningColor; font.pixelSize: 24; font.bold: true }
                                }
                                
                                Column {
                                    Text { text: "Win Rate"; color: "#ffffff"; font.pixelSize: 14 }
                                    Text { text: "87.3%"; color: successColor; font.pixelSize: 24; font.bold: true }
                                }
                            }
                        }
                    }
                    
                    // Top stocks grid
                    Rectangle {
                        width: parent.width
                        height: 300
                        color: surfaceColor
                        border.color: accentColor
                        border.width: 2
                        radius: 10
                        
                        Column {
                            anchors.fill: parent
                            anchors.margins: 20
                            spacing: 15
                            
                            Text {
                                text: "📈 TOP STOCKS WATCHLIST"
                                font.pixelSize: 18
                                color: accentColor
                                font.bold: true
                            }
                            
                            Grid {
                                columns: 5
                                spacing: 15
                                
                                // Stock items
                                Repeater {
                                    model: [
                                        {symbol: "AAPL", price: "$234.10", change: "+1.2%", color: successColor},
                                        {symbol: "NVDA", price: "$1,185.20", change: "+5.7%", color: successColor},
                                        {symbol: "MSFT", price: "$420.50", change: "-0.8%", color: secondaryColor},
                                        {symbol: "GOOGL", price: "$167.89", change: "+2.1%", color: successColor},
                                        {symbol: "TSLA", price: "$267.85", change: "+3.4%", color: successColor},
                                        {symbol: "AMZN", price: "$189.42", change: "+0.9%", color: successColor},
                                        {symbol: "META", price: "$563.27", change: "-1.5%", color: secondaryColor},
                                        {symbol: "NFLX", price: "$445.03", change: "+2.8%", color: successColor},
                                        {symbol: "AMD", price: "$157.34", change: "+4.2%", color: successColor},
                                        {symbol: "COIN", price: "$198.76", change: "+6.1%", color: successColor}
                                    ]
                                    
                                    Rectangle {
                                        width: 100
                                        height: 60
                                        color: "#1a1a1a"
                                        border.color: modelData.color
                                        border.width: 1
                                        radius: 5
                                        
                                        Column {
                                            anchors.centerIn: parent
                                            spacing: 2
                                            
                                            Text {
                                                text: modelData.symbol
                                                color: primaryColor
                                                font.pixelSize: 12
                                                font.bold: true
                                                anchors.horizontalCenter: parent.horizontalCenter
                                            }
                                            
                                            Text {
                                                text: modelData.price
                                                color: "#ffffff"
                                                font.pixelSize: 10
                                                anchors.horizontalCenter: parent.horizontalCenter
                                            }
                                            
                                            Text {
                                                text: modelData.change
                                                color: modelData.color
                                                font.pixelSize: 9
                                                font.bold: true
                                                anchors.horizontalCenter: parent.horizontalCenter
                                            }
                                        }
                                        
                                        MouseArea {
                                            anchors.fill: parent
                                            onClicked: {
                                                console.log("Selected:", modelData.symbol)
                                                // Add stock selection logic
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    // Quick actions
                    Rectangle {
                        width: parent.width
                        height: 100
                        color: surfaceColor
                        border.color: primaryColor
                        border.width: 1
                        radius: 10
                        
                        Row {
                            anchors.centerIn: parent
                            spacing: 20
                            
                            Button {
                                text: "🔄 Refresh All Data"
                                onClicked: {
                                    redis.getPortfolioData()
                                    redis.getAlpacaAccount()
                                    redis.getGrokRecommendations()
                                }
                                background: Rectangle {
                                    color: primaryColor
                                    radius: 5
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
                                text: "🤖 Train ML Models"
                                onClicked: redis.triggerMLTraining()
                                background: Rectangle {
                                    color: secondaryColor
                                    radius: 5
                                }
                                contentItem: Text {
                                    text: parent.text
                                    color: "#ffffff"
                                    font.bold: true
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                            }
                            
                            Button {
                                text: "📊 Get Predictions"
                                onClicked: redis.getPredictionMetrics()
                                background: Rectangle {
                                    color: accentColor
                                    radius: 5
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
                                text: "⚙️ Settings"
                                onClicked: currentPage = "settings"
                                background: Rectangle {
                                    color: warningColor
                                    radius: 5
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
    }
}