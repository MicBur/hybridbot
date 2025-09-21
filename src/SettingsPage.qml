import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

ScrollView {
    id: settingsPage
    anchors.fill: parent
    
    Column {
        width: parent.width
        spacing: 20
        
        // Page header
        Text {
            text: "⚙️ SYSTEM SETTINGS"
            font.pixelSize: 28
            font.bold: true
            color: window.primaryColor
        }
        
        // Alpaca API Settings
        Rectangle {
            width: parent.width
            height: 350
            color: window.surfaceColor
            border.color: window.primaryColor
            border.width: 2
            radius: 10
            
            Column {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 15
                
                Text {
                    text: "🔑 ALPACA API CONFIGURATION"
                    font.pixelSize: 18
                    font.bold: true
                    color: window.primaryColor
                }
                
                Row {
                    width: parent.width
                    spacing: 20
                    
                    Column {
                        width: parent.width / 2 - 10
                        spacing: 10
                        
                        Text {
                            text: "API Key:"
                            color: "#ffffff"
                            font.pixelSize: 14
                        }
                        
                        TextField {
                            id: apiKeyField
                            width: parent.width
                            height: 40
                            placeholderText: "Enter your Alpaca API Key"
                            text: window.alpacaApiKey
                            echoMode: TextInput.Password
                            color: "#ffffff"
                            background: Rectangle {
                                color: "#1a1a1a"
                                border.color: window.primaryColor
                                border.width: 1
                                radius: 5
                            }
                            onTextChanged: window.alpacaApiKey = text
                        }
                        
                        Text {
                            text: "Secret Key:"
                            color: "#ffffff"
                            font.pixelSize: 14
                        }
                        
                        TextField {
                            id: secretKeyField
                            width: parent.width
                            height: 40
                            placeholderText: "Enter your Alpaca Secret Key"
                            text: window.alpacaSecret
                            echoMode: TextInput.Password
                            color: "#ffffff"
                            background: Rectangle {
                                color: "#1a1a1a"
                                border.color: window.primaryColor
                                border.width: 1
                                radius: 5
                            }
                            onTextChanged: window.alpacaSecret = text
                        }
                    }
                    
                    Column {
                        width: parent.width / 2 - 10
                        spacing: 10
                        
                        Text {
                            text: "Trading Environment:"
                            color: "#ffffff"
                            font.pixelSize: 14
                        }
                        
                        Row {
                            spacing: 10
                            
                            RadioButton {
                                id: paperTradingRadio
                                text: "Paper Trading"
                                checked: window.paperTrading
                                onCheckedChanged: if (checked) window.paperTrading = true
                                
                                indicator: Rectangle {
                                    implicitWidth: 20
                                    implicitHeight: 20
                                    radius: 10
                                    border.color: window.primaryColor
                                    border.width: 2
                                    color: "transparent"
                                    
                                    Rectangle {
                                        width: 10
                                        height: 10
                                        radius: 5
                                        anchors.centerIn: parent
                                        color: window.primaryColor
                                        visible: parent.parent.checked
                                    }
                                }
                                
                                contentItem: Text {
                                    text: parent.text
                                    color: "#ffffff"
                                    leftPadding: parent.indicator ? parent.indicator.width + 10 : 0
                                    verticalAlignment: Text.AlignVCenter
                                }
                            }
                            
                            RadioButton {
                                id: liveTradingRadio
                                text: "Live Trading"
                                checked: !window.paperTrading
                                onCheckedChanged: if (checked) window.paperTrading = false
                                
                                indicator: Rectangle {
                                    implicitWidth: 20
                                    implicitHeight: 20
                                    radius: 10
                                    border.color: window.secondaryColor
                                    border.width: 2
                                    color: "transparent"
                                    
                                    Rectangle {
                                        width: 10
                                        height: 10
                                        radius: 5
                                        anchors.centerIn: parent
                                        color: window.secondaryColor
                                        visible: parent.parent.checked
                                    }
                                }
                                
                                contentItem: Text {
                                    text: parent.text
                                    color: window.secondaryColor
                                    leftPadding: parent.indicator ? parent.indicator.width + 10 : 0
                                    verticalAlignment: Text.AlignVCenter
                                }
                            }
                        }
                        
                        Text {
                            text: "Connection Status:"
                            color: "#ffffff"
                            font.pixelSize: 14
                        }
                        
                        Rectangle {
                            width: parent.width
                            height: 40
                            color: "#1a1a1a"
                            border.color: window.successColor
                            border.width: 1
                            radius: 5
                            
                            Row {
                                anchors.centerIn: parent
                                spacing: 10
                                
                                Rectangle {
                                    width: 12
                                    height: 12
                                    radius: 6
                                    color: window.successColor
                                    
                                    SequentialAnimation on opacity {
                                        loops: Animation.Infinite
                                        NumberAnimation { to: 0.3; duration: 1000 }
                                        NumberAnimation { to: 1.0; duration: 1000 }
                                    }
                                }
                                
                                Text {
                                    text: "API Connected"
                                    color: window.successColor
                                    font.pixelSize: 12
                                    font.bold: true
                                }
                            }
                        }
                    }
                }
                
                Row {
                    width: parent.width
                    spacing: 10
                    
                    Button {
                        text: "Test Connection"
                        onClicked: {
                            console.log("Testing Alpaca API connection...")
                            redis.getAlpacaAccount()
                        }
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
                        text: "Save API Keys"
                        onClicked: {
                            console.log("Saving API keys...")
                            // Add save logic here
                        }
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
                }
            }
        }
        
        // Trading Settings
        Rectangle {
            width: parent.width
            height: 400
            color: window.surfaceColor
            border.color: window.secondaryColor
            border.width: 2
            radius: 10
            
            Column {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 15
                
                Text {
                    text: "📊 TRADING PARAMETERS"
                    font.pixelSize: 18
                    font.bold: true
                    color: window.secondaryColor
                }
                
                // Trading Aggression
                Column {
                    width: parent.width
                    spacing: 10
                    
                    Row {
                        width: parent.width
                        
                        Text {
                            text: "Trading Aggressivität:"
                            color: "#ffffff"
                            font.pixelSize: 14
                            width: 200
                        }
                        
                        Text {
                            text: Math.round(window.tradingAggression * 100) + "%"
                            color: window.primaryColor
                            font.pixelSize: 14
                            font.bold: true
                        }
                    }
                    
                    Slider {
                        id: aggressionSlider
                        width: parent.width
                        from: 0.1
                        to: 1.0
                        value: window.tradingAggression
                        onValueChanged: window.tradingAggression = value
                        
                        background: Rectangle {
                            x: aggressionSlider.leftPadding
                            y: aggressionSlider.topPadding + aggressionSlider.availableHeight / 2 - height / 2
                            implicitWidth: 200
                            implicitHeight: 4
                            width: aggressionSlider.availableWidth
                            height: implicitHeight
                            radius: 2
                            color: "#333333"
                            
                            Rectangle {
                                width: aggressionSlider.visualPosition * parent.width
                                height: parent.height
                                color: window.secondaryColor
                                radius: 2
                            }
                        }
                        
                        handle: Rectangle {
                            x: aggressionSlider.leftPadding + aggressionSlider.visualPosition * (aggressionSlider.availableWidth - width)
                            y: aggressionSlider.topPadding + aggressionSlider.availableHeight / 2 - height / 2
                            implicitWidth: 20
                            implicitHeight: 20
                            radius: 10
                            color: window.secondaryColor
                            border.color: "#ffffff"
                            border.width: 2
                        }
                    }
                    
                    Text {
                        text: "Niedrig (10%) ← → Hoch (100%)"
                        color: "#cccccc"
                        font.pixelSize: 10
                    }
                }
                
                // Risk Management
                Row {
                    width: parent.width
                    spacing: 40
                    
                    Column {
                        width: (parent.width - 40) / 2
                        spacing: 10
                        
                        Text {
                            text: "Max Risk per Trade:"
                            color: "#ffffff"
                            font.pixelSize: 14
                        }
                        
                        SpinBox {
                            id: maxRiskSpinBox
                            width: parent.width
                            from: 1
                            to: 10
                            value: window.maxRiskPerTrade * 100
                            onValueChanged: window.maxRiskPerTrade = value / 100
                            
                            textFromValue: function(value, locale) {
                                return value + "%"
                            }
                            
                            background: Rectangle {
                                color: "#1a1a1a"
                                border.color: window.primaryColor
                                border.width: 1
                                radius: 5
                            }
                            
                            contentItem: TextInput {
                                text: maxRiskSpinBox.textFromValue(maxRiskSpinBox.value, maxRiskSpinBox.locale)
                                font: maxRiskSpinBox.font
                                color: "#ffffff"
                                horizontalAlignment: Qt.AlignHCenter
                                verticalAlignment: Qt.AlignVCenter
                                readOnly: !maxRiskSpinBox.editable
                                validator: maxRiskSpinBox.validator
                                inputMethodHints: maxRiskSpinBox.inputMethodHints
                            }
                        }
                    }
                    
                    Column {
                        width: (parent.width - 40) / 2
                        spacing: 10
                        
                        Text {
                            text: "Portfolio Risk Limit:"
                            color: "#ffffff"
                            font.pixelSize: 14
                        }
                        
                        SpinBox {
                            id: portfolioRiskSpinBox
                            width: parent.width
                            from: 5
                            to: 50
                            value: window.portfolioRiskLimit * 100
                            onValueChanged: window.portfolioRiskLimit = value / 100
                            
                            textFromValue: function(value, locale) {
                                return value + "%"
                            }
                            
                            background: Rectangle {
                                color: "#1a1a1a"
                                border.color: window.primaryColor
                                border.width: 1
                                radius: 5
                            }
                            
                            contentItem: TextInput {
                                text: portfolioRiskSpinBox.textFromValue(portfolioRiskSpinBox.value, portfolioRiskSpinBox.locale)
                                font: portfolioRiskSpinBox.font
                                color: "#ffffff"
                                horizontalAlignment: Qt.AlignHCenter
                                verticalAlignment: Qt.AlignVCenter
                                readOnly: !portfolioRiskSpinBox.editable
                                validator: portfolioRiskSpinBox.validator
                                inputMethodHints: portfolioRiskSpinBox.inputMethodHints
                            }
                        }
                    }
                }
                
                // Trading Strategy Options
                Text {
                    text: "Trading Strategien:"
                    color: "#ffffff"
                    font.pixelSize: 14
                    font.bold: true
                }
                
                Row {
                    spacing: 20
                    
                    CheckBox {
                        id: meanReversionCheck
                        text: "Mean Reversion"
                        checked: true
                        
                        indicator: Rectangle {
                            implicitWidth: 20
                            implicitHeight: 20
                            radius: 3
                            border.color: window.primaryColor
                            border.width: 2
                            color: parent.checked ? window.primaryColor : "transparent"
                            
                            Text {
                                text: "✓"
                                color: "#000000"
                                font.pixelSize: 12
                                font.bold: true
                                anchors.centerIn: parent
                                visible: parent.parent.checked
                            }
                        }
                        
                        contentItem: Text {
                            text: parent.text
                            color: "#ffffff"
                            leftPadding: parent.indicator ? parent.indicator.width + 10 : 0
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                    
                    CheckBox {
                        id: momentumCheck
                        text: "Momentum"
                        checked: true
                        
                        indicator: Rectangle {
                            implicitWidth: 20
                            implicitHeight: 20
                            radius: 3
                            border.color: window.primaryColor
                            border.width: 2
                            color: parent.checked ? window.primaryColor : "transparent"
                            
                            Text {
                                text: "✓"
                                color: "#000000"
                                font.pixelSize: 12
                                font.bold: true
                                anchors.centerIn: parent
                                visible: parent.parent.checked
                            }
                        }
                        
                        contentItem: Text {
                            text: parent.text
                            color: "#ffffff"
                            leftPadding: parent.indicator ? parent.indicator.width + 10 : 0
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                    
                    CheckBox {
                        id: arbitrageCheck
                        text: "Arbitrage"
                        checked: false
                        
                        indicator: Rectangle {
                            implicitWidth: 20
                            implicitHeight: 20
                            radius: 3
                            border.color: window.primaryColor
                            border.width: 2
                            color: parent.checked ? window.primaryColor : "transparent"
                            
                            Text {
                                text: "✓"
                                color: "#000000"
                                font.pixelSize: 12
                                font.bold: true
                                anchors.centerIn: parent
                                visible: parent.parent.checked
                            }
                        }
                        
                        contentItem: Text {
                            text: parent.text
                            color: "#ffffff"
                            leftPadding: parent.indicator ? parent.indicator.width + 10 : 0
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                }
            }
        }
        
        // System Settings
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
                    text: "🖥️ SYSTEM CONFIGURATION"
                    font.pixelSize: 18
                    font.bold: true
                    color: window.accentColor
                }
                
                Row {
                    width: parent.width
                    spacing: 20
                    
                    Column {
                        width: (parent.width - 20) / 2
                        spacing: 10
                        
                        Text {
                            text: "Update Interval:"
                            color: "#ffffff"
                            font.pixelSize: 14
                        }
                        
                        ComboBox {
                            width: parent.width
                            model: ["1 second", "3 seconds", "5 seconds", "10 seconds", "30 seconds"]
                            currentIndex: 1
                            
                            background: Rectangle {
                                color: "#1a1a1a"
                                border.color: window.accentColor
                                border.width: 1
                                radius: 5
                            }
                            
                            contentItem: Text {
                                text: parent.displayText
                                color: "#ffffff"
                                verticalAlignment: Text.AlignVCenter
                                leftPadding: 10
                            }
                        }
                    }
                    
                    Column {
                        width: (parent.width - 20) / 2
                        spacing: 10
                        
                        Text {
                            text: "Theme:"
                            color: "#ffffff"
                            font.pixelSize: 14
                        }
                        
                        ComboBox {
                            width: parent.width
                            model: ["Cyan Dark", "Red Dark", "Green Dark", "Purple Dark"]
                            currentIndex: 0
                            
                            background: Rectangle {
                                color: "#1a1a1a"
                                border.color: window.accentColor
                                border.width: 1
                                radius: 5
                            }
                            
                            contentItem: Text {
                                text: parent.displayText
                                color: "#ffffff"
                                verticalAlignment: Text.AlignVCenter
                                leftPadding: 10
                            }
                        }
                    }
                }
                
                Row {
                    spacing: 10
                    
                    Button {
                        text: "💾 Save Settings"
                        onClicked: {
                            console.log("Saving all settings...")
                            // Add save logic
                        }
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
                        text: "🔄 Reset to Defaults"
                        onClicked: {
                            window.tradingAggression = 0.5
                            window.maxRiskPerTrade = 0.02
                            window.portfolioRiskLimit = 0.10
                            window.paperTrading = true
                        }
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
    }
}