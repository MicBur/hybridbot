// AutoTradingBackend.js - Real Redis Integration
// Uses QML RedisClient and redis.txt endpoints

console.log('🔧 Loading AutoTradingBackend.js...');

class AutoTradingBackend {
    constructor() {
        this.connected = false;
        this.testConnection();
    }
    
    async testConnection() {
        try {
            // Check if QML redisClient is available
            if (typeof redisClient !== 'undefined') {
                console.log('🔌 QML RedisClient detected');
                this.connected = redisClient.connected;
                console.log('🔌 Redis connection status:', this.connected);
                return this.connected;
            } else {
                console.log('⚠️ QML redisClient not available');
                this.connected = false;
            }
        } catch (error) {
            console.log('⚠️ Connection test failed:', error.message);
            this.connected = false;
        }
        return this.connected;
    }
    
    async enableAutoTrading(enabled) {
        console.log('📡 enableAutoTrading called:', enabled);
        
        const settings = {
            "enabled": enabled,
            "buy_threshold_pct": 0.05,
            "sell_threshold_pct": 0.05,
            "max_position_per_trade": 1
        };
        
        try {
            // Use QML RedisClient
            if (typeof redisClient !== 'undefined') {
                if (redisClient.connected) {
                    console.log('📤 Sending trading_settings to Redis via QML');
                    
                    // Try direct method first
                    if (typeof redisClient.enableAutoTrading === 'function') {
                        redisClient.enableAutoTrading(enabled);
                        console.log('✅ QML enableAutoTrading method called');
                        return true;
                    }
                    
                    // Fallback: Direct Redis command via QML
                    const command = `SET trading_settings '${JSON.stringify(settings)}'`;
                    redisClient.sendCommand(command);
                    console.log('✅ Redis SET command sent:', command);
                    return true;
                } else {
                    throw new Error('Redis not connected via QML');
                }
            } else {
                throw new Error('QML redisClient not available');
            }
            
        } catch (error) {
            console.error('❌ enableAutoTrading failed:', error);
            alert('⚠️ Backend not connected!\n\nError: ' + error.message + '\n\nCheck:\n1. Redis server running\n2. QML application connected');
            return false;
        }
    }
        
