import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle {
    id: root
    color: "#0a0a0a"
    
    Column {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 20
        
        // Trading Status Overview
        Row {
            width: parent.width
            height: 120
            spacing: 20
            
            GlassTile {
                width: (parent.width - 3 * parent.spacing) / 4
                height: parent.height
                title: "Active Orders"
                value: "3"
                subtitle: "Live"
                accentColor: "#00ffff"
            }
            
            GlassTile {
                width: (parent.width - 3 * parent.spacing) / 4
                height: parent.height
                title: "Filled Today"
                value: "12"
                subtitle: "Orders"
                accentColor: "#00ff00"
            }
            
            GlassTile {
                width: (parent.width - 3 * parent.spacing) / 4
                height: parent.height
                title: "P&L Trading"
                value: "+$1,234.56"
                subtitle: "Today"
                accentColor: "#00ff00"
            }
            
            GlassTile {
                width: (parent.width - 3 * parent.spacing) / 4
                height: parent.height
                title: "Success Rate"
                value: "87%"
                subtitle: "This week"
                accentColor: "#00ffff"
            }
        }
        
        // Active Orders Table
        Rectangle {
            width: parent.width
            height: 300
            color: "#1a1a1a"
            radius: 12
            border.color: "#00ffff"
            border.width: 1
            
            Column {
                anchors.fill: parent
                anchors.margins: 15
                spacing: 10
                
                Text {
                    text: "Active Orders"
                    color: "#00ffff"
                    font.pixelSize: 18
                    font.weight: Font.Bold
                }
                
                // Table Header
                Rectangle {
                    width: parent.width
                    height: 40
                    color: "#2a2a2a"
                    radius: 6
                    
                    Row {
                        anchors.left: parent.left
                        anchors.leftMargin: 15
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 80
                        
                        Text { text: "Symbol"; color: "#ffffff"; font.weight: Font.Bold; width: 80 }
                        Text { text: "Side"; color: "#ffffff"; font.weight: Font.Bold; width: 60 }
                        Text { text: "Quantity"; color: "#ffffff"; font.weight: Font.Bold; width: 80 }
                        Text { text: "Price"; color: "#ffffff"; font.weight: Font.Bold; width: 100 }
                        Text { text: "Status"; color: "#ffffff"; font.weight: Font.Bold; width: 100 }
                        Text { text: "Time"; color: "#ffffff"; font.weight: Font.Bold; width: 120 }
                    }
                }
                
                ListView {
                    width: parent.width
                    height: parent.height - 70
                    model: activeOrdersModel
                    
                    delegate: Rectangle {
                        width: parent.width
                        height: 45
                        color: index % 2 === 0 ? "#1a1a1a" : "#2a2a2a"
                        
                        Row {
                            anchors.left: parent.left
                            anchors.leftMargin: 15
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 80
                            
                            Text {
                                text: model.symbol
                                color: "#ffffff"
                                font.pixelSize: 14
                                font.weight: Font.Bold
                                width: 80
                            }
                            
                            Rectangle {
                                width: 50
                                height: 25
                                radius: 12
                                color: model.side === "BUY" ? "#00ff0040" : "#ff006640"
                                border.color: model.side === "BUY" ? "#00ff00" : "#ff0066"
                                border.width: 1
                                
                                Text {
                                    anchors.centerIn: parent
                                    text: model.side
                                    color: model.side === "BUY" ? "#00ff00" : "#ff0066"
                                    font.pixelSize: 10
                                    font.weight: Font.Bold
                                }
                            }
                            
                            Text {
                                text: model.quantity
                                color: "#cccccc"
                                font.pixelSize: 12
                                width: 80
                            }
                            
                            Text {
                                text: "$" + model.price
                                color: "#cccccc"
                                font.pixelSize: 12
                                width: 100
                            }
                            
                            Rectangle {
                                width: 80
                                height: 20
                                radius: 10
                                color: getStatusColor(model.status)
                                
                                Text {
                                    anchors.centerIn: parent
                                    text: model.status
                                    color: "#ffffff"
                                    font.pixelSize: 9
                                    font.weight: Font.Bold
                                }
                            }
                            
                            Text {
                                text: model.time
                                color: "#cccccc"
                                font.pixelSize: 11
                                width: 120
                            }
                        }
                    }
                }
            }
        }
        
        // Recent Trades
        Rectangle {
            width: parent.width
            height: 250
            color: "#1a1a1a"
            radius: 12
            border.color: "#00ffff"
            border.width: 1
            
            Column {
                anchors.fill: parent
                anchors.margins: 15
                spacing: 10
                
                Text {
                    text: "Recent Trades (Last 24h)"
                    color: "#00ffff"
                    font.pixelSize: 18
                    font.weight: Font.Bold
                }
                
                ListView {
                    width: parent.width
                    height: parent.height - 40
                    model: recentTradesModel
                    
                    delegate: Rectangle {
                        width: parent.width
                        height: 40
                        color: "transparent"
                        
                        Row {
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 15
                            
                            Rectangle {
                                width: 8
                                height: 8
                                radius: 4
                                color: model.side === "BUY" ? "#00ff00" : "#ff0066"
                            }
                            
                            Text {
                                text: model.symbol
                                color: "#ffffff"
                                font.pixelSize: 14
                                font.weight: Font.Bold
                                width: 80
                            }
                            
                            Text {
                                text: model.side + " " + model.quantity
                                color: "#cccccc"
                                font.pixelSize: 12
                                width: 100
                            }
                            
                            Text {
                                text: "@ $" + model.price
                                color: "#cccccc"
                                font.pixelSize: 12
                                width: 100
                            }
                            
                            Text {
                                text: model.pl
                                color: model.pl.startsWith("+") ? "#00ff00" : "#ff0066"
                                font.pixelSize: 12
                                font.weight: Font.Bold
                                width: 100
                            }
                            
                            Text {
                                text: model.time
                                color: "#666666"
                                font.pixelSize: 11
                                width: 80
                            }
                        }
                    }
                }
            }
        }
    }
    
    function getStatusColor(status) {
        switch (status) {
            case "PENDING": return "#ffaa0060"
            case "FILLED": return "#00ff0060"
            case "PARTIAL": return "#00ffff60"
            case "CANCELED": return "#ff006660"
            default: return "#666666"
        }
    }
    
    // Sample active orders data
    ListModel {
        id: activeOrdersModel
        
        ListElement { 
            symbol: "AAPL"; side: "BUY"; quantity: "100"; price: "233.50"; 
            status: "PENDING"; time: "14:32:15" 
        }
        ListElement { 
            symbol: "NVDA"; side: "SELL"; quantity: "50"; price: "845.20"; 
            status: "PARTIAL"; time: "14:28:43" 
        }
        ListElement { 
            symbol: "MSFT"; side: "BUY"; quantity: "75"; price: "411.80"; 
            status: "FILLED"; time: "14:15:22" 
        }
    }
    
    // Sample recent trades data
    ListModel {
        id: recentTradesModel
        
        ListElement { 
            symbol: "TSLA"; side: "BUY"; quantity: "25"; price: "248.91"; 
            pl: "+$82.50"; time: "13:45" 
        }
        ListElement { 
            symbol: "AAPL"; side: "SELL"; quantity: "50"; price: "234.07"; 
            pl: "+$185.00"; time: "12:30" 
        }
        ListElement { 
            symbol: "NVDA"; side: "BUY"; quantity: "20"; price: "842.33"; 
            pl: "-$45.20"; time: "11:15" 
        }
        ListElement { 
            symbol: "MSFT"; side: "SELL"; quantity: "100"; price: "412.18"; 
            pl: "+$456.80"; time: "10:45" 
        }
    }
}