#ifndef HTTPREDISCLIENT_H
#define HTTPREDISCLIENT_H

#include <QObject>
#include <QNetworkAccessManager>
#include <QNetworkRequest>
#include <QNetworkReply>
#include <QJsonObject>
#include <QJsonDocument>
#include <QTimer>

class HttpRedisClient : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool connected READ connected NOTIFY connectedChanged)
    Q_PROPERTY(QString redisHost READ redisHost WRITE setRedisHost NOTIFY redisHostChanged)
    Q_PROPERTY(int redisPort READ redisPort WRITE setRedisPort NOTIFY redisPortChanged)

public:
    explicit HttpRedisClient(QObject *parent = nullptr);
    
    bool connected() const { return m_connected; }
    QString redisHost() const { return m_redisHost; }
    int redisPort() const { return m_redisPort; }
    
    void setRedisHost(const QString &host);
    void setRedisPort(int port);
    
    Q_INVOKABLE void connectToRedis();
    Q_INVOKABLE void enableAutoTrading(bool enabled);
    Q_INVOKABLE void setTradingSettings(const QJsonObject &settings);
    Q_INVOKABLE void getSystemStatus();
    Q_INVOKABLE void emergencyStopAll();

signals:
    void connectedChanged();
    void redisHostChanged();
    void redisPortChanged();
    void autoTradingStatusChanged(bool enabled);
    void systemStatusReceived(const QJsonObject &status);
    void errorOccurred(const QString &error);

private slots:
    void onNetworkReply();
    void checkConnection();

private:
    void sendHttpRequest(const QString &endpoint, const QJsonObject &data = QJsonObject());
    void processResponse(QNetworkReply *reply);
    
    QNetworkAccessManager *m_networkManager;
    QTimer *m_connectionTimer;
    bool m_connected;
    QString m_redisHost;
    int m_redisPort;
    QString m_baseUrl;
};

#endif // HTTPREDISCLIENT_H