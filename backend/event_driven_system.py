#!/usr/bin/env python3
"""
⚡ EVENT-DRIVEN TRADING SYSTEM
Ultra-reactive event processing with Redis Streams and Pub/Sub
"""
import asyncio
import json
import redis.asyncio as redis
from typing import Dict, List, Any, Callable, Optional
from datetime import datetime, timedelta
import logging
from dataclasses import dataclass, asdict, field
from enum import Enum
import uuid
from collections import defaultdict
import traceback

logging.basicConfig(
    level=logging.INFO,
    format='[%(asctime)s] %(levelname)s [%(name)s] %(message)s'
)
logger = logging.getLogger('EventSystem')

class EventType(Enum):
    # Market Events
    MARKET_TICK = "market.tick"
    MARKET_OPEN = "market.open"
    MARKET_CLOSE = "market.close"
    PRICE_ALERT = "market.price_alert"
    VOLUME_SPIKE = "market.volume_spike"
    VOLATILITY_CHANGE = "market.volatility_change"
    
    # Trading Events
    SIGNAL_GENERATED = "trading.signal"
    ORDER_PLACED = "trading.order_placed"
    ORDER_FILLED = "trading.order_filled"
    ORDER_CANCELLED = "trading.order_cancelled"
    POSITION_OPENED = "trading.position_opened"
    POSITION_CLOSED = "trading.position_closed"
    STOP_LOSS_HIT = "trading.stop_loss_hit"
    TAKE_PROFIT_HIT = "trading.take_profit_hit"
    
    # Portfolio Events
    PORTFOLIO_UPDATE = "portfolio.update"
    MARGIN_CALL = "portfolio.margin_call"
    RISK_LIMIT_BREACH = "portfolio.risk_breach"
    REBALANCE_NEEDED = "portfolio.rebalance"
    
    # AI/ML Events
    PREDICTION_READY = "ai.prediction_ready"
    MODEL_RETRAINED = "ai.model_retrained"
    ANOMALY_DETECTED = "ai.anomaly_detected"
    PATTERN_RECOGNIZED = "ai.pattern_found"
    
    # System Events
    SYSTEM_START = "system.start"
    SYSTEM_STOP = "system.stop"
    ERROR_CRITICAL = "system.error_critical"
    PERFORMANCE_DEGRADED = "system.performance_degraded"
    API_LIMIT_WARNING = "system.api_limit_warning"
    
    # User Events
    USER_ACTION = "user.action"
    CONFIG_CHANGED = "user.config_changed"
    EMERGENCY_STOP = "user.emergency_stop"
    MANUAL_OVERRIDE = "user.manual_override"

@dataclass
class Event:
    id: str = field(default_factory=lambda: str(uuid.uuid4()))
    type: EventType = EventType.SYSTEM_START
    source: str = ""
    data: Dict[str, Any] = field(default_factory=dict)
    timestamp: str = field(default_factory=lambda: datetime.utcnow().isoformat())
    correlation_id: Optional[str] = None
    priority: int = 5  # 1-10, 10 being highest
    ttl: Optional[int] = None  # Time to live in seconds
    
    def to_dict(self) -> Dict[str, Any]:
        return {
            'id': self.id,
            'type': self.type.value,
            'source': self.source,
            'data': self.data,
            'timestamp': self.timestamp,
            'correlation_id': self.correlation_id,
            'priority': self.priority,
            'ttl': self.ttl
        }

class EventHandler:
    """Base class for event handlers"""
    def __init__(self, name: str):
        self.name = name
        self.handled_count = 0
        self.error_count = 0
        
    async def handle(self, event: Event) -> Optional[List[Event]]:
        """Handle event and optionally return new events"""
        raise NotImplementedError
        
    async def can_handle(self, event: Event) -> bool:
        """Check if this handler can process the event"""
        return True

