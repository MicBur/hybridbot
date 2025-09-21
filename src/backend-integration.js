// 6bot Auto-Trading Backend Integration
// Uses Redis endpoints from redis.txt

class AutoTradingBackend {
    constructor() {
        this.baseUrl = ''; // Same origin for API calls
        this.connected = false;
        this.checkConnection();
    }
    
    async checkConnection() {
        try {
            // Test Redis connection via system_status
            const response = await fetch('/api/redis/get/system_status');
            if (response.ok) {
                const status = await response.json();
                this.connected = status.redis_connected || false;
                console.log('🔌 Backend Connection:', this.connected ? 'CONNECTED' : 'DISCONNECTED');
                return this.connected;
            }
        } catch (error) {
            console.log('⚠️ Backend connection test failed:', error);
            this.connected = false;
        }
        return false;
    }
    
    // Auto-Trading Control using redis.txt endpoints
    async enableTrading(enabled) {
        const settings = {
            "enabled": enabled,
            "buy_threshold_pct": 0.05,
            "sell_threshold_pct": 0.05,
            "max_position_per_trade": 1
        };
        
        try {
            const response = await fetch('/api/redis/set', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    key: 'trading_settings',
                    value: JSON.stringify(settings)
                })
            });
            
            if (response.ok) {
                console.log('✅ Trading enabled:', enabled);
                return true;
            } else {
                throw new Error('HTTP ' + response.status);
            }
        } catch (error) {
            console.error('❌ Failed to set trading enabled:', error);
            alert('Backend not connected! Check Redis server.\nError: ' + error.message);
            return false;
        }
    }
    
    async getTradingStatus() {
        try {
            const response = await fetch('/api/redis/get/trading_settings');
            if (response.ok) {
                const settings = await response.json();
                return settings ? settings.enabled : false;
            }
        } catch (error) {
            console.log('⚠️ Could not get trading status:', error);
        }
        return false;
    }
    
    async getTradingStatusDetails() {
        try {
            const response = await fetch('/api/redis/get/trading_status');
            if (response.ok) {
                return await response.json();
            }
        } catch (error) {
            console.log('⚠️ Could not get trading status details:', error);
        }
        return null;
    }
    
    async getTradeLog() {
        try {
            const response = await fetch('/api/redis/get/trades_log');
            if (response.ok) {
                return await response.json();
            }
        } catch (error) {
            console.log('⚠️ Could not get trade log:', error);
        }
        return [];
    }
    
    async setRiskSettings(settings) {
        try {
            const response = await fetch('/api/redis/set', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    key: 'risk_settings',
                    value: JSON.stringify(settings)
                })
            });
            
            if (response.ok) {
                console.log('✅ Risk settings updated');
                return true;
            }
        } catch (error) {
            console.error('❌ Failed to set risk settings:', error);
        }
        return false;
    }
    
    async emergencyStop() {
        console.log('🛑 EMERGENCY STOP TRIGGERED');
        
        // Disable trading immediately
        const success = await this.enableTrading(false);
        
        if (success) {
            alert('🛑 EMERGENCY STOP ACTIVATED!\n\nAll auto-trading has been disabled.\nSystem is safe.');
        } else {
            alert('⚠️ EMERGENCY STOP FAILED!\n\nCould not connect to backend.\nManually check Redis server!');
        }
        
        return success;
    }
}

// Global backend instance
const backend = new AutoTradingBackend();

