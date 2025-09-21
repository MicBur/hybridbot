#include "autotrader.h"
#include "redisclient.h"
#include <QJsonDocument>
#include <QJsonArray>
#include <QDebug>
#include <QRandomGenerator>

AutoTrader::AutoTrader(RedisClient *redisClient, QObject *parent)
    : QObject(parent)
    , m_redisClient(redisClient)
    , m_tradingTimer(new QTimer(this))
    , m_riskTimer(new QTimer(this))
    , m_enabled(false)
    , m_strategy("CONSERVATIVE")
    , m_riskLevel(0.5)
    , m_grokTradingEnabled(true)
    , m_mlTradingEnabled(true)
    , m_momentumTradingEnabled(false)
    , m_arbitrageTradingEnabled(false)
    , m_maxPositionSize(0.05) // 5% max per position
    , m_stopLossPercentage(0.02) // 2% stop loss
    , m_takeProfitPercentage(0.06) // 6% take profit
    , m_maxDailyLoss(1000.0) // $1000 max daily loss
    , m_portfolioValue(109329.05)
    , m_dailyPnL(2847.23)
    , m_totalTrades(0)
    , m_buyingPower(25670.45)
    , m_checkInterval(5000) // 5 seconds
    , m_minConfidenceThreshold(0.75) // 75% minimum confidence
    , m_maxTradesPerDay(50)
    , m_tradesExecutedToday(0)
    , m_emergencyStop(false)
    , m_paused(false)
{
    // Initialize daily start value
    m_dailyStartValue = m_portfolioValue - m_dailyPnL;
    
    // Connect Redis data signals
    connect(m_redisClient, &RedisClient::dataReceived,
            this, &AutoTrader::onRedisDataReceived);
    
    // Setup trading timer
    m_tradingTimer->setInterval(m_checkInterval);
    connect(m_tradingTimer, &QTimer::timeout,
            this, &AutoTrader::checkTradingOpportunities);
    
    // Setup risk management timer (faster checks)
    m_riskTimer->setInterval(1000); // 1 second
    connect(m_riskTimer, &QTimer::timeout,
            this, &AutoTrader::checkRiskLimits);
    
    // Initialize current prices with some mock data
    m_currentPrices["AAPL"] = 234.10;
    m_currentPrices["NVDA"] = 1185.20;
    m_currentPrices["MSFT"] = 412.85;
    m_currentPrices["GOOGL"] = 162.45;
    m_currentPrices["TSLA"] = 248.75;
    m_currentPrices["META"] = 578.23;
    m_currentPrices["AMZN"] = 186.12;
    
    qDebug() << "AutoTrader initialized with strategy:" << m_strategy << "risk level:" << m_riskLevel;
}

AutoTrader::~AutoTrader()
{
    stopTrading();
}

void AutoTrader::setEnabled(bool enabled)
{
    if (m_enabled != enabled) {
        m_enabled = enabled;
        emit enabledChanged();
        
        if (enabled) {
            startTrading();
        } else {
            stopTrading();
        }
        
        qDebug() << "AutoTrader enabled:" << enabled;
    }
}

void AutoTrader::setStrategy(const QString &strategy)
{
    if (m_strategy != strategy) {
        m_strategy = strategy;
        emit strategyChanged();
        
        // Adjust parameters based on strategy
        if (strategy == "AGGRESSIVE") {
            m_riskLevel = 0.8;
            m_maxPositionSize = 0.1; // 10%
            m_minConfidenceThreshold = 0.65; // 65%
            m_checkInterval = 2000; // 2 seconds
        } else if (strategy == "CONSERVATIVE") {
            m_riskLevel = 0.3;
            m_maxPositionSize = 0.03; // 3%
            m_minConfidenceThreshold = 0.85; // 85%
            m_checkInterval = 10000; // 10 seconds
        } else if (strategy == "BALANCED") {
            m_riskLevel = 0.5;
            m_maxPositionSize = 0.05; // 5%
            m_minConfidenceThreshold = 0.75; // 75%
            m_checkInterval = 5000; // 5 seconds
        }
        
        m_tradingTimer->setInterval(m_checkInterval);
        emit riskLevelChanged();
        
        qDebug() << "Trading strategy changed to:" << strategy;
    }
}