class EventDrivenSystem:
    def __init__(self, redis_url: str = 'redis://:pass123@localhost:6379/0'):
        self.redis_url = redis_url
        self.redis_client: Optional[redis.Redis] = None
        self.handlers: Dict[EventType, List[EventHandler]] = defaultdict(list)
        self.event_store: List[Event] = []  # In-memory event store
        self.metrics = defaultdict(lambda: {
            'processed': 0,
            'errors': 0,
            'avg_latency_ms': 0,
            'handlers_triggered': 0
        })
        self.running = False
        self.tasks: List[asyncio.Task] = []
        
    async def initialize(self):
        """Initialize the event system"""
        logger.info("⚡ Initializing Event-Driven System...")
        
        # Redis connection with streams support
        self.redis_client = await redis.from_url(self.redis_url)
        
        # Register built-in handlers
        await self._register_core_handlers()
        
        # Create event streams
        await self._create_event_streams()
        
        logger.info("✅ Event System initialized")
        
    async def _create_event_streams(self):
        """Create Redis streams for event processing"""
        streams = [
            'events:market',
            'events:trading',
            'events:portfolio',
            'events:ai',
            'events:system',
            'events:user',
            'events:priority'  # High priority events
        ]
        
        for stream in streams:
            # Ensure stream exists
            await self.redis_client.xadd(stream, {'init': 'true'}, maxlen=10000)
            
    def register_handler(self, event_type: EventType, handler: EventHandler):
        """Register an event handler"""
        self.handlers[event_type].append(handler)
        logger.info(f"Registered handler '{handler.name}' for {event_type.value}")
        
    async def emit(self, event: Event):
        """Emit an event for processing"""
        try:
            # Add to appropriate stream based on type
            stream_name = f"events:{event.type.value.split('.')[0]}"
            
            # High priority events go to priority stream
            if event.priority >= 8:
                await self.redis_client.xadd(
                    'events:priority',
                    event.to_dict(),
                    maxlen=1000
                )
                
            # Add to regular stream
            event_id = await self.redis_client.xadd(
                stream_name,
                event.to_dict(),
                maxlen=10000
            )
            
            # Publish for real-time subscribers
            await self.redis_client.publish(
                f'event:{event.type.value}',
                json.dumps(event.to_dict())
            )
            
            # Store in event store
            self.event_store.append(event)
            if len(self.event_store) > 10000:
                self.event_store = self.event_store[-5000:]  # Keep last 5000
                
            logger.debug(f"Emitted event {event.id} type={event.type.value}")
            
        except Exception as e:
            logger.error(f"Error emitting event: {e}")
            
    async def process_stream(self, stream_name: str):
        """Process events from a Redis stream"""
        logger.info(f"📡 Processing stream: {stream_name}")
        last_id = '0'
        
        while self.running:
            try:
                # Read from stream
                messages = await self.redis_client.xread(
                    {stream_name: last_id},
                    block=1000,  # 1 second timeout
                    count=10
                )
                
                for stream, stream_messages in messages:
                    for message_id, data in stream_messages:
                        last_id = message_id
                        
                        # Convert back to Event
                        event = Event(
                            id=data.get('id', str(uuid.uuid4())),
                            type=EventType(data.get('type', 'system.unknown')),
                            source=data.get('source', ''),
                            data=json.loads(data.get('data', '{}')),
                            timestamp=data.get('timestamp', ''),
                            correlation_id=data.get('correlation_id'),
                            priority=int(data.get('priority', 5))
                        )
                        
                        # Process event
                        await self._process_event(event)
                        
            except Exception as e:
                logger.error(f"Stream processing error in {stream_name}: {e}")
                await asyncio.sleep(1)
                
    async def _process_event(self, event: Event):
        """Process a single event"""
        start_time = datetime.utcnow()
        
        try:
            # Get handlers for this event type
            handlers = self.handlers.get(event.type, [])
            
            # Also check for wildcard handlers
            wildcard_type = EventType(f"{event.type.value.split('.')[0]}.*")
            if wildcard_type in self.handlers:
                handlers.extend(self.handlers[wildcard_type])
                
            if not handlers:
                logger.debug(f"No handlers for event type {event.type.value}")
                return
                
            # Process with all handlers
            new_events = []
            handlers_triggered = 0
            
            for handler in handlers:
                try:
                    if await handler.can_handle(event):
                        result = await handler.handle(event)
                        handlers_triggered += 1
                        handler.handled_count += 1
                        
                        # Collect any new events generated
                        if result:
                            new_events.extend(result)
                            
                except Exception as e:
                    handler.error_count += 1
                    logger.error(f"Handler '{handler.name}' error: {e}")
                    logger.error(traceback.format_exc())
                    
            # Emit any new events
            for new_event in new_events:
                await self.emit(new_event)
                
            # Update metrics
            latency = (datetime.utcnow() - start_time).total_seconds() * 1000
            metrics = self.metrics[event.type]
            metrics['processed'] += 1
            metrics['handlers_triggered'] += handlers_triggered
            metrics['avg_latency_ms'] = (
                (metrics['avg_latency_ms'] * (metrics['processed'] - 1) + latency) 
                / metrics['processed']
            )
            
        except Exception as e:
            self.metrics[event.type]['errors'] += 1
            logger.error(f"Event processing error: {e}")
            
    async def _register_core_handlers(self):
        """Register core system handlers"""
        
        # Market tick aggregator
        self.register_handler(
            EventType.MARKET_TICK,
            MarketTickAggregator()
        )
        
        # Price alert handler
        self.register_handler(
            EventType.MARKET_TICK,
            PriceAlertHandler(self.redis_client)
        )
        
        # Signal processor
        self.register_handler(
            EventType.SIGNAL_GENERATED,
            SignalProcessor(self.redis_client)
        )
        
        # Risk monitor
        self.register_handler(
            EventType.POSITION_OPENED,
            RiskMonitor(self.redis_client)
        )
        
        # System health monitor
        self.register_handler(
            EventType.SYSTEM_START,
            SystemHealthMonitor()
        )
        
    async def start(self):
        """Start the event processing system"""
        await self.initialize()
        self.running = True
        
        # Start stream processors
        streams = [
            'events:market',
            'events:trading',
            'events:portfolio',
            'events:ai',
            'events:system',
            'events:priority'
        ]
        
        for stream in streams:
            task = asyncio.create_task(self.process_stream(stream))
            self.tasks.append(task)
            
        # Start metrics reporter
        self.tasks.append(
            asyncio.create_task(self._report_metrics())
        )
        
        # Emit system start event
        await self.emit(Event(
            type=EventType.SYSTEM_START,
            source='event_system',
            data={'message': 'Event system started'},
            priority=7
        ))
        
        logger.info("⚡ Event System started!")
        
    async def stop(self):
        """Stop the event processing system"""
        logger.info("Stopping event system...")
        self.running = False
        
        # Cancel all tasks
        for task in self.tasks:
            task.cancel()
            
        # Wait for tasks to complete
        await asyncio.gather(*self.tasks, return_exceptions=True)
        
        # Emit system stop event
        await self.emit(Event(
            type=EventType.SYSTEM_STOP,
            source='event_system',
            data={'message': 'Event system stopped'},
            priority=7
        ))
        
        # Close Redis connection
        await self.redis_client.close()
        
    async def _report_metrics(self):
        """Periodically report system metrics"""
        while self.running:
            await asyncio.sleep(60)  # Report every minute
            
            total_processed = sum(m['processed'] for m in self.metrics.values())
            total_errors = sum(m['errors'] for m in self.metrics.values())
            
            report = {
                'timestamp': datetime.utcnow().isoformat(),
                'total_processed': total_processed,
                'total_errors': total_errors,
                'error_rate': total_errors / max(total_processed, 1),
                'event_types': {}
            }
            
            for event_type, metrics in self.metrics.items():
                if metrics['processed'] > 0:
                    report['event_types'][event_type.value] = {
                        'count': metrics['processed'],
                        'errors': metrics['errors'],
                        'avg_latency_ms': round(metrics['avg_latency_ms'], 2),
                        'handlers_triggered': metrics['handlers_triggered']
                    }
                    
            # Store metrics
            await self.redis_client.set(
                'event_system:metrics',
                json.dumps(report),
                ex=300
            )
            
            logger.info(f"📊 Event Metrics: {total_processed} processed, {total_errors} errors")

