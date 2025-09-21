#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickStyle>
#include "redisclient.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    // Set dark style
    QQuickStyle::setStyle("Material");
    
    // Register RedisClient type
    qmlRegisterType<RedisClient>("Redis", 1, 0, "RedisClient");

    QQmlApplicationEngine engine;
    
    // Create RedisClient instance
    RedisClient redisClient;
    redisClient.setHost("localhost");
    redisClient.setPort(6380);
    redisClient.setPassword("pass123");
    
    // Make RedisClient available to QML
    engine.rootContext()->setContextProperty("redisClient", &redisClient);
    
    // Auto-connect to Redis
    redisClient.connectToRedis();
    
    // Check command line arguments for QML file
    QString qmlFile = "HybridMain.qml";  // Default to full hybrid mode with WebEngine
    
    if (argc > 1) {
        QString arg = QString(argv[1]);
        if (arg == "--advanced") {
            qmlFile = "AdvancedMain.qml";
        } else if (arg == "--simple") {
            qmlFile = "SimpleMain.qml";
        } else if (arg == "--hybrid") {
            qmlFile = "HybridMain.qml";
        } else if (arg == "--fallback") {
            qmlFile = "HybridFallback.qml";
        }
    }
    
    QString qmlPath = QCoreApplication::applicationDirPath() + "/../src/" + qmlFile;
    engine.load(QUrl::fromLocalFile(qmlPath));
    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
