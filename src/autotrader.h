#ifndef AUTOTRADER_H
#define AUTOTRADER_H

#include <QObject>
#include <QTimer>
#include <QJsonObject>
#include <QJsonArray>
#include <QMap>
#include <QDateTime>

class RedisClient;

class AutoTrader : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool enabled READ enabled WRITE setEnabled NOTIFY enabledChanged)
    Q_PROPERTY(QString strategy READ strategy WRITE setStrategy NOTIFY strategyChanged)
    Q_PROPERTY(double riskLevel READ riskLevel WRITE setRiskLevel NOTIFY riskLevelChanged)
    Q_PROPERTY(double portfolioValue READ portfolioValue NOTIFY portfolioValueChanged)
    Q_PROPERTY(double dailyPnL READ dailyPnL NOTIFY dailyPnLChanged)
    Q_PROPERTY(int totalTrades READ totalTrades NOTIFY totalTradesChanged)

public:
    explicit AutoTrader(RedisClient *redisClient, QObject *parent = nullptr);
    ~AutoTrader();

    bool enabled() const { return m_enabled; }
    QString strategy() const { return m_strategy; }
    double riskLevel() const { return m_riskLevel; }
    double portfolioValue() const { return m_portfolioValue; }
    double dailyPnL() const { return m_dailyPnL; }
    int totalTrades() const { return m_totalTrades; }

    void setEnabled(bool enabled);
    void setStrategy(const QString &strategy);
    void setRiskLevel(double riskLevel);

    // Trading strategies
    Q_INVOKABLE void setGrokTradingEnabled(bool enabled);
    Q_INVOKABLE void setMLTradingEnabled(bool enabled);
    Q_INVOKABLE void setMomentumTradingEnabled(bool enabled);
    Q_INVOKABLE void setArbitrageTradingEnabled(bool enabled);
    
    // Risk management
    Q_INVOKABLE void setMaxPositionSize(double percentage);
    Q_INVOKABLE void setStopLossPercentage(double percentage);
    Q_INVOKABLE void setTakeProfitPercentage(double percentage);
    Q_INVOKABLE void setMaxDailyLoss(double amount);
    
    // Trading controls
    Q_INVOKABLE void startTrading();
    Q_INVOKABLE void stopTrading();
    Q_INVOKABLE void pauseTrading();
    Q_INVOKABLE void emergencyStop();
    
    // Manual overrides
    Q_INVOKABLE void forceBuy(const QString &symbol, int quantity);
    Q_INVOKABLE void forceSell(const QString &symbol, int quantity);
    Q_INVOKABLE void closeAllPositions();

signals:
    void enabledChanged();
    void strategyChanged();
    void riskLevelChanged();
    void portfolioValueChanged();
    void dailyPnLChanged();
    void totalTradesChanged();
    
    void tradeExecuted(const QString &symbol, const QString &action, int quantity, double price, const QString &reason);
    void tradingStarted();
    void tradingStopped();
    void tradingPaused();
    void emergencyStopActivated();
    void riskLimitReached(const QString &reason);

private slots:
    void onRedisDataReceived(const QString &key, const QJsonObject &data);
    void checkTradingOpportunities();
    void updatePortfolioMetrics();
    void checkRiskLimits();
    void executePendingOrders();

private:
    // Core trading logic
    void processGrokSignals(const QJsonObject &grokData);
    void processMLPredictions(const QJsonObject &mlData);
    void processMomentumSignals(const QJsonObject &marketData);
    void checkArbitrageOpportunities(const QJsonObject &marketData);
    
    // Trade execution
    bool executeTrade(const QString &symbol, const QString &action, int quantity, const QString &reason);
    double calculatePositionSize(const QString &symbol, double confidence);
    bool checkRiskLimits(const QString &symbol, const QString &action, int quantity);
    
    // Position management
    void updatePosition(const QString &symbol, int quantity, double price);
    void checkStopLoss(const QString &symbol);
    void checkTakeProfit(const QString &symbol);
    
    // Data structures
    struct Position {
        QString symbol;
        int quantity;
        double avgPrice;
        double currentPrice;
        double unrealizedPnL;
        QDateTime openTime;
        double stopLoss;
        double takeProfit;
    };
    
    struct TradingSignal {
        QString symbol;
        QString action; // BUY, SELL, HOLD
        double confidence;
        QString source; // GROK, ML, MOMENTUM, ARBITRAGE
        QDateTime timestamp;
        QString reason;
    };
    
    RedisClient *m_redisClient;
    QTimer *m_tradingTimer;
    QTimer *m_riskTimer;
    
    // Trading state
    bool m_enabled;
    QString m_strategy;
    double m_riskLevel;
    bool m_grokTradingEnabled;
    bool m_mlTradingEnabled;
    bool m_momentumTradingEnabled;
    bool m_arbitrageTradingEnabled;
    
    // Risk management
    double m_maxPositionSize;
    double m_stopLossPercentage;
    double m_takeProfitPercentage;
    double m_maxDailyLoss;
    double m_dailyStartValue;
    
    // Portfolio tracking
    double m_portfolioValue;
    double m_dailyPnL;
    int m_totalTrades;
    double m_buyingPower;
    
    // Positions and signals
    QMap<QString, Position> m_positions;
    QList<TradingSignal> m_pendingSignals;
    QMap<QString, double> m_currentPrices;
    
    // Trading parameters
    int m_checkInterval; // milliseconds
    double m_minConfidenceThreshold;
    int m_maxTradesPerDay;
    int m_tradesExecutedToday;
    
    // Emergency controls
    bool m_emergencyStop;
    bool m_paused;
    QDateTime m_lastTradeTime;
};

#endif // AUTOTRADER_H