# Built-in Event Handlers

class MarketTickAggregator(EventHandler):
    """Aggregates market ticks and detects patterns"""
    def __init__(self):
        super().__init__("MarketTickAggregator")
        self.tick_buffer = defaultdict(list)
        self.pattern_detectors = [
            self._detect_momentum,
            self._detect_reversal,
            self._detect_breakout
        ]
        
    async def handle(self, event: Event) -> Optional[List[Event]]:
        """Process market tick and detect patterns"""
        tick_data = event.data
        symbol = tick_data.get('symbol')
        price = tick_data.get('price')
        
        if not symbol or not price:
            return None
            
        # Add to buffer
        self.tick_buffer[symbol].append({
            'price': price,
            'volume': tick_data.get('volume', 0),
            'timestamp': event.timestamp
        })
        
        # Keep last 100 ticks
        if len(self.tick_buffer[symbol]) > 100:
            self.tick_buffer[symbol] = self.tick_buffer[symbol][-100:]
            
        # Run pattern detection
        new_events = []
        for detector in self.pattern_detectors:
            pattern_event = await detector(symbol, self.tick_buffer[symbol])
            if pattern_event:
                new_events.append(pattern_event)
                
        return new_events if new_events else None
        
    async def _detect_momentum(self, symbol: str, ticks: List[Dict]) -> Optional[Event]:
        """Detect momentum patterns"""
        if len(ticks) < 10:
            return None
            
        recent_prices = [t['price'] for t in ticks[-10:]]
        price_change = (recent_prices[-1] - recent_prices[0]) / recent_prices[0]
        
        if abs(price_change) > 0.02:  # 2% move
            return Event(
                type=EventType.PATTERN_RECOGNIZED,
                source='MarketTickAggregator',
                data={
                    'symbol': symbol,
                    'pattern': 'momentum',
                    'direction': 'up' if price_change > 0 else 'down',
                    'strength': abs(price_change),
                    'price': recent_prices[-1]
                },
                priority=6
            )
            
        return None

