cmake_minimum_required(VERSION 3.16)
project(6bot LANGUAGES CXX)

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

if(MSVC)
    add_compile_options(/Zc:__cplusplus /permissive-)
endif()

find_package(Qt6 REQUIRED COMPONENTS 
    Quick 
    QuickControls2 
    Charts
    DataVisualization
    Network
    WebEngineQuick
)

qt_add_executable(6bot
    src/main.cpp
    src/redisclient.cpp
    src/redisclient.h
)

qt_add_qml_module(6bot
    URI 6bot
    VERSION 1.0
    NO_CACHEGEN
    QML_FILES 
        src/Main.qml
        src/SimpleMain.qml
        src/SimpleDemo.qml
        src/GlassTile.qml
        src/DashboardView.qml
        src/ChartsView.qml
        src/PortfolioView.qml
        src/TradesView.qml
        src/PremiumButton.qml
        src/DynamicChart.qml
        src/HologramTile.qml
        src/PremiumDashboard.qml
        src/PremiumTile.qml
        src/HologramButton.qml
        src/PremiumMain.qml
        src/GrokRecommendations.qml
        src/MLStatusPanel.qml
        src/AdvancedMain.qml
        src/DashboardPage.qml
        src/PortfolioPage.qml
        src/MLPage.qml
        src/GrokPage.qml
        src/TradingPage.qml
        src/SettingsPage.qml
        src/HybridFallback.qml
        src/HybridMain.qml
)

target_link_libraries(6bot
    PRIVATE Qt6::Quick Qt6::QuickControls2 Qt6::Charts Qt6::DataVisualization Qt6::Network Qt6::WebEngineQuick
)
