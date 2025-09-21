import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    id: tradingPage
    anchors.fill: parent
    
    property string selectedSymbol: "AAPL"
    property real selectedPrice: 234.10
    property int shareQuantity: 10
    property string orderType: "Market"
    
    Column {
        width: parent.width
        spacing: 20
        
        // Page header
        Text {
            text: "📈 TRADING TERMINAL"
            font.pixelSize: 28
            font.bold: true
            color: window.primaryColor
        }
        
        // Quick Stats
        Row {
            width: parent.width
            spacing: 20
            
            Rectangle {
                width: (parent.width - 80) / 4
                height: 80
                color: window.surfaceColor
                border.color: window.successColor
                border.width: 2
                radius: 10
                
                Column {
                    anchors.centerIn: parent
                    spacing: 3
                    
                    Text {
                        text: "Buying Power"
                        color: "#cccccc"
                        font.pixelSize: 10
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    
                    Text {
                        text: "$25,670"
                        color: window.successColor
                        font.pixelSize: 16
                        font.bold: true
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }
            }
            
            Rectangle {
                width: (parent.width - 80) / 4
                height: 80
                color: window.surfaceColor
                border.color: window.primaryColor
                border.width: 2
                radius: 10
                
                Column {
                    anchors.centerIn: parent
                    spacing: 3
                    
                    Text {
                        text: "Day P&L"
                        color: "#cccccc"
                        font.pixelSize: 10
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    
                    Text {
                        text: "+$2,847"
                        color: window.successColor
                        font.pixelSize: 16
                        font.bold: true
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }
            }
            
            Rectangle {
                width: (parent.width - 80) / 4
                height: 80
                color: window.surfaceColor
                border.color: window.warningColor
                border.width: 2
                radius: 10
                
                Column {
                    anchors.centerIn: parent
                    spacing: 3
                    
                    Text {
                        text: "Open Orders"
                        color: "#cccccc"
                        font.pixelSize: 10
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    
                    Text {
                        text: "3"
                        color: window.warningColor
                        font.pixelSize: 16
                        font.bold: true
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }
            }
            
            Rectangle {
                width: (parent.width - 80) / 4
                height: 80
                color: window.surfaceColor
                border.color: window.dangerColor
                border.width: 2
                radius: 10
                
                Column {
                    anchors.centerIn: parent
                    spacing: 3
                    
                    Text {
                        text: "Risk Level"
                        color: "#cccccc"
                        font.pixelSize: 10
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    
                    Text {
                        text: "MEDIUM"
                        color: window.warningColor
                        font.pixelSize: 12
                        font.bold: true
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }
            }
        }
        
        // Trading Interface
        Row {
            width: parent.width
            spacing: 20
            
            // Order Entry Panel
            Rectangle {
                width: (parent.width - 20) / 2
                height: 500
                color: window.surfaceColor
                border.color: window.primaryColor
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
                        color: window.primaryColor
                    }
                    
                    // Symbol Selection
                    Column {
                        width: parent.width
                        spacing: 10
                        
                        Text {
                            text: "Symbol:"
                            color: "#ffffff"
                            font.pixelSize: 12
                        }
                        
                        ComboBox {
                            id: symbolBox
                            width: parent.width
                            model: ["AAPL", "NVDA", "MSFT", "GOOGL", "TSLA", "AMZN", "META", "NFLX"]
                            currentIndex: 0
                            onCurrentTextChanged: {
                                selectedSymbol = currentText
                                // Update price based on symbol
                                switch(currentText) {
                                    case "AAPL": selectedPrice = 234.10; break;
                                    case "NVDA": selectedPrice = 1185.20; break;
                                    case "MSFT": selectedPrice = 412.85; break;
                                    case "GOOGL": selectedPrice = 162.45; break;
                                    case "TSLA": selectedPrice = 248.75; break;
                                    case "AMZN": selectedPrice = 186.12; break;
                                    case "META": selectedPrice = 578.23; break;
                                    case "NFLX": selectedPrice = 492.88; break;
                                }
                            }
                            
                            background: Rectangle {
                                color: "#1a1a1a"
                                border.color: window.primaryColor
                                border.width: 1
                                radius: 5
                            }
                            
                            contentItem: Text {
                                text: parent.displayText
                                color: "#ffffff"
                                verticalAlignment: Text.AlignVCenter
                                leftPadding: 10
                                font.bold: true
                            }
                        }
                        
                        Text {
                            text: "Current Price: $" + selectedPrice.toFixed(2)
                            color: window.primaryColor
                            font.pixelSize: 14
                            font.bold: true
                        }
                    }
                    
                    // Order Type
                    Column {
                        width: parent.width
                        spacing: 10
                        
                        Text {
                            text: "Order Type:"
                            color: "#ffffff"
                            font.pixelSize: 12
                        }
                        
                        Row {
                            spacing: 15
                            
                            RadioButton {
                                text: "Market"
                                checked: orderType === "Market"
                                onCheckedChanged: if (checked) orderType = "Market"
                                
                                indicator: Rectangle {
                                    implicitWidth: 16
                                    implicitHeight: 16
                                    radius: 8
                                    border.color: window.primaryColor
                                    border.width: 2
                                    color: "transparent"
                                    
                                    Rectangle {
                                        width: 8
                                        height: 8
                                        radius: 4
                                        anchors.centerIn: parent
                                        color: window.primaryColor
                                        visible: parent.parent.checked
                                    }
                                }
                                
                                contentItem: Text {
                                    text: parent.text
                                    color: "#ffffff"
                                    leftPadding: parent.indicator.width + 10
                                    verticalAlignment: Text.AlignVCenter
                                    font.pixelSize: 12
                                }
                            }
                            
                            RadioButton {
                                text: "Limit"
                                checked: orderType === "Limit"
                                onCheckedChanged: if (checked) orderType = "Limit"
                                
                                indicator: Rectangle {
                                    implicitWidth: 16
                                    implicitHeight: 16
                                    radius: 8
                                    border.color: window.primaryColor
                                    border.width: 2
                                    color: "transparent"
                                    
                                    Rectangle {
                                        width: 8
                                        height: 8
                                        radius: 4
                                        anchors.centerIn: parent
                                        color: window.primaryColor
                                        visible: parent.parent.checked
                                    }
                                }
                                
                                contentItem: Text {
                                    text: parent.text
                                    color: "#ffffff"
                                    leftPadding: parent.indicator.width + 10
                                    verticalAlignment: Text.AlignVCenter
                                    font.pixelSize: 12
                                }
                            }
                        }
                    }
                    
                    // Quantity
                    Column {
                        width: parent.width
                        spacing: 10
                        
                        Text {
                            text: "Quantity:"
                            color: "#ffffff"
                            font.pixelSize: 12
                        }
                        
                        SpinBox {
                            id: quantitySpinBox
                            width: parent.width
                            from: 1
                            to: 1000
                            value: shareQuantity
                            onValueChanged: shareQuantity = value
                            
                            background: Rectangle {
                                color: "#1a1a1a"
                                border.color: window.primaryColor
                                border.width: 1
                                radius: 5
                            }
                            
                            contentItem: TextInput {
                                text: quantitySpinBox.value
                                font: quantitySpinBox.font
                                color: "#ffffff"
                                horizontalAlignment: Qt.AlignHCenter
                                verticalAlignment: Qt.AlignVCenter
                                readOnly: !quantitySpinBox.editable
                                validator: quantitySpinBox.validator
                                inputMethodHints: quantitySpinBox.inputMethodHints
                            }
                        }
                        
                        Text {
                            text: "Estimated Cost: $" + (selectedPrice * shareQuantity).toLocaleString(Qt.locale("en_US"), "f", 2)
                            color: window.warningColor
                            font.pixelSize: 12
                            font.bold: true
                        }
                    }
                    
                    // Action Buttons
                    Row {
                        width: parent.width
                        spacing: 10
                        
                        Button {
                            text: "🟢 BUY"
                            width: (parent.width - 10) / 2
                            height: 50
                            onClicked: {
                                console.log("BUY order:", shareQuantity + " shares of " + selectedSymbol)
                                // Add buy logic here
                            }
                            background: Rectangle {
                                color: window.successColor
                                radius: 8
                            }
                            contentItem: Text {
                                text: parent.text
                                color: "#000000"
                                font.bold: true
                                font.pixelSize: 14
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                        }
                        
                        Button {
                            text: "🔴 SELL"
                            width: (parent.width - 10) / 2
                            height: 50
                            onClicked: {
                                console.log("SELL order:", shareQuantity + " shares of " + selectedSymbol)
                                // Add sell logic here
                            }
                            background: Rectangle {
                                color: window.dangerColor
                                radius: 8
                            }
                            contentItem: Text {
                                text: parent.text
                                color: "#000000"
                                font.bold: true
                                font.pixelSize: 14
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                        }
                    }
                    
                    // Risk Warning
                    Rectangle {
                        width: parent.width
                        height: 60
                        color: "#2a1a1a"
                        border.color: window.warningColor
                        border.width: 1
                        radius: 5
                        
                        Column {
                            anchors.centerIn: parent
                            spacing: 3
                            
                            Text {
                                text: "⚠️ Risk Assessment"
                                color: window.warningColor
                                font.pixelSize: 10
                                font.bold: true
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                            
                            Text {
                                text: "Position Size: " + ((selectedPrice * shareQuantity / 109329) * 100).toFixed(1) + "% of Portfolio"
                                color: "#ffffff"
                                font.pixelSize: 9
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                            
                            Text {
                                text: "Risk Level: " + (shareQuantity > 50 ? "HIGH" : shareQuantity > 20 ? "MEDIUM" : "LOW")
                                color: shareQuantity > 50 ? window.dangerColor : shareQuantity > 20 ? window.warningColor : window.successColor
                                font.pixelSize: 9
                                font.bold: true
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                        }
                    }
                }
            }
            
            // Active Orders Panel
            Rectangle {
                width: (parent.width - 20) / 2
                height: 500
                color: window.surfaceColor
                border.color: window.secondaryColor
                border.width: 2
                radius: 10
                
                Column {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 15
                    
                    Text {
                        text: "📋 ACTIVE ORDERS"
                        font.pixelSize: 16
                        font.bold: true
                        color: window.secondaryColor
                    }
                    
                    ScrollView {
                        width: parent.width
                        height: 420
                        
                        Column {
                            width: parent.width
                            spacing: 10
                            
                            Repeater {
                                model: ListModel {
                                    ListElement { symbol: "NVDA"; type: "BUY"; quantity: 25; price: 1180.00; status: "PENDING" }
                                    ListElement { symbol: "AAPL"; type: "SELL"; quantity: 10; price: 235.50; status: "FILLED" }
                                    ListElement { symbol: "TSLA"; type: "BUY"; quantity: 15; price: 245.00; status: "PENDING" }
                                    ListElement { symbol: "MSFT"; type: "BUY"; quantity: 20; price: 410.00; status: "CANCELLED" }
                                    ListElement { symbol: "GOOGL"; type: "SELL"; quantity: 5; price: 165.00; status: "PENDING" }
                                }
                                
                                Rectangle {
                                    width: parent.width
                                    height: 70
                                    color: index % 2 === 0 ? "#2a2a2a" : "#1f1f1f"
                                    border.color: status === "FILLED" ? window.successColor : 
                                                  status === "PENDING" ? window.warningColor : window.dangerColor
                                    border.width: 1
                                    radius: 5
                                    
                                    Row {
                                        anchors.fill: parent
                                        anchors.margins: 10
                                        spacing: 15
                                        
                                        Column {
                                            width: 60
                                            spacing: 2
                                            
                                            Text {
                                                text: symbol
                                                color: window.primaryColor
                                                font.pixelSize: 12
                                                font.bold: true
                                            }
                                            
                                            Rectangle {
                                                width: 35
                                                height: 18
                                                color: type === "BUY" ? window.successColor : window.dangerColor
                                                radius: 9
                                                
                                                Text {
                                                    text: type
                                                    color: "#000000"
                                                    font.pixelSize: 8
                                                    font.bold: true
                                                    anchors.centerIn: parent
                                                }
                                            }
                                        }
                                        
                                        Column {
                                            spacing: 2
                                            
                                            Text {
                                                text: quantity + " shares"
                                                color: "#ffffff"
                                                font.pixelSize: 10
                                            }
                                            
                                            Text {
                                                text: "@$" + price.toFixed(2)
                                                color: "#cccccc"
                                                font.pixelSize: 10
                                            }
                                        }
                                        
                                        Column {
                                            spacing: 2
                                            
                                            Rectangle {
                                                width: 60
                                                height: 16
                                                color: status === "FILLED" ? window.successColor : 
                                                       status === "PENDING" ? window.warningColor : window.dangerColor
                                                radius: 8
                                                
                                                Text {
                                                    text: status
                                                    color: status === "PENDING" ? "#000000" : "#ffffff"
                                                    font.pixelSize: 8
                                                    font.bold: true
                                                    anchors.centerIn: parent
                                                }
                                            }
                                            
                                            Text {
                                                text: "Value: $" + (quantity * price).toLocaleString()
                                                color: "#cccccc"
                                                font.pixelSize: 8
                                            }
                                        }
                                        
                                        Button {
                                            text: status === "PENDING" ? "Cancel" : "Details"
                                            width: 50
                                            height: 25
                                            onClicked: console.log("Action on order:", symbol)
                                            background: Rectangle {
                                                color: status === "PENDING" ? window.dangerColor : window.primaryColor
                                                radius: 3
                                            }
                                            contentItem: Text {
                                                text: parent.text
                                                color: "#000000"
                                                font.pixelSize: 8
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
        
        // Trading Analytics
        Rectangle {
            width: parent.width
            height: 200
            color: window.surfaceColor
            border.color: window.accentColor
            border.width: 2
            radius: 10
            
            Column {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 15
                
                Text {
                    text: "📊 TRADING ANALYTICS"
                    font.pixelSize: 16
                    font.bold: true
                    color: window.accentColor
                }
                
                Row {
                    width: parent.width
                    spacing: 30
                    
                    Column {
                        spacing: 8
                        
                        Text {
                            text: "Today's Performance"
                            color: "#cccccc"
                            font.pixelSize: 12
                            font.bold: true
                        }
                        
                        Text {
                            text: "Trades Executed: 12"
                            color: "#ffffff"
                            font.pixelSize: 11
                        }
                        
                        Text {
                            text: "Win Rate: 83.3%"
                            color: window.successColor
                            font.pixelSize: 11
                        }
                        
                        Text {
                            text: "Avg Profit: $237.50"
                            color: window.successColor
                            font.pixelSize: 11
                        }
                    }
                    
                    Column {
                        spacing: 8
                        
                        Text {
                            text: "Risk Metrics"
                            color: "#cccccc"
                            font.pixelSize: 12
                            font.bold: true
                        }
                        
                        Text {
                            text: "Max Drawdown: -2.1%"
                            color: window.dangerColor
                            font.pixelSize: 11
                        }
                        
                        Text {
                            text: "Sharpe Ratio: 2.34"
                            color: window.successColor
                            font.pixelSize: 11
                        }
                        
                        Text {
                            text: "Risk Score: 6.5/10"
                            color: window.warningColor
                            font.pixelSize: 11
                        }
                    }
                    
                    Column {
                        spacing: 8
                        
                        Text {
                            text: "AI Integration"
                            color: "#cccccc"
                            font.pixelSize: 12
                            font.bold: true
                        }
                        
                        Text {
                            text: "ML Confidence: 94.2%"
                            color: window.successColor
                            font.pixelSize: 11
                        }
                        
                        Text {
                            text: "Grok Signals: 8 Active"
                            color: window.primaryColor
                            font.pixelSize: 11
                        }
                        
                        Text {
                            text: "Auto-Trading: " + (window.tradingAggression > 0.7 ? "ENABLED" : "DISABLED")
                            color: window.tradingAggression > 0.7 ? window.successColor : window.warningColor
                            font.pixelSize: 11
                        }
                    }
                }
            }
        }
    }
}