class PriceAlertHandler(EventHandler):
    """Monitors price levels and generates alerts"""
    def __init__(self, redis_client):
        super().__init__("PriceAlertHandler")
        self.redis_client = redis_client
        self.alerts = defaultdict(list)  # symbol -> list of alerts
        
    async def handle(self, event: Event) -> Optional[List[Event]]:
        """Check price against configured alerts"""
        tick_data = event.data
        symbol = tick_data.get('symbol')
        price = tick_data.get('price')
        
        if not symbol or not price:
            return None
            
        # Get alerts for this symbol
        alerts = await self._get_alerts(symbol)
        triggered_events = []
        
        for alert in alerts:
            if self._check_alert_condition(price, alert):
                triggered_events.append(Event(
                    type=EventType.PRICE_ALERT,
                    source='PriceAlertHandler',
                    data={
                        'symbol': symbol,
                        'alert_id': alert['id'],
                        'condition': alert['condition'],
                        'threshold': alert['threshold'],
                        'current_price': price,
                        'message': f"{symbol} {alert['condition']} ${alert['threshold']}"
                    },
                    priority=7
                ))
                
        return triggered_events if triggered_events else None
        
    async def _get_alerts(self, symbol: str) -> List[Dict]:
        """Get price alerts from Redis"""
        # In production, fetch from Redis
        # For now, return sample alerts
        return [
            {'id': '1', 'condition': 'above', 'threshold': 200},
            {'id': '2', 'condition': 'below', 'threshold': 150}
        ]
        
    def _check_alert_condition(self, price: float, alert: Dict) -> bool:
        """Check if alert condition is met"""
        condition = alert['condition']
        threshold = alert['threshold']
        
        if condition == 'above':
            return price > threshold
        elif condition == 'below':
            return price < threshold
        elif condition == 'crosses':
            # Would need price history to detect crossing
            return False
            
        return False

class SignalProcessor(EventHandler):
    """Processes trading signals and decides on actions"""
    def __init__(self, redis_client):
        super().__init__("SignalProcessor")
        self.redis_client = redis_client
        self.signal_aggregator = defaultdict(list)
        
    async def handle(self, event: Event) -> Optional[List[Event]]:
        """Process trading signal"""
        signal = event.data
        symbol = signal.get('symbol')
        
        if not symbol:
            return None
            
        # Aggregate signals
        self.signal_aggregator[symbol].append(signal)
        
        # Keep last 10 signals
        if len(self.signal_aggregator[symbol]) > 10:
            self.signal_aggregator[symbol] = self.signal_aggregator[symbol][-10:]
            
        # Check if we should act
        action_event = await self._evaluate_signals(symbol)
        
        return [action_event] if action_event else None
        
    async def _evaluate_signals(self, symbol: str) -> Optional[Event]:
        """Evaluate aggregated signals"""
        signals = self.signal_aggregator[symbol]
        
        if len(signals) < 3:
            return None
            
        # Count buy/sell signals
        buy_signals = sum(1 for s in signals if s.get('action') == 'BUY')
        sell_signals = sum(1 for s in signals if s.get('action') == 'SELL')
        
        # Strong consensus needed
        if buy_signals >= len(signals) * 0.7:
            return Event(
                type=EventType.ORDER_PLACED,
                source='SignalProcessor',
                data={
                    'symbol': symbol,
                    'action': 'BUY',
                    'confidence': buy_signals / len(signals),
                    'reason': 'Strong buy consensus from multiple signals'
                },
                priority=8
            )
        elif sell_signals >= len(signals) * 0.7:
            return Event(
                type=EventType.ORDER_PLACED,
                source='SignalProcessor',
                data={
                    'symbol': symbol,
                    'action': 'SELL',
                    'confidence': sell_signals / len(signals),
                    'reason': 'Strong sell consensus from multiple signals'
                },
                priority=8
            )
            
        return None

