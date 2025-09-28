#!/usr/bin/env python3
"""
🚀 REALTIME TRADING ENGINE 
Ultra-fast, event-driven trading system with WebSocket streams
"""
import asyncio
import json
import redis.asyncio as redis
import websockets
import aiohttp
from datetime import datetime, timedelta
import numpy as np
from typing import Dict, List, Any, Optional
import logging
from dataclasses import dataclass, asdict
from collections import defaultdict
import uvloop  # Faster event loop

# Use uvloop for 2-4x faster async performance
asyncio.set_event_loop_policy(uvloop.EventLoopPolicy())

logging.basicConfig(
    level=logging.INFO,
    format='[%(asctime)s] %(levelname)s [%(name)s] %(message)s',
    datefmt='%Y-%m-%d %H:%M:%S'
)
logger = logging.getLogger('RealTimeEngine')

@dataclass
class MarketTick:
    symbol: str
    price: float
    volume: int
    bid: float
    ask: float
    timestamp: str
    source: str
    
@dataclass
class TradingSignal:
    symbol: str
    action: str  # BUY, SELL, HOLD
    strength: float  # 0-1
    confidence: float  # 0-1
    strategy: str
    reason: str
    target_price: Optional[float] = None
    stop_loss: Optional[float] = None
    timestamp: str = ""
    
    def __post_init__(self):
        if not self.timestamp:
            self.timestamp = datetime.utcnow().isoformat()

