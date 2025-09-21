#include <QCoreApplication>
#include <QHttpServer>
#include <QJsonDocument>
#include <QJsonObject>
#include <QTcpSocket>
#include <QDebug>

class QtRedisHttpBridge : public QObject
{
    Q_OBJECT

public:
    QtRedisHttpBridge(QObject *parent = nullptr) : QObject(parent)
    {
        m_server = new QHttpServer(this);
        m_socket = new QTcpSocket(this);
        
        setupRoutes();
        connectToRedis();
    }
    
    void start()
    {
        if (m_server->listen(QHostAddress::Any, 8080)) {
            qDebug() << "🚀 Qt Redis HTTP Bridge started on port 8080";
            qDebug() << "📡 Bridging HTTP requests to Redis on port 6380";
        } else {
            qDebug() << "❌ Failed to start HTTP server";
        }
    }

private slots:
    void onRedisConnected()
    {
        qDebug() << "✅ Connected to Redis on port 6380";
        // Authenticate if needed
        sendRedisCommand("AUTH pass123");
    }
    
    void onRedisDisconnected()
    {
        qDebug() << "❌ Disconnected from Redis";
    }

private:
    void setupRoutes()
    {
        // Health check
        m_server->route("/api/redis/ping", QHttpServerRequest::Method::Get,
            [this](const QHttpServerRequest &request) {
                QJsonObject response;
                response["status"] = "ok";
                response["redis_connected"] = (m_socket->state() == QAbstractSocket::ConnectedState);
                response["timestamp"] = QDateTime::currentDateTime().toString(Qt::ISODate);
                
                return QHttpServerResponse(QJsonDocument(response).toJson(), "application/json");
            });
        
        // Set Redis key
        m_server->route("/api/redis/set/<arg>", QHttpServerRequest::Method::Post,
            [this](const QString &key, const QHttpServerRequest &request) {
                QJsonDocument doc = QJsonDocument::fromJson(request.body());
                QJsonObject data = doc.object();
                
                QString value = QJsonDocument(data).toJson(QJsonDocument::Compact);
                QString command = QString("SET %1 '%2'").arg(key, value);
                
                sendRedisCommand(command);
                
                QJsonObject response;
                response["status"] = "success";
                response["key"] = key;
                response["command"] = command;
                
                return QHttpServerResponse(QJsonDocument(response).toJson(), "application/json");
            });
        
        // Get Redis key
        m_server->route("/api/redis/get/<arg>", QHttpServerRequest::Method::Get,
            [this](const QString &key, const QHttpServerRequest &request) {
                QString command = QString("GET %1").arg(key);
                QString value = sendRedisCommandSync(command);
                
                QJsonObject response;
                response["status"] = "success";
                response["key"] = key;
                response["value"] = value;
                
                return QHttpServerResponse(QJsonDocument(response).toJson(), "application/json");
            });
        
        // CORS preflight
        m_server->route("/api/redis/<arg>", QHttpServerRequest::Method::Options,
            [](const QString &, const QHttpServerRequest &) {
                QHttpServerResponse response("", "text/plain", QHttpServerResponse::StatusCode::Ok);
                response.setHeader("Access-Control-Allow-Origin", "*");
                response.setHeader("Access-Control-Allow-Methods", "GET, POST, OPTIONS");
                response.setHeader("Access-Control-Allow-Headers", "Content-Type");
                return response;
            });
    }
    
    void connectToRedis()
    {
        connect(m_socket, &QTcpSocket::connected, this, &QtRedisHttpBridge::onRedisConnected);
        connect(m_socket, &QTcpSocket::disconnected, this, &QtRedisHttpBridge::onRedisDisconnected);
        
        qDebug() << "🔌 Connecting to Redis localhost:6380...";
        m_socket->connectToHost("localhost", 6380);
    }
    
    void sendRedisCommand(const QString &command)
    {
        if (m_socket->state() != QAbstractSocket::ConnectedState) {
            qDebug() << "❌ Redis not connected";
            return;
        }
        
        QString redisCommand = command + "\r\n";
        m_socket->write(redisCommand.toUtf8());
        m_socket->flush();
        
        qDebug() << "📤 Redis command:" << command;
    }
    
    QString sendRedisCommandSync(const QString &command)
    {
        sendRedisCommand(command);
        
        if (m_socket->waitForReadyRead(1000)) {
            QByteArray response = m_socket->readAll();
            return QString::fromUtf8(response).trimmed();
        }
        
        return "";
    }

    QHttpServer *m_server;
    QTcpSocket *m_socket;
};

int main(int argc, char *argv[])
{
    QCoreApplication app(argc, argv);
    
    qDebug() << "🚀 Starting Qt Redis HTTP Bridge...";
    
    QtRedisHttpBridge bridge;
    bridge.start();
    
    return app.exec();
}

#include "main.moc"