        this.init();
    }
    
    init() {
        console.log('🔌 Initializing Auto-Trading Backend Connection...');
        
        // Try WebSocket connection first
        this.connectWebSocket();
        
        // Fallback to HTTP polling
        this.startHttpPolling();
    }
    
    connectWebSocket() {
        try {
            this.websocket = new WebSocket('ws://localhost:8081/autotrading');
            
            this.websocket.onopen = () => {
                console.log('✅ WebSocket connected to Auto-Trading Backend');
                this.isConnected = true;
                this.onConnectionStatusChanged(true);
            };
            
            this.websocket.onmessage = (event) => {
                const data = JSON.parse(event.data);
                this.handleBackendMessage(data);
            };
            
            this.websocket.onclose = () => {
                console.log('❌ WebSocket disconnected from Backend');
                this.isConnected = false;
                this.onConnectionStatusChanged(false);
                
                // Retry in 5 seconds
                setTimeout(() => this.connectWebSocket(), 5000);
            };
            
            this.websocket.onerror = (error) => {
                console.error('🚨 WebSocket error:', error);
                this.isConnected = false;
            };
            
        } catch (error) {
            console.warn('⚠️ WebSocket not available, using HTTP fallback');
            this.isConnected = false;
        }
    }
    
    startHttpPolling() {
        // Poll backend status every 3 seconds
        setInterval(() => {
            if (!this.websocket || this.websocket.readyState !== WebSocket.OPEN) {
                this.pollBackendStatus();
            }
        }, 3000);
    }
    
    async pollBackendStatus() {
        try {
            const response = await fetch(`${this.httpEndpoint}/trading-status`);
            if (response.ok) {
                const data = await response.json();
                this.handleBackendMessage(data);
                
                if (!this.isConnected) {
                    this.isConnected = true;
                    this.onConnectionStatusChanged(true);
                }
            }
        } catch (error) {
            if (this.isConnected) {
                console.warn('⚠️ HTTP Backend not reachable:', error.message);
                this.isConnected = false;
                this.onConnectionStatusChanged(false);
            }
        }
    }
    
    handleBackendMessage(data) {
        switch (data.type) {
            case 'trading_status':
                this.autoTradingEnabled = data.enabled;
                this.currentStrategy = data.strategy;
                this.onTradingStatusChanged(data.enabled, data.strategy);
                break;
                
            case 'trade_executed':
                this.onTradeExecuted(data);
                break;
                
            case 'trading_error':
                this.onTradingError(data.error);
                break;
                
            case 'emergency_stop':
                this.onEmergencyStop();
                break;
                
            case 'portfolio_update':
                this.onPortfolioUpdate(data.portfolio);
                break;
                
            default:
                console.log('📨 Backend message:', data);
        }
    }
    
    // Send commands to backend
    async enableAutoTrading(enabled) {
        const command = {
            action: 'enable_auto_trading',
            enabled: enabled,
            strategy: this.currentStrategy
        };
        
        return this.sendCommand(command);
    }
    
    async setTradingStrategy(strategy) {
        this.currentStrategy = strategy;
        
        const command = {
            action: 'set_trading_strategy',
            strategy: strategy
        };
        
        return this.sendCommand(command);
    }
    
    async emergencyStopAll() {
        const command = {
            action: 'emergency_stop_all'
        };
        
        return this.sendCommand(command);
    }
    
    async setRiskLimits(maxPosition, stopLoss) {
        const command = {
            action: 'set_risk_limits',
            max_position_size: maxPosition,
            stop_loss_percent: stopLoss
        };
        
        return this.sendCommand(command);
    }
    
    async sendCommand(command) {
        // Try WebSocket first
        if (this.websocket && this.websocket.readyState === WebSocket.OPEN) {
            this.websocket.send(JSON.stringify(command));
            console.log('📤 WebSocket command sent:', command);
            return true;
        }
        
        // Fallback to HTTP
        try {
            const response = await fetch(`${this.httpEndpoint}/command`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify(command)
            });
            
            if (response.ok) {
                const result = await response.json();
                console.log('📤 HTTP command sent:', command, '✅ Result:', result);
                return result;
            } else {
                throw new Error(`HTTP ${response.status}: ${response.statusText}`);
            }
            
        } catch (error) {
            console.error('🚨 Failed to send command:', error);
            this.onTradingError(`Backend communication failed: ${error.message}`);
            return false;
        }
    }
    
    // Event handlers (to be overridden by frontend)
    onConnectionStatusChanged(connected) {
        console.log(`🔗 Backend connection: ${connected ? 'CONNECTED' : 'DISCONNECTED'}`);
        
        // Update UI connection indicator
        const indicator = document.getElementById('backendStatus');
        if (indicator) {
            indicator.textContent = connected ? '🟢 Backend Connected' : '🔴 Backend Disconnected';
            indicator.className = connected ? 'connected' : 'disconnected';
        }
    }
    
    onTradingStatusChanged(enabled, strategy) {
        console.log(`📊 Trading Status: ${enabled ? 'ENABLED' : 'DISABLED'} | Strategy: ${strategy}`);
        
        // Update frontend UI
        const button = document.getElementById('startTradingBtn');
        const statusText = document.getElementById('tradingStatusText');
        const statusLed = document.getElementById('tradingStatusLed');
        
        if (button && statusText && statusLed) {
            this.autoTradingEnabled = enabled;
            
            if (enabled) {
                button.textContent = '⏸️ TRADING STOPPEN';
                button.classList.add('active');
                statusLed.classList.add('active');
                statusText.classList.add('active');
                statusText.textContent = `🤖 AUTO-TRADING AKTIV (${strategy})`;
            } else {
                button.textContent = '▶️ TRADING STARTEN';
                button.classList.remove('active');
                statusLed.classList.remove('active');
                statusText.classList.remove('active');
                statusText.textContent = '⏸️ AUTO-TRADING GESTOPPT';
            }
        }
    }
    
    onTradeExecuted(tradeData) {
        console.log('💰 TRADE EXECUTED:', tradeData);
        
        // Add to live feed
        const liveFeed = document.getElementById('liveFeed');
        const tradesList = document.getElementById('tradesList');
        
        if (liveFeed && tradesList) {
            liveFeed.classList.add('active');
            
            const tradeItem = document.createElement('div');
            tradeItem.className = 'trade-item';
            tradeItem.innerHTML = `
                <strong style="color: ${tradeData.action === 'BUY' ? '#00ff00' : '#ff4444'}">${tradeData.action}</strong>
                ${tradeData.quantity} ${tradeData.symbol} @ $${tradeData.price}<br>
                <small>🤖 ${tradeData.reason || 'AI Signal'}</small><br>
                <small style="color: ${tradeData.pnl >= 0 ? '#00ff00' : '#ff4444'}">
                    P&L: ${tradeData.pnl >= 0 ? '+' : ''}$${tradeData.pnl.toFixed(2)}
                </small>
                <small style="color: #888; float: right;">${new Date().toLocaleTimeString()}</small>
            `;
            
            tradesList.insertBefore(tradeItem, tradesList.firstChild);
            
            // Keep only last 10 trades
            while (tradesList.children.length > 10) {
                tradesList.removeChild(tradesList.lastChild);
            }
        }
        
        // Update metrics
        this.updateTradingMetrics(tradeData);
    }
    
    onTradingError(error) {
        console.error('🚨 TRADING ERROR:', error);
        
        // Show error notification
        alert(`🚨 Trading Error:\n${error}\n\nPlease check the system and try again.`);
        
        // If critical error, stop auto-trading
        if (error.includes('CRITICAL') || error.includes('EMERGENCY')) {
            this.emergencyStopAll();
        }
    }
    
    onEmergencyStop() {
        console.log('🛑 EMERGENCY STOP TRIGGERED BY BACKEND');
        
        // Force update UI to stopped state
        this.onTradingStatusChanged(false, this.currentStrategy);
        
        alert('🛑 EMERGENCY STOP ACTIVATED!\n\nAll trading activities have been stopped by the backend system.');
    }
    
    onPortfolioUpdate(portfolio) {
        console.log('💼 Portfolio Update:', portfolio);
        
        // Update portfolio display
        const portfolioElement = document.querySelector('.header-left .metric.portfolio');
        if (portfolioElement && portfolio.total_value) {
            const pnlPercent = ((portfolio.total_value - portfolio.initial_value) / portfolio.initial_value * 100).toFixed(2);
            portfolioElement.textContent = `Portfolio: $${portfolio.total_value.toLocaleString()} (${pnlPercent >= 0 ? '+' : ''}${pnlPercent}%)`;
        }
        
        // Update metrics cards
        this.updatePortfolioMetrics(portfolio);
    }
    
    updateTradingMetrics(tradeData) {
        // Update trades count
        const tradesElement = document.getElementById('tradesCount');
        if (tradesElement) {
            const currentCount = parseInt(tradesElement.textContent) || 0;
            tradesElement.textContent = currentCount + 1;
        }
        
        // Update daily P&L
        const pnlElement = document.getElementById('dailyPnL');
        if (pnlElement && tradeData.pnl) {
            const currentPnL = parseFloat(pnlElement.textContent.replace(/[$,+]/g, '')) || 0;
            const newPnL = currentPnL + tradeData.pnl;
            pnlElement.textContent = `${newPnL >= 0 ? '+' : ''}$${newPnL.toFixed(0)}`;
            pnlElement.style.color = newPnL >= 0 ? '#00ff00' : '#ff4444';
        }
    }
    
    updatePortfolioMetrics(portfolio) {
        const portfolioValue = document.getElementById('portfolioValue');
        if (portfolioValue && portfolio.total_value) {
            portfolioValue.textContent = `$${portfolio.total_value.toLocaleString()}`;
        }
    }
    
    // Status getters
    isBackendConnected() {
        return this.isConnected;
    }
    
    isAutoTradingEnabled() {
        return this.autoTradingEnabled;
    }
    
    getCurrentStrategy() {
        return this.currentStrategy;
    }
}

// Global backend instance
let autoTradingBackend = null;

// Initialize when DOM is loaded
document.addEventListener('DOMContentLoaded', () => {
    autoTradingBackend = new AutoTradingBackend();
    console.log('🚀 Auto-Trading Backend Integration loaded');
});

// Export for use in other scripts
if (typeof module !== 'undefined' && module.exports) {
    module.exports = AutoTradingBackend;
}