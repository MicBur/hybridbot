#include "redisclient.h"
#include <QDebug>
#include <QJsonParseError>

RedisClient::RedisClient(QObject *parent)
    : QObject(parent)
    , m_socket(new QTcpSocket(this))
    , m_pollTimer(new QTimer(this))
    , m_host("localhost")
    , m_port(6380)
    , m_password("")
    , m_connected(false)
{
    connect(m_socket, &QTcpSocket::connected, this, &RedisClient::onConnected);
    connect(m_socket, &QTcpSocket::disconnected, this, &RedisClient::onDisconnected);
    connect(m_socket, &QTcpSocket::readyRead, this, &RedisClient::onReadyRead);
    connect(m_socket, QOverload<QAbstractSocket::SocketError>::of(&QAbstractSocket::errorOccurred),
            this, &RedisClient::onErrorOccurred);

    // Setup polling timer for 5 second intervals
    m_pollTimer->setInterval(5000);
    connect(m_pollTimer, &QTimer::timeout, this, &RedisClient::pollData);
}

RedisClient::~RedisClient()
{
    disconnectFromRedis();
}

bool RedisClient::connected() const
{
    return m_connected;
}

QString RedisClient::host() const
{
    return m_host;
}

int RedisClient::port() const
{
    return m_port;
}

QString RedisClient::password() const
{
    return m_password;
}

void RedisClient::setHost(const QString &host)
{
    if (m_host != host) {
        m_host = host;
        emit hostChanged();
    }
}

void RedisClient::setPort(int port)
{
    if (m_port != port) {
        m_port = port;
        emit portChanged();
    }
}

void RedisClient::setPassword(const QString &password)
{
    if (m_password != password) {
        m_password = password;
        emit passwordChanged();
    }
}

void RedisClient::connectToRedis()
{
    if (m_socket->state() == QAbstractSocket::ConnectedState) {
        return;
    }

    qDebug() << "Connecting to Redis at" << m_host << ":" << m_port;
    m_socket->connectToHost(m_host, m_port);
}

void RedisClient::disconnectFromRedis()
{
    m_pollTimer->stop();
    if (m_socket->state() == QAbstractSocket::ConnectedState) {
        m_socket->disconnectFromHost();
    }
}

void RedisClient::sendCommand(const QString &command)
{
    if (!m_connected) {
        emit errorOccurred("Not connected to Redis");
        return;
    }

    sendRedisCommand(command);
}

void RedisClient::getMarketData()
{
    sendRedisCommand("GET market_data");
}

void RedisClient::getPortfolioData()
{
    sendRedisCommand("GET portfolio_equity");
}

void RedisClient::getMLStatus()
{
    sendRedisCommand("GET ml_status");
}

void RedisClient::getChartData(const QString &symbol)
{
    sendRedisCommand(QString("GET chart_data_%1").arg(symbol));
}

void RedisClient::getGrokRecommendations()
{
    sendRedisCommand("GET grok_top10");
}

void RedisClient::getGrokDeepSearch()
{
    sendRedisCommand("GET grok_deepersearch");
}

void RedisClient::getGrokTopStocks()
{
    sendRedisCommand("GET grok_topstocks_prediction");
}

void RedisClient::getAlpacaAccount()
{
    sendRedisCommand("GET alpaca_account");
}

void RedisClient::getAlpacaPositions()
{
    sendRedisCommand("GET alpaca_positions");
}

void RedisClient::getSystemStatus()
{
    sendRedisCommand("GET system_status");
}

void RedisClient::getPredictionMetrics()
{
    sendRedisCommand("GET prediction_quality_metrics");
}

void RedisClient::triggerMLTraining()
{
    sendRedisCommand("SET manual_trigger_ml true");
}

void RedisClient::triggerGrokFetch()
{
    sendRedisCommand("SET manual_trigger_grok true");
}

void RedisClient::onConnected()
{
    qDebug() << "Connected to Redis";
    
    // Authenticate if password is provided
    if (!m_password.isEmpty()) {
        sendRedisCommand(QString("AUTH %1").arg(m_password));
    }
    
    m_connected = true;
    emit connectedChanged();
    
    // Start polling for data
    m_pollTimer->start();
}

void RedisClient::onDisconnected()
{
    qDebug() << "Disconnected from Redis";
    m_connected = false;
    m_pollTimer->stop();
    emit connectedChanged();
}

void RedisClient::onReadyRead()
{
    QByteArray data = m_socket->readAll();
    m_buffer.append(data);
    
    // Process complete responses
    while (m_buffer.contains("\r\n")) {
        int endIndex = m_buffer.indexOf("\r\n");
        QByteArray response = m_buffer.left(endIndex);
        m_buffer.remove(0, endIndex + 2);
        
        processResponse(response);
    }
}

void RedisClient::onErrorOccurred(QAbstractSocket::SocketError error)
{
    QString errorString = m_socket->errorString();
    qDebug() << "Redis connection error:" << errorString;
    emit errorOccurred(errorString);
    
    m_connected = false;
    emit connectedChanged();
}

void RedisClient::pollData()
{
    if (!m_connected) {
        return;
    }

    // Poll various data sources
    getMarketData();
    getPortfolioData();
    getMLStatus();
    getGrokRecommendations();
    getGrokDeepSearch();
    getGrokTopStocks();
    getAlpacaAccount();
    getAlpacaPositions();
    getSystemStatus();
    getPredictionMetrics();
    
    // Poll chart data for major symbols
    QStringList symbols = {"AAPL", "NVDA", "MSFT", "TSLA"};
    for (const QString &symbol : symbols) {
        getChartData(symbol);
    }
}

void RedisClient::sendRedisCommand(const QString &command)
{
    if (!m_connected) {
        return;
    }

    // Simple Redis protocol implementation
    QStringList parts = command.split(" ");
    QString redisCommand = QString("*%1\r\n").arg(parts.size());
    
    for (const QString &part : parts) {
        redisCommand += QString("$%1\r\n%2\r\n").arg(part.length()).arg(part);
    }
    
    m_socket->write(redisCommand.toUtf8());
}

void RedisClient::processResponse(const QByteArray &response)
{
    QString responseStr = parseRedisResponse(response);
    
    if (responseStr.isEmpty()) {
        return;
    }

    // Try to parse as JSON
    QJsonParseError error;
    QJsonDocument doc = QJsonDocument::fromJson(responseStr.toUtf8(), &error);
    
    if (error.error == QJsonParseError::NoError && doc.isObject()) {
        QJsonObject obj = doc.object();
        emit dataReceived("redis_data", obj);
    } else {
        // Handle non-JSON responses
        qDebug() << "Redis response:" << responseStr;
    }
}

QString RedisClient::parseRedisResponse(const QByteArray &response)
{
    if (response.isEmpty()) {
        return QString();
    }

    char type = response[0];
    QByteArray content = response.mid(1);

    switch (type) {
    case '+': // Simple string
        return QString::fromUtf8(content);
    case '-': // Error
        emit errorOccurred(QString::fromUtf8(content));
        return QString();
    case ':': // Integer
        return QString::fromUtf8(content);
    case '$': // Bulk string
        // Handle bulk string format
        return QString::fromUtf8(content);
    case '*': // Array
        // Handle array format
        return QString::fromUtf8(content);
    default:
        return QString::fromUtf8(response);
    }
}