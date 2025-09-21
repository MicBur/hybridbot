#!/usr/bin/env python3
"""
6bot Auto-Trading Backend Simulator
Simulates the C++ backend for testing the frontend integration
"""

import asyncio
import websockets
import json
import time
import random
from datetime import datetime
from http.server import HTTPServer, BaseHTTPRequestHandler
import threading
import urllib.parse

class AutoTradingSimulator:
    def __init__(self):
        self.auto_trading_enabled = False
        self.current_strategy = 'CONSERVATIVE'
        self.connected_clients = set()
        self.portfolio_value = 109329.0
        self.daily_pnl = 0.0
        self.trades_today = 0
        
        # Trading strategies configuration
        self.strategies = {
            'CONSERVATIVE': {'max_position': 3, 'confidence_threshold': 85, 'risk_factor': 0.5},
            'BALANCED': {'max_position': 5, 'confidence_threshold': 75, 'risk_factor': 1.0},
            'AGGRESSIVE': {'max_position': 10, 'confidence_threshold': 65, 'risk_factor': 2.0}
        }
        
        # Sample stocks for trading
        self.stocks = [
            {'symbol': 'NVDA', 'price': 489.23, 'volatility': 0.05},
            {'symbol': 'AAPL', 'price': 174.56, 'volatility': 0.03},
            {'symbol': 'MSFT', 'price': 329.87, 'volatility': 0.04},
            {'symbol': 'GOOGL', 'price': 132.45, 'volatility': 0.04},
            {'symbol': 'TSLA', 'price': 267.89, 'volatility': 0.08},
            {'symbol': 'META', 'price': 312.34, 'volatility': 0.06},
            {'symbol': 'AMZN', 'price': 134.67, 'volatility': 0.05},
            {'symbol': 'NFLX', 'price': 445.23, 'volatility': 0.07}
        ]
        
        print("🤖 6bot Auto-Trading Backend Simulator initialized")
    
    async def handle_websocket(self, websocket, path):
        """Handle WebSocket connections from frontend"""
        print(f"🔌 New WebSocket client connected: {websocket.remote_address}")
        self.connected_clients.add(websocket)
        
        # Send initial status
        await self.send_status_update(websocket)
        
        try:
            async for message in websocket:
                data = json.loads(message)
                await self.handle_command(data, websocket)
        except websockets.exceptions.ConnectionClosed:
            print(f"❌ WebSocket client disconnected: {websocket.remote_address}")
        finally:
            self.connected_clients.discard(websocket)
    
    async def handle_command(self, command, client_websocket):
        """Process commands from frontend"""
        action = command.get('action')
        print(f"📨 Received command: {action}")
        
        if action == 'enable_auto_trading':
            enabled = command.get('enabled', False)
            strategy = command.get('strategy', 'CONSERVATIVE')
            await self.set_auto_trading(enabled, strategy)
            
        elif action == 'set_trading_strategy':
            strategy = command.get('strategy', 'CONSERVATIVE')
            await self.set_strategy(strategy)
            
        elif action == 'emergency_stop_all':
            await self.emergency_stop()
            
        elif action == 'set_risk_limits':
            max_position = command.get('max_position_size', 5.0)
            stop_loss = command.get('stop_loss_percent', 5.0)
            await self.set_risk_limits(max_position, stop_loss)
            
        else:
            print(f"⚠️ Unknown command: {action}")
    
    async def set_auto_trading(self, enabled, strategy=None):
        """Enable/disable auto-trading"""
        self.auto_trading_enabled = enabled
        if strategy:
            self.current_strategy = strategy
            
        print(f"🔄 Auto-trading {'ENABLED' if enabled else 'DISABLED'} | Strategy: {self.current_strategy}")
        
        # Broadcast status to all clients
        await self.broadcast_status()
        
        # Start/stop trading simulation
        if enabled:
            asyncio.create_task(self.trading_loop())
        
    async def set_strategy(self, strategy):
        """Change trading strategy"""
        if strategy in self.strategies:
            self.current_strategy = strategy
            print(f"📈 Strategy changed to: {strategy}")
            await self.broadcast_status()
        else:
            print(f"❌ Invalid strategy: {strategy}")
    
    async def emergency_stop(self):
        """Emergency stop all trading"""
        self.auto_trading_enabled = False
        print("🛑 EMERGENCY STOP ACTIVATED")
        
        message = {
            'type': 'emergency_stop',
            'timestamp': datetime.now().isoformat(),
            'message': 'All trading activities stopped immediately'
        }
        
        await self.broadcast_message(message)
        await self.broadcast_status()
    
    async def set_risk_limits(self, max_position, stop_loss):
        """Set risk management limits"""
        print(f"⚠️ Risk limits updated: Max Position: {max_position}%, Stop Loss: {stop_loss}%")
        
        message = {
            'type': 'risk_limits_updated',
            'max_position_size': max_position,
            'stop_loss_percent': stop_loss,
            'timestamp': datetime.now().isoformat()
        }
        
        await self.broadcast_message(message)
    
    async def trading_loop(self):
        """Main trading simulation loop"""
        print("🚀 Trading loop started")
        
        while self.auto_trading_enabled:
            try:
                # Wait random interval (3-10 seconds)
                await asyncio.sleep(random.uniform(3, 10))
                
                if not self.auto_trading_enabled:
                    break
                
                # Generate AI signal
                confidence = random.uniform(60, 95)
                strategy = self.strategies[self.current_strategy]
                
                if confidence >= strategy['confidence_threshold']:
                    await self.execute_simulated_trade(confidence)
                    
            except Exception as e:
                print(f"🚨 Trading loop error: {e}")
                await asyncio.sleep(5)
        
        print("⏸️ Trading loop stopped")
    
    async def execute_simulated_trade(self, confidence):
        """Execute a simulated trade"""
        # Select random stock
        stock = random.choice(self.stocks)
        symbol = stock['symbol']
        base_price = stock['price']
        
        # Random price movement
        price_change = random.uniform(-0.02, 0.02)
        current_price = base_price * (1 + price_change)
        
        # Determine trade action
        action = random.choice(['BUY', 'SELL'])
        
        # Calculate quantity based on strategy
        strategy = self.strategies[self.current_strategy]
        max_quantity = strategy['max_position']
        quantity = random.randint(1, max_quantity)
        
        # Simulate P&L
        pnl = random.uniform(-50, 150) * strategy['risk_factor']
        self.daily_pnl += pnl
        self.portfolio_value += pnl
        self.trades_today += 1
        
        # Generate AI reasons
        reasons = [
            f'Grok AI Signal ({confidence:.1f}% confidence)',
            'LSTM Model Prediction',
            'Momentum Breakout Detected',
            'Support Level Bounce',
            'Volume Spike Analysis',
            'Technical Pattern Match'
        ]
        
        trade_data = {
            'type': 'trade_executed',
            'symbol': symbol,
            'action': action,
            'quantity': quantity,
            'price': round(current_price, 2),
            'pnl': round(pnl, 2),
            'confidence': round(confidence, 1),
            'reason': random.choice(reasons),
            'strategy': self.current_strategy,
            'timestamp': datetime.now().isoformat()
        }
        
        print(f"💰 TRADE: {action} {quantity} {symbol} @ ${current_price:.2} | P&L: ${pnl:.2f}")
        
        # Broadcast trade to all clients
        await self.broadcast_message(trade_data)
        
        # Send portfolio update
        portfolio_data = {
            'type': 'portfolio_update',
            'portfolio': {
                'total_value': round(self.portfolio_value, 2),
                'daily_pnl': round(self.daily_pnl, 2),
                'trades_today': self.trades_today,
                'initial_value': 109329.0
            },
            'timestamp': datetime.now().isoformat()
        }
        
        await self.broadcast_message(portfolio_data)
    
    async def broadcast_status(self):
        """Broadcast current status to all clients"""
        status_data = {
            'type': 'trading_status',
            'enabled': self.auto_trading_enabled,
            'strategy': self.current_strategy,
            'timestamp': datetime.now().isoformat()
        }
        
        await self.broadcast_message(status_data)
    
    async def send_status_update(self, websocket):
        """Send status update to specific client"""
        status_data = {
            'type': 'trading_status',
            'enabled': self.auto_trading_enabled,
            'strategy': self.current_strategy,
            'timestamp': datetime.now().isoformat()
        }
        
        try:
            await websocket.send(json.dumps(status_data))
        except websockets.exceptions.ConnectionClosed:
            pass
    
    async def broadcast_message(self, message):
        """Broadcast message to all connected clients"""
        if not self.connected_clients:
            return
            
        disconnected = set()
        
        for client in self.connected_clients:
            try:
                await client.send(json.dumps(message))
            except websockets.exceptions.ConnectionClosed:
                disconnected.add(client)
        
        # Remove disconnected clients
        self.connected_clients -= disconnected


