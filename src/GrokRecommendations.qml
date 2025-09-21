import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle {
    id: root
    width: parent.width
    height: 400
    color: Qt.rgba(0, 0, 0, 0.3)
    border.width: 1
    border.color: "#00ffff"
    radius: 15
    
    property var grokData: []
    property var deepSearchData: []
    property var topStocksData: ({})
    
    Column {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 15
        
        // Header
        Text {
            text: "GROK AI EMPFEHLUNGEN"
            color: "#ffffff"
            font.pixelSize: 18
            font.weight: Font.Bold
            anchors.horizontalCenter: parent.horizontalCenter
        }
        
        // Grok Top 10 Recommendations
        Rectangle {
            width: parent.width
            height: 150
            color: "transparent"
            border.width: 1
            border.color: "#00ffff"
            radius: 10
            
            ScrollView {
                anchors.fill: parent
                anchors.margins: 10
                
                ListView {
                    id: grokListView
                    model: root.grokData
                    spacing: 5
                    
                    delegate: Rectangle {
                        width: grokListView.width
                        height: 35
                        color: Qt.rgba(0, 1, 1, 0.1)
                        radius: 5
                        
                        Row {
                            anchors.left: parent.left
                            anchors.leftMargin: 10
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 15
                            
                            Text {
                                text: modelData.ticker || ""
                                color: "#00ffff"
                                font.pixelSize: 14
                                font.weight: Font.Bold
                                width: 60
                            }
                            
                            Rectangle {
                                width: 60
                                height: 8
                                color: "#333"
                                radius: 4
                                border.width: 1
                                border.color: "#00ffff"
                                
                                Rectangle {
                                    width: parent.width * (modelData.score || 0)
                                    height: parent.height
                                    color: "#00ffff"
                                    radius: parent.radius
                                }
                            }
                            
                            Text {
                                text: Math.round((modelData.score || 0) * 100) + "%"
                                color: "#ffffff"
                                font.pixelSize: 12
                                width: 40
                            }
                            
                            Text {
                                text: modelData.reason || ""
                                color: "#aaaaaa"
                                font.pixelSize: 11
                                elide: Text.ElideRight
                                width: 180
                            }
                        }
                    }
                }
            }
            
            Text {
                text: "GROK TOP 10"
                color: "#00ffff"
                font.pixelSize: 12
                font.weight: Font.Bold
                anchors.top: parent.top
                anchors.topMargin: 5
                anchors.left: parent.left
                anchors.leftMargin: 10
            }
        }
        
        // Grok Deep Search Results
        Rectangle {
            width: parent.width
            height: 180
            color: "transparent"
            border.width: 1
            border.color: "#ff6b6b"
            radius: 10
            
            ScrollView {
                anchors.fill: parent
                anchors.margins: 10
                
                ListView {
                    id: deepSearchListView
                    model: root.deepSearchData
                    spacing: 8
                    
                    delegate: Rectangle {
                        width: deepSearchListView.width
                        height: 55
                        color: Qt.rgba(1, 0.42, 0.42, 0.1)
                        radius: 5
                        
                        Column {
                            anchors.left: parent.left
                            anchors.leftMargin: 10
                            anchors.right: parent.right
                            anchors.rightMargin: 10
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 3
                            
                            Row {
                                spacing: 15
                                
                                Text {
                                    text: modelData.ticker || ""
                                    color: "#ff6b6b"
                                    font.pixelSize: 14
                                    font.weight: Font.Bold
                                }
                                
                                Rectangle {
                                    width: 50
                                    height: 6
                                    color: "#333"
                                    radius: 3
                                    border.width: 1
                                    border.color: "#ff6b6b"
                                    
                                    Rectangle {
                                        width: parent.width * (modelData.sentiment || 0)
                                        height: parent.height
                                        color: "#ff6b6b"
                                        radius: parent.radius
                                    }
                                }
                                
                                Text {
                                    text: "Sentiment: " + Math.round((modelData.sentiment || 0) * 100) + "%"
                                    color: "#ffffff"
                                    font.pixelSize: 11
                                }
                            }
                            
                            Text {
                                text: modelData.explanation_de || ""
                                color: "#cccccc"
                                font.pixelSize: 10
                                wrapMode: Text.WordWrap
                                width: parent.width
                                maximumLineCount: 2
                                elide: Text.ElideRight
                            }
                        }
                    }
                }
            }
            
            Text {
                text: "GROK DEEP SEARCH"
                color: "#ff6b6b"
                font.pixelSize: 12
                font.weight: Font.Bold
                anchors.top: parent.top
                anchors.topMargin: 5
                anchors.left: parent.left
                anchors.leftMargin: 10
            }
        }
    }
    
    // Glow effect
    Rectangle {
        anchors.fill: parent
        color: "transparent"
        border.width: 2
        border.color: "#00ffff"
        radius: parent.radius
        opacity: 0.3
        
        SequentialAnimation on opacity {
            loops: Animation.Infinite
            running: true
            NumberAnimation { to: 0.6; duration: 3000 }
            NumberAnimation { to: 0.2; duration: 3000 }
        }
    }
}