class RealTimeEngine:
    def __init__(self, redis_url: str = 'redis://:pass123@localhost:6379/0'):
        self.redis_url = redis_url
        self.redis_client: Optional[redis.Redis] = None
        self.pubsub: Optional[redis.client.PubSub] = None
        self.websocket_clients: Dict[str, websockets.WebSocketServerProtocol] = {}
        self.market_data: Dict[str, MarketTick] = {}
        self.active_streams: Dict[str, asyncio.Task] = {}
        self.signal_processors: List[Any] = []
        self.performance_metrics = defaultdict(lambda: {
            'ticks_processed': 0,
            'signals_generated': 0,
            'latency_ms': [],
            'errors': 0
        })
        
    async def initialize(self):
        """Initialize all connections and systems"""
        logger.info("🚀 Initializing RealTime Trading Engine...")
        
        # Redis connection with connection pool
        pool = redis.ConnectionPool.from_url(self.redis_url, max_connections=50)
        self.redis_client = redis.Redis(connection_pool=pool)
        self.pubsub = self.redis_client.pubsub()
        
        # Subscribe to important channels
        await self.pubsub.subscribe(
            'market:ticks',
            'trading:signals', 
            'system:alerts',
            'ml:predictions',
            'grok:insights'
        )
        
        logger.info("✅ Engine initialized successfully")
        
    async def start_market_streams(self):
        """Start real-time market data streams"""
        streams = {
            'alpaca': self._stream_alpaca_data,
            'finnhub': self._stream_finnhub_data,
            'binance': self._stream_crypto_data,
            'polygon': self._stream_polygon_data
        }
        
        for name, stream_func in streams.items():
            if name not in self.active_streams:
                task = asyncio.create_task(stream_func())
                self.active_streams[name] = task
                logger.info(f"📡 Started {name} market stream")
                
    async def _stream_alpaca_data(self):
        """Stream real-time data from Alpaca WebSocket"""
        url = "wss://stream.data.alpaca.markets/v2/iex"
        
        while True:
            try:
                async with websockets.connect(url) as ws:
                    # Authenticate
                    await ws.send(json.dumps({
                        "action": "auth",
                        "key": os.getenv("ALPACA_API_KEY"),
                        "secret": os.getenv("ALPACA_SECRET_KEY")
                    }))
                    
                    # Subscribe to symbols
                    symbols = await self._get_active_symbols()
                    await ws.send(json.dumps({
                        "action": "subscribe",
                        "trades": symbols[:30],  # Limit to 30 symbols
                        "quotes": symbols[:30]
                    }))
                    
                    async for message in ws:
                        await self._process_alpaca_message(json.loads(message))
                        
            except Exception as e:
                logger.error(f"Alpaca stream error: {e}")
                await asyncio.sleep(5)  # Reconnect after 5 seconds
                
    async def _process_alpaca_message(self, data: Dict):
        """Process incoming Alpaca market data"""
        start_time = datetime.utcnow()
        
        for msg in data:
            if msg['T'] == 't':  # Trade
                tick = MarketTick(
                    symbol=msg['S'],
                    price=msg['p'],
                    volume=msg['s'],
                    bid=0,  # Will be updated from quotes
                    ask=0,
                    timestamp=msg['t'],
                    source='alpaca'
                )
                await self._process_market_tick(tick)
                
            elif msg['T'] == 'q':  # Quote
                if msg['S'] in self.market_data:
                    self.market_data[msg['S']].bid = msg['bp']
                    self.market_data[msg['S']].ask = msg['ap']
                    
        # Track performance
        latency = (datetime.utcnow() - start_time).total_seconds() * 1000
        self.performance_metrics['alpaca']['latency_ms'].append(latency)
        
    async def _process_market_tick(self, tick: MarketTick):
        """Process market tick and generate signals"""
        # Update market data cache
        self.market_data[tick.symbol] = tick
        
        # Publish to Redis for other services
        await self.redis_client.publish(
            'market:ticks',
            json.dumps(asdict(tick))
        )
        
        # Store in time-series format
        await self._store_timeseries_data(tick)
        
        # Generate trading signals
        signals = await self._generate_trading_signals(tick)
        
        # Publish signals
        for signal in signals:
            await self._publish_trading_signal(signal)
            
        # Update metrics
        self.performance_metrics[tick.source]['ticks_processed'] += 1
        
    async def _generate_trading_signals(self, tick: MarketTick) -> List[TradingSignal]:
        """Generate trading signals using multiple strategies"""
        signals = []
        
        # Strategy 1: Momentum Detection
        momentum_signal = await self._momentum_strategy(tick)
        if momentum_signal:
            signals.append(momentum_signal)
            
        # Strategy 2: Mean Reversion
        mean_reversion_signal = await self._mean_reversion_strategy(tick)
        if mean_reversion_signal:
            signals.append(mean_reversion_signal)
            
        # Strategy 3: AI/ML Predictions
        ml_signal = await self._ml_prediction_strategy(tick)
        if ml_signal:
            signals.append(ml_signal)
            
        # Strategy 4: Volume Spike Detection
        volume_signal = await self._volume_spike_strategy(tick)
        if volume_signal:
            signals.append(volume_signal)
            
        return signals
        
    async def _momentum_strategy(self, tick: MarketTick) -> Optional[TradingSignal]:
        """Detect strong momentum movements"""
        # Get recent price history
        history_key = f'price_history:{tick.symbol}'
        history = await self.redis_client.lrange(history_key, 0, 20)
        
        if len(history) < 10:
            return None
            
        prices = [float(p) for p in history]
        current_price = tick.price
        
        # Calculate momentum indicators
        sma_5 = np.mean(prices[:5])
        sma_10 = np.mean(prices[:10])
        
        momentum = (current_price - sma_10) / sma_10
        
        if abs(momentum) > 0.02:  # 2% momentum threshold
            action = "BUY" if momentum > 0 else "SELL"
            return TradingSignal(
                symbol=tick.symbol,
                action=action,
                strength=min(abs(momentum) * 10, 1.0),
                confidence=0.75,
                strategy="momentum",
                reason=f"Strong {action.lower()} momentum detected: {momentum:.2%}",
                target_price=current_price * (1.03 if action == "BUY" else 0.97),
                stop_loss=current_price * (0.98 if action == "BUY" else 1.02)
            )
            
        return None
        
    async def _ml_prediction_strategy(self, tick: MarketTick) -> Optional[TradingSignal]:
        """Use ML predictions for signals"""
        # Get ML predictions from Redis
        predictions = await self.redis_client.get(f'ml_prediction:{tick.symbol}')
        if not predictions:
            return None
            
        pred_data = json.loads(predictions)
        predicted_price = pred_data.get('price_15min')
        confidence = pred_data.get('confidence', 0.5)
        
        if not predicted_price:
            return None
            
        expected_return = (predicted_price - tick.price) / tick.price
        
        if abs(expected_return) > 0.01 and confidence > 0.7:  # 1% threshold
            action = "BUY" if expected_return > 0 else "SELL"
            return TradingSignal(
                symbol=tick.symbol,
                action=action,
                strength=min(abs(expected_return) * 20, 1.0),
                confidence=confidence,
                strategy="ml_prediction",
                reason=f"ML predicts {expected_return:.2%} move in 15min",
                target_price=predicted_price,
                stop_loss=tick.price * (0.99 if action == "BUY" else 1.01)
            )
            
        return None
        
    async def _publish_trading_signal(self, signal: TradingSignal):
        """Publish trading signal to all subscribers"""
        # Redis pub/sub
        await self.redis_client.publish(
            'trading:signals',
            json.dumps(asdict(signal))
        )
        
        # Store in sorted set for history
        await self.redis_client.zadd(
            f'signals:history:{signal.symbol}',
            {json.dumps(asdict(signal)): datetime.utcnow().timestamp()}
        )
        
        # WebSocket broadcast
        await self._broadcast_to_websockets({
            'type': 'trading_signal',
            'data': asdict(signal)
        })
        
        # Update metrics
        self.performance_metrics[signal.strategy]['signals_generated'] += 1
        
    async def _broadcast_to_websockets(self, message: Dict):
        """Broadcast message to all connected WebSocket clients"""
        if not self.websocket_clients:
            return
            
        message_str = json.dumps(message)
        disconnected = []
        
        for client_id, ws in self.websocket_clients.items():
            try:
                await ws.send(message_str)
            except:
                disconnected.append(client_id)
                
        # Clean up disconnected clients
        for client_id in disconnected:
            del self.websocket_clients[client_id]
            
    async def websocket_handler(self, websocket, path):
        """Handle WebSocket connections from clients"""
        client_id = f"client_{datetime.utcnow().timestamp()}"
        self.websocket_clients[client_id] = websocket
        
        logger.info(f"🔌 New WebSocket client connected: {client_id}")
        
        try:
            # Send initial data
            await websocket.send(json.dumps({
                'type': 'connection',
                'status': 'connected',
                'client_id': client_id,
                'available_symbols': list(self.market_data.keys())
            }))
            
            # Handle client messages
            async for message in websocket:
                await self._handle_client_message(client_id, json.loads(message))
                
        except websockets.exceptions.ConnectionClosed:
            logger.info(f"Client {client_id} disconnected")
        finally:
            del self.websocket_clients[client_id]
            
    async def _handle_client_message(self, client_id: str, message: Dict):
        """Handle messages from WebSocket clients"""
        msg_type = message.get('type')
        
        if msg_type == 'subscribe':
            symbols = message.get('symbols', [])
            # Client wants real-time updates for specific symbols
            logger.info(f"Client {client_id} subscribed to: {symbols}")
            
        elif msg_type == 'get_signals':
            # Send recent signals
            symbol = message.get('symbol')
            signals = await self.redis_client.zrevrange(
                f'signals:history:{symbol}', 0, 10
            )
            await self.websocket_clients[client_id].send(json.dumps({
                'type': 'historical_signals',
                'symbol': symbol,
                'signals': [json.loads(s) for s in signals]
            }))
            
    async def start_performance_monitor(self):
        """Monitor and report system performance"""
        while True:
            await asyncio.sleep(60)  # Report every minute
            
            report = {
                'timestamp': datetime.utcnow().isoformat(),
                'uptime_minutes': 0,  # Calculate from start time
                'metrics': {}
            }
            
            for source, metrics in self.performance_metrics.items():
                avg_latency = np.mean(metrics['latency_ms']) if metrics['latency_ms'] else 0
                report['metrics'][source] = {
                    'ticks_processed': metrics['ticks_processed'],
                    'signals_generated': metrics['signals_generated'],
                    'avg_latency_ms': round(avg_latency, 2),
                    'error_rate': metrics['errors'] / max(metrics['ticks_processed'], 1)
                }
                
            # Store performance report
            await self.redis_client.set(
                'engine:performance:latest',
                json.dumps(report)
            )
            
            # Reset latency tracking
            for metrics in self.performance_metrics.values():
                metrics['latency_ms'] = metrics['latency_ms'][-100:]  # Keep last 100
                
            logger.info(f"📊 Performance: {json.dumps(report['metrics'], indent=2)}")
            
    async def _get_active_symbols(self) -> List[str]:
        """Get list of active symbols to monitor"""
        # Get from dynamic_tickers
        tickers = await self.redis_client.get('dynamic_tickers')
        if tickers:
            return json.loads(tickers)
        return ['AAPL', 'MSFT', 'NVDA', 'TSLA', 'AMZN']
        
    async def _store_timeseries_data(self, tick: MarketTick):
        """Store tick data in time-series format for analysis"""
        # Price history (keep last 1000 ticks)
        await self.redis_client.lpush(f'price_history:{tick.symbol}', tick.price)
        await self.redis_client.ltrim(f'price_history:{tick.symbol}', 0, 999)
        
        # Volume history
        await self.redis_client.lpush(f'volume_history:{tick.symbol}', tick.volume)
        await self.redis_client.ltrim(f'volume_history:{tick.symbol}', 0, 999)
        
        # Store in time-series hash
        ts_key = f"tick:{tick.symbol}:{datetime.utcnow().strftime('%Y%m%d:%H%M')}"
        await self.redis_client.hset(ts_key, mapping=asdict(tick))
        await self.redis_client.expire(ts_key, 86400)  # 24 hour TTL
        
    async def run(self):
        """Main run loop"""
        await self.initialize()
        
        # Start all components
        tasks = [
            self.start_market_streams(),
            self.start_performance_monitor(),
            self._run_pubsub_listener(),
        ]
        
        # Start WebSocket server
        ws_server = await websockets.serve(
            self.websocket_handler, 
            'localhost', 
            8765
        )
        
        logger.info("🚀 RealTime Trading Engine is running!")
        logger.info("📡 WebSocket server: ws://localhost:8765")
        
        try:
            await asyncio.gather(*tasks)
        except KeyboardInterrupt:
            logger.info("Shutting down...")
        finally:
            ws_server.close()
            await ws_server.wait_closed()
            
    async def _run_pubsub_listener(self):
        """Listen for Redis pub/sub messages"""
        async for message in self.pubsub.listen():
            if message['type'] == 'message':
                channel = message['channel'].decode()
                data = json.loads(message['data'])
                
                # Route messages to appropriate handlers
                if channel == 'ml:predictions':
                    await self._handle_ml_update(data)
                elif channel == 'grok:insights':
                    await self._handle_grok_insight(data)
                elif channel == 'system:alerts':
                    await self._handle_system_alert(data)
                    
    async def _mean_reversion_strategy(self, tick: MarketTick) -> Optional[TradingSignal]:
        """Mean reversion strategy for oversold/overbought conditions"""
        # Get price history
        history = await self.redis_client.lrange(f'price_history:{tick.symbol}', 0, 50)
        if len(history) < 20:
            return None
            
        prices = [float(p) for p in history]
        
        # Calculate Bollinger Bands
        sma = np.mean(prices[:20])
        std = np.std(prices[:20])
        upper_band = sma + (2 * std)
        lower_band = sma - (2 * std)
        
        current_price = tick.price
        
        # Check for mean reversion opportunity
        if current_price < lower_band:
            return TradingSignal(
                symbol=tick.symbol,
                action="BUY",
                strength=min((sma - current_price) / sma * 10, 1.0),
                confidence=0.70,
                strategy="mean_reversion",
                reason=f"Price below lower Bollinger Band, expecting reversion to {sma:.2f}",
                target_price=sma,
                stop_loss=current_price * 0.98
            )
        elif current_price > upper_band:
            return TradingSignal(
                symbol=tick.symbol,
                action="SELL",
                strength=min((current_price - sma) / sma * 10, 1.0),
                confidence=0.70,
                strategy="mean_reversion",
                reason=f"Price above upper Bollinger Band, expecting reversion to {sma:.2f}",
                target_price=sma,
                stop_loss=current_price * 1.02
            )
            
        return None
        
    async def _volume_spike_strategy(self, tick: MarketTick) -> Optional[TradingSignal]:
        """Detect unusual volume spikes"""
        # Get volume history
        volume_history = await self.redis_client.lrange(f'volume_history:{tick.symbol}', 0, 50)
        if len(volume_history) < 20:
            return None
            
        volumes = [int(v) for v in volume_history]
        avg_volume = np.mean(volumes[:20])
        
        # Check for volume spike (3x average)
        if tick.volume > avg_volume * 3:
            # Determine direction based on price movement
            price_history = await self.redis_client.lrange(f'price_history:{tick.symbol}', 0, 5)
            if len(price_history) >= 2:
                prev_price = float(price_history[1])
                price_change = (tick.price - prev_price) / prev_price
                
                if abs(price_change) > 0.005:  # 0.5% move with volume
                    action = "BUY" if price_change > 0 else "SELL"
                    return TradingSignal(
                        symbol=tick.symbol,
                        action=action,
                        strength=min(tick.volume / avg_volume / 5, 1.0),
                        confidence=0.65,
                        strategy="volume_spike",
                        reason=f"Unusual volume spike ({tick.volume/avg_volume:.1f}x average) with {price_change:.2%} price move",
                        target_price=tick.price * (1.02 if action == "BUY" else 0.98),
                        stop_loss=tick.price * (0.99 if action == "BUY" else 1.01)
                    )
                    
        return None

    async def _stream_finnhub_data(self):
        """Stream from Finnhub WebSocket"""
        # Implementation similar to Alpaca
        pass
        
    async def _stream_crypto_data(self):
        """Stream crypto data from Binance"""
        # Implementation for crypto markets
        pass
        
    async def _stream_polygon_data(self):
        """Stream from Polygon.io"""
        # Implementation for Polygon
        pass
        
    async def _handle_ml_update(self, data: Dict):
        """Handle ML model updates"""
        logger.info(f"📊 ML Update: {data.get('symbol')} - Confidence: {data.get('confidence')}")
        
    async def _handle_grok_insight(self, data: Dict):
        """Handle Grok AI insights"""
        logger.info(f"🧠 Grok Insight: {data.get('ticker')} - {data.get('reason')}")
        
    async def _handle_system_alert(self, data: Dict):
        """Handle system alerts"""
        logger.warning(f"⚠️ System Alert: {data.get('message')}")

async def main():
    engine = RealTimeEngine()
    await engine.run()

if __name__ == "__main__":
    asyncio.run(main())