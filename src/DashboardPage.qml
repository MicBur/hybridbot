import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    id: dashboardPage
    anchors.fill: parent
    
    property real portfolioValue: 109329.05
    property real dayChange: 2847.23
    property real dayChangePercent: 2.67
    
    Column {
        width: parent.width
        spacing: 20
        
        // Page header
        Text {
            text: "🏠 DASHBOARD OVERVIEW"
            font.pixelSize: 28
            font.bold: true
            color: window.primaryColor
        }
        
        // Key Metrics Row
        Row {
            width: parent.width
            spacing: 15
            
            Rectangle {
                width: (parent.width - 60) / 4
                height: 120
                color: window.surfaceColor
                border.color: window.primaryColor
                border.width: 2
                radius: 10
                
                Column {
                    anchors.centerIn: parent
                    spacing: 5
                    
                    Text {
                        text: "💼 Portfolio Value"
                        color: "#cccccc"
                        font.pixelSize: 10
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    
                    Text {
                        text: "$" + portfolioValue.toLocaleString(Qt.locale("en_US"), "f", 2)
                        color: window.primaryColor
                        font.pixelSize: 18
                        font.bold: true
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    
                    Text {
                        text: (dayChange >= 0 ? "+" : "") + "$" + dayChange.toLocaleString(Qt.locale("en_US"), "f", 2) + 
                              " (" + (dayChange >= 0 ? "+" : "") + dayChangePercent.toFixed(2) + "%)"
                        color: dayChange >= 0 ? window.successColor : window.dangerColor
                        font.pixelSize: 10
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }
            }
            
            Rectangle {
                width: (parent.width - 60) / 4
                height: 120
                color: window.surfaceColor
                border.color: window.successColor
                border.width: 2
                radius: 10
                
                Column {
                    anchors.centerIn: parent
                    spacing: 5
                    
                    Text {
                        text: "🤖 ML Accuracy"
                        color: "#cccccc"
                        font.pixelSize: 10
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    
                    Text {
                        text: "87.3%"
                        color: window.successColor
                        font.pixelSize: 22
                        font.bold: true
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    
                    Text {
                        text: "Last 1000 predictions"
                        color: "#cccccc"
                        font.pixelSize: 8
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }
            }
            
            Rectangle {
                width: (parent.width - 60) / 4
                height: 120
                color: window.surfaceColor
                border.color: window.warningColor
                border.width: 2
                radius: 10
                
                Column {
                    anchors.centerIn: parent
                    spacing: 5
                    
                    Text {
                        text: "🎯 Grok Signals"
                        color: "#cccccc"
                        font.pixelSize: 10
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    
                    Text {
                        text: "8"
                        color: window.warningColor
                        font.pixelSize: 22
                        font.bold: true
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    
                    Text {
                        text: "Active recommendations"
                        color: "#cccccc"
                        font.pixelSize: 8
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }
            }
            
            Rectangle {
                width: (parent.width - 60) / 4
                height: 120
                color: window.surfaceColor
                border.color: window.secondaryColor
                border.width: 2
                radius: 10
                
                Column {
                    anchors.centerIn: parent
                    spacing: 5
                    
                    Text {
                        text: "📊 Open Positions"
                        color: "#cccccc"
                        font.pixelSize: 10
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    
                    Text {
                        text: "17"
                        color: window.secondaryColor
                        font.pixelSize: 22
                        font.bold: true
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    
                    Text {
                        text: "Active trades"
                        color: "#cccccc"
                        font.pixelSize: 8
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }
            }
        }
        
        // Charts and Analysis Row
        Row {
            width: parent.width
            spacing: 20
            
            // Portfolio Performance Chart
            Rectangle {
                width: (parent.width - 20) / 2
                height: 300
                color: window.surfaceColor
                border.color: window.primaryColor
                border.width: 2
                radius: 10
                
                Column {
                    anchors.fill: parent
                    anchors.margins: 15
                    spacing: 10
                    
                    Text {
                        text: "📈 PORTFOLIO PERFORMANCE (7D)"
                        color: window.primaryColor
                        font.pixelSize: 14
                        font.bold: true
                    }
                    
                    Canvas {
                        id: performanceChart
                        width: parent.width
                        height: 250
                        
                        property var dataPoints: [
                            106482, 107125, 108374, 107923, 109156, 108674, 109329
                        ]
                        
                        onPaint: {
                            var ctx = getContext("2d")
                            ctx.clearRect(0, 0, width, height)
                            
                            if (dataPoints.length < 2) return
                            
                            var margin = 30
                            var chartWidth = width - 2 * margin
                            var chartHeight = height - 2 * margin
                            
                            var minValue = Math.min(...dataPoints)
                            var maxValue = Math.max(...dataPoints)
                            var valueRange = maxValue - minValue
                            
                            // Draw grid
                            ctx.strokeStyle = "#333333"
                            ctx.lineWidth = 1
                            for (var i = 0; i <= 4; i++) {
                                var y = margin + (chartHeight / 4) * i
                                ctx.beginPath()
                                ctx.moveTo(margin, y)
                                ctx.lineTo(margin + chartWidth, y)
                                ctx.stroke()
                            }
                            
                            // Draw line
                            ctx.strokeStyle = window.primaryColor
                            ctx.lineWidth = 3
                            ctx.beginPath()
                            
                            for (var i = 0; i < dataPoints.length; i++) {
                                var x = margin + (chartWidth / (dataPoints.length - 1)) * i
                                var y = margin + chartHeight - ((dataPoints[i] - minValue) / valueRange) * chartHeight
                                
                                if (i === 0) {
                                    ctx.moveTo(x, y)
                                } else {
                                    ctx.lineTo(x, y)
                                }
                            }
                            ctx.stroke()
                            
                            // Fill area
                            ctx.fillStyle = window.primaryColor + "20"
                            ctx.lineTo(margin + chartWidth, margin + chartHeight)
                            ctx.lineTo(margin, margin + chartHeight)
                            ctx.closePath()
                            ctx.fill()
                        }
                    }
                }
            }
            
            // Top Holdings
            Rectangle {
                width: (parent.width - 20) / 2
                height: 300
                color: window.surfaceColor
                border.color: window.secondaryColor
                border.width: 2
                radius: 10
                
                Column {
                    anchors.fill: parent
                    anchors.margins: 15
                    spacing: 10
                    
                    Text {
                        text: "🏆 TOP HOLDINGS"
                        color: window.secondaryColor
                        font.pixelSize: 14
                        font.bold: true
                    }
                    
                    Column {
                        width: parent.width
                        spacing: 8
                        
                        Repeater {
                            model: [
                                { symbol: "NVDA", value: 29630, percent: 27.1, change: 5.7 },
                                { symbol: "MSFT", value: 30964, percent: 28.3, change: 2.1 },
                                { symbol: "META", value: 20238, percent: 18.5, change: 3.8 },
                                { symbol: "AAPL", value: 11705, percent: 10.7, change: 1.2 },
                                { symbol: "TSLA", value: 9950, percent: 9.1, change: -1.4 }
                            ]
                            
                            Rectangle {
                                width: parent.width
                                height: 40
                                color: index % 2 === 0 ? "#2a2a2a" : "#1a1a1a"
                                radius: 5
                                
                                Row {
                                    anchors.fill: parent
                                    anchors.margins: 10
                                    spacing: 15
                                    
                                    Text {
                                        text: modelData.symbol
                                        color: window.primaryColor
                                        font.pixelSize: 12
                                        font.bold: true
                                        width: 50
                                    }
                                    
                                    Text {
                                        text: "$" + modelData.value.toLocaleString()
                                        color: "#ffffff"
                                        font.pixelSize: 11
                                        width: 80
                                    }
                                    
                                    Text {
                                        text: modelData.percent.toFixed(1) + "%"
                                        color: "#cccccc"
                                        font.pixelSize: 11
                                        width: 50
                                    }
                                    
                                    Text {
                                        text: (modelData.change >= 0 ? "+" : "") + modelData.change.toFixed(1) + "%"
                                        color: modelData.change >= 0 ? window.successColor : window.dangerColor
                                        font.pixelSize: 11
                                        font.bold: true
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        
        // Quick Actions and Alerts
        Row {
            width: parent.width
            spacing: 20
            
            // Quick Actions
            Rectangle {
                width: (parent.width - 20) / 2
                height: 200
                color: window.surfaceColor
                border.color: window.accentColor
                border.width: 2
                radius: 10
                
                Column {
                    anchors.fill: parent
                    anchors.margins: 15
                    spacing: 15
                    
                    Text {
                        text: "⚡ QUICK ACTIONS"
                        color: window.accentColor
                        font.pixelSize: 14
                        font.bold: true
                    }
                    
                    Grid {
                        columns: 2
                        columnSpacing: 10
                        rowSpacing: 10
                        
                        Button {
                            text: "🛒 Quick Buy"
                            width: 140
                            height: 35
                            onClicked: console.log("Quick buy action")
                            background: Rectangle {
                                color: window.successColor
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
                            text: "💰 Quick Sell"
                            width: 140
                            height: 35
                            onClicked: console.log("Quick sell action")
                            background: Rectangle {
                                color: window.dangerColor
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
                            text: "🔄 Rebalance"
                            width: 140
                            height: 35
                            onClicked: console.log("Rebalance portfolio")
                            background: Rectangle {
                                color: window.primaryColor
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
                            text: "📊 Analyze"
                            width: 140
                            height: 35
                            onClicked: console.log("Run analysis")
                            background: Rectangle {
                                color: window.warningColor
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
            
            // System Alerts
            Rectangle {
                width: (parent.width - 20) / 2
                height: 200
                color: window.surfaceColor
                border.color: window.warningColor
                border.width: 2
                radius: 10
                
                Column {
                    anchors.fill: parent
                    anchors.margins: 15
                    spacing: 10
                    
                    Text {
                        text: "🚨 SYSTEM ALERTS"
                        color: window.warningColor
                        font.pixelSize: 14
                        font.bold: true
                    }
                    
                    ScrollView {
                        width: parent.width
                        height: 140
                        
                        Column {
                            width: parent.width
                            spacing: 8
                            
                            Rectangle {
                                width: parent.width
                                height: 30
                                color: "#2a2a2a"
                                border.color: window.successColor
                                border.width: 1
                                radius: 3
                                
                                Row {
                                    anchors.fill: parent
                                    anchors.margins: 8
                                    spacing: 10
                                    
                                    Rectangle {
                                        width: 8
                                        height: 8
                                        radius: 4
                                        color: window.successColor
                                    }
                                    
                                    Text {
                                        text: "NVDA target price reached: $1185"
                                        color: "#ffffff"
                                        font.pixelSize: 9
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                }
                            }
                            
                            Rectangle {
                                width: parent.width
                                height: 30
                                color: "#2a2a2a"
                                border.color: window.warningColor
                                border.width: 1
                                radius: 3
                                
                                Row {
                                    anchors.fill: parent
                                    anchors.margins: 8
                                    spacing: 10
                                    
                                    Rectangle {
                                        width: 8
                                        height: 8
                                        radius: 4
                                        color: window.warningColor
                                    }
                                    
                                    Text {
                                        text: "Portfolio risk level increased to MEDIUM"
                                        color: "#ffffff"
                                        font.pixelSize: 9
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                }
                            }
                            
                            Rectangle {
                                width: parent.width
                                height: 30
                                color: "#2a2a2a"
                                border.color: window.primaryColor
                                border.width: 1
                                radius: 3
                                
                                Row {
                                    anchors.fill: parent
                                    anchors.margins: 8
                                    spacing: 10
                                    
                                    Rectangle {
                                        width: 8
                                        height: 8
                                        radius: 4
                                        color: window.primaryColor
                                    }
                                    
                                    Text {
                                        text: "New Grok AI recommendation: GOOGL BUY"
                                        color: "#ffffff"
                                        font.pixelSize: 9
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                }
                            }
                            
                            Rectangle {
                                width: parent.width
                                height: 30
                                color: "#2a2a2a"
                                border.color: window.successColor
                                border.width: 1
                                radius: 3
                                
                                Row {
                                    anchors.fill: parent
                                    anchors.margins: 8
                                    spacing: 10
                                    
                                    Rectangle {
                                        width: 8
                                        height: 8
                                        radius: 4
                                        color: window.successColor
                                    }
                                    
                                    Text {
                                        text: "ML model accuracy improved to 87.3%"
                                        color: "#ffffff"
                                        font.pixelSize: 9
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
    
    // Connect to Redis signals
    Connections {
        target: redis
        
        function onPortfolioEquityReceived(equity) {
            var newValue = parseFloat(equity.replace("$", "").replace(",", ""))
            if (portfolioValue > 0) {
                dayChange = newValue - portfolioValue
                dayChangePercent = (dayChange / portfolioValue) * 100
            }
            portfolioValue = newValue
        }
    }
}