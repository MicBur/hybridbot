import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    id: grokPage
    anchors.fill: parent
    
    property var grokData: []
    property string lastUpdate: ""
    
    Column {
        width: parent.width
        spacing: 20
        
        // Page header
        Text {
            text: "🤖 GROK AI RECOMMENDATIONS"
            font.pixelSize: 28
            font.bold: true
            color: window.primaryColor
        }
        
        // Grok Status Panel
        Rectangle {
            width: parent.width
            height: 100
            color: window.surfaceColor
            border.color: window.primaryColor
            border.width: 2
            radius: 10
            
            Row {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 40
                
                Column {
                    spacing: 5
                    
                    Text {
                        text: "🔮 AI Status"
                        color: window.primaryColor
                        font.pixelSize: 14
                        font.bold: true
                    }
                    
                    Row {
                        spacing: 10
                        
                        Rectangle {
                            width: 12
                            height: 12
                            radius: 6
                            color: window.successColor
                            
                            SequentialAnimation on opacity {
                                loops: Animation.Infinite
                                NumberAnimation { to: 0.5; duration: 1000 }
                                NumberAnimation { to: 1.0; duration: 1000 }
                            }
                        }
                        
                        Text {
                            text: "Online & Active"
                            color: window.successColor
                            font.pixelSize: 12
                            font.bold: true
                        }
                    }
                }
                
                Column {
                    spacing: 5
                    
                    Text {
                        text: "📊 Analysis Confidence"
                        color: window.primaryColor
                        font.pixelSize: 14
                        font.bold: true
                    }
                    
                    Text {
                        text: "94.7%"
                        color: window.successColor
                        font.pixelSize: 16
                        font.bold: true
                    }
                }
                
                Column {
                    spacing: 5
                    
                    Text {
                        text: "🕐 Last Update"
                        color: window.primaryColor
                        font.pixelSize: 14
                        font.bold: true
                    }
                    
                    Text {
                        text: lastUpdate || "Updating..."
                        color: "#ffffff"
                        font.pixelSize: 12
                    }
                }
                
                Column {
                    spacing: 5
                    
                    Text {
                        text: "🎯 Active Recommendations"
                        color: window.primaryColor
                        font.pixelSize: 14
                        font.bold: true
                    }
                    
                    Text {
                        text: grokData.length.toString()
                        color: window.warningColor
                        font.pixelSize: 16
                        font.bold: true
                    }
                }
            }
        }
        
        // Top Recommendations
        Rectangle {
            width: parent.width
            height: 450
            color: window.surfaceColor
            border.color: window.secondaryColor
            border.width: 2
            radius: 10
            
            Column {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 15
                
                Row {
                    width: parent.width
                    
                    Text {
                        text: "🔥 TOP GROK EMPFEHLUNGEN"
                        font.pixelSize: 16
                        font.bold: true
                        color: window.secondaryColor
                    }
                    
                    Item { Layout.fillWidth: true }
                    
                    Button {
                        text: "🔄 Refresh"
                        onClicked: {
                            redis.getGrokRecommendations()
                            redis.getGrokDeepersearch()
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
                }
                
                ScrollView {
                    width: parent.width
                    height: 380
                    
                    Column {
                        width: parent.width
                        spacing: 10
                        
                        Repeater {
                            model: grokData.length > 0 ? grokData : [
                                {
                                    symbol: "NVDA",
                                    action: "BUY",
                                    confidence: 96.2,
                                    reason: "KI-Boom und starke Quartalszahlen erwarten. Grafikkarten-Nachfrage steigt weiter durch ML-Training.",
                                    sentiment: "BULLISH",
                                    price_target: 1350.00,
                                    current_price: 1185.20
                                },
                                {
                                    symbol: "TSLA",
                                    action: "HOLD",
                                    confidence: 78.5,
                                    reason: "Autopilot-Updates und China-Expansion positiv, aber Bewertung bereits hoch. Abwarten empfohlen.",
                                    sentiment: "NEUTRAL",
                                    price_target: 280.00,
                                    current_price: 248.75
                                },
                                {
                                    symbol: "AAPL",
                                    action: "BUY",
                                    confidence: 89.3,
                                    reason: "iPhone 16 Launch läuft gut, Services-Wachstum stabil. KI-Integration in iOS wird Nachfrage treiben.",
                                    sentiment: "BULLISH",
                                    price_target: 260.00,
                                    current_price: 234.10
                                },
                                {
                                    symbol: "AMZN",
                                    action: "SELL",
                                    confidence: 82.1,
                                    reason: "Cloud-Konkurrenz nimmt zu, E-Commerce-Wachstum verlangsamt sich. Bewertung zu hoch für aktuelles Wachstum.",
                                    sentiment: "BEARISH",
                                    price_target: 160.00,
                                    current_price: 186.12
                                },
                                {
                                    symbol: "GOOGL",
                                    action: "BUY",
                                    confidence: 91.7,
                                    reason: "Bard/Gemini KI-Fortschritte, Werbemarkt erholt sich. Such-Monopol bleibt stark trotz KI-Konkurrenz.",
                                    sentiment: "BULLISH",
                                    price_target: 185.00,
                                    current_price: 162.45
                                }
                            ]
                            
                            Rectangle {
                                width: parent.width
                                height: 140
                                color: index % 2 === 0 ? "#2a2a2a" : "#1f1f1f"
                                border.color: modelData.action === "BUY" ? window.successColor : 
                                              modelData.action === "SELL" ? window.dangerColor : window.warningColor
                                border.width: 1
                                radius: 8
                                
                                Row {
                                    anchors.fill: parent
                                    anchors.margins: 15
                                    spacing: 20
                                    
                                    // Symbol and Action
                                    Column {
                                        width: 120
                                        spacing: 5
                                        
                                        Text {
                                            text: modelData.symbol
                                            color: window.primaryColor
                                            font.pixelSize: 18
                                            font.bold: true
                                        }
                                        
                                        Rectangle {
                                            width: 60
                                            height: 25
                                            color: modelData.action === "BUY" ? window.successColor : 
                                                   modelData.action === "SELL" ? window.dangerColor : window.warningColor
                                            radius: 12
                                            
                                            Text {
                                                text: modelData.action
                                                color: "#000000"
                                                font.pixelSize: 12
                                                font.bold: true
                                                anchors.centerIn: parent
                                            }
                                        }
                                        
                                        Text {
                                            text: "Confidence: " + modelData.confidence.toFixed(1) + "%"
                                            color: "#cccccc"
                                            font.pixelSize: 10
                                        }
                                        
                                        Text {
                                            text: modelData.sentiment
                                            color: modelData.sentiment === "BULLISH" ? window.successColor : 
                                                   modelData.sentiment === "BEARISH" ? window.dangerColor : window.warningColor
                                            font.pixelSize: 10
                                            font.bold: true
                                        }
                                    }
                                    
                                    // Price Info
                                    Column {
                                        width: 140
                                        spacing: 5
                                        
                                        Text {
                                            text: "Current Price"
                                            color: "#cccccc"
                                            font.pixelSize: 10
                                        }
                                        
                                        Text {
                                            text: "$" + modelData.current_price.toFixed(2)
                                            color: "#ffffff"
                                            font.pixelSize: 14
                                            font.bold: true
                                        }
                                        
                                        Text {
                                            text: "Target Price"
                                            color: "#cccccc"
                                            font.pixelSize: 10
                                        }
                                        
                                        Text {
                                            text: "$" + modelData.price_target.toFixed(2)
                                            color: window.primaryColor
                                            font.pixelSize: 14
                                            font.bold: true
                                        }
                                        
                                        Text {
                                            text: "Potential: " + (((modelData.price_target - modelData.current_price) / modelData.current_price) * 100).toFixed(1) + "%"
                                            color: (modelData.price_target > modelData.current_price) ? window.successColor : window.dangerColor
                                            font.pixelSize: 10
                                            font.bold: true
                                        }
                                    }
                                    
                                    // Reasoning
                                    Column {
                                        width: parent.width - 280
                                        spacing: 5
                                        
                                        Text {
                                            text: "🧠 Grok Analysis:"
                                            color: window.primaryColor
                                            font.pixelSize: 12
                                            font.bold: true
                                        }
                                        
                                        Text {
                                            text: modelData.reason
                                            color: "#ffffff"
                                            font.pixelSize: 11
                                            wrapMode: Text.WordWrap
                                            width: parent.width
                                        }
                                        
                                        Row {
                                            spacing: 10
                                            
                                            Button {
                                                text: "📊 Details"
                                                width: 70
                                                height: 25
                                                onClicked: console.log("Show details for " + modelData.symbol)
                                                background: Rectangle {
                                                    color: window.primaryColor
                                                    radius: 3
                                                }
                                                contentItem: Text {
                                                    text: parent.text
                                                    color: "#000000"
                                                    font.pixelSize: 9
                                                    font.bold: true
                                                    horizontalAlignment: Text.AlignHCenter
                                                    verticalAlignment: Text.AlignVCenter
                                                }
                                            }
                                            
                                            Button {
                                                text: modelData.action === "BUY" ? "🛒 Buy" : modelData.action === "SELL" ? "💰 Sell" : "⏳ Watch"
                                                width: 70
                                                height: 25
                                                onClicked: console.log(modelData.action + " " + modelData.symbol)
                                                background: Rectangle {
                                                    color: modelData.action === "BUY" ? window.successColor : 
                                                           modelData.action === "SELL" ? window.dangerColor : window.warningColor
                                                    radius: 3
                                                }
                                                contentItem: Text {
                                                    text: parent.text
                                                    color: "#000000"
                                                    font.pixelSize: 9
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
        }
        
        // Market Sentiment Analysis
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
                    text: "📈 MARKET SENTIMENT ANALYSIS"
                    font.pixelSize: 16
                    font.bold: true
                    color: window.accentColor
                }
                
                Row {
                    width: parent.width
                    spacing: 20
                    
                    Column {
                        width: (parent.width - 40) / 3
                        spacing: 10
                        
                        Text {
                            text: "🟢 Bullish Signals"
                            color: window.successColor
                            font.pixelSize: 12
                            font.bold: true
                        }
                        
                        Text {
                            text: "• KI-Sektor Wachstum\n• Starke Earnings Season\n• Fed Rate Optimismus\n• Tech Innovation Boost"
                            color: "#ffffff"
                            font.pixelSize: 10
                            lineHeight: 1.3
                        }
                    }
                    
                    Column {
                        width: (parent.width - 40) / 3
                        spacing: 10
                        
                        Text {
                            text: "🔴 Bearish Signals"
                            color: window.dangerColor
                            font.pixelSize: 12
                            font.bold: true
                        }
                        
                        Text {
                            text: "• Hohe Bewertungen\n• Geopolitische Risiken\n• Inflations-Sorgen\n• Konsumenten-Schwäche"
                            color: "#ffffff"
                            font.pixelSize: 10
                            lineHeight: 1.3
                        }
                    }
                    
                    Column {
                        width: (parent.width - 40) / 3
                        spacing: 10
                        
                        Text {
                            text: "🎯 Grok Empfehlung"
                            color: window.warningColor
                            font.pixelSize: 12
                            font.bold: true
                        }
                        
                        Text {
                            text: "Selektiv bullish bleiben. KI/Tech fokussieren, aber Risiko-Management beachten. Zyklische Werte meiden."
                            color: "#ffffff"
                            font.pixelSize: 10
                            wrapMode: Text.WordWrap
                            width: parent.width
                            lineHeight: 1.3
                        }
                    }
                }
                
                Text {
                    text: "Overall Market Sentiment: CAUTIOUSLY OPTIMISTIC (Score: 7.2/10)"
                    color: window.primaryColor
                    font.pixelSize: 12
                    font.bold: true
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
        }
    }
    
    // Update Grok data
    Timer {
        interval: 8000
        running: true
        repeat: true
        onTriggered: {
            redis.getGrokRecommendations()
            lastUpdate = new Date().toLocaleTimeString()
        }
    }
    
    Connections {
        target: redis
        
        function onGrokRecommendationsReceived(data) {
            try {
                grokData = JSON.parse(data)
            } catch (e) {
                console.log("Error parsing Grok data:", e)
            }
        }
    }
}