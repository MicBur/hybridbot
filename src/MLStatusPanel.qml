import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle {
    id: root
    width: parent.width
    height: 200
    color: Qt.rgba(0, 0, 0, 0.3)
    border.width: 1
    border.color: "#4ecdc4"
    radius: 15
    
    property var mlStatus: ({})
    property var predictionMetrics: ({})
    
    Column {
        anchors.fill: parent
        anchors.margins: 15
        spacing: 10
        
        // Header
        Text {
            text: "ML MODEL STATUS & METRIKEN"
            color: "#ffffff"
            font.pixelSize: 16
            font.weight: Font.Bold
            anchors.horizontalCenter: parent.horizontalCenter
        }
        
        // Status indicators
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 20
            
            // Training Status
            Column {
                spacing: 5
                
                Text {
                    text: "TRAINING"
                    color: "#4ecdc4"
                    font.pixelSize: 12
                    font.weight: Font.Bold
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                
                Rectangle {
                    width: 60
                    height: 60
                    radius: 30
                    color: "transparent"
                    border.width: 3
                    border.color: root.mlStatus.training_active ? "#ff6b6b" : "#00ff00"
                    
                    Text {
                        text: root.mlStatus.training_active ? "AKTIV" : "BEREIT"
                        color: root.mlStatus.training_active ? "#ff6b6b" : "#00ff00"
                        font.pixelSize: 10
                        font.weight: Font.Bold
                        anchors.centerIn: parent
                    }
                    
                    SequentialAnimation on opacity {
                        running: root.mlStatus.training_active
                        loops: Animation.Infinite
                        NumberAnimation { to: 0.3; duration: 1000 }
                        NumberAnimation { to: 1.0; duration: 1000 }
                    }
                }
            }
            
            // Model Accuracy
            Column {
                spacing: 5
                
                Text {
                    text: "ACCURACY"
                    color: "#4ecdc4"
                    font.pixelSize: 12
                    font.weight: Font.Bold
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                
                Rectangle {
                    width: 80
                    height: 60
                    radius: 10
                    color: Qt.rgba(0.3, 0.8, 0.77, 0.2)
                    border.width: 2
                    border.color: "#4ecdc4"
                    
                    Text {
                        text: Math.round((root.mlStatus.model_accuracy || 0) * 100) + "%"
                        color: "#ffffff"
                        font.pixelSize: 18
                        font.weight: Font.Bold
                        anchors.centerIn: parent
                    }
                }
            }
            
            // Data Points
            Column {
                spacing: 5
                
                Text {
                    text: "DATA POINTS"
                    color: "#4ecdc4"
                    font.pixelSize: 12
                    font.weight: Font.Bold
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                
                Rectangle {
                    width: 80
                    height: 60
                    radius: 10
                    color: Qt.rgba(0.3, 0.8, 0.77, 0.2)
                    border.width: 2
                    border.color: "#4ecdc4"
                    
                    Text {
                        text: (root.mlStatus.data_points || 0).toLocaleString()
                        color: "#ffffff"
                        font.pixelSize: 14
                        font.weight: Font.Bold
                        anchors.centerIn: parent
                    }
                }
            }
        }
        
        // Prediction metrics
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 15
            
            Column {
                spacing: 2
                
                Text {
                    text: "15min MAE"
                    color: "#aaaaaa"
                    font.pixelSize: 10
                }
                
                Text {
                    text: (root.predictionMetrics.per_horizon && root.predictionMetrics.per_horizon["15"]) ? 
                          root.predictionMetrics.per_horizon["15"].mae.toFixed(2) : "N/A"
                    color: "#ffffff"
                    font.pixelSize: 12
                    font.weight: Font.Bold
                }
            }
            
            Column {
                spacing: 2
                
                Text {
                    text: "30min MAE"
                    color: "#aaaaaa"
                    font.pixelSize: 10
                }
                
                Text {
                    text: (root.predictionMetrics.per_horizon && root.predictionMetrics.per_horizon["30"]) ? 
                          root.predictionMetrics.per_horizon["30"].mae.toFixed(2) : "N/A"
                    color: "#ffffff"
                    font.pixelSize: 12
                    font.weight: Font.Bold
                }
            }
            
            Column {
                spacing: 2
                
                Text {
                    text: "60min MAE"
                    color: "#aaaaaa"
                    font.pixelSize: 10
                }
                
                Text {
                    text: (root.predictionMetrics.per_horizon && root.predictionMetrics.per_horizon["60"]) ? 
                          root.predictionMetrics.per_horizon["60"].mae.toFixed(2) : "N/A"
                    color: "#ffffff"
                    font.pixelSize: 12
                    font.weight: Font.Bold
                }
            }
        }
        
        // Last training info
        Text {
            text: "Letztes Training: " + (root.mlStatus.last_training ? 
                  new Date(root.mlStatus.last_training).toLocaleString("de-DE") : "Nie")
            color: "#aaaaaa"
            font.pixelSize: 10
            anchors.horizontalCenter: parent.horizontalCenter
        }
        
        Text {
            text: "Nächstes Training: " + (root.mlStatus.next_scheduled ? 
                  new Date(root.mlStatus.next_scheduled).toLocaleString("de-DE") : "Nicht geplant")
            color: "#aaaaaa"
            font.pixelSize: 10
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }
    
    // Glow effect
    Rectangle {
        anchors.fill: parent
        color: "transparent"
        border.width: 2
        border.color: "#4ecdc4"
        radius: parent.radius
        opacity: 0.4
        
        SequentialAnimation on opacity {
            loops: Animation.Infinite
            running: true
            NumberAnimation { to: 0.7; duration: 2500 }
            NumberAnimation { to: 0.3; duration: 2500 }
        }
    }
}