void AutoTrader::setRiskLevel(double riskLevel)
{
    if (m_riskLevel != riskLevel) {
        m_riskLevel = qBound(0.0, riskLevel, 1.0);
        emit riskLevelChanged();
        
        // Adjust position size based on risk level
        m_maxPositionSize = 0.02 + (m_riskLevel * 0.08); // 2% to 10%
        
        qDebug() << "Risk level set to:" << m_riskLevel << "max position size:" << m_maxPositionSize;
    }
}

void AutoTrader::startTrading()
{
    if (m_emergencyStop) {
        qWarning() << "Cannot start trading: Emergency stop is active";
        return;
    }
    
    m_paused = false;
    m_tradingTimer->start();
    m_riskTimer->start();
    
    // Reset daily counters if new day
    QDateTime now = QDateTime::currentDateTime();
    static QDate lastTradeDate = now.date();
    if (now.date() != lastTradeDate) {
        m_tradesExecutedToday = 0;
        m_dailyStartValue = m_portfolioValue;
        m_dailyPnL = 0;
        lastTradeDate = now.date();
        emit dailyPnLChanged();
    }
    
    emit tradingStarted();
    qDebug() << "AutoTrader started with" << m_strategy << "strategy";
}

void AutoTrader::stopTrading()
{
    m_tradingTimer->stop();
    m_riskTimer->stop();
    emit tradingStopped();
    qDebug() << "AutoTrader stopped";
}

void AutoTrader::pauseTrading()
{
    m_paused = true;
    m_tradingTimer->stop();
    emit tradingPaused();
    qDebug() << "AutoTrader paused";
}

void AutoTrader::emergencyStop()
{
    m_emergencyStop = true;
    stopTrading();
    
    // Close all positions immediately
    closeAllPositions();
    
    emit emergencyStopActivated();
    qWarning() << "EMERGENCY STOP ACTIVATED - All trading halted";
}

void AutoTrader::onRedisDataReceived(const QString &key, const QJsonObject &data)
{
    if (key == "grok_recommendations") {
        processGrokSignals(data);
    } else if (key == "ml_predictions") {
        processMLPredictions(data);
    } else if (key == "market_data") {
        processMomentumSignals(data);
        checkArbitrageOpportunities(data);
        updatePortfolioMetrics();
    }
}

void AutoTrader::checkTradingOpportunities()
{
    if (!m_enabled || m_paused || m_emergencyStop) {
        return;
    }
    
    if (m_tradesExecutedToday >= m_maxTradesPerDay) {
        qDebug() << "Daily trade limit reached:" << m_tradesExecutedToday;
        return;
    }
    
    // Process pending signals
    executePendingOrders();
    
    // Request fresh data from Redis
    m_redisClient->getGrokRecommendations();
    m_redisClient->getMLStatus();
    m_redisClient->getMarketData();
    
    qDebug() << "Checking trading opportunities... Trades today:" << m_tradesExecutedToday;
}

void AutoTrader::processGrokSignals(const QJsonObject &grokData)
{
    if (!m_grokTradingEnabled) return;
    
    QJsonArray recommendations = grokData["recommendations"].toArray();
    
    for (const auto &value : recommendations) {
        QJsonObject rec = value.toObject();
        QString symbol = rec["symbol"].toString();
        QString action = rec["action"].toString().toUpper();
        double confidence = rec["confidence"].toDouble() / 100.0; // Convert percentage to decimal
        QString reason = "Grok AI: " + rec["reason"].toString();
        
        if (confidence >= m_minConfidenceThreshold) {
            TradingSignal signal;
            signal.symbol = symbol;
            signal.action = action;
            signal.confidence = confidence;
            signal.source = "GROK";
            signal.timestamp = QDateTime::currentDateTime();
            signal.reason = reason;
            
            m_pendingSignals.append(signal);
            
            emit tradingSignalReceived(symbol, action, confidence);
            qDebug() << "Grok signal:" << symbol << action << "confidence:" << confidence;
        }
    }
}

