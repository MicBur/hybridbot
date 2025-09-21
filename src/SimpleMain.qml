import QtQuick 2.15
import QtQuick.Controls 2.15
import Redis 1.0

ApplicationWindow {
    id: window
    visible: true
    width: 1200
    height: 800
    title: "6bot - Portfolio Dashboard"
    
    // Dark theme
    color: "#1a1a1a"
    
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
                statusText.text = "✅ Redis Connected - Ready for Portfolio Data"
                statusText.color = "#00ff00"
                // Start getting data
                getPortfolioData()
                getAlpacaAccount()
                getGrokRecommendations()
            } else {
                statusText.text = "❌ Redis Disconnected"
                statusText.color = "#ff0000"
            }
        }
    }
    
    // Timer for periodic data updates
    Timer {
        interval: 5000
        running: true
        repeat: true
        onTriggered: {
            if (redis.connected) {
                redis.getPortfolioData()
                redis.getAlpacaAccount()
            }
        }
    }
    
    // Main content
    Rectangle {
        anchors.fill: parent
        color: "#1a1a1a"
        
        Column {
            anchors.centerIn: parent
            spacing: 30
            
            // Header
            Text {
                text: "6bot Premium Portfolio Dashboard"
                font.pixelSize: 32
                font.bold: true
                color: "#00ffff"
                anchors.horizontalCenter: parent.horizontalCenter
            }
            
            // Status indicator
            Text {
                id: statusText
                text: "🔄 Connecting to Redis..."
                font.pixelSize: 18
                color: "#ffff00"
                anchors.horizontalCenter: parent.horizontalCenter
            }
            
            // Main dashboard grid
            Row {
                spacing: 20
                
                // Left column - Portfolio and Charts
                Column {
                    spacing: 20
                    
                    // Portfolio info section
                    Rectangle {
                        width: 600
                        height: 300
                        color: "#2a2a2a"
                        border.color: "#00ffff"
                        border.width: 2
                        radius: 10
                        
                        Column {
                            anchors.fill: parent
                            anchors.margins: 20
                            spacing: 15
                            
                            Text {
                                text: "📊 PORTFOLIO OVERVIEW"
                                font.pixelSize: 20
                                font.bold: true
                                color: "#00ffff"
                            }
                            
                            Row {
                                spacing: 30
                                
                                // Portfolio Value
                                Column {
                                    spacing: 8
                                    
                                    Text {
                                        text: "Portfolio Value"
                                        font.pixelSize: 14
                                        color: "#ffffff"
                                    }
                                    
                                    Text {
                                        id: portfolioValue
                                        text: "$109,329.05"
                                        font.pixelSize: 24
                                        font.bold: true
                                        color: "#00ff00"
                                    }
                                }
                                
                                // Buying Power
                                Column {
                                    spacing: 8
                                    
                                    Text {
                                        text: "Buying Power"
                                        font.pixelSize: 14
                                        color: "#ffffff"
                                    }
                                    
                                    Text {
                                        id: buyingPower
                                        text: "$45,680.75"
                                        font.pixelSize: 24
                                        font.bold: true
                                        color: "#ffff00"
                                    }
                                }
                                
                                // P&L Today
                                Column {
                                    spacing: 8
                                    
                                    Text {
                                        text: "P&L Today"
                                        font.pixelSize: 14
                                        color: "#ffffff"
                                    }
                                    
                                    Text {
                                        id: dailyPL
                                        text: "+$2,340.80"
                                        font.pixelSize: 24
                                        font.bold: true
                                        color: "#00ff00"
                                    }
                                }
                            }
                            
                            // Stock prices row
                            Row {
                                spacing: 25
                                
                                Column {
                                    Text {
                                        text: "AAPL"
                                        font.pixelSize: 12
                                        color: "#00ffff"
                                        font.bold: true
                                    }
                                    Text {
                                        text: "$234.10"
                                        font.pixelSize: 16
                                        color: "#00ff00"
                                    }
                                }
                                
                                Column {
                                    Text {
                                        text: "NVDA"
                                        font.pixelSize: 12
                                        color: "#00ffff"
                                        font.bold: true
                                    }
                                    Text {
                                        text: "$1,185.20"
                                        font.pixelSize: 16
                                        color: "#00ff00"
                                    }
                                }
                                
                                Column {
                                    Text {
                                        text: "MSFT"
                                        font.pixelSize: 12
                                        color: "#00ffff"
                                        font.bold: true
                                    }
                                    Text {
                                        text: "$420.50"
                                        font.pixelSize: 16
                                        color: "#ff6b6b"
                                    }
                                }
                                
                                Column {
                                    Text {
                                        text: "TSLA"
                                        font.pixelSize: 12
                                        color: "#00ffff"
                                        font.bold: true
                                    }
                                    Text {
                                        text: "$267.85"
                                        font.pixelSize: 16
                                        color: "#00ff00"
                                    }
                                }
                            }
                        }
                    }
                    
                    // Simple Chart Visualization
                    Rectangle {
                        width: 600
                        height: 250
                        color: "#2a2a2a"
                        border.color: "#00ffff"
                        border.width: 2
                        radius: 10
                        
                        Column {
                            anchors.fill: parent
                            anchors.margins: 20
                            spacing: 15
                            
                            Text {
                                text: "📈 MARKET TRENDS"
                                font.pixelSize: 18
                                font.bold: true
                                color: "#00ffff"
                            }
                            
                            // Simple ASCII-style chart
                            Rectangle {
                                width: parent.width
                                height: 180
                                color: "#1a1a1a"
                                border.color: "#333333"
                                border.width: 1
                                
                                Canvas {
                                    id: chartCanvas
                                    anchors.fill: parent
                                    
                                    property var stockPrices: [234.10, 238.50, 235.20, 240.15, 243.80, 241.30, 245.90]
                                    
                                    onPaint: {
                                        var ctx = getContext("2d")
                                        ctx.clearRect(0, 0, width, height)
                                        
                                        // Draw grid
                                        ctx.strokeStyle = "#333333"
                                        ctx.lineWidth = 1
                                        
                                        // Vertical lines
                                        for (var x = 0; x < width; x += 50) {
                                            ctx.beginPath()
                                            ctx.moveTo(x, 0)
                                            ctx.lineTo(x, height)
                                            ctx.stroke()
                                        }
                                        
                                        // Horizontal lines
                                        for (var y = 0; y < height; y += 30) {
                                            ctx.beginPath()
                                            ctx.moveTo(0, y)
                                            ctx.lineTo(width, y)
                                            ctx.stroke()
                                        }
                                        
                                        // Draw chart line
                                        ctx.strokeStyle = "#00ffff"
                                        ctx.lineWidth = 3
                                        ctx.beginPath()
                                        
                                        var stepX = width / (stockPrices.length - 1)
                                        for (var i = 0; i < stockPrices.length; i++) {
                                            var x = i * stepX
                                            var y = height - (stockPrices[i] - 230) * 10
                                            
                                            if (i === 0) {
                                                ctx.moveTo(x, y)
                                            } else {
                                                ctx.lineTo(x, y)
                                            }
                                        }
                                        ctx.stroke()
                                        
                                        // Draw points
                                        ctx.fillStyle = "#00ff00"
                                        for (var j = 0; j < stockPrices.length; j++) {
                                            var px = j * stepX
                                            var py = height - (stockPrices[j] - 230) * 10
                                            ctx.beginPath()
                                            ctx.arc(px, py, 4, 0, 2 * Math.PI)
                                            ctx.fill()
                                        }
                                    }
                                    
                                    Timer {
                                        interval: 2000
                                        running: true
                                        repeat: true
                                        onTriggered: {
                                            // Simulate price updates
                                            for (var i = 0; i < chartCanvas.stockPrices.length; i++) {
                                                chartCanvas.stockPrices[i] += (Math.random() - 0.5) * 2
                                            }
                                            chartCanvas.requestPaint()
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
                // Right column - ML Status and Grok Recommendations
                Column {
                    spacing: 20
                    
                    // ML Status Panel
                    Rectangle {
                        width: 400
                        height: 280
                        color: "#2a2a2a"
                        border.color: "#ff6b6b"
                        border.width: 2
                        radius: 10
                        
                        Column {
                            anchors.fill: parent
                            anchors.margins: 20
                            spacing: 15
                            
                            Text {
                                text: "🤖 ML MODEL STATUS"
                                font.pixelSize: 18
                                font.bold: true
                                color: "#ff6b6b"
                            }
                            
                            Row {
                                spacing: 20
                                
                                Column {
                                    spacing: 10
                                    
                                    Text {
                                        text: "Training Status"
                                        font.pixelSize: 14
                                        color: "#ffffff"
                                    }
                                    
                                    Rectangle {
                                        width: 20
                                        height: 20
                                        radius: 10
                                        color: "#00ff00"
                                        
                                        SequentialAnimation on opacity {
                                            loops: Animation.Infinite
                                            NumberAnimation { to: 0.3; duration: 1000 }
                                            NumberAnimation { to: 1.0; duration: 1000 }
                                        }
                                    }
                                    
                                    Text {
                                        text: "ACTIVE"
                                        font.pixelSize: 12
                                        color: "#00ff00"
                                        font.bold: true
                                    }
                                }
                                
                                Column {
                                    spacing: 8
                                    
                                    Text {
                                        text: "Model Accuracy"
                                        font.pixelSize: 14
                                        color: "#ffffff"
                                    }
                                    
                                    Text {
                                        text: "87.3%"
                                        font.pixelSize: 20
                                        color: "#00ff00"
                                        font.bold: true
                                    }
                                }
                            }
                            
                            Text {
                                text: "Prediction Horizons:"
                                font.pixelSize: 14
                                color: "#ffffff"
                                font.bold: true
                            }
                            
                            Column {
                                spacing: 5
                                
                                Row {
                                    spacing: 10
                                    Text { text: "15min:"; color: "#cccccc"; font.pixelSize: 12 }
                                    Text { text: "MAE 0.023"; color: "#00ff00"; font.pixelSize: 12 }
                                }
                                
                                Row {
                                    spacing: 10
                                    Text { text: "30min:"; color: "#cccccc"; font.pixelSize: 12 }
                                    Text { text: "MAE 0.035"; color: "#ffff00"; font.pixelSize: 12 }
                                }
                                
                                Row {
                                    spacing: 10
                                    Text { text: "60min:"; color: "#cccccc"; font.pixelSize: 12 }
                                    Text { text: "MAE 0.048"; color: "#ff6b6b"; font.pixelSize: 12 }
                                }
                            }
                            
                            Text {
                                text: "Next Training: 14:30 UTC"
                                font.pixelSize: 12
                                color: "#cccccc"
                            }
                        }
                    }
                    
                    // Grok Recommendations
                    Rectangle {
                        width: 400
                        height: 270
                        color: "#2a2a2a"
                        border.color: "#4ecdc4"
                        border.width: 2
                        radius: 10
                        
                        Column {
                            anchors.fill: parent
                            anchors.margins: 20
                            spacing: 10
                            
                            Text {
                                text: "🎯 GROK AI EMPFEHLUNGEN"
                                font.pixelSize: 16
                                font.bold: true
                                color: "#4ecdc4"
                            }
                            
                            ScrollView {
                                width: parent.width
                                height: 200
                                
                                Column {
                                    spacing: 8
                                    width: parent.width
                                    
                                    Rectangle {
                                        width: parent.width
                                        height: 50
                                        color: "#1a1a1a"
                                        border.color: "#00ff00"
                                        border.width: 1
                                        radius: 5
                                        
                                        Row {
                                            anchors.verticalCenter: parent.verticalCenter
                                            anchors.left: parent.left
                                            anchors.leftMargin: 10
                                            spacing: 15
                                            
                                            Text {
                                                text: "NVDA"
                                                font.pixelSize: 14
                                                color: "#00ffff"
                                                font.bold: true
                                            }
                                            
                                            Rectangle {
                                                width: 60
                                                height: 20
                                                color: "#00ff00"
                                                radius: 10
                                                
                                                Text {
                                                    anchors.centerIn: parent
                                                    text: "90%"
                                                    font.pixelSize: 10
                                                    color: "#000000"
                                                    font.bold: true
                                                }
                                            }
                                            
                                            Text {
                                                text: "GPU KI-Boom"
                                                font.pixelSize: 10
                                                color: "#ffffff"
                                                width: 200
                                                wrapMode: Text.WordWrap
                                            }
                                        }
                                    }
                                    
                                    Rectangle {
                                        width: parent.width
                                        height: 50
                                        color: "#1a1a1a"
                                        border.color: "#00ff00"
                                        border.width: 1
                                        radius: 5
                                        
                                        Row {
                                            anchors.verticalCenter: parent.verticalCenter
                                            anchors.left: parent.left
                                            anchors.leftMargin: 10
                                            spacing: 15
                                            
                                            Text {
                                                text: "AAPL"
                                                font.pixelSize: 14
                                                color: "#00ffff"
                                                font.bold: true
                                            }
                                            
                                            Rectangle {
                                                width: 60
                                                height: 20
                                                color: "#ccff00"
                                                radius: 10
                                                
                                                Text {
                                                    anchors.centerIn: parent
                                                    text: "85%"
                                                    font.pixelSize: 10
                                                    color: "#000000"
                                                    font.bold: true
                                                }
                                            }
                                            
                                            Text {
                                                text: "iPhone Verkäufe"
                                                font.pixelSize: 10
                                                color: "#ffffff"
                                                width: 200
                                                wrapMode: Text.WordWrap
                                            }
                                        }
                                    }
                                    
                                    Rectangle {
                                        width: parent.width
                                        height: 50
                                        color: "#1a1a1a"
                                        border.color: "#ffff00"
                                        border.width: 1
                                        radius: 5
                                        
                                        Row {
                                            anchors.verticalCenter: parent.verticalCenter
                                            anchors.left: parent.left
                                            anchors.leftMargin: 10
                                            spacing: 15
                                            
                                            Text {
                                                text: "MSFT"
                                                font.pixelSize: 14
                                                color: "#00ffff"
                                                font.bold: true
                                            }
                                            
                                            Rectangle {
                                                width: 60
                                                height: 20
                                                color: "#ffff00"
                                                radius: 10
                                                
                                                Text {
                                                    anchors.centerIn: parent
                                                    text: "78%"
                                                    font.pixelSize: 10
                                                    color: "#000000"
                                                    font.bold: true
                                                }
                                            }
                                            
                                            Text {
                                                text: "Azure Cloud Wachstum"
                                                font.pixelSize: 10
                                                color: "#ffffff"
                                                width: 200
                                                wrapMode: Text.WordWrap
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            // Action buttons
            Row {
                spacing: 20
                anchors.horizontalCenter: parent.horizontalCenter
                
                Button {
                    text: "🔄 Refresh Data"
                    font.pixelSize: 16
                    onClicked: {
                        redis.getPortfolioData()
                        redis.getAlpacaAccount()
                        redis.getGrokRecommendations()
                    }
                    
                    background: Rectangle {
                        color: "#00ffff"
                        radius: 5
                    }
                }
                
                Button {
                    text: "📈 Get ML Status"
                    font.pixelSize: 16
                    onClicked: redis.getMLStatus()
                    
                    background: Rectangle {
                        color: "#ff6b6b"
                        radius: 5
                    }
                }
                
                Button {
                    text: "🎯 Trigger Training"
                    font.pixelSize: 16
                    onClicked: redis.triggerMLTraining()
                    
                    background: Rectangle {
                        color: "#4ecdc4"
                        radius: 5
                    }
                }
            }
        }
    }
}