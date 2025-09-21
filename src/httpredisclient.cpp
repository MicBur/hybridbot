#include "httpredisclient.h"
#include <QNetworkRequest>
#include <QNetworkReply>
#include <QJsonDocument>
#include <QJsonObject>
#include <QUrl>
#include <QDebug>

HttpRedisClient::HttpRedisClient(QObject *parent)
    : QObject(parent)
    , m_networkManager(new QNetworkAccessManager(this))
    , m_connectionTimer(new QTimer(this))
    , m_connected(false)
    , m_redisHost("localhost")
    , m_redisPort(6380)
    , m_baseUrl("http://localhost:8080") // Qt HTTP-Redis Bridge
{
    connect(m_connectionTimer, &QTimer::timeout, this, &HttpRedisClient::checkConnection);
    m_connectionTimer->setInterval(5000); // Check every 5 seconds
}

void HttpRedisClient::setRedisHost(const QString &host)
{
    if (m_redisHost != host) {
        m_redisHost = host;
        emit redisHostChanged();
    }
}

void HttpRedisClient::setRedisPort(int port)
{
    if (m_redisPort != port) {
        m_redisPort = port;
        emit redisPortChanged();
    }
}

void HttpRedisClient::connectToRedis()
{
    qDebug() << "🔌 Attempting connection to Redis via Qt Network...";
    
    // Start connection checking
    m_connectionTimer->start();
    checkConnection();
}

void HttpRedisClient::checkConnection()
{
    qDebug() << "🔍 Checking Redis connection via HTTP bridge...";
    
    QNetworkRequest request(QUrl(m_baseUrl + "/api/redis/ping"));
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
    
    QNetworkReply *reply = m_networkManager->get(request);
    connect(reply, &QNetworkReply::finished, [this, reply]() {
        if (reply->error() == QNetworkReply::NoError) {
            QJsonDocument doc = QJsonDocument::fromJson(reply->readAll());
            QJsonObject obj = doc.object();
            
            bool wasConnected = m_connected;
            m_connected = obj["redis_connected"].toBool(false);
            
            if (m_connected != wasConnected) {
                qDebug() << "📡 Redis connection status changed:" << m_connected;
                emit connectedChanged();
            }
            
            if (m_connected) {
                qDebug() << "✅ Redis connection active via Qt Network";
            }
        } else {
            if (m_connected) {
                m_connected = false;
                qDebug() << "❌ Redis connection lost:" << reply->errorString();
                emit connectedChanged();
            }
        }
        reply->deleteLater();
    });
}

void HttpRedisClient::enableAutoTrading(bool enabled)
{
    qDebug() << "🤖 Enabling auto-trading via Qt Network:" << enabled;
    
    QJsonObject settings;
    settings["enabled"] = enabled;
    settings["buy_threshold_pct"] = 0.05;
    settings["sell_threshold_pct"] = 0.05;
    settings["max_position_per_trade"] = 1;
    
    sendHttpRequest("/api/redis/set/trading_settings", settings);
    emit autoTradingStatusChanged(enabled);
}

void HttpRedisClient::setTradingSettings(const QJsonObject &settings)
{
    qDebug() << "⚙️ Setting trading configuration via Qt Network";
    sendHttpRequest("/api/redis/set/trading_settings", settings);
}

void HttpRedisClient::getSystemStatus()
{
    qDebug() << "📊 Requesting system status via Qt Network";
    sendHttpRequest("/api/redis/get/system_status");
}

void HttpRedisClient::emergencyStopAll()
{
    qDebug() << "🛑 Emergency stop via Qt Network";
    
    QJsonObject settings;
    settings["enabled"] = false;
    sendHttpRequest("/api/redis/set/trading_settings", settings);
    emit autoTradingStatusChanged(false);
}

void HttpRedisClient::sendHttpRequest(const QString &endpoint, const QJsonObject &data)
{
    QNetworkRequest request(QUrl(m_baseUrl + endpoint));
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
    
    QJsonDocument doc(data);
    QByteArray jsonData = doc.toJson();
    
    QNetworkReply *reply;
    if (data.isEmpty()) {
        reply = m_networkManager->get(request);
    } else {
        reply = m_networkManager->post(request, jsonData);
    }
    
    connect(reply, &QNetworkReply::finished, this, &HttpRedisClient::onNetworkReply);
}

void HttpRedisClient::onNetworkReply()
{
    QNetworkReply *reply = qobject_cast<QNetworkReply*>(sender());
    if (!reply) return;
    
    if (reply->error() == QNetworkReply::NoError) {
        QByteArray data = reply->readAll();
        QJsonDocument doc = QJsonDocument::fromJson(data);
        QJsonObject obj = doc.object();
        
        qDebug() << "✅ Qt Network response:" << obj;
        
        if (obj.contains("system_status")) {
            emit systemStatusReceived(obj["system_status"].toObject());
        }
    } else {
        QString error = reply->errorString();
        qDebug() << "❌ Qt Network error:" << error;
        emit errorOccurred(error);
    }
    
    reply->deleteLater();
}