void AutoTrader::processMLPredictions(const QJsonObject &mlData)
{
    if (!m_mlTradingEnabled) return;
    
    QJsonArray predictions = mlData["predictions"].toArray();
    
    for (const auto &value : predictions) {
        QJsonObject pred = value.toObject();
        QString symbol = pred["symbol"].toString();
        double prediction = pred["prediction"].toDouble();
        double confidence = pred["confidence"].toDouble();
        QString model = pred["model"].toString();
        
        if (confidence >= m_minConfidenceThreshold) {
            QString action = (prediction > 0.02) ? "BUY" : 
                           (prediction < -0.02) ? "SELL" : "HOLD";
            
            if (action != "HOLD") {
                TradingSignal signal;
                signal.symbol = symbol;
                signal.action = action;
                signal.confidence = confidence;
                signal.source = "ML";
                signal.timestamp = QDateTime::currentDateTime();
                signal.reason = QString("ML %1: %2% prediction").arg(model).arg(prediction * 100, 0, 'f', 1);
                
                m_pendingSignals.append(signal);
                
                emit tradingSignalReceived(symbol, action, confidence);
                qDebug() << "ML signal:" << symbol << action << "confidence:" << confidence;
            }
        }
    }
}

void AutoTrader::executePendingOrders()
{
    if (m_pendingSignals.isEmpty()) return;
    
    // Sort signals by confidence (highest first)
    std::sort(m_pendingSignals.begin(), m_pendingSignals.end(),
              [](const TradingSignal &a, const TradingSignal &b) {
                  return a.confidence > b.confidence;
              });
    
    auto it = m_pendingSignals.begin();
    while (it != m_pendingSignals.end()) {
        const TradingSignal &signal = *it;
        
        // Check if signal is still fresh (within 30 seconds)
        if (signal.timestamp.secsTo(QDateTime::currentDateTime()) > 30) {
            it = m_pendingSignals.erase(it);
            continue;
        }
        
        // Calculate position size based on confidence and risk level
        double positionSize = calculatePositionSize(signal.symbol, signal.confidence);
        int quantity = static_cast<int>(positionSize / m_currentPrices[signal.symbol]);
        
        if (quantity > 0 && executeTrade(signal.symbol, signal.action, quantity, signal.reason)) {
            it = m_pendingSignals.erase(it);
        } else {
            ++it;
        }
    }
}

bool AutoTrader::executeTrade(const QString &symbol, const QString &action, int quantity, const QString &reason)
{
    if (!checkRiskLimits(symbol, action, quantity)) {
        return false;
    }
    
    double price = m_currentPrices.value(symbol, 0.0);
    if (price <= 0) {
        qWarning() << "Invalid price for" << symbol;
        return false;
    }
    
    double tradeValue = quantity * price;
    
    // Check buying power for buy orders
    if (action == "BUY" && tradeValue > m_buyingPower) {
        qDebug() << "Insufficient buying power for" << symbol << "trade";
        return false;
    }
    
    // Simulate trade execution
    updatePosition(symbol, (action == "BUY") ? quantity : -quantity, price);
    
    m_totalTrades++;
    m_tradesExecutedToday++;
    m_lastTradeTime = QDateTime::currentDateTime();
    
    if (action == "BUY") {
        m_buyingPower -= tradeValue;
    } else {
        m_buyingPower += tradeValue;
    }
    
    emit tradeExecuted(symbol, action, quantity, price, reason);
    emit totalTradesChanged();
    
    qDebug() << "TRADE EXECUTED:" << action << quantity << symbol << "@" << price << "Reason:" << reason;
    
    // Send trade to Redis/Alpaca
    QJsonObject tradeData;
    tradeData["symbol"] = symbol;
    tradeData["action"] = action;
    tradeData["quantity"] = quantity;
    tradeData["price"] = price;
    tradeData["timestamp"] = QDateTime::currentDateTime().toString(Qt::ISODate);
    tradeData["reason"] = reason;
    tradeData["source"] = "AutoTrader";
    
    m_redisClient->sendCommand(QString("SET trade:%1:%2 '%3'")
                              .arg(symbol)
                              .arg(QDateTime::currentDateTime().toMSecsSinceEpoch())
                              .arg(QJsonDocument(tradeData).toJson(QJsonDocument::Compact)));
    
    return true;
}

double AutoTrader::calculatePositionSize(const QString &symbol, double confidence)
{
    // Base position size adjusted by confidence and risk level
    double baseSize = m_portfolioValue * m_maxPositionSize;
    double adjustedSize = baseSize * confidence * m_riskLevel;
    
    // Don't exceed available buying power
    return qMin(adjustedSize, m_buyingPower * 0.9);
}

