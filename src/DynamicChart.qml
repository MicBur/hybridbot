import QtQuick 2.15
import QtQuick.Controls 2.15
import QtCharts 2.15
import QtGraphicalEffects 1.15

Rectangle {
    id: root
    color: "transparent"
    
    property var dataPoints: []
    property string chartTitle: "Dynamic Chart"
    property color primaryColor: "#00ffff"
    property color secondaryColor: "#ff6b6b"
    property bool animated: true
    property real animationProgress: 0
    
    // Background with glassmorphism
    Rectangle {
        anchors.fill: parent
        color: "#1a1a1a"
        radius: 15
        border.color: "#00ffff"
        border.width: 2
        opacity: 0.9
        
        // Animated border glow
        Rectangle {
            anchors.fill: parent
            radius: parent.radius
            color: "transparent"
            border.color: root.primaryColor
            border.width: 1
            opacity: glowOpacity.value
            
            NumberAnimation {
                id: glowOpacity
                property real value: 0.3
                from: 0.3
                to: 0.8
                duration: 2000
                running: root.animated
                loops: Animation.Infinite
                easing.type: Easing.InOutSine
                
                onFinished: {
                    from = to
                    to = (to === 0.8) ? 0.3 : 0.8
                    restart()
                }
            }
        }
    }
    
    // Chart title with glow effect
    Text {
        id: titleText
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: 15
        text: root.chartTitle
        color: root.primaryColor
        font.pixelSize: 18
        font.weight: Font.Bold
        
        layer.enabled: true
        layer.effect: Glow {
            color: root.primaryColor
            radius: 8
            samples: 16
            spread: 0.3
        }
    }
    
    // Dynamic Chart Area
    ChartView {
        id: chartView
        anchors.fill: parent
        anchors.margins: 20
        anchors.topMargin: 50
        backgroundColor: "transparent"
        plotAreaColor: "transparent"
        legend.visible: false
        antialiasing: true
        
        theme: ChartView.ChartThemeDark
        
        ValueAxis {
            id: axisX
            min: 0
            max: 100
            gridLineColor: "#333333"
            labelsColor: "#cccccc"
            color: "#666666"
        }
        
        ValueAxis {
            id: axisY
            min: 0
            max: 100
            gridLineColor: "#333333"
            labelsColor: "#cccccc"
            color: "#666666"
        }
        
        SplineSeries {
            id: mainSeries
            name: "Primary Data"
            color: root.primaryColor
            width: 3
            axisX: axisX
            axisY: axisY
            
            Component.onCompleted: {
                generateDynamicData()
            }
        }
        
        SplineSeries {
            id: secondarySeries
            name: "Secondary Data"
            color: root.secondaryColor
            width: 2
            axisX: axisX
            axisY: axisY
        }
        
        // Animated data point indicators
        Repeater {
            model: mainSeries.count
            
            Rectangle {
                property point dataPoint: mainSeries.at(index)
                x: chartView.plotArea.x + (dataPoint.x / axisX.max) * chartView.plotArea.width - width/2
                y: chartView.plotArea.y + chartView.plotArea.height - (dataPoint.y / axisY.max) * chartView.plotArea.height - height/2
                width: 8
                height: 8
                radius: 4
                color: root.primaryColor
                opacity: pulseAnimation.opacity
                
                NumberAnimation {
                    id: pulseAnimation
                    property real opacity: 0.7
                    target: pulseAnimation
                    property: "opacity"
                    from: 0.7
                    to: 1.0
                    duration: 1000 + (index * 100)
                    running: root.animated
                    loops: Animation.Infinite
                    easing.type: Easing.InOutSine
                    
                    onFinished: {
                        from = to
                        to = (to === 1.0) ? 0.7 : 1.0
                        restart()
                    }
                }
            }
        }
    }
    
    // Performance metrics overlay
    Rectangle {
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.margins: 15
        width: 120
        height: 60
        color: "#2a2a2a"
        radius: 8
        border.color: root.primaryColor
        border.width: 1
        opacity: 0.9
        
        Column {
            anchors.centerIn: parent
            spacing: 2
            
            Text {
                text: "Performance"
                color: "#cccccc"
                font.pixelSize: 10
                horizontalAlignment: Text.AlignHCenter
            }
            
            Text {
                text: "+23.7%"
                color: "#00ff00"
                font.pixelSize: 16
                font.weight: Font.Bold
                horizontalAlignment: Text.AlignHCenter
            }
            
            Text {
                text: "↗ Trending"
                color: root.primaryColor
                font.pixelSize: 8
                horizontalAlignment: Text.AlignHCenter
            }
        }
    }
    
    // Dynamic data generation
    Timer {
        id: dataTimer
        interval: 2000
        running: root.animated
        repeat: true
        
        onTriggered: {
            updateChartData()
        }
    }
    
    function generateDynamicData() {
        mainSeries.clear()
        secondarySeries.clear()
        
        for (let i = 0; i <= 20; i++) {
            let primaryY = 30 + Math.sin(i * 0.3) * 20 + Math.random() * 15
            let secondaryY = 40 + Math.cos(i * 0.4) * 15 + Math.random() * 10
            
            mainSeries.append(i * 5, primaryY)
            secondarySeries.append(i * 5, secondaryY)
        }
    }
    
    function updateChartData() {
        // Shift data left and add new point
        for (let i = 0; i < mainSeries.count - 1; i++) {
            let point = mainSeries.at(i + 1)
            mainSeries.replace(i, point.x - 5, point.y)
        }
        
        // Add new data point
        let newY = 30 + Math.sin(Date.now() * 0.001) * 20 + Math.random() * 15
        mainSeries.replace(mainSeries.count - 1, 100, newY)
        
        // Update secondary series
        for (let i = 0; i < secondarySeries.count - 1; i++) {
            let point = secondarySeries.at(i + 1)
            secondarySeries.replace(i, point.x - 5, point.y)
        }
        
        let newSecondaryY = 40 + Math.cos(Date.now() * 0.001) * 15 + Math.random() * 10
        secondarySeries.replace(secondarySeries.count - 1, 100, newSecondaryY)
    }
}