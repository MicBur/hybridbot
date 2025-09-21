import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtCharts 2.15
import QtQuick.Controls.Material 2.15

ApplicationWindow {
    id: window
    width: 1400
    height: 900
    visible: true
    title: "6bot - Premium Trading Suite"
    
    property color primaryAccent: "#00ffff"
    property color secondaryAccent: "#ff6b6b"
    property color tertiaryAccent: "#4ecdc4"
    
    Material.theme: Material.Dark
    Material.accent: primaryAccent
    
    // Portfolio data properties
    property var portfolioData: ({})
    property var alpacaAccount: ({})
    property var marketData: ({})
    property var grokRecommendations: []
    property var deepSearchData: []
    property var topStocksData: ({})
    property var mlStatus: ({})
    property var systemStatus: ({})
    property var predictionMetrics: ({})
    
    // Connection to Redis data
    Connections {
        target: redisClient
        function onDataReceived(key, data) {
            console.log("Received data for key:", key, JSON.stringify(data))
            
            if (key === "alpaca_account" || key.indexOf("alpaca_account") >= 0) {
                alpacaAccount = data
                updatePortfolioMetrics()
            } else if (key === "market_data" || key.indexOf("market_data") >= 0) {
                marketData = data
                updateMarketCharts()
            } else if (key === "grok_top10" || key.indexOf("grok_top10") >= 0) {
                if (Array.isArray(data)) {
                    grokRecommendations = data
                } else {
                    grokRecommendations = []
                }
            } else if (key === "grok_deepersearch" || key.indexOf("grok_deepersearch") >= 0) {
                if (Array.isArray(data)) {
                    deepSearchData = data
                } else {
                    deepSearchData = []
                }
            } else if (key === "grok_topstocks_prediction" || key.indexOf("grok_topstocks") >= 0) {
                topStocksData = data
            } else if (key === "ml_status" || key.indexOf("ml_status") >= 0) {
                mlStatus = data
                updateMLMetrics()
            } else if (key === "system_status" || key.indexOf("system_status") >= 0) {
                systemStatus = data
            } else if (key === "prediction_quality_metrics" || key.indexOf("prediction_quality_metrics") >= 0) {
                predictionMetrics = data
            }
        }
    }
    
    function updatePortfolioMetrics() {
        if (alpacaAccount.portfolio_value) {
            portfolioValueTile.value = "$" + Number(alpacaAccount.portfolio_value).toLocaleString()
        }
        if (alpacaAccount.buying_power) {
            buyingPowerTile.value = "$" + Number(alpacaAccount.buying_power).toLocaleString()
        }
        if (alpacaAccount.daytrade_count) {
            dayTradesTile.value = alpacaAccount.daytrade_count.toString()
        }
    }
    
    function updateMLMetrics() {
        if (mlStatus.model_accuracy) {
            mlAccuracyTile.value = Math.round(mlStatus.model_accuracy * 100) + "%"
        }
        if (mlStatus.training_active) {
            mlAccuracyTile.change = "Training..."
        } else {
            mlAccuracyTile.change = "Model Score"
        }
    }
    
    function updateMarketCharts() {
        // Update chart data with real market data
        console.log("Updating charts with market data")
    }
    
    Rectangle {
        anchors.fill: parent
        color: "#0a0a0a"
        
        // Dynamic background grid
        Canvas {
            id: gridCanvas
            anchors.fill: parent
            
            property real animationOffset: 0
            
            onPaint: {
                var ctx = getContext("2d")
                ctx.clearRect(0, 0, width, height)
                
                ctx.strokeStyle = Qt.rgba(0, 1, 1, 0.1)
                ctx.lineWidth = 1
                
                var gridSize = 50
                var offsetX = animationOffset % gridSize
                var offsetY = animationOffset % gridSize
                
                // Vertical lines
                for (var x = offsetX; x < width; x += gridSize) {
                    ctx.beginPath()
                    ctx.moveTo(x, 0)
                    ctx.lineTo(x, height)
                    ctx.stroke()
                }
                
                // Horizontal lines  
                for (var y = offsetY; y < height; y += gridSize) {
                    ctx.beginPath()
                    ctx.moveTo(0, y)
                    ctx.lineTo(width, y)
                    ctx.stroke()
                }
            }
            
            NumberAnimation {
                target: window
                property: "animationOffset"
                from: 0
                to: 50
                duration: 5000
                loops: Animation.Infinite
                running: true
            }
            
            // Timer to trigger canvas repaints
            Timer {
                interval: 50
                running: true
                repeat: true
                onTriggered: gridCanvas.requestPaint()
            }
        }
        
        // Header bar
        Rectangle {
            id: headerBar
            width: parent.width
            height: 80
            color: Qt.rgba(0, 0, 0, 0.8)
            border.width: 1
            border.color: primaryAccent
            
            Row {
                anchors.left: parent.left
                anchors.leftMargin: 30
                anchors.verticalCenter: parent.verticalCenter
                spacing: 30
                
                Text {
                    text: "6BOT PREMIUM"
                    color: "#ffffff"
                    font.pixelSize: 24
                    font.weight: Font.Bold
                    font.family: "Arial"
                    anchors.verticalCenter: parent.verticalCenter
                }
                
                Rectangle {
                    width: 2
                    height: 40
                    color: primaryAccent
                    anchors.verticalCenter: parent.verticalCenter
                }
                
                Text {
                    text: "ADVANCED TRADING ANALYTICS"
                    color: primaryAccent
                    font.pixelSize: 14
                    font.family: "Arial"
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
            
            Row {
                anchors.right: parent.right
                anchors.rightMargin: 30
                anchors.verticalCenter: parent.verticalCenter
                spacing: 15
                
                Text {
                    text: "CONNECTED"
                    color: "#00ff00"
                    font.pixelSize: 12
                    font.weight: Font.Bold
                    anchors.verticalCenter: parent.verticalCenter
                }
                
                Rectangle {
                    width: 12
                    height: 12
                    radius: 6
                    color: "#00ff00"
                    anchors.verticalCenter: parent.verticalCenter
                    
                    SequentialAnimation on opacity {
                        loops: Animation.Infinite
                        running: true
                        NumberAnimation { to: 0.3; duration: 1000 }
                        NumberAnimation { to: 1.0; duration: 1000 }
                    }
                }
            }
        }
        
        // Main content area
        Item {
            anchors.top: headerBar.bottom
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 20
            
            // Top metrics row
            Row {
                id: metricsRow
                anchors.top: parent.top
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 30
                
                PremiumTile {
                    id: portfolioValueTile
                    width: 200
                    height: 120
                    title: "PORTFOLIO VALUE"
                    value: "$125,430.50"
                    change: "ALPACA"
                }
                
                PremiumTile {
                    id: buyingPowerTile
                    width: 200
                    height: 120
                    title: "BUYING POWER"
                    value: "$25,000.00"
                    change: "Available"
                    accentColor: "#00ff00"
                }
                
                PremiumTile {
                    id: dayTradesTile
                    width: 200
                    height: 120
                    title: "DAY TRADES"
                    value: "2"
                    change: "Used Today"
                    accentColor: secondaryAccent
                }
                
                PremiumTile {
                    id: mlAccuracyTile
                    width: 200
                    height: 120
                    title: "ML ACCURACY"
                    value: "87%"
                    change: "Model Score"
                    accentColor: tertiaryAccent
                }
            }
            
            // Main dashboard area
            Row {
                anchors.top: metricsRow.bottom
                anchors.topMargin: 30
                anchors.left: parent.left
                anchors.right: parent.right
                spacing: 20
                
                // Left column - Charts
                Column {
                    width: (parent.width - parent.spacing) * 0.7
                    spacing: 20
                    
                    // Market chart
                    Rectangle {
                        width: parent.width
                        height: 300
                        color: Qt.rgba(0, 0, 0, 0.3)
                        border.width: 1
                        border.color: primaryAccent
                        radius: 15
                        
                        ChartView {
                            anchors.fill: parent
                            anchors.margins: 15
                            backgroundColor: "transparent"
                            theme: ChartView.ChartThemeDark
                            legend.visible: false
                            
                            LineSeries {
                                id: aaplSeries
                                name: "AAPL"
                                color: primaryAccent
                                width: 3
                                
                                XYPoint { x: 0; y: 234.10 }
                                XYPoint { x: 1; y: 235.20 }
                                XYPoint { x: 2; y: 233.80 }
                                XYPoint { x: 3; y: 236.50 }
                                XYPoint { x: 4; y: 235.90 }
                                XYPoint { x: 5; y: 237.20 }
                                XYPoint { x: 6; y: 236.80 }
                                XYPoint { x: 7; y: 238.10 }
                            }
                            
                            LineSeries {
                                id: nvidaSeries
                                name: "NVDA"
                                color: secondaryAccent
                                width: 2
                                
                                XYPoint { x: 0; y: 1185.20 }
                                XYPoint { x: 1; y: 1195.50 }
                                XYPoint { x: 2; y: 1178.80 }
                                XYPoint { x: 3; y: 1205.20 }
                                XYPoint { x: 4; y: 1198.80 }
                                XYPoint { x: 5; y: 1212.10 }
                                XYPoint { x: 6; y: 1206.65 }
                                XYPoint { x: 7; y: 1220.90 }
                            }
                            
                            LineSeries {
                                id: msftSeries
                                name: "MSFT"
                                color: tertiaryAccent
                                width: 2
                                
                                XYPoint { x: 0; y: 420.50 }
                                XYPoint { x: 1; y: 422.30 }
                                XYPoint { x: 2; y: 418.90 }
                                XYPoint { x: 3; y: 425.10 }
                                XYPoint { x: 4; y: 423.80 }
                                XYPoint { x: 5; y: 427.60 }
                                XYPoint { x: 6; y: 426.20 }
                                XYPoint { x: 7; y: 429.40 }
                            }
                        }
                        
                        Text {
                            text: "US STOCK MARKET DATA - AAPL, NVDA, MSFT"
                            color: primaryAccent
                            font.pixelSize: 14
                            font.weight: Font.Bold
                            anchors.top: parent.top
                            anchors.topMargin: 10
                            anchors.left: parent.left
                            anchors.leftMargin: 20
                        }
                    }
                    
                    // ML Status Panel
                    MLStatusPanel {
                        id: mlStatusPanel
                        width: parent.width
                        mlStatus: window.mlStatus
                        predictionMetrics: window.predictionMetrics || {}
                    }
                }
                
                // Right column - Grok Recommendations
                Column {
                    width: (parent.width - parent.spacing) * 0.3
                    spacing: 20
                    
                    GrokRecommendations {
                        id: grokPanel
                        width: parent.width
                        grokData: window.grokRecommendations
                        deepSearchData: window.deepSearchData || []
                        topStocksData: window.topStocksData || {}
                    }
                    
                    // Control buttons
                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 10
                        
                        HologramButton {
                            width: 140
                            height: 60
                            title: "ML TRAINING"
                            subtitle: "Start Model"
                            accentColor: primaryAccent
                            
                            onClicked: {
                                if (redisClient) {
                                    redisClient.triggerMLTraining()
                                    console.log("ML Training triggered")
                                }
                            }
                        }
                        
                        HologramButton {
                            width: 140
                            height: 60
                            title: "GROK FETCH"
                            subtitle: "Get Stocks"
                            accentColor: secondaryAccent
                            
                            onClicked: {
                                if (redisClient) {
                                    redisClient.triggerGrokFetch()
                                    console.log("Grok fetch triggered")
                                }
                            }
                        }
                    }
                }
            }
        }
        
        // Holographic scan line overlay
        Rectangle {
            id: hologramScan
            width: parent.width
            height: 3
            color: primaryAccent
            opacity: 0.4
            y: -height
            
            gradient: Gradient {
                GradientStop { position: 0.0; color: "transparent" }
                GradientStop { position: 0.5; color: primaryAccent }
                GradientStop { position: 1.0; color: "transparent" }
            }
            
            SequentialAnimation on y {
                loops: Animation.Infinite
                running: true
                NumberAnimation { 
                    to: parent.height + hologramScan.height
                    duration: 8000
                    easing.type: Easing.InOutQuad
                }
                PropertyAction { value: -hologramScan.height }
                PauseAnimation { duration: 3000 }
            }
        }
    }
}