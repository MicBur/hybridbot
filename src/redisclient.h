#ifndef REDISCLIENT_H
#define REDISCLIENT_H

#include <QObject>
#include <QTcpSocket>
#include <QTimer>
#include <QJsonObject>
#include <QJsonDocument>

class RedisClient : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool connected READ connected NOTIFY connectedChanged)
    Q_PROPERTY(QString host READ host WRITE setHost NOTIFY hostChanged)
    Q_PROPERTY(int port READ port WRITE setPort NOTIFY portChanged)
    Q_PROPERTY(QString password READ password WRITE setPassword NOTIFY passwordChanged)

public:
    explicit RedisClient(QObject *parent = nullptr);
    ~RedisClient();

    bool connected() const;
    QString host() const;
    int port() const;
    QString password() const;

    void setHost(const QString &host);
    void setPort(int port);
    void setPassword(const QString &password);

    Q_INVOKABLE void connectToRedis();
    Q_INVOKABLE void disconnectFromRedis();
    Q_INVOKABLE void sendCommand(const QString &command);
    Q_INVOKABLE void getMarketData();
    Q_INVOKABLE void getPortfolioData();
    Q_INVOKABLE void getMLStatus();
    Q_INVOKABLE void getChartData(const QString &symbol);
    Q_INVOKABLE void getGrokRecommendations();
    Q_INVOKABLE void getGrokDeepSearch();
    Q_INVOKABLE void getGrokTopStocks();
    Q_INVOKABLE void getAlpacaAccount();
    Q_INVOKABLE void getAlpacaPositions();
    Q_INVOKABLE void getSystemStatus();
    Q_INVOKABLE void getPredictionMetrics();
    Q_INVOKABLE void triggerMLTraining();
    Q_INVOKABLE void triggerGrokFetch();

signals:
    void connectedChanged();
    void hostChanged();
    void portChanged();
    void passwordChanged();
    void dataReceived(const QString &key, const QJsonObject &data);
    void errorOccurred(const QString &error);

private slots:
    void onConnected();
    void onDisconnected();
    void onReadyRead();
    void onErrorOccurred(QAbstractSocket::SocketError error);
    void pollData();

private:
    void sendRedisCommand(const QString &command);
    void processResponse(const QByteArray &response);
    QString parseRedisResponse(const QByteArray &response);

    QTcpSocket *m_socket;
    QTimer *m_pollTimer;
    QString m_host;
    int m_port;
    QString m_password;
    bool m_connected;
    QByteArray m_buffer;
};

#endif // REDISCLIENT_H