import QtQuick 2.15
import QtQuick.Controls 2.15
import QtDataVisualization 1.15

Rectangle {
    id: root
    color: "#0a0a0a"
    
    Row {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 20
        
        // Left side - 3D Candlestick Chart
        Rectangle {
            width: parent.width * 0.7
            height: parent.height
            color: "#1a1a1a"
            radius: 12
            border.color: "#00ffff"
            border.width: 1
            
            Bars3D {
                id: candlestickChart
                anchors.fill: parent
                anchors.margins: 10
                
                theme: Theme3D {
                    type: Theme3D.ThemeEbony
                    labelBackgroundEnabled: true
                    colorStyle: Theme3D.ColorStyleUniform
                    baseColor: "#00ffff"
                    backgroundColor: "#0a0a0a"
                    windowColor: "#0a0a0a"
                    labelTextColor: "#ffffff"
                    gridLineColor: "#333333"
                }
                
                scene: Scene3D {
                    activeCamera: Camera3D {
                        cameraPreset: Camera3D.CameraPresetIsometricLeft
                    }
                }
                
                Bar3DSeries {
                    id: ohlcSeries
                    name: "OHLC Data"
                    baseColor: "#00ffff"
                    
                    ItemModelBarDataProxy {
                        itemModel: candlestickModel
                        rowRole: "timestamp"
                        columnRole: "type"
                        valueRole: "price"
                    }
                }
                
                rowAxis: CategoryAxis3D {
                    title: "Time"
                    labels: ["09:30", "10:00", "10:30", "11:00", "11:30", "12:00"]
                    labelFormat: "%s"
                }
                
                columnAxis: CategoryAxis3D {
                    title: "OHLC"
                    labels: ["Open", "High", "Low", "Close"]
                }
                
                valueAxis: ValueAxis3D {
                    title: "Price ($)"
                    labelFormat: "$%.2f"
                    min: 230
                    max: 240
                }
            }
            
            // Chart title
            Text {
                anchors.top: parent.top
                anchors.topMargin: 15
                anchors.horizontalCenter: parent.horizontalCenter
                text: "AAPL - 3D Candlestick Chart"
                color: "#00ffff"
                font.pixelSize: 18
                font.weight: Font.Bold
            }
        }
        
        // Right side - Controls and Info
        Column {
            width: parent.width * 0.25
            height: parent.height
            spacing: 20
            
            GlassTile {
                width: parent.width
                height: 120
                title: "Current Price"
                value: "$234.07"
                subtitle: "AAPL"
                accentColor: "#00ffff"
            }
            
            GlassTile {
                width: parent.width
                height: 120
                title: "ML Prediction"
                value: "$236.40"
                subtitle: "15min forecast"
                accentColor: "#00ff00"
            }
            
            GlassTile {
                width: parent.width
                height: 120
                title: "Volume"
                value: "45.2M"
                subtitle: "Today"
                accentColor: "#ffaa00"
            }
            
            Rectangle {
                width: parent.width
                height: 200
                color: "#1a1a1a"
                radius: 12
                border.color: "#00ffff"
                border.width: 1
                
                Column {
                    anchors.centerIn: parent
                    spacing: 10
                    
                    Text {
                        text: "Chart Controls"
                        color: "#00ffff"
                        font.pixelSize: 16
                        font.weight: Font.Bold
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    
                    Button {
                        text: "Reset View"
                        onClicked: {
                            candlestickChart.scene.activeCamera.cameraPreset = Camera3D.CameraPresetIsometricLeft
                        }
                        
                        background: Rectangle {
                            color: parent.pressed ? "#00ffff" : "#2a2a2a"
                            opacity: parent.pressed ? 0.3 : 1.0
                            radius: 6
                        }
                        
                        contentItem: Text {
                            text: parent.text
                            color: "#ffffff"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                    
                    Button {
                        text: "Animate"
                        onClicked: {
                            // Animation logic here
                        }
                        
                        background: Rectangle {
                            color: parent.pressed ? "#00ffff" : "#2a2a2a"
                            opacity: parent.pressed ? 0.3 : 1.0
                            radius: 6
                        }
                        
                        contentItem: Text {
                            text: parent.text
                            color: "#ffffff"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                }
            }
        }
    }
    
    // Sample data model for candlestick chart
    ListModel {
        id: candlestickModel
        
        ListElement { timestamp: "09:30"; type: "Open"; price: 233.50 }
        ListElement { timestamp: "09:30"; type: "High"; price: 234.20 }
        ListElement { timestamp: "09:30"; type: "Low"; price: 233.10 }
        ListElement { timestamp: "09:30"; type: "Close"; price: 234.07 }
        
        ListElement { timestamp: "10:00"; type: "Open"; price: 234.07 }
        ListElement { timestamp: "10:00"; type: "High"; price: 235.15 }
        ListElement { timestamp: "10:00"; type: "Low"; price: 233.80 }
        ListElement { timestamp: "10:00"; type: "Close"; price: 234.90 }
        
        ListElement { timestamp: "10:30"; type: "Open"; price: 234.90 }
        ListElement { timestamp: "10:30"; type: "High"; price: 235.50 }
        ListElement { timestamp: "10:30"; type: "Low"; price: 234.60 }
        ListElement { timestamp: "10:30"; type: "Close"; price: 235.20 }
    }
}