bool AutoTrader::checkRiskLimits(const QString &symbol, const QString &action, int quantity)
{
    double price = m_currentPrices.value(symbol, 0.0);
    double tradeValue = quantity * price;
    
    // Check position size limit
    if (tradeValue > m_portfolioValue * m_maxPositionSize) {
        qDebug() << "Trade size exceeds position limit for" << symbol;
        return false;
    }
    
    // Check daily loss limit
    double currentLoss = m_dailyStartValue - m_portfolioValue;
    if (currentLoss > m_maxDailyLoss) {
        emit riskLimitReached("Daily loss limit exceeded");
        pauseTrading();
        return false;
    }
    
    // Check if we already have a large position in this symbol
    if (m_positions.contains(symbol)) {
        const Position &pos = m_positions[symbol];
        double currentPositionValue = qAbs(pos.quantity) * price;
        if (currentPositionValue > m_portfolioValue * m_maxPositionSize * 1.5) {
            qDebug() << "Position size limit already reached for" << symbol;
            return false;
        }
    }
    
    return true;
}

void AutoTrader::updatePosition(const QString &symbol, int quantity, double price)
{
    if (m_positions.contains(symbol)) {
        Position &pos = m_positions[symbol];
        
        if ((pos.quantity > 0 && quantity > 0) || (pos.quantity < 0 && quantity < 0)) {
            // Adding to position
            double totalValue = pos.avgPrice * qAbs(pos.quantity) + price * qAbs(quantity);
            pos.quantity += quantity;
            pos.avgPrice = totalValue / qAbs(pos.quantity);
        } else {
            // Reducing or closing position
            pos.quantity += quantity;
            if (qAbs(pos.quantity) < 1) {
                // Position closed
                m_positions.remove(symbol);
                return;
            }
        }
        
        pos.currentPrice = price;
        pos.unrealizedPnL = (price - pos.avgPrice) * pos.quantity;
        
        // Set stop loss and take profit
        if (pos.quantity > 0) {
            pos.stopLoss = pos.avgPrice * (1.0 - m_stopLossPercentage);
            pos.takeProfit = pos.avgPrice * (1.0 + m_takeProfitPercentage);
        } else {
            pos.stopLoss = pos.avgPrice * (1.0 + m_stopLossPercentage);
            pos.takeProfit = pos.avgPrice * (1.0 - m_takeProfitPercentage);
        }
    } else {
        // New position
        Position pos;
        pos.symbol = symbol;
        pos.quantity = quantity;
        pos.avgPrice = price;
        pos.currentPrice = price;
        pos.unrealizedPnL = 0.0;
        pos.openTime = QDateTime::currentDateTime();
        
        if (quantity > 0) {
            pos.stopLoss = price * (1.0 - m_stopLossPercentage);
            pos.takeProfit = price * (1.0 + m_takeProfitPercentage);
        } else {
            pos.stopLoss = price * (1.0 + m_stopLossPercentage);
            pos.takeProfit = price * (1.0 - m_takeProfitPercentage);
        }
        
        m_positions[symbol] = pos;
    }
}

void AutoTrader::checkRiskLimits()
{
    if (!m_enabled || m_paused) return;
    
    // Update current prices (simulate with small random changes)
    for (auto it = m_currentPrices.begin(); it != m_currentPrices.end(); ++it) {
        double change = (QRandomGenerator::global()->generateDouble() - 0.5) * 0.02; // ±1%
        it.value() *= (1.0 + change);
    }
    
    // Check stop loss and take profit for all positions
    for (auto it = m_positions.begin(); it != m_positions.end();) {
        Position &pos = it.value();
        pos.currentPrice = m_currentPrices[pos.symbol];
        pos.unrealizedPnL = (pos.currentPrice - pos.avgPrice) * pos.quantity;
        
        bool shouldClose = false;
        QString reason;
        
        if (pos.quantity > 0) {
            // Long position
            if (pos.currentPrice <= pos.stopLoss) {
                shouldClose = true;
                reason = "Stop Loss";
            } else if (pos.currentPrice >= pos.takeProfit) {
                shouldClose = true;
                reason = "Take Profit";
            }
        } else {
            // Short position
            if (pos.currentPrice >= pos.stopLoss) {
                shouldClose = true;
                reason = "Stop Loss";
            } else if (pos.currentPrice <= pos.takeProfit) {
                shouldClose = true;
                reason = "Take Profit";
            }
        }
        
        if (shouldClose) {
            executeTrade(pos.symbol, (pos.quantity > 0) ? "SELL" : "BUY", 
                        qAbs(pos.quantity), reason);
            it = m_positions.erase(it);
        } else {
            ++it;
        }
    }
    
    updatePortfolioMetrics();
}

