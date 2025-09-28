#!/usr/bin/env python3
"""
🚀 MODERN DASHBOARD API
FastAPI + GraphQL + WebSocket API for ultimate trading experience
"""
from fastapi import FastAPI, WebSocket, WebSocketDisconnect, HTTPException, Depends
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
import strawberry
from strawberry.fastapi import GraphQLRouter
from strawberry.subscriptions import GRAPHQL_TRANSPORT_WS_PROTOCOL
import redis.asyncio as redis
from typing import Dict, List, Any, Optional, AsyncGenerator
import json
import asyncio
from datetime import datetime, timedelta
import logging
from pydantic import BaseModel, Field
from contextlib import asynccontextmanager
import jwt
from passlib.context import CryptContext
import os

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger('DashboardAPI')

# Pydantic Models for REST API
class TradingConfig(BaseModel):
    enabled: bool
    aggressiveness: int = Field(ge=1, le=5)
    max_position_size: int = Field(ge=1)
    max_daily_trades: int = Field(ge=1)
    buy_threshold_pct: float = Field(ge=0.001, le=0.5)
    sell_threshold_pct: float = Field(ge=0.001, le=0.5)
    stop_loss_pct: float = Field(ge=0.01, le=0.5)
    take_profit_pct: float = Field(ge=0.01, le=1.0)
    
class OrderRequest(BaseModel):
    symbol: str
    side: str = Field(pattern="^(BUY|SELL)$")
    quantity: int = Field(ge=1)
    order_type: str = Field(pattern="^(MARKET|LIMIT|STOP)$")
    limit_price: Optional[float] = None
    stop_price: Optional[float] = None
    
class PortfolioStats(BaseModel):
    total_value: float
    cash_balance: float
    positions_count: int
    daily_pnl: float
    daily_pnl_pct: float
    total_pnl: float
    win_rate: float
    sharpe_ratio: float
    
# GraphQL Schema
@strawberry.type
class MarketData:
    symbol: str
    price: float
    change: float
    change_pct: float
    volume: int
    bid: float
    ask: float
    timestamp: str
    
@strawberry.type
class Position:
    symbol: str
    quantity: int
    avg_price: float
    current_price: float
    market_value: float
    unrealized_pnl: float
    unrealized_pnl_pct: float
    
@strawberry.type
class TradingSignal:
    symbol: str
    action: str
    strength: float
    confidence: float
    strategy: str
    reason: str
    target_price: float
    stop_loss: float
    timestamp: str
    
@strawberry.type
class AIPredict ion:
    symbol: str
    horizon: str
    predicted_price: float
    current_price: float
    confidence: float
    trend: str
    expected_return: float
    
@strawberry.type
class SystemStatus:
    trading_active: bool
    market_open: bool
    connected_apis: List[str]
    active_strategies: List[str]
    error_count: int
    uptime_hours: float
    
# Connection manager for WebSockets
class ConnectionManager:
    def __init__(self):
        self.active_connections: Dict[str, List[WebSocket]] = {
            'market': [],
            'signals': [],
            'portfolio': [],
            'system': []
        }
        
    async def connect(self, websocket: WebSocket, channel: str):
        await websocket.accept()
        self.active_connections[channel].append(websocket)
        
    def disconnect(self, websocket: WebSocket, channel: str):
        self.active_connections[channel].remove(websocket)
        
    async def broadcast(self, message: dict, channel: str):
        disconnected = []
        for connection in self.active_connections[channel]:
            try:
                await connection.send_json(message)
            except:
                disconnected.append(connection)
                
        # Clean up disconnected
        for conn in disconnected:
            self.active_connections[channel].remove(conn)

# App lifecycle
@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup
    app.state.redis = await redis.from_url('redis://:pass123@localhost:6379/0')
    app.state.manager = ConnectionManager()
    
    # Start background tasks
    app.state.tasks = [
        asyncio.create_task(market_data_broadcaster(app)),
        asyncio.create_task(signal_broadcaster(app)),
        asyncio.create_task(portfolio_updater(app)),
        asyncio.create_task(system_monitor(app))
    ]
    
    yield
    
    # Shutdown
    for task in app.state.tasks:
        task.cancel()
    await app.state.redis.close()