class HTTPRequestHandler(BaseHTTPRequestHandler):
    """HTTP API handler for backend communication"""
    
    def __init__(self, simulator, *args, **kwargs):
        self.simulator = simulator
        super().__init__(*args, **kwargs)
    
    def do_GET(self):
        """Handle GET requests"""
        if self.path == '/api/trading-status':
            self.send_json_response({
                'type': 'trading_status',
                'enabled': self.simulator.auto_trading_enabled,
                'strategy': self.simulator.current_strategy,
                'portfolio_value': self.simulator.portfolio_value,
                'daily_pnl': self.simulator.daily_pnl,
                'trades_today': self.simulator.trades_today,
                'timestamp': datetime.now().isoformat()
            })
        else:
            self.send_error(404, "Not Found")
    
    def do_POST(self):
        """Handle POST requests"""
        if self.path == '/api/command':
            try:
                content_length = int(self.headers['Content-Length'])
                body = self.rfile.read(content_length)
                command = json.loads(body.decode('utf-8'))
                
                # Process command synchronously
                asyncio.create_task(self.simulator.handle_command(command, None))
                
                self.send_json_response({
                    'success': True,
                    'message': f"Command {command.get('action')} processed",
                    'timestamp': datetime.now().isoformat()
                })
                
            except Exception as e:
                self.send_json_response({
                    'success': False,
                    'error': str(e),
                    'timestamp': datetime.now().isoformat()
                }, status=400)
        else:
            self.send_error(404, "Not Found")
    
    def send_json_response(self, data, status=200):
        """Send JSON response"""
        response = json.dumps(data).encode('utf-8')
        
        self.send_response(status)
        self.send_header('Content-Type', 'application/json')
        self.send_header('Content-Length', str(len(response)))
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type')
        self.end_headers()
        
        self.wfile.write(response)
    
    def do_OPTIONS(self):
        """Handle CORS preflight"""
        self.send_response(200)
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type')
        self.end_headers()
    
    def log_message(self, format, *args):
        """Override to reduce HTTP logging noise"""
        pass


def start_http_server(simulator):
    """Start HTTP API server"""
    def handler(*args, **kwargs):
        return HTTPRequestHandler(simulator, *args, **kwargs)
    
    server = HTTPServer(('localhost', 8080), handler)
    print("🌐 HTTP API server started on http://localhost:8080")
    server.serve_forever()


async def main():
    """Main entry point"""
    simulator = AutoTradingSimulator()
    
    # Start HTTP server in background thread
    http_thread = threading.Thread(target=start_http_server, args=(simulator,))
    http_thread.daemon = True
    http_thread.start()
    
    # Start WebSocket server
    print("🔌 Starting WebSocket server on ws://localhost:8081")
    await websockets.serve(simulator.handle_websocket, 'localhost', 8081)
    
    print("✅ 6bot Auto-Trading Backend Simulator is running")
    print("📡 WebSocket: ws://localhost:8081/autotrading")
    print("🌐 HTTP API: http://localhost:8080/api")
    print("🛑 Press Ctrl+C to stop")
    
    # Keep running
    try:
        await asyncio.Future()  # Run forever
    except KeyboardInterrupt:
        print("\n🛑 Backend simulator stopped")


if __name__ == '__main__':
    asyncio.run(main())