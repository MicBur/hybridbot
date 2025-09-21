import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Redis 1.0

ApplicationWindow {
    id: root
    visible: true
    width: 800
    height: 600
    title: "6bot Redis Connection Test"
    
    property bool autoTradingEnabled: false
    
    Rectangle {
        anchors.fill: parent
        color: "#1a1a1a"
        
        ColumnLayout {
            anchors.centerIn: parent
            spacing: 30
            
            Text {
                text: "🔌 Redis Connection Test"
                color: "#00ffff" 
                font.pixelSize: 24
                font.bold: true
                Layout.alignment: Qt.AlignHCenter
            }
            
            // Connection Status
            Rectangle {
                Layout.preferredWidth: 400
                Layout.preferredHeight: 100
                color: "#2a2a2a"
                border.color: redisClient.connected ? "#00ff00" : "#ff4444"
                border.width: 3
                radius: 10
                
                ColumnLayout {
                    anchors.centerIn: parent
                    
                    Text {
                        text: redisClient.connected ? "✅ REDIS VERBUNDEN" : "❌ REDIS GETRENNT"
                        color: redisClient.connected ? "#00ff00" : "#ff4444"
                        font.pixelSize: 18
                        font.bold: true
                        Layout.alignment: Qt.AlignHCenter
                    }
                    
                    Text {
                        text: `Host: ${redisClient.host}:${redisClient.port}`
                        color: "#ffffff"
                        font.pixelSize: 14
                        Layout.alignment: Qt.AlignHCenter
                    }
                }
            }
            
            // Connect Button
            Button {
                text: redisClient.connected ? "🔌 Verbunden" : "🔄 Verbinden"
                enabled: !redisClient.connected
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: 200
                Layout.preferredHeight: 50
                
                background: Rectangle {
                    color: redisClient.connected ? "#00ff00" : "#0066cc"
                    radius: 10
                }
                
                contentItem: Text {
                    text: parent.text
                    color: "#ffffff"
                    font.pixelSize: 16
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                
                onClicked: {
                    console.log("🔄 Connecting to Redis...")
                    redisClient.connectToRedis()
                }
            }
            
            // Auto-Trading Test
            Rectangle {
                Layout.preferredWidth: 400
                Layout.preferredHeight: 150
                color: "#2a2a2a"
                border.color: "#ffaa00"
                border.width: 2
                radius: 10
                visible: redisClient.connected
                
                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 15
                    
                    Text {
                        text: "🤖 AUTO-TRADING TEST"
                        color: "#ffaa00"
                        font.pixelSize: 16
                        font.bold: true
                        Layout.alignment: Qt.AlignHCenter
                    }
                    
                    Button {
                        text: autoTradingEnabled ? "⏸️ TRADING STOPPEN" : "▶️ TRADING STARTEN"
                        Layout.alignment: Qt.AlignHCenter
                        Layout.preferredWidth: 250
                        Layout.preferredHeight: 45
                        
                        background: Rectangle {
                            color: autoTradingEnabled ? "#ff4444" : "#00ff00"
                            radius: 8
                        }
                        
                        contentItem: Text {
                            text: parent.text
                            color: "#000000"
                            font.pixelSize: 14
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        
                        onClicked: {
                            console.log("🔄 Toggling auto-trading:", !autoTradingEnabled)
                            redisClient.enableAutoTrading(!autoTradingEnabled)
                            autoTradingEnabled = !autoTradingEnabled
                        }
                    }
                    
                    Text {
                        text: autoTradingEnabled ? "🟢 AKTIV" : "🔴 GESTOPPT"
                        color: autoTradingEnabled ? "#00ff00" : "#ff4444"
                        font.pixelSize: 14
                        font.bold: true
                        Layout.alignment: Qt.AlignHCenter
                    }
                }
            }
        }
    }
    
    // Redis Client - Configured for port 6380
    RedisClient {
        id: redisClient
        host: "localhost"
        port: 6380
        password: "pass123"
        
        Component.onCompleted: {
            console.log("🚀 Redis Client initialized - connecting to localhost:6380")
            connectToRedis()
        }
        
        onConnectedChanged: {
            console.log("📡 Redis connection changed:", connected)
            if (connected) {
                console.log("✅ Successfully connected to Redis on port 6380")
            } else {
                console.log("❌ Redis connection lost")
            }
        }
        
        onDataReceived: {
            console.log("📨 Redis data received:", key, data)
        }
        
        onErrorOccurred: {
            console.log("❌ Redis error:", error)
        }
        
        onAutoTradingStatusChanged: {
            console.log("🤖 Auto-trading status changed:", enabled)
            autoTradingEnabled = enabled
        }
    }
}