// Enhanced functions that use real backend
async function toggleAutoTradingReal() {
    const button = document.getElementById('startTradingBtn');
    const statusLed = document.getElementById('tradingStatusLed');
    const statusText = document.getElementById('tradingStatusText');
    
    // Check connection first
    const connected = await backend.checkConnection();
    if (!connected) {
        alert('❌ Backend not connected!\n\nCheck that:\n1. Redis server is running\n2. Backend API is available\n3. Network connection is working');
        return;
    }
    
    const currentStatus = await backend.getTradingStatus();
    const newStatus = !currentStatus;
    
    console.log('🔄 Toggling auto-trading:', currentStatus, '→', newStatus);
    
    const success = await backend.enableTrading(newStatus);
    
    if (success) {
        // Update UI based on new status
        if (newStatus) {
            button.textContent = '⏸️ TRADING STOPPEN';
            button.classList.add('active');
            statusLed.classList.add('active');
            statusText.classList.add('active');
            statusText.textContent = '🤖 AUTO-TRADING AKTIV';
            
            console.log('🚀 AUTO-TRADING STARTED');
            
            // Update header
            document.querySelector('.status-indicator span').textContent = 'AUTO-TRADING AKTIV';
            document.querySelector('.status-indicator span').style.color = '#ffaa00';
            
        } else {
            button.textContent = '▶️ TRADING STARTEN';
            button.classList.remove('active');
            statusLed.classList.remove('active');
            statusText.classList.remove('active');
            statusText.textContent = '⏸️ AUTO-TRADING GESTOPPT';
            
            console.log('⏸️ AUTO-TRADING STOPPED');
            
            // Restore header
            document.querySelector('.status-indicator span').textContent = 'System ONLINE';
            document.querySelector('.status-indicator span').style.color = '#00ff00';
        }
        
        // Start monitoring if enabled
        if (newStatus) {
            startTradingMonitor();
        } else {
            stopTradingMonitor();
        }
    }
}

// Monitor live trading activity
let tradingMonitorInterval;

function startTradingMonitor() {
    tradingMonitorInterval = setInterval(async () => {
        try {
            const trades = await backend.getTradeLog();
            const status = await backend.getTradingStatusDetails();
            
            if (trades && trades.length > 0) {
                console.log('📊 Latest trades:', trades.slice(-3));
                
                // Update portfolio in header if we have trade data
                const latestTrade = trades[trades.length - 1];
                if (latestTrade) {
                    console.log('🔄 Latest trade:', latestTrade);
                }
            }
            
            if (status) {
                console.log('📈 Trading status:', status);
            }
            
        } catch (error) {
            console.log('⚠️ Trading monitor error:', error);
        }
    }, 10000); // Every 10 seconds
}

function stopTradingMonitor() {
    if (tradingMonitorInterval) {
        clearInterval(tradingMonitorInterval);
        tradingMonitorInterval = null;
    }
}

async function emergencyStopReal() {
    await backend.emergencyStop();
    
    // Update UI to stopped state
    const button = document.getElementById('startTradingBtn');
    const statusLed = document.getElementById('tradingStatusLed');
    const statusText = document.getElementById('tradingStatusText');
    
    button.textContent = '▶️ TRADING STARTEN';
    button.classList.remove('active');
    statusLed.classList.remove('active');
    statusText.classList.remove('active');
    statusText.textContent = '⏸️ AUTO-TRADING GESTOPPT';
    
    stopTradingMonitor();
}

// Initialize on page load
document.addEventListener('DOMContentLoaded', async () => {
    console.log('🚀 Auto-Trading Backend Integration loaded');
    
    // Check initial status
    const connected = await backend.checkConnection();
    console.log('📡 Initial connection check:', connected);
    
    if (connected) {
        const tradingEnabled = await backend.getTradingStatus();
        console.log('📊 Initial trading status:', tradingEnabled);
        
        // Update UI to match backend state
        if (tradingEnabled) {
            const button = document.getElementById('startTradingBtn');
            const statusLed = document.getElementById('tradingStatusLed');
            const statusText = document.getElementById('tradingStatusText');
            
            if (button) {
                button.textContent = '⏸️ TRADING STOPPEN';
                button.classList.add('active');
            }
            if (statusLed) statusLed.classList.add('active');
            if (statusText) {
                statusText.classList.add('active');
                statusText.textContent = '🤖 AUTO-TRADING AKTIV';
            }
            
            startTradingMonitor();
        }
    }
});