# Create FastAPI app
app = FastAPI(
    title="QBot Trading Dashboard API",
    description="🚀 High-performance trading API with real-time updates",
    version="2.0.0",
    lifespan=lifespan
)

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Configure for production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Authentication
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")
SECRET_KEY = os.getenv("JWT_SECRET_KEY", "your-secret-key-change-in-production")

async def get_current_user(token: str = Depends(lambda: None)):
    # Simplified auth - implement properly in production
    return {"user_id": "trader1", "roles": ["trader", "admin"]}

# REST API Endpoints
@app.get("/")
async def root():
    return {
        "message": "🚀 QBot Trading API",
        "version": "2.0.0",
        "endpoints": {
            "rest": "/docs",
            "graphql": "/graphql",
            "websocket": "ws://localhost:8000/ws/{channel}"
        }
    }

@app.get("/api/v1/portfolio", response_model=PortfolioStats)
async def get_portfolio(user = Depends(get_current_user)):
    """Get current portfolio statistics"""
    redis_client = app.state.redis
    
    # Get portfolio data
    portfolio_data = await redis_client.get('backend:portfolio_summary')
    if not portfolio_data:
        raise HTTPException(404, "Portfolio data not found")
        
    data = json.loads(portfolio_data)
    
    return PortfolioStats(
        total_value=data.get('total_value', 0),
        cash_balance=data.get('cash_balance', 0),
        positions_count=data.get('positions_count', 0),
        daily_pnl=data.get('day_change', 0),
        daily_pnl_pct=data.get('day_change_pct', 0),
        total_pnl=0,  # Calculate from history
        win_rate=0.75,  # Get from performance metrics
        sharpe_ratio=1.85  # Calculate properly
    )

@app.get("/api/v1/positions")
async def get_positions(user = Depends(get_current_user)):
    """Get all open positions"""
    redis_client = app.state.redis
    
    positions = await redis_client.get('portfolio_positions')
    if not positions:
        return []
        
    return json.loads(positions)

@app.post("/api/v1/orders")
async def place_order(order: OrderRequest, user = Depends(get_current_user)):
    """Place a new trading order"""
    redis_client = app.state.redis
    
    # Create manual order
    order_data = {
        "order_id": f"api_{datetime.utcnow().timestamp()}",
        "symbol": order.symbol,
        "side": order.side,
        "quantity": order.quantity,
        "order_type": order.order_type,
        "limit_price": order.limit_price,
        "stop_price": order.stop_price,
        "status": "PENDING",
        "created_at": datetime.utcnow().isoformat(),
        "created_by": user["user_id"],
        "source": "dashboard_api"
    }
    
    # Add to manual orders queue
    manual_orders = await redis_client.get('frontend:manual_orders')
    orders = json.loads(manual_orders) if manual_orders else []
    orders.append(order_data)
    
    await redis_client.set('frontend:manual_orders', json.dumps(orders))
    
    return {"order_id": order_data["order_id"], "status": "submitted"}

@app.put("/api/v1/trading/config")
async def update_trading_config(config: TradingConfig, user = Depends(get_current_user)):
    """Update trading configuration"""
    redis_client = app.state.redis
    
    config_data = {
        **config.dict(),
        "updated_at": datetime.utcnow().isoformat(),
        "updated_by": user["user_id"]
    }
    
    await redis_client.set('frontend:trading_config', json.dumps(config_data))
    
    return {"status": "updated", "config": config_data}

@app.post("/api/v1/trading/{action}")
async def control_trading(action: str, user = Depends(get_current_user)):
    """Start or stop auto trading"""
    if action not in ["start", "stop", "pause"]:
        raise HTTPException(400, "Invalid action")
        
    redis_client = app.state.redis
    
    if action == "start":
        await redis_client.set('autotrading:status', 'ACTIVE')
        await redis_client.set('autotrading:enabled', json.dumps({
            "enabled": True,
            "timestamp": datetime.utcnow().isoformat(),
            "source": "dashboard_api",
            "user": user["user_id"]
        }))
    elif action == "stop":
        await redis_client.set('autotrading:status', 'STOPPED')
        await redis_client.delete('autotrading:enabled')
        
    return {"status": action, "timestamp": datetime.utcnow().isoformat()}

