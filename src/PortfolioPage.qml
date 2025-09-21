import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    id: portfolioPage
    anchors.fill: parent
    
    property real portfolioValue: 0
    property real dayChange: 0
    property real dayChangePercent: 0
    
    Column {
        width: parent.width
        spacing: 20
        
        // Page header
        Text {
            text: "💼 PORTFOLIO MANAGEMENT"
            font.pixelSize: 28
            font.bold: true
            color: window.primaryColor
        }
        
        // Portfolio Overview
        Row {
            width: parent.width
            spacing: 20
            
            Rectangle {
                width: (parent.width - 60) / 3
                height: 120
                color: window.surfaceColor
                border.color: window.primaryColor
                border.width: 2
                radius: 10
                
                Column {
                    anchors.centerIn: parent
                    spacing: 5
                    
                    Text {
                        text: "Total Portfolio Value"
                        color: "#cccccc"
                        font.pixelSize: 12
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    
                    Text {
                        text: "$" + portfolioValue.toLocaleString(Qt.locale("en_US"), "f", 2)
                        color: window.primaryColor
                        font.pixelSize: 20
                        font.bold: true
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    
                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 5
                        
                        Text {
                            text: dayChange >= 0 ? "+" : ""
                            color: dayChange >= 0 ? window.successColor : window.dangerColor
                            font.pixelSize: 12
                        }
                        
                        Text {
                            text: "$" + Math.abs(dayChange).toLocaleString(Qt.locale("en_US"), "f", 2)
                            color: dayChange >= 0 ? window.successColor : window.dangerColor
                            font.pixelSize: 12
                        }
                        
                        Text {
                            text: "(" + (dayChange >= 0 ? "+" : "") + dayChangePercent.toFixed(2) + "%)"
                            color: dayChange >= 0 ? window.successColor : window.dangerColor
                            font.pixelSize: 12
                        }
                    }
                }
            }
            
            Rectangle {
                width: (parent.width - 60) / 3
                height: 120
                color: window.surfaceColor
                border.color: window.successColor
                border.width: 2
                radius: 10
                
                Column {
                    anchors.centerIn: parent
                    spacing: 5
                    
                    Text {
                        text: "Available Cash"
                        color: "#cccccc"
                        font.pixelSize: 12
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    
                    Text {
                        text: "$25,670.45"
                        color: window.successColor
                        font.pixelSize: 20
                        font.bold: true
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    
                    Text {
                        text: "Ready to Trade"
                        color: "#cccccc"
                        font.pixelSize: 10
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }
            }
            
            Rectangle {
                width: (parent.width - 60) / 3
                height: 120
                color: window.surfaceColor
                border.color: window.warningColor
                border.width: 2
                radius: 10
                
                Column {
                    anchors.centerIn: parent
                    spacing: 5
                    
                    Text {
                        text: "Open Positions"
                        color: "#cccccc"
                        font.pixelSize: 12
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    
                    Text {
                        text: "17"
                        color: window.warningColor
                        font.pixelSize: 20
                        font.bold: true
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    
                    Text {
                        text: "Active Trades"
                        color: "#cccccc"
                        font.pixelSize: 10
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }
            }
        }
        
        // Portfolio Holdings
        Rectangle {
            width: parent.width
            height: 400
            color: window.surfaceColor
            border.color: window.primaryColor
            border.width: 2
            radius: 10
            
            Column {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 15
                
                Row {
                    width: parent.width
                    
                    Text {
                        text: "📊 CURRENT HOLDINGS"
                        font.pixelSize: 16
                        font.bold: true
                        color: window.primaryColor
                    }
                    
                    Item { Layout.fillWidth: true }
                    
                    Button {
                        text: "🔄 Refresh"
                        onClicked: redis.getPortfolioEquity()
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
                }
                
                // Holdings Header
                Rectangle {
                    width: parent.width
                    height: 30
                    color: "#1a1a1a"
                    radius: 5
                    
                    Row {
                        anchors.fill: parent
                        anchors.margins: 10
                        
                        Text {
                            text: "Symbol"
                            color: "#ffffff"
                            font.bold: true
                            width: 80
                        }
                        
                        Text {
                            text: "Shares"
                            color: "#ffffff"
                            font.bold: true
                            width: 80
                        }
                        
                        Text {
                            text: "Price"
                            color: "#ffffff"
                            font.bold: true
                            width: 100
                        }
                        
                        Text {
                            text: "Value"
                            color: "#ffffff"
                            font.bold: true
                            width: 120
                        }
                        
                        Text {
                            text: "P&L"
                            color: "#ffffff"
                            font.bold: true
                            width: 100
                        }
                        
                        Text {
                            text: "Actions"
                            color: "#ffffff"
                            font.bold: true
                            width: 120
                        }
                    }
                }
                
                ScrollView {
                    width: parent.width
                    height: 300
                    
                    Column {
                        width: parent.width
                        spacing: 2
                        
                        Repeater {
                            model: ListModel {
                                ListElement { symbol: "AAPL"; shares: 50; price: 234.10; value: 11705; pnl: 1250; pnlPercent: 11.9 }
                                ListElement { symbol: "NVDA"; shares: 25; price: 1185.20; value: 29630; pnl: 4820; pnlPercent: 19.4 }
                                ListElement { symbol: "MSFT"; shares: 75; price: 412.85; value: 30964; pnl: 2100; pnlPercent: 7.3 }
                                ListElement { symbol: "GOOGL"; shares: 30; price: 162.45; value: 4874; pnl: -250; pnlPercent: -4.9 }
                                ListElement { symbol: "TSLA"; shares: 40; price: 248.75; value: 9950; pnl: 850; pnlPercent: 9.3 }
                                ListElement { symbol: "AMZN"; shares: 20; price: 186.12; value: 3722; pnl: 120; pnlPercent: 3.3 }
                                ListElement { symbol: "META"; shares: 35; price: 578.23; value: 20238; pnl: 1850; pnlPercent: 10.1 }
                            }
                            
                            Rectangle {
                                width: parent.width
                                height: 40
                                color: index % 2 === 0 ? "#2a2a2a" : "#1f1f1f"
                                
                                Row {
                                    anchors.fill: parent
                                    anchors.margins: 10
                                    
                                    Text {
                                        text: symbol
                                        color: window.primaryColor
                                        font.bold: true
                                        width: 80
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                    
                                    Text {
                                        text: shares
                                        color: "#ffffff"
                                        width: 80
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                    
                                    Text {
                                        text: "$" + price.toFixed(2)
                                        color: "#ffffff"
                                        width: 100
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                    
                                    Text {
                                        text: "$" + value.toLocaleString()
                                        color: "#ffffff"
                                        width: 120
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                    
                                    Text {
                                        text: (pnl >= 0 ? "+" : "") + "$" + pnl.toLocaleString() + " (" + (pnl >= 0 ? "+" : "") + pnlPercent.toFixed(1) + "%)"
                                        color: pnl >= 0 ? window.successColor : window.dangerColor
                                        width: 100
                                        verticalAlignment: Text.AlignVCenter
                                        font.pixelSize: 11
                                    }
                                    
                                    Row {
                                        width: 120
                                        spacing: 5
                                        
                                        Button {
                                            text: "Buy"
                                            width: 35
                                            height: 25
                                            onClicked: console.log("Buy " + symbol)
                                            background: Rectangle {
                                                color: window.successColor
                                                radius: 3
                                            }
                                            contentItem: Text {
                                                text: parent.text
                                                color: "#000000"
                                                font.pixelSize: 10
                                                font.bold: true
                                                horizontalAlignment: Text.AlignHCenter
                                                verticalAlignment: Text.AlignVCenter
                                            }
                                        }
                                        
                                        Button {
                                            text: "Sell"
                                            width: 35
                                            height: 25
                                            onClicked: console.log("Sell " + symbol)
                                            background: Rectangle {
                                                color: window.dangerColor
                                                radius: 3
                                            }
                                            contentItem: Text {
                                                text: parent.text
                                                color: "#000000"
                                                font.pixelSize: 10
                                                font.bold: true
                                                horizontalAlignment: Text.AlignHCenter
                                                verticalAlignment: Text.AlignVCenter
                                            }
                                        }
                                        
                                        Button {
                                            text: "Chart"
                                            width: 40
                                            height: 25
                                            onClicked: console.log("Show chart for " + symbol)
                                            background: Rectangle {
                                                color: window.primaryColor
                                                radius: 3
                                            }
                                            contentItem: Text {
                                                text: parent.text
                                                color: "#000000"
                                                font.pixelSize: 10
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
        }
        
        // Performance Chart
        Rectangle {
            width: parent.width
            height: 300
            color: window.surfaceColor
            border.color: window.secondaryColor
            border.width: 2
            radius: 10
            
            Column {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 15
                
                Text {
                    text: "📈 PORTFOLIO PERFORMANCE"
                    font.pixelSize: 16
                    font.bold: true
                    color: window.secondaryColor
                }
                
                Canvas {
                    id: performanceChart
                    width: parent.width
                    height: 240
                    
                    property var dataPoints: [
                        100000, 102500, 104200, 103800, 105600, 107200, 106800,
                        108500, 109300, 110200, 109800, 111500, 109329, 112000
                    ]
                    
                    onPaint: {
                        var ctx = getContext("2d")
                        ctx.clearRect(0, 0, width, height)
                        
                        if (dataPoints.length < 2) return
                        
                        // Set up chart area
                        var margin = 40
                        var chartWidth = width - 2 * margin
                        var chartHeight = height - 2 * margin
                        
                        // Find min/max values
                        var minValue = Math.min(...dataPoints)
                        var maxValue = Math.max(...dataPoints)
                        var valueRange = maxValue - minValue
                        
                        // Draw grid lines
                        ctx.strokeStyle = "#333333"
                        ctx.lineWidth = 1
                        
                        for (var i = 0; i <= 5; i++) {
                            var y = margin + (chartHeight / 5) * i
                            ctx.beginPath()
                            ctx.moveTo(margin, y)
                            ctx.lineTo(margin + chartWidth, y)
                            ctx.stroke()
                        }
                        
                        // Draw performance line
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
                        
                        // Draw fill area
                        ctx.fillStyle = window.primaryColor + "20"
                        ctx.lineTo(margin + chartWidth, margin + chartHeight)
                        ctx.lineTo(margin, margin + chartHeight)
                        ctx.closePath()
                        ctx.fill()
                        
                        // Draw value labels
                        ctx.fillStyle = "#ffffff"
                        ctx.font = "12px Arial"
                        ctx.textAlign = "right"
                        
                        for (var i = 0; i <= 5; i++) {
                            var value = minValue + (valueRange / 5) * (5 - i)
                            var y = margin + (chartHeight / 5) * i + 5
                            ctx.fillText("$" + value.toLocaleString(Qt.locale("en_US"), "f", 0), margin - 10, y)
                        }
                    }
                    
                    Timer {
                        interval: 5000
                        running: true
                        repeat: true
                        onTriggered: {
                            // Update last data point with current portfolio value
                            performanceChart.dataPoints[performanceChart.dataPoints.length - 1] = portfolioValue
                            performanceChart.requestPaint()
                        }
                    }
                }
            }
        }
    }
    
    // Update portfolio data
    Timer {
        interval: 3000
        running: true
        repeat: true
        onTriggered: {
            redis.getPortfolioEquity()
        }
    }
    
    Connections {
        target: redis
        function onPortfolioEquityReceived(equity) {
            var currentValue = parseFloat(equity.replace("$", "").replace(",", ""))
            var previousValue = portfolioValue
            
            portfolioValue = currentValue
            
            if (previousValue > 0) {
                dayChange = currentValue - previousValue
                dayChangePercent = (dayChange / previousValue) * 100
            }
        }
    }
}