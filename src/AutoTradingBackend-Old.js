// AutoTradingBackend.js - Enhanced Redis Integration for 6bot
// Supports both QML RedisClient and HTTP REST API

console.log('🔧 Loading A        // Method 3: Redis Port Detection (Qt Network Style)
        try {
            console.log('🔍 Detecting Redis on port 6380...');
            
            // Check if Redis port 6380 is accessible
            const redisPortCheck = await this.checkRedisPort();
            if (redisPortCheck) {
                this.connected = true;
                this.connectionType = 'redis-direct';
                console.log('✅ Redis detected on port 6380 - using Qt Network simulation');
                return true;
            }
        } catch (error) {
            console.log('🔌 Redis port check failed:', error.message);
        }
        
        // Method 4: Simulation mode (development fallback)
        console.log('⚠️ No backend connections available - using simulation mode');
        this.connected = true;
        this.connectionType = 'simulation';
        return true;adingBackend...');

// Enhanced backend interface with dual connection support
const AutoTradingBackend = {
    connected: false,
    connectionType: 'unknown', // 'qml', 'http', 'redis', or 'simulation'
    baseUrl: 'http://localhost:8000', // Backend REST API
    redisConfig: {
        host: 'localhost',
        port: 6380,
        password: 'pass123' // From redis.txt
    },
    
    // Enhanced QML Redis detection
    isQMLAvailable: function() {
        return (typeof redisClient !== 'undefined' && 
                redisClient !== null && 
                typeof redisClient.connectToRedis === 'function');
    },
    
    // Enhanced connection test - tries QML first, then HTTP
    testConnection: async function() {
        console.log('🔍 Testing backend connections...');
        
        // Method 1: Try QML RedisClient (hybrid mode with Qt Network)
        try {
            if (this.isQMLAvailable()) {
                console.log('🔌 QML RedisClient detected - checking connection to port 6380...');
                
                // Check current connection
                if (redisClient.connected) {
                    this.connected = true;
                    this.connectionType = 'qml';
                    console.log('✅ QML RedisClient already connected to Redis on port 6380');
                    return true;
                }
                
                // Try to establish connection
                console.log('🔄 Attempting QML Redis connection...');
                redisClient.host = this.redisConfig.host;
                redisClient.port = this.redisConfig.port;
                redisClient.password = this.redisConfig.password;
                redisClient.connectToRedis();
                
                // Wait for connection with timeout
                const connectionResult = await new Promise((resolve) => {
                    const timeout = setTimeout(() => resolve(false), 3000);
                    
                    const checkConnection = () => {
                        if (redisClient.connected) {
                            clearTimeout(timeout);
                            resolve(true);
                        }
                    };
                    
                    // Check immediately
                    checkConnection();
                    
                    // Setup connection change listener
                    if (redisClient.connectedChanged) {
                        const handler = () => {
                            checkConnection();
                            redisClient.connectedChanged.disconnect(handler);
                        };
                        redisClient.connectedChanged.connect(handler);
                    }
                    
                    // Fallback polling
                    const pollInterval = setInterval(() => {
                        checkConnection();
                        if (redisClient.connected) {
                            clearInterval(pollInterval);
                        }
                    }, 500);
                    
                    setTimeout(() => clearInterval(pollInterval), 3000);
                });
                
                if (connectionResult) {
                    this.connected = true;
                    this.connectionType = 'qml';
                    console.log('✅ QML RedisClient successfully connected to Redis on port 6380');
                    return true;
                } else {
                    console.log('⚠️ QML RedisClient connection timeout after 3 seconds');
                }
            }
        } catch (error) {
            console.log('❌ QML Redis connection failed:', error.message);
        }
        
        // Method 2: Try QML RedisClient if available but not connected yet
        try {
            if (typeof redisClient !== 'undefined' && redisClient) {
                console.log('🔌 Found QML RedisClient, checking connection...');
                
                // Try to trigger connection if not connected
                if (!redisClient.connected && typeof redisClient.connectToRedis === 'function') {
                    console.log('🔄 Attempting to connect QML RedisClient to port 6380...');
                    redisClient.connectToRedis();
                    
                    // Wait a moment for connection
                    await new Promise(resolve => setTimeout(resolve, 1000));
                }
                
                if (redisClient.connected) {
                    this.connected = true;
                    this.connectionType = 'qml';
                    console.log('✅ QML RedisClient connected to Redis on port 6380');
                    return true;
                }
            }
        } catch (error) {
            console.log('🔌 QML RedisClient connection attempt failed:', error.message);
        }
        
        // Method 3: Try HTTP REST API (for browser mode)
        try {
            console.log('🌐 Testing HTTP REST API at:', this.baseUrl);
            const response = await fetch(`${this.baseUrl}/api/health`, {
                method: 'GET',
                timeout: 3000,
                headers: {
                    'Content-Type': 'application/json'
                }
            });
            
            if (response.ok) {
                const data = await response.json();
                this.connected = data.status === 'ok';
                this.connectionType = 'http';
                console.log('✅ HTTP REST API connected:', this.connected, data);
                return this.connected;
            } else {
                console.log('❌ HTTP REST API error:', response.status, response.statusText);
            }
        } catch (error) {
            console.log('🌐 HTTP REST API not available:', error.message);
        }
        
        // Method 3: Mock/Simulation mode for development
        console.log('⚠️ No backend connections available - using simulation mode');
        this.connected = true;
        this.connectionType = 'simulation';
        return true;
    },
    
    // WebSocket connection for Redis communication
    ws: null,
    
    // Enhanced enable/disable auto-trading with multiple backend support
    enableAutoTrading: async function(enabled) {
        console.log('📡 enableAutoTrading called:', enabled, 'via', this.connectionType);
        
        const settings = {
            "enabled": enabled,
            "buy_threshold_pct": 0.05,
            "sell_threshold_pct": 0.05,
            "max_position_per_trade": 1
        };
        
        try {
            // Method 1: QML RedisClient (hybrid mode)
            if (this.connectionType === 'qml' && typeof redisClient !== 'undefined' && redisClient && redisClient.connected) {
                const command = "SET trading_settings '" + JSON.stringify(settings) + "'";
                redisClient.sendCommand(command);
                console.log('✅ QML Redis SET trading_settings sent:', command);
                return true;
            }
            
            // Method 2: QML RedisClient (force connection attempt)
            if (this.connectionType === 'qml' || (typeof redisClient !== 'undefined' && redisClient)) {
                console.log('🔄 Using QML RedisClient for trading settings...');
                
                // Ensure connection
                if (!redisClient.connected && typeof redisClient.connectToRedis === 'function') {
                    redisClient.connectToRedis();
                    await new Promise(resolve => setTimeout(resolve, 1000));
                }
                
                if (redisClient.connected) {
                    // Use the enableAutoTrading method directly
                    redisClient.enableAutoTrading(enabled);
                    console.log('✅ QML RedisClient enableAutoTrading called:', enabled);
                    return true;
                } else {
                    throw new Error('QML RedisClient nicht verbunden mit Port 6380');
                }
            }
            
            // Method 3: HTTP REST API (browser mode)
            if (this.connectionType === 'http') {
                const response = await fetch(`${this.baseUrl}/api/trading/settings`, {
                    method: 'PUT',
                    headers: {
                        'Content-Type': 'application/json'
                    },
                    body: JSON.stringify(settings)
                });
                
                if (response.ok) {
                    const result = await response.json();
                    console.log('✅ HTTP REST API trading settings updated:', result);
                    return true;
                } else {
                    throw new Error(`HTTP ${response.status}: ${response.statusText}`);
                }
            }
            
            // Method 3: Simulation mode (development)
            if (this.connectionType === 'simulation') {
                console.log('🎭 SIMULATION MODE: Auto-trading', enabled ? 'enabled' : 'disabled');
                console.log('🎭 Settings would be:', JSON.stringify(settings, null, 2));
                
                // Simulate brief delay
                await new Promise(resolve => setTimeout(resolve, 500));
                
                // Show simulation notification
                this.showSimulationNotification(enabled ? 'TRADING GESTARTET (Simulation)' : 'TRADING GESTOPPT (Simulation)');
                return true;
            }
            
            throw new Error('Keine verfügbare Backend-Verbindung');
            
        } catch (error) {
            console.error('❌ enableAutoTrading failed:', error);
            
            // Enhanced error message
            const errorMessage = this.connectionType === 'simulation' 
                ? `Simulation Fehler: ${error.message}`
                : `Backend Fehler (${this.connectionType}): ${error.message}`;
                
            alert('⚠️ Auto-Trading Fehler!\n\n' + 
                  errorMessage + '\n\n' +
                  'Verbindung: ' + this.connectionType.toUpperCase() + '\n' +
                  (this.connectionType === 'http' ? 'REST API: ' + this.baseUrl : '') +
                  '\n\nTipp: Prüfe Backend-Status in Einstellungen');
            return false;
        }
    },
    
    // Show simulation mode notifications
    showSimulationNotification: function(message) {
        // Create toast notification
        const toast = document.createElement('div');
        toast.style.cssText = `
            position: fixed;
            top: 80px;
            right: 20px;
            background: linear-gradient(45deg, #ffaa00, #ff8800);
            color: #000000;
            padding: 15px 20px;
            border-radius: 8px;
            font-weight: bold;
            font-size: 14px;
            z-index: 1000;
            box-shadow: 0 4px 12px rgba(255, 170, 0, 0.3);
            animation: slideIn 0.3s ease-out;
        `;
        toast.textContent = '🎭 ' + message;
        
        // Add slide-in animation
        const style = document.createElement('style');
        style.textContent = `
            @keyframes slideIn {
                from { transform: translateX(100%); opacity: 0; }
                to { transform: translateX(0); opacity: 1; }
            }
        `;
        document.head.appendChild(style);
        
        document.body.appendChild(toast);
        
        // Remove after 3 seconds
        setTimeout(() => {
            toast.style.animation = 'slideIn 0.3s ease-out reverse';
            setTimeout(() => toast.remove(), 300);
        }, 3000);
    },
    
    // WebSocket Redis communication methods
    connectWebSocket: async function() {
        return new Promise((resolve, reject) => {
            try {
                this.ws = new WebSocket('ws://localhost:6381/redis');
                
                this.ws.onopen = () => {
                    console.log('✅ WebSocket connected to Redis proxy');
                    resolve(true);
                };
                
                this.ws.onmessage = (event) => {
                    const data = JSON.parse(event.data);
                    console.log('📨 WebSocket message:', data);
                    
                    // Handle responses
                    if (this.wsPromises && this.wsPromises[data.type]) {
                        this.wsPromises[data.type](data);
                    }
                };
                
                this.ws.onerror = (error) => {
                    console.error('❌ WebSocket error:', error);
                    reject(error);
                };
                
                this.ws.onclose = () => {
                    console.log('🔌 WebSocket disconnected');
                    this.ws = null;
                };
                
            } catch (error) {
                reject(error);
            }
        });
    },
    
    wsPromises: {},
    
    sendRedisCommand: async function(action, data = {}) {
        if (!this.ws || this.ws.readyState !== WebSocket.OPEN) {
            await this.connectWebSocket();
        }
        
        return new Promise((resolve, reject) => {
            const message = {
                action: action,
                ...data,
                timestamp: Date.now()
            };
            
            // Set up response handler
            const timeout = setTimeout(() => {
                reject(new Error('WebSocket command timeout'));
            }, 5000);
            
            this.wsPromises['success'] = (response) => {
                clearTimeout(timeout);
                console.log('✅ Redis command successful:', response);
                resolve(true);
            };
            
            this.wsPromises['error'] = (response) => {
                clearTimeout(timeout);
                console.error('❌ Redis command failed:', response);
                reject(new Error(response.message || 'Redis command failed'));
            };
            
            // Send command
            this.ws.send(JSON.stringify(message));
            console.log('📤 Sent Redis command:', message);
        });
    },
    
    // Enhanced emergency stop with multiple backend support
    emergencyStop: async function() {
        console.log('🛑 EMERGENCY STOP TRIGGERED via', this.connectionType);
        
        const success = await this.enableAutoTrading(false);
        
        if (success) {
            const message = this.connectionType === 'simulation' 
                ? '🛑 NOTFALL-STOPP AKTIVIERT! (Simulation)\n\nAlle simulierten Trading-Aktivitäten wurden gestoppt.'
                : '🛑 NOTFALL-STOPP AKTIVIERT!\n\nAlle Auto-Trading Aktivitäten wurden sofort gestoppt.\nSystem ist sicher.';
            alert(message);
        } else {
            alert('⚠️ NOTFALL-STOPP FEHLGESCHLAGEN!\n\n' +
                  `Backend-Typ: ${this.connectionType.toUpperCase()}\n` +
                  'Konnte keine Verbindung zum Backend herstellen.\n\n' +
                  'Bitte manuell prüfen:\n' +
                  '1. Backend-Server Status\n' +
                  '2. Trading Einstellungen\n' +
                  '3. Netzwerkverbindung');
        }
        
        return success;
    }
};

// Enhanced toggle function with async backend support
async function toggleAutoTradingReal() {
    console.log('🔄 toggleAutoTradingReal called');
    
    const button = document.getElementById('startTradingBtn');
    const statusLed = document.getElementById('tradingStatusLed');
    const statusText = document.getElementById('tradingStatusText');
    
    if (!button) {
        console.error('❌ UI elements not found');
        return;
    }
    
    // Show loading state
    const originalText = button.textContent;
    button.textContent = '⏳ Verbinde...';
    button.disabled = true;
    
    try {
        // Test connection first
        const connected = await AutoTradingBackend.testConnection();
        if (!connected) {
            alert('❌ Backend nicht verbunden!\n\n' +
                  'Bitte prüfe:\n' +
                  '1. Backend Server läuft\n' +
                  '2. Netzwerkverbindung\n' +
                  '3. API Endpunkte verfügbar\n\n' +
                  'Tipp: Im Simulation-Modus funktioniert das System trotzdem!');
            return;
        }
        
        // Get current state from UI
        const isCurrentlyActive = button.classList.contains('active');
        const newState = !isCurrentlyActive;
        
        console.log('🔄 Toggling auto-trading:', isCurrentlyActive, '→', newState, 'via', AutoTradingBackend.connectionType);
        
        // Send command to backend
        const success = await AutoTradingBackend.enableAutoTrading(newState);
        
        if (success) {
            // Update UI to match new state
            if (newState) {
                // ENABLE AUTO-TRADING
                button.textContent = '⏸️ TRADING STOPPEN';
                button.classList.add('active');
                if (statusLed) statusLed.classList.add('active');
                if (statusText) {
                    statusText.classList.add('active');
                    const modePrefix = AutoTradingBackend.connectionType === 'simulation' ? '🎭 ' : '🤖 ';
                    statusText.textContent = modePrefix + 'AUTO-TRADING AKTIV';
                }
                
                console.log('🚀 AUTO-TRADING ENABLED via', AutoTradingBackend.connectionType);
                
                // Update header
                const headerSpan = document.querySelector('.status-indicator span');
                if (headerSpan) {
                    headerSpan.textContent = AutoTradingBackend.connectionType === 'simulation' 
                        ? 'AUTO-TRADING AKTIV (SIM)' 
                        : 'AUTO-TRADING AKTIV';
                    headerSpan.style.color = '#ffaa00';
                }
                
            } else {
                // DISABLE AUTO-TRADING  
                button.textContent = '▶️ TRADING STARTEN';
                button.classList.remove('active');
                if (statusLed) statusLed.classList.remove('active');
                if (statusText) {
                    statusText.classList.remove('active');
                    statusText.textContent = '⏸️ AUTO-TRADING GESTOPPT';
                }
                
                console.log('⏸️ AUTO-TRADING DISABLED via', AutoTradingBackend.connectionType);
                
                // Restore header
                const headerSpan = document.querySelector('.status-indicator span');
                if (headerSpan) {
                    headerSpan.textContent = 'System ONLINE';
                    headerSpan.style.color = '#00ff00';
                }
            }
            
            console.log('✅ UI updated successfully');
        } else {
            console.error('❌ Backend operation failed');
        }
        
    } finally {
        // Restore button state
        button.disabled = false;
        if (button.textContent === '⏳ Verbinde...') {
            button.textContent = originalText;
        }
    }
}

// Enhanced emergency stop with async backend support
async function emergencyStopReal() {
    console.log('🛑 emergencyStopReal called');
    
    // Show loading state
    const button = document.getElementById('startTradingBtn');
    if (button) {
        button.textContent = '🛑 STOPPE...';
        button.disabled = true;
    }
    
    try {
        const success = await AutoTradingBackend.emergencyStop();
        
        if (success) {
            // Force UI to stopped state
            const statusLed = document.getElementById('tradingStatusLed');
            const statusText = document.getElementById('tradingStatusText');
            
            if (button) {
                button.textContent = '▶️ TRADING STARTEN';
                button.classList.remove('active');
            }
            if (statusLed) statusLed.classList.remove('active');
            if (statusText) {
                statusText.classList.remove('active');
                statusText.textContent = '⏸️ AUTO-TRADING GESTOPPT';
            }
            
            // Restore header
            const headerSpan = document.querySelector('.status-indicator span');
            if (headerSpan) {
                headerSpan.textContent = 'System ONLINE';
                headerSpan.style.color = '#00ff00';
            }
            
            console.log('🛑 Emergency stop completed via', AutoTradingBackend.connectionType);
        }
    } finally {
        // Restore button state
        if (button) {
            button.disabled = false;
            if (button.textContent === '🛑 STOPPE...') {
                button.textContent = '▶️ TRADING STARTEN';
            }
        }
    }
}

// Setup QML signal handlers if available
function setupQMLSignals() {
    if (typeof redisClient !== 'undefined' && redisClient) {
        console.log('🔗 Setting up QML signal handlers');
        
        // Handle connection changes
        if (redisClient.connectedChanged) {
            redisClient.connectedChanged.connect(function() {
                const connected = redisClient.connected;
                console.log('📡 QML Signal - Redis connection changed:', connected);
                
                AutoTradingBackend.connected = connected;
                
                if (!connected) {
                    // Show disconnection warning
                    const headerSpan = document.querySelector('.status-indicator span');
                    if (headerSpan) {
                        headerSpan.textContent = 'REDIS GETRENNT';
                        headerSpan.style.color = '#ff4444';
                    }
                }
            });
        }
        
        // Handle data received (for getting trading status)
        if (redisClient.dataReceived) {
            redisClient.dataReceived.connect(function(key, data) {
                console.log('📡 QML Signal - dataReceived:', key, data);
                
                if (key === 'trading_settings') {
                    // Update UI based on trading settings
                    const enabled = data && data.enabled;
                    console.log('📊 Trading enabled from Redis:', enabled);
                    
                    // You could update UI here based on Redis data
                }
            });
        }
        
        console.log('✅ QML signal handlers set up');
    } else {
        console.log('⚠️ QML redisClient not available for signals');
    }
}

// Enhanced initialization with async connection testing
document.addEventListener('DOMContentLoaded', async function() {
    console.log('🚀 AutoTradingBackend initializing...');
    
    try {
        // Test initial connection with timeout
        const connected = await Promise.race([
            AutoTradingBackend.testConnection(),
            new Promise(resolve => setTimeout(() => resolve(false), 5000)) // 5s timeout
        ]);
        
        console.log('📡 Initial connection status:', connected, 'via', AutoTradingBackend.connectionType);
        
        if (connected) {
            console.log('✅ Backend ready for auto-trading via', AutoTradingBackend.connectionType.toUpperCase());
            
            // Add connection status indicator to header
            const header = document.querySelector('.header');
            if (header) {
                const indicator = document.createElement('div');
                indicator.style.cssText = `
                    background: ${AutoTradingBackend.connectionType === 'simulation' ? '#ffaa00' : '#00ff00'};
                    color: #000000;
                    padding: 4px 8px;
                    border-radius: 4px;
                    font-size: 11px;
                    font-weight: bold;
                    margin-left: 10px;
                `;
                indicator.textContent = AutoTradingBackend.connectionType.toUpperCase() + ' MODE';
                indicator.title = `Backend connection: ${AutoTradingBackend.connectionType}`;
                header.appendChild(indicator);
            }
            
            setupQMLSignals();
        } else {
            console.log('⚠️ No backend connections available - using fallback mode');
            
            // Show warning indicator
            const header = document.querySelector('.header');
            if (header) {
                const warning = document.createElement('div');
                warning.style.cssText = `
                    background: #ff4444;
                    color: #ffffff;
                    padding: 4px 8px;
                    border-radius: 4px;
                    font-size: 11px;
                    font-weight: bold;
                    margin-left: 10px;
                `;
                warning.textContent = 'OFFLINE MODE';
                warning.title = 'No backend connection available';
                header.appendChild(warning);
            }
        }
        
    } catch (error) {
        console.error('❌ Backend initialization failed:', error);
    }
});

console.log('✅ AutoTradingBackend loaded successfully');