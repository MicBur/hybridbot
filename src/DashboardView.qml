import QtQuick 2.15
import QtQuick.Controls 2.15

ScrollView {
    id: root
    
    property alias redisClient: redisConnection
    
    Rectangle {
        width: root.width
        height: root.height
        color: "#0a0a0a"
        
        Grid {
            id: tilesGrid
            anchors.fill: parent
            anchors.margins: 20
            columns: 4
            spacing: 20
            
            // Market Data Tiles
            GlassTile {
                width: (parent.width - 3 * parent.spacing) / 4
                height: 120
                title: "AAPL"
                value: "$234.07"
                subtitle: "+1.76%"
                accentColor: "#00ff00"
            }
            
            GlassTile {
                width: (parent.width - 3 * parent.spacing) / 4
                height: 120
                title: "NVDA"
                value: "$842.33"
                subtitle: "+2.43%"
                accentColor: "#00ff00"
            }
            
            GlassTile {
                width: (parent.width - 3 * parent.spacing) / 4
                height: 120
                title: "MSFT"
                value: "$412.18"
                subtitle: "-0.87%"
                accentColor: "#ff0066"
            }
            
            GlassTile {
                width: (parent.width - 3 * parent.spacing) / 4
                height: 120
                title: "TSLA"
                value: "$248.91"
                subtitle: "+3.21%"
                accentColor: "#00ff00"
            }
            
            // Portfolio Overview
            GlassTile {
                width: (parent.width - parent.spacing) / 2
                height: 160
                title: "Portfolio Value"
                value: "$125,430.50"
                subtitle: "Buying Power: $25,000"
                accentColor: "#00ffff"
            }
            
            GlassTile {
                width: (parent.width - parent.spacing) / 2
                height: 160
                title: "P&L Today"
                value: "+$2,847.33"
                subtitle: "+2.3% unrealized"
                accentColor: "#00ff00"
            }
            
            // ML Status
            GlassTile {
                width: (parent.width - 2 * parent.spacing) / 3
                height: 140
                title: "Model Status"
                value: "Trained"
                subtitle: "Accuracy: 87%"
                accentColor: "#00ffff"
            }
            
            GlassTile {
                width: (parent.width - 2 * parent.spacing) / 3
                height: 140
                title: "Active Trades"
                value: "3"
                subtitle: "Pending: 1"
                accentColor: "#ffaa00"
            }
            
            GlassTile {
                width: (parent.width - 2 * parent.spacing) / 3
                height: 140
                title: "Redis Status"
                value: redisConnection.connected ? "Connected" : "Disconnected"
                subtitle: "Port 6380"
                accentColor: "#00ffff"
            }
        }
    }
    
    // Redis connection placeholder
    Item {
        id: redisConnection
        property bool connected: false
        
        Timer {
            interval: 5000
            running: true
            repeat: true
            onTriggered: {
                // Simulate connection status
                redisConnection.connected = Math.random() > 0.1
            }
        }
    }
}