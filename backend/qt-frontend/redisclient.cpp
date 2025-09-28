#include "redisclient.h"
#include <QDebug>
#include <QProcess>
#include <QJsonParseError>

RedisClient::RedisClient(const QString &host, int port, const QString &password, QObject *parent)
    : QObject(parent), m_host(host), m_port(port), m_password(password), m_connected(false)
{
    // Verwende QProcess für redis-cli Verbindung
    // Bei lokalem Slave (6380) oder direktem Remote-Server
    // Format: redis-cli -h HOST -p PORT -a PASSWORD get key
    
    // Test connection
    testConnection();
    
    qDebug() << "Connecting to Redis at" << host << ":" << port;
}

QString RedisClient::get(const QString &key)
{
    // Verwende QProcess für redis-cli zum Remote-Server
    QProcess process;
    QStringList arguments;
    arguments << "-h" << m_host 
              << "-p" << QString::number(m_port)
              << "-a" << m_password
              << "get" << key;
    
    process.start("redis-cli", arguments);
    process.waitForFinished(5000); // 5 Sekunden timeout
    
    if (process.exitCode() == 0) {
        QString result = process.readAllStandardOutput().trimmed();
        // Entferne Anführungszeichen falls vorhanden
        if (result.startsWith('"') && result.endsWith('"')) {
            result = result.mid(1, result.length() - 2);
        }
        return result;
    }
    
    qWarning() << "Redis GET failed for key:" << key << process.readAllStandardError();
    
    // No fallback to mock data - return empty string on error
    return QString();
}

bool RedisClient::set(const QString &key, const QString &value)
{
    // Real implementation using redis-cli
    QProcess process;
    QStringList arguments;
    arguments << "-h" << m_host 
              << "-p" << QString::number(m_port)
              << "-a" << m_password
              << "set" << key << value;
    
    process.start("redis-cli", arguments);
    process.waitForFinished(5000);
    
    if (process.exitCode() == 0) {
        qDebug() << "Successfully set Redis key:" << key;
        return true;
    }
    
    qWarning() << "Redis SET failed for key:" << key << process.readAllStandardError();
    return false;
}

QStringList RedisClient::keys(const QString &pattern)
{
    // Real implementation using redis-cli
    QProcess process;
    QStringList arguments;
    arguments << "-h" << m_host 
              << "-p" << QString::number(m_port)
              << "-a" << m_password
              << "keys" << pattern;
    
    process.start("redis-cli", arguments);
    process.waitForFinished(5000);
    
    if (process.exitCode() == 0) {
        QString result = process.readAllStandardOutput();
        return result.split('\n', Qt::SkipEmptyParts);
    }
    
    qWarning() << "Redis KEYS failed for pattern:" << pattern << process.readAllStandardError();
    return QStringList();
}

QJsonObject RedisClient::getMarketData()
{
    QString jsonStr = get("market_data");
    if (jsonStr.isEmpty()) {
        return QJsonObject();
    }
    
    QJsonParseError error;
    QJsonDocument doc = QJsonDocument::fromJson(jsonStr.toUtf8(), &error);
    
    if (error.error != QJsonParseError::NoError) {
        qWarning() << "Failed to parse market data JSON:" << error.errorString();
        return QJsonObject(); // Return empty object instead of mock data
    }
    
    return doc.object();
}

bool RedisClient::isModelTrained()
{
    return get("model_trained") == "true";
}

QString RedisClient::getModelPath()
{
    return get("model_path");
}

void RedisClient::testConnection()
{
    // Test Redis connection
    QProcess process;
    QStringList arguments;
    arguments << "-h" << m_host 
              << "-p" << QString::number(m_port)
              << "-a" << m_password
              << "ping";
    
    process.start("redis-cli", arguments);
    process.waitForFinished(2000);
    
    if (process.exitCode() == 0) {
        QString result = process.readAllStandardOutput().trimmed();
        if (result == "PONG") {
            m_connected = true;
            emit connected();
            qDebug() << "Redis connection successful";
        } else {
            m_connected = false;
            qWarning() << "Redis ping failed, unexpected response:" << result;
        }
    } else {
        m_connected = false;
        qWarning() << "Redis connection failed:" << process.readAllStandardError();
    }
}

QJsonObject RedisClient::mockMarketData()
{
    // This method is now deprecated - we use real data only
    return QJsonObject();
}