class RiskMonitor(EventHandler):
    """Monitors risk levels and enforces limits"""
    def __init__(self, redis_client):
        super().__init__("RiskMonitor")
        self.redis_client = redis_client
        
    async def handle(self, event: Event) -> Optional[List[Event]]:
        """Monitor risk when positions change"""
        position_data = event.data
        
        # Check various risk metrics
        risk_events = []
        
        # Position concentration
        concentration_event = await self._check_concentration_risk()
        if concentration_event:
            risk_events.append(concentration_event)
            
        # Margin usage
        margin_event = await self._check_margin_risk()
        if margin_event:
            risk_events.append(margin_event)
            
        # Daily loss limit
        loss_event = await self._check_loss_limit()
        if loss_event:
            risk_events.append(loss_event)
            
        return risk_events if risk_events else None
        
    async def _check_concentration_risk(self) -> Optional[Event]:
        """Check if portfolio is too concentrated"""
        # Get portfolio data
        positions = await self.redis_client.get('portfolio_positions')
        if not positions:
            return None
            
        positions_data = json.loads(positions)
        
        # Calculate concentration
        total_value = sum(float(p.get('market_value', 0)) for p in positions_data)
        
        for position in positions_data:
            position_value = float(position.get('market_value', 0))
            concentration = position_value / total_value if total_value > 0 else 0
            
            if concentration > 0.25:  # 25% limit
                return Event(
                    type=EventType.RISK_LIMIT_BREACH,
                    source='RiskMonitor',
                    data={
                        'type': 'concentration',
                        'symbol': position['ticker'],
                        'concentration': concentration,
                        'limit': 0.25,
                        'action': 'reduce_position'
                    },
                    priority=9
                )
                
        return None

class SystemHealthMonitor(EventHandler):
    """Monitors system health and performance"""
    def __init__(self):
        super().__init__("SystemHealthMonitor")
        self.start_time = datetime.utcnow()
        
    async def handle(self, event: Event) -> Optional[List[Event]]:
        """Monitor system health"""
        # This is called on system start
        # Set up periodic health checks
        
        return [Event(
            type=EventType.SYSTEM_START,
            source='SystemHealthMonitor',
            data={
                'message': 'System health monitoring activated',
                'uptime': 0,
                'status': 'healthy'
            },
            priority=5
        )]

# Example usage and patterns
async def example_event_flows():
    """Example of complex event flows"""
    
    # Create custom handler
    class TrendFollowingHandler(EventHandler):
        def __init__(self):
            super().__init__("TrendFollowing")
            self.trends = {}
            
        async def handle(self, event: Event) -> Optional[List[Event]]:
            pattern = event.data
            symbol = pattern.get('symbol')
            
            if pattern.get('pattern') == 'momentum':
                # Generate trading signal based on momentum
                return [Event(
                    type=EventType.SIGNAL_GENERATED,
                    source=self.name,
                    data={
                        'symbol': symbol,
                        'action': 'BUY' if pattern['direction'] == 'up' else 'SELL',
                        'strategy': 'trend_following',
                        'strength': pattern['strength'],
                        'confidence': 0.75
                    },
                    correlation_id=event.id,
                    priority=6
                )]
                
            return None
    
    # Initialize system
    event_system = EventDrivenSystem()
    
    # Register custom handler
    event_system.register_handler(
        EventType.PATTERN_RECOGNIZED,
        TrendFollowingHandler()
    )
    
    # Start system
    await event_system.start()
    
    # Emit some events
    await event_system.emit(Event(
        type=EventType.MARKET_TICK,
        source='market_data_feed',
        data={
            'symbol': 'AAPL',
            'price': 180.50,
            'volume': 1000000,
            'bid': 180.45,
            'ask': 180.55
        }
    ))
    
    # Keep running
    try:
        await asyncio.sleep(3600)  # Run for an hour
    finally:
        await event_system.stop()

async def main():
    """Main entry point"""
    system = EventDrivenSystem()
    await system.start()
    
    # Keep running
    try:
        while True:
            await asyncio.sleep(60)
    except KeyboardInterrupt:
        logger.info("Shutting down...")
    finally:
        await system.stop()

if __name__ == "__main__":
    asyncio.run(main())