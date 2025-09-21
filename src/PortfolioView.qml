import QtQuick 2.15
import QtQuick.Controls 2.15
import QtDataVisualization 1.15

Rectangle {
    id: root
    color: "#0a0a0a"
    
    Column {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 20
        
        // Portfolio Overview Section
        Row {
            width: parent.width
            height: 140
            spacing: 20
            
            GlassTile {
                width: (parent.width - 2 * parent.spacing) / 3
                height: parent.height
                title: "Total Value"
                value: "$125,430.50"
                subtitle: "Equity"
                accentColor: "#00ffff"
            }
            
            GlassTile {
                width: (parent.width - 2 * parent.spacing) / 3
                height: parent.height
                title: "P&L Today"
                value: "+$2,847.33"
                subtitle: "+2.3%"
                accentColor: "#00ff00"
            }
            
            GlassTile {
                width: (parent.width - 2 * parent.spacing) / 3
                height: parent.height
                title: "Buying Power"
                value: "$25,000.00"
                subtitle: "Available"
                accentColor: "#ffaa00"
            }
        }
        
        // 3D Portfolio Performance Chart
        Rectangle {
            width: parent.width
            height: 400
            color: "#1a1a1a"
            radius: 12
            border.color: "#00ffff"
            border.width: 1
            
            Surface3D {
                id: portfolioChart
                anchors.fill: parent
                anchors.margins: 10
                
                theme: Theme3D {
                    type: Theme3D.ThemeEbony
                    labelBackgroundEnabled: true
                    colorStyle: Theme3D.ColorStyleRangeGradient
                    baseGradients: [
                        ColorGradient {
                            ColorGradientStop { position: 0.0; color: "#ff0066" }
                            ColorGradientStop { position: 0.5; color: "#ffaa00" }
                            ColorGradientStop { position: 1.0; color: "#00ff00" }
                        }
                    ]
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
                
                Surface3DSeries {
                    id: portfolioSeries
                    name: "Portfolio Performance"
                    baseColor: "#00ffff"
                    
                    ItemModelSurfaceDataProxy {
                        itemModel: portfolioModel
                        rowRole: "day"
                        columnRole: "hour"
                        yPosRole: "value"
                    }
                }
                
                axisX: CategoryAxis3D {
                    title: "Day"
                    labels: ["Mon", "Tue", "Wed", "Thu", "Fri"]
                }
                
                axisZ: CategoryAxis3D {
                    title: "Hour"
                    labels: ["9:30", "10:30", "11:30", "12:30", "13:30", "14:30", "15:30"]
                }
                
                axisY: ValueAxis3D {
                    title: "Portfolio Value ($)"
                    labelFormat: "$%.0f"
                    min: 120000
                    max: 130000
                }
            }
            
            Text {
                anchors.top: parent.top
                anchors.topMargin: 15
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Portfolio Performance - 3D Surface"
                color: "#00ffff"
                font.pixelSize: 18
                font.weight: Font.Bold
            }
        }
        
        // Current Positions
        Rectangle {
            width: parent.width
            height: 200
            color: "#1a1a1a"
            radius: 12
            border.color: "#00ffff"
            border.width: 1
            
            Column {
                anchors.fill: parent
                anchors.margins: 15
                spacing: 10
                
                Text {
                    text: "Current Positions"
                    color: "#00ffff"
                    font.pixelSize: 16
                    font.weight: Font.Bold
                }
                
                ListView {
                    width: parent.width
                    height: parent.height - 30
                    model: positionsModel
                    
                    delegate: Rectangle {
                        width: parent.width
                        height: 40
                        color: "transparent"
                        
                        Row {
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 20
                            
                            Text {
                                text: model.symbol
                                color: "#ffffff"
                                font.pixelSize: 14
                                font.weight: Font.Bold
                                width: 80
                            }
                            
                            Text {
                                text: model.quantity + " shares"
                                color: "#cccccc"
                                font.pixelSize: 12
                                width: 100
                            }
                            
                            Text {
                                text: "$" + model.avgPrice
                                color: "#cccccc"
                                font.pixelSize: 12
                                width: 100
                            }
                            
                            Text {
                                text: model.unrealizedPL
                                color: model.unrealizedPL.startsWith("+") ? "#00ff00" : "#ff0066"
                                font.pixelSize: 12
                                font.weight: Font.Bold
                                width: 100
                            }
                        }
                    }
                }
            }
        }
    }
    
    // Sample portfolio performance data
    ListModel {
        id: portfolioModel
        
        // Generate sample 3D surface data
        Component.onCompleted: {
            var days = ["Mon", "Tue", "Wed", "Thu", "Fri"];
            var hours = ["9:30", "10:30", "11:30", "12:30", "13:30", "14:30", "15:30"];
            
            for (var d = 0; d < days.length; d++) {
                for (var h = 0; h < hours.length; h++) {
                    var baseValue = 125000;
                    var variation = Math.random() * 5000 - 2500;
                    append({
                        "day": days[d],
                        "hour": hours[h],
                        "value": baseValue + variation
                    });
                }
            }
        }
    }
    
    // Sample positions data
    ListModel {
        id: positionsModel
        
        ListElement { symbol: "AAPL"; quantity: "100"; avgPrice: "150.25"; unrealizedPL: "+$375.00" }
        ListElement { symbol: "NVDA"; quantity: "50"; avgPrice: "420.80"; unrealizedPL: "+$1,247.50" }
        ListElement { symbol: "MSFT"; quantity: "75"; avgPrice: "380.40"; unrealizedPL: "-$142.75" }
        ListElement { symbol: "TSLA"; quantity: "25"; avgPrice: "245.60"; unrealizedPL: "+$82.50" }
    }
}