void AutoTrader::updatePortfolioMetrics()
{
    double totalValue = m_buyingPower;
    double totalUnrealizedPnL = 0.0;
    
    // Calculate total portfolio value including positions
    for (const Position &pos : m_positions) {
        double positionValue = qAbs(pos.quantity) * pos.currentPrice;
        totalValue += positionValue;
        totalUnrealizedPnL += pos.unrealizedPnL;
    }
    
    if (qAbs(m_portfolioValue - totalValue) > 0.01) {
        m_portfolioValue = totalValue;
        emit portfolioValueChanged();
    }
    
    double newDailyPnL = m_portfolioValue - m_dailyStartValue;
    if (qAbs(m_dailyPnL - newDailyPnL) > 0.01) {
        m_dailyPnL = newDailyPnL;
        emit dailyPnLChanged();
    }
}

void AutoTrader::closeAllPositions()
{
    for (const Position &pos : m_positions) {
        executeTrade(pos.symbol, (pos.quantity > 0) ? "SELL" : "BUY", 
                    qAbs(pos.quantity), "Emergency Close");
    }
    m_positions.clear();
    qDebug() << "All positions closed";
}

// Strategy enable/disable methods
void AutoTrader::setGrokTradingEnabled(bool enabled)
{
    m_grokTradingEnabled = enabled;
    qDebug() << "Grok trading enabled:" << enabled;
}

void AutoTrader::setMLTradingEnabled(bool enabled)
{
    m_mlTradingEnabled = enabled;
    qDebug() << "ML trading enabled:" << enabled;
}

void AutoTrader::setMomentumTradingEnabled(bool enabled)
{
    m_momentumTradingEnabled = enabled;
    qDebug() << "Momentum trading enabled:" << enabled;
}

void AutoTrader::setArbitrageTradingEnabled(bool enabled)
{
    m_arbitrageTradingEnabled = enabled;
    qDebug() << "Arbitrage trading enabled:" << enabled;
}

// Risk management setters
void AutoTrader::setMaxPositionSize(double percentage)
{
    m_maxPositionSize = qBound(0.01, percentage, 0.5); // 1% to 50%
    qDebug() << "Max position size set to:" << m_maxPositionSize * 100 << "%";
}

void AutoTrader::setStopLossPercentage(double percentage)
{
    m_stopLossPercentage = qBound(0.005, percentage, 0.2); // 0.5% to 20%
    qDebug() << "Stop loss percentage set to:" << m_stopLossPercentage * 100 << "%";
}

void AutoTrader::setTakeProfitPercentage(double percentage)
{
    m_takeProfitPercentage = qBound(0.01, percentage, 1.0); // 1% to 100%
    qDebug() << "Take profit percentage set to:" << m_takeProfitPercentage * 100 << "%";
}

void AutoTrader::setMaxDailyLoss(double amount)
{
    m_maxDailyLoss = qMax(100.0, amount); // Minimum $100
    qDebug() << "Max daily loss set to: $" << m_maxDailyLoss;
}

// Manual trading methods
void AutoTrader::forceBuy(const QString &symbol, int quantity)
{
    executeTrade(symbol, "BUY", quantity, "Manual Buy");
}

void AutoTrader::forceSell(const QString &symbol, int quantity)
{
    executeTrade(symbol, "SELL", quantity, "Manual Sell");
}

void AutoTrader::processMomentumSignals(const QJsonObject &marketData)
{
    // Placeholder for momentum trading logic
    Q_UNUSED(marketData)
}

void AutoTrader::checkArbitrageOpportunities(const QJsonObject &marketData)
{
    // Placeholder for arbitrage trading logic
    Q_UNUSED(marketData)
}