@app.get("/api/v1/market/{symbol}")
async def get_market_data(symbol: str):
    """Get real-time market data for a symbol"""
    redis_client = app.state.redis
    
    # Get from multiple sources
    market_data = await redis_client.get(f'market_data:{symbol}')
    if not market_data:
        # Try aggregated data
        multi_data = await redis_client.get('multi_api_enhanced_data')
        if multi_data:
            all_data = json.loads(multi_data)
            if symbol in all_data:
                return all_data[symbol]
                
        raise HTTPException(404, f"No data for {symbol}")
        
    return json.loads(market_data)

@app.get("/api/v1/signals/latest")
async def get_latest_signals(limit: int = 20):
    """Get latest trading signals"""
    redis_client = app.state.redis
    
    signals = []
    symbols = ['AAPL', 'MSFT', 'NVDA', 'TSLA', 'AMZN']  # Get from dynamic_tickers
    
    for symbol in symbols:
        signal_history = await redis_client.zrevrange(
            f'signals:history:{symbol}', 0, limit // len(symbols)
        )
        for signal_json in signal_history:
            signals.append(json.loads(signal_json))
            
    # Sort by timestamp
    signals.sort(key=lambda x: x.get('timestamp', ''), reverse=True)
    
    return signals[:limit]

@app.get("/api/v1/predictions/{symbol}")
async def get_predictions(symbol: str):
    """Get AI predictions for a symbol"""
    redis_client = app.state.redis
    
    predictions = await redis_client.get(f'ai_predictions:{symbol}')
    if not predictions:
        # Fallback to ML predictions
        ml_preds = await redis_client.get('predictions_current')
        if ml_preds:
            all_preds = json.loads(ml_preds)
            if symbol in all_preds:
                return {
                    "symbol": symbol,
                    "predictions": all_preds[symbol],
                    "source": "ml_model"
                }
                
        raise HTTPException(404, f"No predictions for {symbol}")
        
    return json.loads(predictions)

@app.get("/api/v1/analytics/performance")
async def get_performance_analytics():
    """Get detailed performance analytics"""
    redis_client = app.state.redis
    
    # Get performance data
    perf_data = await redis_client.get('backend:trading_performance')
    if not perf_data:
        raise HTTPException(404, "Performance data not available")
        
    performance = json.loads(perf_data)
    
    # Add additional analytics
    trades_log = await redis_client.get('trades_log')
    if trades_log:
        trades = json.loads(trades_log)
        
        # Calculate additional metrics
        if trades:
            winning_trades = [t for t in trades if float(t.get('pnl', 0)) > 0]
            losing_trades = [t for t in trades if float(t.get('pnl', 0)) < 0]
            
            performance['trade_analytics'] = {
                'total_trades': len(trades),
                'winning_trades': len(winning_trades),
                'losing_trades': len(losing_trades),
                'win_rate': len(winning_trades) / len(trades) if trades else 0,
                'avg_win': sum(float(t.get('pnl', 0)) for t in winning_trades) / len(winning_trades) if winning_trades else 0,
                'avg_loss': sum(float(t.get('pnl', 0)) for t in losing_trades) / len(losing_trades) if losing_trades else 0,
                'profit_factor': abs(sum(float(t.get('pnl', 0)) for t in winning_trades) / sum(float(t.get('pnl', 0)) for t in losing_trades)) if losing_trades else 0
            }
            
    return performance

# WebSocket endpoints
@app.websocket("/ws/market")
async def websocket_market(websocket: WebSocket):
    """Real-time market data stream"""
    await app.state.manager.connect(websocket, 'market')
    try:
        while True:
            # Keep connection alive
            await asyncio.sleep(30)
            await websocket.send_json({"type": "ping"})
    except WebSocketDisconnect:
        app.state.manager.disconnect(websocket, 'market')

@app.websocket("/ws/signals")
async def websocket_signals(websocket: WebSocket):
    """Real-time trading signals"""
    await app.state.manager.connect(websocket, 'signals')
    try:
        while True:
            await asyncio.sleep(30)
            await websocket.send_json({"type": "ping"})
    except WebSocketDisconnect:
        app.state.manager.disconnect(websocket, 'signals')

