import QtQuick 2.12
import QtQuick.Controls 2.12

ApplicationWindow {
    id: window
    width: 1200
    height: 800
    visible: true
    title: "6bot Portfolio & Trading Suite"
    color: "#0a0a0a"
    
    // Navigation bar
    Rectangle {
        id: navbar
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 60
        color: "#1a1a1a"
        border.color: "#00ffff"
        border.width: 2
        
        Row {
            anchors.centerIn: parent
            spacing: 20
            
            Button {
                text: "Dashboard"
                width: 120
                height: 40
                background: Rectangle {
                    color: stack.currentIndex === 0 ? "#00ffff" : "#333333"
                    radius: 8
                }
                onClicked: stack.currentIndex = 0
            }
            
            Button {
                text: "Portfolio"
                width: 120
                height: 40
                background: Rectangle {
                    color: stack.currentIndex === 1 ? "#00ffff" : "#333333"
                    radius: 8
                }
                onClicked: stack.currentIndex = 1
            }
            
            Button {
                text: "ML Models"
                width: 120
                height: 40
                background: Rectangle {
                    color: stack.currentIndex === 2 ? "#00ffff" : "#333333"
                    radius: 8
                }
                onClicked: stack.currentIndex = 2
            }
            
            Button {
                text: "Grok AI"
                width: 120
                height: 40
                background: Rectangle {
                    color: stack.currentIndex === 3 ? "#00ffff" : "#333333"
                    radius: 8
                }
                onClicked: stack.currentIndex = 3
            }
            
            Button {
                text: "Trading"
                width: 120
                height: 40
                background: Rectangle {
                    color: stack.currentIndex === 4 ? "#00ffff" : "#333333"
                    radius: 8
                }
                onClicked: stack.currentIndex = 4
            }
        }
    }
    
    // Main content area
    StackLayout {
        id: stack
        anchors.top: navbar.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 20
        currentIndex: 0
        
        // Dashboard
        Rectangle {
            color: "#1a1a1a"
            border.color: "#00ffff"
            border.width: 1
            radius: 10
            
            Column {
                anchors.centerIn: parent
                spacing: 30
                
                Text {
                    text: "📊 DASHBOARD"
                    font.pixelSize: 32
                    color: "#00ffff"
                    font.bold: true
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                
                Row {
                    spacing: 40
                    anchors.horizontalCenter: parent.horizontalCenter
                    
                    Rectangle {
                        width: 200
                        height: 100
                        color: "#2a2a2a"
                        border.color: "#00ffff"
                        border.width: 2
                        radius: 10
                        
                        Column {
                            anchors.centerIn: parent
                            Text {
                                text: "Portfolio Value"
                                color: "#cccccc"
                                font.pixelSize: 12
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                            Text {
                                text: "$109,329.05"
                                color: "#00ffff"
                                font.pixelSize: 18
                                font.bold: true
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                            Text {
                                text: "+2.67%"
                                color: "#00ff00"
                                font.pixelSize: 12
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                        }
                    }
                    
                    Rectangle {
                        width: 200
                        height: 100
                        color: "#2a2a2a"
                        border.color: "#00ff00"
                        border.width: 2
                        radius: 10
                        
                        Column {
                            anchors.centerIn: parent
                            Text {
                                text: "ML Accuracy"
                                color: "#cccccc"
                                font.pixelSize: 12
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                            Text {
                                text: "87.3%"
                                color: "#00ff00"
                                font.pixelSize: 20
                                font.bold: true
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                            Text {
                                text: "LSTM Model"
                                color: "#cccccc"
                                font.pixelSize: 10
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                        }
                    }
                    
                    Rectangle {
                        width: 200
                        height: 100
                        color: "#2a2a2a"
                        border.color: "#ffaa00"
                        border.width: 2
                        radius: 10
                        
                        Column {
                            anchors.centerIn: parent
                            Text {
                                text: "Grok Recommendations"
                                color: "#cccccc"
                                font.pixelSize: 12
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                            Text {
                                text: "8"
                                color: "#ffaa00"
                                font.pixelSize: 20
                                font.bold: true
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                            Text {
                                text: "Active Signals"
                                color: "#cccccc"
                                font.pixelSize: 10
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                        }
                    }
                }
                
                Text {
                    text: "🚀 System Status: ONLINE"
                    color: "#00ff00"
                    font.pixelSize: 16
                    font.bold: true
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
        }
        
        // Portfolio
        Rectangle {
            color: "#1a1a1a"
            border.color: "#00ffff"
            border.width: 1
            radius: 10
            
            Column {
                anchors.fill: parent
                anchors.margins: 30
                spacing: 20
                
                Text {
                    text: "💼 PORTFOLIO MANAGEMENT"
                    font.pixelSize: 28
                    color: "#00ffff"
                    font.bold: true
                }
                
                Text {
                    text: "Top Holdings:"
                    color: "#ffffff"
                    font.pixelSize: 16
                    font.bold: true
                }
                
                Column {
                    width: parent.width
                    spacing: 10
                    
                    Rectangle {
                        width: parent.width
                        height: 40
                        color: "#2a2a2a"
                        radius: 5
                        
                        Row {
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 40
                            
                            Text { text: "NVDA"; color: "#00ffff"; font.bold: true; width: 60 }
                            Text { text: "$29,630"; color: "#ffffff"; width: 80 }
                            Text { text: "27.1%"; color: "#cccccc"; width: 60 }
                            Text { text: "+5.7%"; color: "#00ff00"; font.bold: true }
                        }
                    }
                    
                    Rectangle {
                        width: parent.width
                        height: 40
                        color: "#252525"
                        radius: 5
                        
                        Row {
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 40
                            
                            Text { text: "MSFT"; color: "#00ffff"; font.bold: true; width: 60 }
                            Text { text: "$30,964"; color: "#ffffff"; width: 80 }
                            Text { text: "28.3%"; color: "#cccccc"; width: 60 }
                            Text { text: "+2.1%"; color: "#00ff00"; font.bold: true }
                        }
                    }
                    
                    Rectangle {
                        width: parent.width
                        height: 40
                        color: "#2a2a2a"
                        radius: 5
                        
                        Row {
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 40
                            
                            Text { text: "META"; color: "#00ffff"; font.bold: true; width: 60 }
                            Text { text: "$20,238"; color: "#ffffff"; width: 80 }
                            Text { text: "18.5%"; color: "#cccccc"; width: 60 }
                            Text { text: "+3.8%"; color: "#00ff00"; font.bold: true }
                        }
                    }
                    
                    Rectangle {
                        width: parent.width
                        height: 40
                        color: "#252525"
                        radius: 5
                        
                        Row {
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 40
                            
                            Text { text: "AAPL"; color: "#00ffff"; font.bold: true; width: 60 }
                            Text { text: "$11,705"; color: "#ffffff"; width: 80 }
                            Text { text: "10.7%"; color: "#cccccc"; width: 60 }
                            Text { text: "+1.2%"; color: "#00ff00"; font.bold: true }
                        }
                    }
                }
            }
        }
        
        // ML Models
        Rectangle {
            color: "#1a1a1a"
            border.color: "#00ffff"
            border.width: 1
            radius: 10
            
            Column {
                anchors.fill: parent
                anchors.margins: 30
                spacing: 20
                
                Text {
                    text: "🤖 MACHINE LEARNING MODELS"
                    font.pixelSize: 28
                    color: "#00ffff"
                    font.bold: true
                }
                
                Grid {
                    columns: 2
                    columnSpacing: 20
                    rowSpacing: 15
                    
                    Rectangle {
                        width: 250
                        height: 80
                        color: "#1a2a1a"
                        border.color: "#00ff00"
                        border.width: 2
                        radius: 8
                        
                        Column {
                            anchors.centerIn: parent
                            Text {
                                text: "LSTM Neural Network"
                                color: "#00ff00"
                                font.pixelSize: 14
                                font.bold: true
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                            Text {
                                text: "Accuracy: 89.2%"
                                color: "#ffffff"
                                font.pixelSize: 12
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                        }
                    }
                    
                    Rectangle {
                        width: 250
                        height: 80
                        color: "#1a1a2a"
                        border.color: "#00ffff"
                        border.width: 2
                        radius: 8
                        
                        Column {
                            anchors.centerIn: parent
                            Text {
                                text: "Random Forest"
                                color: "#00ffff"
                                font.pixelSize: 14
                                font.bold: true
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                            Text {
                                text: "Accuracy: 84.7%"
                                color: "#ffffff"
                                font.pixelSize: 12
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                        }
                    }
                    
                    Rectangle {
                        width: 250
                        height: 80
                        color: "#2a1a1a"
                        border.color: "#ffaa00"
                        border.width: 2
                        radius: 8
                        
                        Column {
                            anchors.centerIn: parent
                            Text {
                                text: "Transformer Model"
                                color: "#ffaa00"
                                font.pixelSize: 14
                                font.bold: true
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                            Text {
                                text: "Training... 67%"
                                color: "#ffffff"
                                font.pixelSize: 12
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                        }
                    }
                    
                    Rectangle {
                        width: 250
                        height: 80
                        color: "#1a1a2a"
                        border.color: "#ff6b6b"
                        border.width: 2
                        radius: 8
                        
                        Column {
                            anchors.centerIn: parent
                            Text {
                                text: "Ensemble Model"
                                color: "#ff6b6b"
                                font.pixelSize: 14
                                font.bold: true
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                            Text {
                                text: "Accuracy: 91.8%"
                                color: "#ffffff"
                                font.pixelSize: 12
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                        }
                    }
                }
            }
        }
        
        // Grok AI
        Rectangle {
            color: "#1a1a1a"
            border.color: "#00ffff"
            border.width: 1
            radius: 10
            
            Column {
                anchors.fill: parent
                anchors.margins: 30
                spacing: 20
                
                Text {
                    text: "🧠 GROK AI RECOMMENDATIONS"
                    font.pixelSize: 28
                    color: "#00ffff"
                    font.bold: true
                }
                
                Text {
                    text: "Top AI Signals:"
                    color: "#ffffff"
                    font.pixelSize: 16
                    font.bold: true
                }
                
                Column {
                    width: parent.width
                    spacing: 10
                    
                    Rectangle {
                        width: parent.width
                        height: 60
                        color: "#1a2a1a"
                        border.color: "#00ff00"
                        border.width: 1
                        radius: 8
                        
                        Row {
                            anchors.fill: parent
                            anchors.margins: 15
                            spacing: 30
                            
                            Column {
                                Text { text: "NVDA"; color: "#00ffff"; font.bold: true; font.pixelSize: 14 }
                                Rectangle {
                                    width: 40; height: 16; color: "#00ff00"; radius: 8
                                    Text { text: "BUY"; color: "#000000"; font.pixelSize: 8; font.bold: true; anchors.centerIn: parent }
                                }
                            }
                            
                            Column {
                                Text { text: "Target: $1,350"; color: "#00ffff"; font.pixelSize: 11 }
                                Text { text: "Confidence: 96.2%"; color: "#cccccc"; font.pixelSize: 10 }
                            }
                            
                            Text {
                                text: "KI-Boom und starke Quartalszahlen erwartet"
                                color: "#ffffff"
                                font.pixelSize: 10
                                width: 300
                                wrapMode: Text.WordWrap
                            }
                        }
                    }
                    
                    Rectangle {
                        width: parent.width
                        height: 60
                        color: "#1a1a2a"
                        border.color: "#00ff00"
                        border.width: 1
                        radius: 8
                        
                        Row {
                            anchors.fill: parent
                            anchors.margins: 15
                            spacing: 30
                            
                            Column {
                                Text { text: "AAPL"; color: "#00ffff"; font.bold: true; font.pixelSize: 14 }
                                Rectangle {
                                    width: 40; height: 16; color: "#00ff00"; radius: 8
                                    Text { text: "BUY"; color: "#000000"; font.pixelSize: 8; font.bold: true; anchors.centerIn: parent }
                                }
                            }
                            
                            Column {
                                Text { text: "Target: $260"; color: "#00ffff"; font.pixelSize: 11 }
                                Text { text: "Confidence: 89.3%"; color: "#cccccc"; font.pixelSize: 10 }
                            }
                            
                            Text {
                                text: "iPhone 16 Launch läuft gut, Services stabil"
                                color: "#ffffff"
                                font.pixelSize: 10
                                width: 300
                                wrapMode: Text.WordWrap
                            }
                        }
                    }
                    
                    Rectangle {
                        width: parent.width
                        height: 60
                        color: "#2a1a1a"
                        border.color: "#ffaa00"
                        border.width: 1
                        radius: 8
                        
                        Row {
                            anchors.fill: parent
                            anchors.margins: 15
                            spacing: 30
                            
                            Column {
                                Text { text: "TSLA"; color: "#00ffff"; font.bold: true; font.pixelSize: 14 }
                                Rectangle {
                                    width: 40; height: 16; color: "#ffaa00"; radius: 8
                                    Text { text: "HOLD"; color: "#000000"; font.pixelSize: 8; font.bold: true; anchors.centerIn: parent }
                                }
                            }
                            
                            Column {
                                Text { text: "Target: $280"; color: "#00ffff"; font.pixelSize: 11 }
                                Text { text: "Confidence: 78.5%"; color: "#cccccc"; font.pixelSize: 10 }
                            }
                            
                            Text {
                                text: "Autopilot Updates positiv, aber Bewertung hoch"
                                color: "#ffffff"
                                font.pixelSize: 10
                                width: 300
                                wrapMode: Text.WordWrap
                            }
                        }
                    }
                }
            }
        }
        
        // Trading
        Rectangle {
            color: "#1a1a1a"
            border.color: "#00ffff"
            border.width: 1
            radius: 10
            
            Column {
                anchors.fill: parent
                anchors.margins: 30
                spacing: 20
                
                Text {
                    text: "📈 TRADING TERMINAL"
                    font.pixelSize: 28
                    color: "#00ffff"
                    font.bold: true
                }
                
                Row {
                    spacing: 30
                    
                    Rectangle {
                        width: 150
                        height: 60
                        color: "#2a2a2a"
                        border.color: "#00ff00"
                        border.width: 2
                        radius: 10
                        
                        Column {
                            anchors.centerIn: parent
                            Text { text: "Buying Power"; color: "#cccccc"; font.pixelSize: 10; anchors.horizontalCenter: parent.horizontalCenter }
                            Text { text: "$25,670"; color: "#00ff00"; font.pixelSize: 14; font.bold: true; anchors.horizontalCenter: parent.horizontalCenter }
                        }
                    }
                    
                    Rectangle {
                        width: 150
                        height: 60
                        color: "#2a2a2a"
                        border.color: "#00ffff"
                        border.width: 2
                        radius: 10
                        
                        Column {
                            anchors.centerIn: parent
                            Text { text: "Day P&L"; color: "#cccccc"; font.pixelSize: 10; anchors.horizontalCenter: parent.horizontalCenter }
                            Text { text: "+$2,847"; color: "#00ff00"; font.pixelSize: 14; font.bold: true; anchors.horizontalCenter: parent.horizontalCenter }
                        }
                    }
                    
                    Rectangle {
                        width: 150
                        height: 60
                        color: "#2a2a2a"
                        border.color: "#ffaa00"
                        border.width: 2
                        radius: 10
                        
                        Column {
                            anchors.centerIn: parent
                            Text { text: "Open Orders"; color: "#cccccc"; font.pixelSize: 10; anchors.horizontalCenter: parent.horizontalCenter }
                            Text { text: "3"; color: "#ffaa00"; font.pixelSize: 14; font.bold: true; anchors.horizontalCenter: parent.horizontalCenter }
                        }
                    }
                }
                
                Rectangle {
                    width: parent.width * 0.8
                    height: 150
                    color: "#2a2a2a"
                    border.color: "#00ffff"
                    border.width: 2
                    radius: 10
                    
                    Column {
                        anchors.centerIn: parent
                        spacing: 15
                        
                        Text {
                            text: "Quick Order Entry"
                            color: "#00ffff"
                            font.pixelSize: 16
                            font.bold: true
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                        
                        Row {
                            spacing: 20
                            anchors.horizontalCenter: parent.horizontalCenter
                            
                            Column {
                                Text { text: "Symbol: AAPL"; color: "#ffffff"; font.pixelSize: 12 }
                                Text { text: "Price: $234.10"; color: "#00ffff"; font.pixelSize: 12 }
                                Text { text: "Quantity: 10"; color: "#ffffff"; font.pixelSize: 12 }
                            }
                            
                            Column {
                                Button {
                                    text: "BUY"
                                    width: 80
                                    height: 30
                                    background: Rectangle { color: "#00ff00"; radius: 6 }
                                }
                                Button {
                                    text: "SELL"
                                    width: 80
                                    height: 30
                                    background: Rectangle { color: "#ff4444"; radius: 6 }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}