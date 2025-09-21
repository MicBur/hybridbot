import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    id: mlPage
    anchors.fill: parent
    
    property real modelAccuracy: 87.3
    property real predictionConfidence: 92.1
    property string modelStatus: "Training"
    
    Column {
        width: parent.width
        spacing: 20
        
        // Page header
        Text {
            text: "🤖 MACHINE LEARNING MODELS"
            font.pixelSize: 28
            font.bold: true
            color: window.primaryColor
        }
        
        // Model Status Overview
        Row {
            width: parent.width
            spacing: 20
            
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
                        text: "Model Accuracy"
                        color: "#cccccc"
                        font.pixelSize: 12
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    
                    Text {
                        text: modelAccuracy.toFixed(1) + "%"
                        color: window.successColor
                        font.pixelSize: 24
                        font.bold: true
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    
                    Text {
                        text: "Last 1000 predictions"
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
                border.color: window.primaryColor
                border.width: 2
                radius: 10
                
                Column {
                    anchors.centerIn: parent
                    spacing: 5
                    
                    Text {
                        text: "Prediction Confidence"
                        color: "#cccccc"
                        font.pixelSize: 12
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    
                    Text {
                        text: predictionConfidence.toFixed(1) + "%"
                        color: window.primaryColor
                        font.pixelSize: 24
                        font.bold: true
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    
                    Text {
                        text: "Current batch average"
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
                        text: "Status"
                        color: "#cccccc"
                        font.pixelSize: 12
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    
                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 10
                        
                        Rectangle {
                            width: 12
                            height: 12
                            radius: 6
                            color: modelStatus === "Training" ? window.warningColor : 
                                   modelStatus === "Active" ? window.successColor : window.dangerColor
                            
                            SequentialAnimation on opacity {
                                loops: Animation.Infinite
                                running: modelStatus === "Training"
                                NumberAnimation { to: 0.3; duration: 500 }
                                NumberAnimation { to: 1.0; duration: 500 }
                            }
                        }
                        
                        Text {
                            text: modelStatus
                            color: modelStatus === "Training" ? window.warningColor : 
                                   modelStatus === "Active" ? window.successColor : window.dangerColor
                            font.pixelSize: 16
                            font.bold: true
                        }
                    }
                    
                    Text {
                        text: "Model state"
                        color: "#cccccc"
                        font.pixelSize: 10
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }
            }
        }
        
        // Model Details
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
                
                Row {
                    width: parent.width
                    
                    Text {
                        text: "🧠 ACTIVE MODELS"
                        font.pixelSize: 16
                        font.bold: true
                        color: window.primaryColor
                    }
                    
                    Item { Layout.fillWidth: true }
                    
                    Button {
                        text: "🔄 Retrain All"
                        onClicked: redis.triggerMLTraining()
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
                
                // Models Grid
                Grid {
                    width: parent.width
                    columns: 2
                    columnSpacing: 20
                    rowSpacing: 15
                    
                    Rectangle {
                        width: (parent.width - 20) / 2
                        height: 120
                        color: "#1a1a1a"
                        border.color: window.successColor
                        border.width: 1
                        radius: 8
                        
                        Column {
                            anchors.fill: parent
                            anchors.margins: 15
                            spacing: 8
                            
                            Row {
                                width: parent.width
                                
                                Text {
                                    text: "📊 LSTM Neural Network"
                                    color: window.successColor
                                    font.pixelSize: 12
                                    font.bold: true
                                }
                                
                                Item { Layout.fillWidth: true }
                                
                                Rectangle {
                                    width: 8
                                    height: 8
                                    radius: 4
                                    color: window.successColor
                                }
                            }
                            
                            Text {
                                text: "Accuracy: 89.2%"
                                color: "#ffffff"
                                font.pixelSize: 11
                            }
                            
                            Text {
                                text: "Predictions: 2,847"
                                color: "#cccccc"
                                font.pixelSize: 10
                            }
                            
                            Text {
                                text: "Used for: Price movement prediction"
                                color: "#cccccc"
                                font.pixelSize: 10
                                wrapMode: Text.WordWrap
                                width: parent.width
                            }
                        }
                    }
                    
                    Rectangle {
                        width: (parent.width - 20) / 2
                        height: 120
                        color: "#1a1a1a"
                        border.color: window.primaryColor
                        border.width: 1
                        radius: 8
                        
                        Column {
                            anchors.fill: parent
                            anchors.margins: 15
                            spacing: 8
                            
                            Row {
                                width: parent.width
                                
                                Text {
                                    text: "🎯 Random Forest"
                                    color: window.primaryColor
                                    font.pixelSize: 12
                                    font.bold: true
                                }
                                
                                Item { Layout.fillWidth: true }
                                
                                Rectangle {
                                    width: 8
                                    height: 8
                                    radius: 4
                                    color: window.primaryColor
                                }
                            }
                            
                            Text {
                                text: "Accuracy: 84.7%"
                                color: "#ffffff"
                                font.pixelSize: 11
                            }
                            
                            Text {
                                text: "Predictions: 1,923"
                                color: "#cccccc"
                                font.pixelSize: 10
                            }
                            
                            Text {
                                text: "Used for: Risk assessment"
                                color: "#cccccc"
                                font.pixelSize: 10
                                wrapMode: Text.WordWrap
                                width: parent.width
                            }
                        }
                    }
                    
                    Rectangle {
                        width: (parent.width - 20) / 2
                        height: 120
                        color: "#1a1a1a"
                        border.color: window.warningColor
                        border.width: 1
                        radius: 8
                        
                        Column {
                            anchors.fill: parent
                            anchors.margins: 15
                            spacing: 8
                            
                            Row {
                                width: parent.width
                                
                                Text {
                                    text: "🌊 Gradient Boosting"
                                    color: window.warningColor
                                    font.pixelSize: 12
                                    font.bold: true
                                }
                                
                                Item { Layout.fillWidth: true }
                                
                                Rectangle {
                                    width: 8
                                    height: 8
                                    radius: 4
                                    color: window.warningColor
                                    
                                    SequentialAnimation on opacity {
                                        loops: Animation.Infinite
                                        NumberAnimation { to: 0.3; duration: 800 }
                                        NumberAnimation { to: 1.0; duration: 800 }
                                    }
                                }
                            }
                            
                            Text {
                                text: "Training... 67%"
                                color: "#ffffff"
                                font.pixelSize: 11
                            }
                            
                            Text {
                                text: "ETA: 12 minutes"
                                color: "#cccccc"
                                font.pixelSize: 10
                            }
                            
                            Text {
                                text: "Used for: Market sentiment analysis"
                                color: "#cccccc"
                                font.pixelSize: 10
                                wrapMode: Text.WordWrap
                                width: parent.width
                            }
                        }
                    }
                    
                    Rectangle {
                        width: (parent.width - 20) / 2
                        height: 120
                        color: "#1a1a1a"
                        border.color: window.secondaryColor
                        border.width: 1
                        radius: 8
                        
                        Column {
                            anchors.fill: parent
                            anchors.margins: 15
                            spacing: 8
                            
                            Row {
                                width: parent.width
                                
                                Text {
                                    text: "🔮 Transformer Model"
                                    color: window.secondaryColor
                                    font.pixelSize: 12
                                    font.bold: true
                                }
                                
                                Item { Layout.fillWidth: true }
                                
                                Rectangle {
                                    width: 8
                                    height: 8
                                    radius: 4
                                    color: window.secondaryColor
                                }
                            }
                            
                            Text {
                                text: "Accuracy: 91.8%"
                                color: "#ffffff"
                                font.pixelSize: 11
                            }
                            
                            Text {
                                text: "Predictions: 4,156"
                                color: "#cccccc"
                                font.pixelSize: 10
                            }
                            
                            Text {
                                text: "Used for: News sentiment & price correlation"
                                color: "#cccccc"
                                font.pixelSize: 10
                                wrapMode: Text.WordWrap
                                width: parent.width
                            }
                        }
                    }
                }
            }
        }
        
        // Performance Metrics
        Rectangle {
            width: parent.width
            height: 250
            color: window.surfaceColor
            border.color: window.secondaryColor
            border.width: 2
            radius: 10
            
            Column {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 15
                
                Text {
                    text: "📈 MODEL PERFORMANCE METRICS"
                    font.pixelSize: 16
                    font.bold: true
                    color: window.secondaryColor
                }
                
                Canvas {
                    id: accuracyChart
                    width: parent.width
                    height: 180
                    
                    property var accuracyData: [
                        { name: "LSTM", accuracy: 89.2, color: window.successColor },
                        { name: "Random Forest", accuracy: 84.7, color: window.primaryColor },
                        { name: "Gradient Boost", accuracy: 67.0, color: window.warningColor },
                        { name: "Transformer", accuracy: 91.8, color: window.secondaryColor }
                    ]
                    
                    onPaint: {
                        var ctx = getContext("2d")
                        ctx.clearRect(0, 0, width, height)
                        
                        var barWidth = (width - 100) / accuracyData.length
                        var maxAccuracy = 100
                        
                        for (var i = 0; i < accuracyData.length; i++) {
                            var data = accuracyData[i]
                            var barHeight = (data.accuracy / maxAccuracy) * (height - 60)
                            var x = 50 + i * barWidth + barWidth * 0.1
                            var y = height - 40 - barHeight
                            var barActualWidth = barWidth * 0.8
                            
                            // Draw bar
                            ctx.fillStyle = data.color
                            ctx.fillRect(x, y, barActualWidth, barHeight)
                            
                            // Draw label
                            ctx.fillStyle = "#ffffff"
                            ctx.font = "10px Arial"
                            ctx.textAlign = "center"
                            ctx.fillText(data.name, x + barActualWidth / 2, height - 25)
                            
                            // Draw value
                            ctx.fillStyle = data.color
                            ctx.font = "12px Arial bold"
                            ctx.fillText(data.accuracy.toFixed(1) + "%", x + barActualWidth / 2, y - 5)
                        }
                        
                        // Draw axis
                        ctx.strokeStyle = "#333333"
                        ctx.lineWidth = 1
                        ctx.beginPath()
                        ctx.moveTo(40, height - 40)
                        ctx.lineTo(width - 20, height - 40)
                        ctx.stroke()
                        
                        // Draw y-axis labels
                        ctx.fillStyle = "#cccccc"
                        ctx.font = "10px Arial"
                        ctx.textAlign = "right"
                        for (var i = 0; i <= 10; i++) {
                            var value = i * 10
                            var y = height - 40 - (value / 100) * (height - 60)
                            ctx.fillText(value + "%", 35, y + 3)
                        }
                    }
                    
                    Timer {
                        interval: 10000
                        running: true
                        repeat: true
                        onTriggered: {
                            // Update training model progress
                            if (accuracyChart.accuracyData[2].accuracy < 85) {
                                accuracyChart.accuracyData[2].accuracy += Math.random() * 2
                                accuracyChart.requestPaint()
                            }
                        }
                    }
                }
            }
        }
        
        // Control Panel
        Rectangle {
            width: parent.width
            height: 150
            color: window.surfaceColor
            border.color: window.accentColor
            border.width: 2
            radius: 10
            
            Column {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 15
                
                Text {
                    text: "🎛️ MODEL CONTROL PANEL"
                    font.pixelSize: 16
                    font.bold: true
                    color: window.accentColor
                }
                
                Row {
                    width: parent.width
                    spacing: 15
                    
                    Button {
                        text: "🚀 Start Training"
                        onClicked: {
                            modelStatus = "Training"
                            redis.triggerMLTraining()
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
                        text: "⏸️ Pause Training"
                        onClicked: modelStatus = "Paused"
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
                    
                    Button {
                        text: "🔄 Reset Models"
                        onClicked: console.log("Resetting all models...")
                        background: Rectangle {
                            color: window.dangerColor
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
                        text: "📊 Export Data"
                        onClicked: console.log("Exporting model data...")
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
                        text: "⚙️ Model Config"
                        onClicked: console.log("Opening model configuration...")
                        background: Rectangle {
                            color: window.accentColor
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
                
                Text {
                    text: "Last update: " + new Date().toLocaleTimeString() + " | Models trained: 4 | Total predictions: 9,926"
                    color: "#cccccc"
                    font.pixelSize: 10
                }
            }
        }
    }
    
    // Update ML data
    Timer {
        interval: 5000
        running: true
        repeat: true
        onTriggered: {
            redis.getPredictionMetrics()
        }
    }
    
    Connections {
        target: redis
        
        function onPredictionMetricsReceived(metrics) {
            try {
                var data = JSON.parse(metrics)
                modelAccuracy = data.accuracy || 87.3
                predictionConfidence = data.confidence || 92.1
            } catch (e) {
                console.log("Error parsing ML metrics:", e)
            }
        }
        
        function onMLTrainingTriggered() {
            modelStatus = "Training"
        }
    }
}