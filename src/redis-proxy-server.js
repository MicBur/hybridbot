#!/usr/bin/env node
// Redis WebSocket Proxy Server for 6bot
// Allows browser JavaScript to communicate with Redis via WebSocket

const WebSocket = require('ws');
const redis = require('redis');

console.log('🚀 Starting Redis WebSocket Proxy Server...');

// Redis configuration from redis.txt
const REDIS_CONFIG = {
    host: 'localhost',
    port: 6380,
    password: 'pass123'
};

const WS_PORT = 6381;

// Create Redis client
const redisClient = redis.createClient({
    host: REDIS_CONFIG.host,
    port: REDIS_CONFIG.port,
    password: REDIS_CONFIG.password
});

// Create WebSocket server
const wss = new WebSocket.Server({ 
    port: WS_PORT,
    path: '/redis'
});

console.log(`📡 WebSocket server listening on ws://localhost:${WS_PORT}/redis`);

// Connect to Redis
redisClient.on('connect', () => {
    console.log('✅ Connected to Redis on port', REDIS_CONFIG.port);
});

redisClient.on('error', (error) => {
    console.error('❌ Redis connection error:', error.message);
});

// Handle WebSocket connections
wss.on('connection', (ws) => {
    console.log('🔌 New WebSocket client connected');
    
    // Send connection confirmation
    ws.send(JSON.stringify({
        type: 'connection',
        status: 'connected',
        redis: redisClient.connected
    }));
    
    // Handle messages from browser
    ws.on('message', async (message) => {
        try {
            const data = JSON.parse(message.toString());
            console.log('📨 Received:', data);
            
            switch (data.action) {
                case 'ping':
                    ws.send(JSON.stringify({
                        type: 'pong',
                        timestamp: Date.now(),
                        redis_connected: redisClient.connected
                    }));
                    break;
                    
                case 'set_trading_settings':
                    const settings = data.settings;
                    await redisClient.set('trading_settings', JSON.stringify(settings));
                    console.log('✅ Trading settings updated:', settings);
                    
                    ws.send(JSON.stringify({
                        type: 'success',
                        action: 'set_trading_settings',
                        settings: settings
                    }));
                    break;
                    
                case 'get_trading_settings':
                    const currentSettings = await redisClient.get('trading_settings');
                    ws.send(JSON.stringify({
                        type: 'data',
                        key: 'trading_settings',
                        value: currentSettings ? JSON.parse(currentSettings) : null
                    }));
                    break;
                    
                case 'get_system_status':
                    const systemStatus = await redisClient.get('system_status');
                    ws.send(JSON.stringify({
                        type: 'data',
                        key: 'system_status',
                        value: systemStatus ? JSON.parse(systemStatus) : {
                            redis_connected: redisClient.connected,
                            proxy_connected: true,
                            last_heartbeat: new Date().toISOString()
                        }
                    }));
                    break;
                    
                default:
                    ws.send(JSON.stringify({
                        type: 'error',
                        message: 'Unknown action: ' + data.action
                    }));
            }
            
        } catch (error) {
            console.error('❌ Message processing error:', error);
            ws.send(JSON.stringify({
                type: 'error',
                message: error.message
            }));
        }
    });
    
    ws.on('close', () => {
        console.log('🔌 WebSocket client disconnected');
    });
    
    ws.on('error', (error) => {
        console.error('❌ WebSocket error:', error);
    });
});

// Graceful shutdown
process.on('SIGINT', () => {
    console.log('\n🛑 Shutting down Redis WebSocket Proxy...');
    redisClient.quit();
    wss.close();
    process.exit(0);
});

console.log('✅ Redis WebSocket Proxy Server ready!');
console.log('📋 Usage:');
console.log('  - WebSocket URL: ws://localhost:6381/redis');
console.log('  - Redis Server: localhost:6380');
console.log('  - Password: pass123');