@app.websocket("/ws/portfolio")
async def websocket_portfolio(websocket: WebSocket):
    """Real-time portfolio updates"""
    await app.state.manager.connect(websocket, 'portfolio')
    try:
        while True:
            await asyncio.sleep(30)
            await websocket.send_json({"type": "ping"})
    except WebSocketDisconnect:
        app.state.manager.disconnect(websocket, 'portfolio')

# GraphQL Schema
@strawberry.type
class Query:
    @strawberry.field
    async def market_data(self, symbols: List[str]) -> List[MarketData]:
        """Get market data for multiple symbols"""
        redis_client = app.state.redis
        result = []
        
        for symbol in symbols:
            data = await redis_client.get(f'market_data:{symbol}')
            if data:
                d = json.loads(data)
                result.append(MarketData(
                    symbol=symbol,
                    price=d.get('price', 0),
                    change=d.get('change', 0),
                    change_pct=d.get('change_pct', 0),
                    volume=d.get('volume', 0),
                    bid=d.get('bid', 0),
                    ask=d.get('ask', 0),
                    timestamp=d.get('timestamp', '')
                ))
                
        return result
    
    @strawberry.field
    async def positions(self) -> List[Position]:
        """Get all positions"""
        redis_client = app.state.redis
        positions_data = await redis_client.get('portfolio_positions')
        
        if not positions_data:
            return []
            
        positions = json.loads(positions_data)
        result = []
        
        for pos in positions:
            # Get current price
            market_data = await redis_client.get(f'market_data:{pos["ticker"]}')
            current_price = json.loads(market_data).get('price', 0) if market_data else float(pos.get('avg_entry_price', 0))
            
            qty = int(pos.get('qty', 0))
            avg_price = float(pos.get('avg_entry_price', 0))
            market_value = qty * current_price
            unrealized_pnl = market_value - (qty * avg_price)
            
            result.append(Position(
                symbol=pos['ticker'],
                quantity=qty,
                avg_price=avg_price,
                current_price=current_price,
                market_value=market_value,
                unrealized_pnl=unrealized_pnl,
                unrealized_pnl_pct=unrealized_pnl / (qty * avg_price) if avg_price > 0 else 0
            ))
            
        return result
    
    @strawberry.field
    async def latest_signals(self, limit: int = 10) -> List[TradingSignal]:
        """Get latest trading signals"""
        redis_client = app.state.redis
        signals = []
        
        # Get from signal history
        symbols = ['AAPL', 'MSFT', 'NVDA']
        for symbol in symbols:
            history = await redis_client.zrevrange(f'signals:history:{symbol}', 0, limit // len(symbols))
            for signal_json in history:
                signal = json.loads(signal_json)
                signals.append(TradingSignal(
                    symbol=signal['symbol'],
                    action=signal['action'],
                    strength=signal['strength'],
                    confidence=signal['confidence'],
                    strategy=signal['strategy'],
                    reason=signal['reason'],
                    target_price=signal.get('target_price', 0),
                    stop_loss=signal.get('stop_loss', 0),
                    timestamp=signal['timestamp']
                ))
                
        return signals[:limit]
    
    @strawberry.field
    async def predictions(self, symbol: str) -> List[AIPrediction]:
        """Get AI predictions for a symbol"""
        redis_client = app.state.redis
        predictions_data = await redis_client.get(f'ai_predictions:{symbol}')
        
        if not predictions_data:
            return []
            
        predictions = json.loads(predictions_data)
        result = []
        
        for horizon, pred in predictions.items():
            if horizon != 'grok_insight':
                result.append(AIPrediction(
                    symbol=symbol,
                    horizon=horizon,
                    predicted_price=pred['predicted_price'],
                    current_price=pred['current_price'],
                    confidence=pred['confidence'],
                    trend=pred['trend'],
                    expected_return=(pred['predicted_price'] - pred['current_price']) / pred['current_price']
                ))
                
        return result
    
    @strawberry.field
    async def system_status(self) -> SystemStatus:
        """Get system status"""
        redis_client = app.state.redis
        status_data = await redis_client.get('system_status')
        
        if not status_data:
            return SystemStatus(
                trading_active=False,
                market_open=False,
                connected_apis=[],
                active_strategies=[],
                error_count=0,
                uptime_hours=0
            )
            
        status = json.loads(status_data)
        
        # Get connected APIs
        connected_apis = []
        if status.get('finnhub_api_active'):
            connected_apis.append('finnhub')
        if status.get('alpaca_api_active'):
            connected_apis.append('alpaca')
        if status.get('grok_api_active'):
            connected_apis.append('grok')
            
        return SystemStatus(
            trading_active=status.get('worker_running', False),
            market_open=status.get('market_open', False),
            connected_apis=connected_apis,
            active_strategies=['momentum', 'mean_reversion', 'ml_prediction'],
            error_count=0,
            uptime_hours=status.get('uptime_seconds', 0) / 3600
        )

@strawberry.type
class Subscription:
    @strawberry.subscription
    async def market_updates(self, symbols: List[str]) -> AsyncGenerator[MarketData, None]:
        """Subscribe to real-time market updates"""
        redis_client = app.state.redis
        pubsub = redis_client.pubsub()
        await pubsub.subscribe('market:ticks')
        
        async for message in pubsub.listen():
            if message['type'] == 'message':
                data = json.loads(message['data'])
                if data['symbol'] in symbols:
                    yield MarketData(
                        symbol=data['symbol'],
                        price=data['price'],
                        change=0,  # Calculate from previous
                        change_pct=0,
                        volume=data['volume'],
                        bid=data['bid'],
                        ask=data['ask'],
                        timestamp=data['timestamp']
                    )
    
    @strawberry.subscription
    async def signal_stream(self) -> AsyncGenerator[TradingSignal, None]:
        """Subscribe to trading signals"""
        redis_client = app.state.redis
        pubsub = redis_client.pubsub()
        await pubsub.subscribe('trading:signals')
        
        async for message in pubsub.listen():
            if message['type'] == 'message':
                signal = json.loads(message['data'])
                yield TradingSignal(
                    symbol=signal['symbol'],
                    action=signal['action'],
                    strength=signal['strength'],
                    confidence=signal['confidence'],
                    strategy=signal['strategy'],
                    reason=signal['reason'],
                    target_price=signal.get('target_price', 0),
                    stop_loss=signal.get('stop_loss', 0),
                    timestamp=signal['timestamp']
                )

# Create GraphQL schema
schema = strawberry.Schema(query=Query, subscription=Subscription)

# Add GraphQL route
graphql_app = GraphQLRouter(
    schema,
    subscription_protocols=[GRAPHQL_TRANSPORT_WS_PROTOCOL]
)
app.include_router(graphql_app, prefix="/graphql")

# Background tasks
async def market_data_broadcaster(app):
    """Broadcast market data updates"""
    redis_client = app.state.redis
    pubsub = redis_client.pubsub()
    await pubsub.subscribe('market:ticks')
    
    async for message in pubsub.listen():
        if message['type'] == 'message':
            data = json.loads(message['data'])
            await app.state.manager.broadcast(
                {"type": "market_update", "data": data},
                'market'
            )

async def signal_broadcaster(app):
    """Broadcast trading signals"""
    redis_client = app.state.redis
    pubsub = redis_client.pubsub()
    await pubsub.subscribe('trading:signals')
    
    async for message in pubsub.listen():
        if message['type'] == 'message':
            signal = json.loads(message['data'])
            await app.state.manager.broadcast(
                {"type": "signal", "data": signal},
                'signals'
            )

async def portfolio_updater(app):
    """Send portfolio updates"""
    while True:
        try:
            redis_client = app.state.redis
            
            # Get portfolio data
            portfolio = await redis_client.get('backend:portfolio_summary')
            if portfolio:
                await app.state.manager.broadcast(
                    {"type": "portfolio_update", "data": json.loads(portfolio)},
                    'portfolio'
                )
                
            await asyncio.sleep(5)  # Update every 5 seconds
            
        except Exception as e:
            logger.error(f"Portfolio update error: {e}")
            await asyncio.sleep(5)

async def system_monitor(app):
    """Monitor system health"""
    while True:
        try:
            redis_client = app.state.redis
            
            # Get system status
            status = await redis_client.get('backend:system_health')
            if status:
                await app.state.manager.broadcast(
                    {"type": "system_status", "data": json.loads(status)},
                    'system'
                )
                
            await asyncio.sleep(10)  # Update every 10 seconds
            
        except Exception as e:
            logger.error(f"System monitor error: {e}")
            await asyncio.sleep(10)

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000, reload=True)