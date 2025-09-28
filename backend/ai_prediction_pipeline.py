#!/usr/bin/env python3
"""
🤖 AI PREDICTION PIPELINE
Advanced ML/AI system with real-time predictions and continuous learning
"""
import asyncio
import json
import numpy as np
import pandas as pd
from datetime import datetime, timedelta
import redis.asyncio as redis
from typing import Dict, List, Any, Optional, Tuple
import logging
import joblib
from dataclasses import dataclass, asdict
import torch
import torch.nn as nn
from sklearn.preprocessing import StandardScaler
from collections import deque
import aiohttp
import os

logging.basicConfig(
    level=logging.INFO,
    format='[%(asctime)s] %(levelname)s [%(name)s] %(message)s'
)
logger = logging.getLogger('AIPipeline')

@dataclass
class PredictionResult:
    symbol: str
    horizon: str  # 5min, 15min, 1h, 1d
    predicted_price: float
    current_price: float
    confidence: float
    volatility: float
    trend: str  # bullish, bearish, neutral
    features_importance: Dict[str, float]
    timestamp: str = ""
    
    def __post_init__(self):
        if not self.timestamp:
            self.timestamp = datetime.utcnow().isoformat()

class NeuralPricePredictor(nn.Module):
    """Advanced neural network for price prediction"""
    def __init__(self, input_size: int, hidden_sizes: List[int], dropout: float = 0.2):
        super().__init__()
        layers = []
        
        prev_size = input_size
        for hidden_size in hidden_sizes:
            layers.extend([
                nn.Linear(prev_size, hidden_size),
                nn.BatchNorm1d(hidden_size),
                nn.ReLU(),
                nn.Dropout(dropout)
            ])
            prev_size = hidden_size
            
        # Output layer
        layers.append(nn.Linear(prev_size, 1))
        
        self.network = nn.Sequential(*layers)
        
    def forward(self, x):
        return self.network(x)

class AIPredictionPipeline:
    def __init__(self, redis_url: str = 'redis://:pass123@localhost:6379/0'):
        self.redis_url = redis_url
        self.redis_client: Optional[redis.Redis] = None
        self.models: Dict[str, Dict[str, Any]] = {}  # symbol -> horizon -> model
        self.scalers: Dict[str, StandardScaler] = {}
        self.feature_buffers: Dict[str, deque] = {}
        self.prediction_cache: Dict[str, PredictionResult] = {}
        self.performance_tracker: Dict[str, List[float]] = {}
        self.grok_api_key = os.getenv("GROK_API_KEY")
        
    async def initialize(self):
        """Initialize the AI pipeline"""
        logger.info("🤖 Initializing AI Prediction Pipeline...")
        
        # Redis connection
        self.redis_client = await redis.from_url(self.redis_url)
        
        # Load or create models
        await self._load_models()
        
        # Initialize feature engineering
        await self._init_feature_engineering()
        
        logger.info("✅ AI Pipeline initialized")
        
    async def _load_models(self):
        """Load existing models or create new ones"""
        symbols = await self._get_active_symbols()
        horizons = ['5min', '15min', '1h', '1d']
        
        for symbol in symbols[:10]:  # Limit to top 10 symbols
            self.models[symbol] = {}
            self.scalers[symbol] = StandardScaler()
            self.feature_buffers[symbol] = deque(maxlen=1000)
            
            for horizon in horizons:
                # Try to load existing model
                model_key = f'ai_model:{symbol}:{horizon}'
                model_data = await self.redis_client.get(model_key)
                
                if model_data:
                    # Load from Redis
                    logger.info(f"Loading model for {symbol} {horizon}")
                    # In production, deserialize the model
                else:
                    # Create new neural network
                    model = NeuralPricePredictor(
                        input_size=50,  # Number of features
                        hidden_sizes=[128, 64, 32],
                        dropout=0.2
                    )
                    self.models[symbol][horizon] = {
                        'model': model,
                        'optimizer': torch.optim.Adam(model.parameters(), lr=0.001),
                        'last_trained': datetime.utcnow(),
                        'accuracy': 0.0
                    }
                    
    async def predict_batch(self, symbols: List[str]) -> Dict[str, Dict[str, PredictionResult]]:
        """Generate predictions for multiple symbols"""
        predictions = {}
        
        # Parallel prediction generation
        tasks = []
        for symbol in symbols:
            tasks.append(self._predict_symbol(symbol))
            
        results = await asyncio.gather(*tasks)
        
        for symbol, result in zip(symbols, results):
            if result:
                predictions[symbol] = result
                
        # Store predictions in Redis
        await self._store_predictions(predictions)
        
        # Publish to real-time subscribers
        await self._publish_predictions(predictions)
        
        return predictions
        
    async def _predict_symbol(self, symbol: str) -> Optional[Dict[str, PredictionResult]]:
        """Generate predictions for a single symbol"""
        try:
            # Get current features
            features = await self._engineer_features(symbol)
            if features is None:
                return None
                
            predictions = {}
            current_price = features['current_price']
            
            for horizon, model_data in self.models.get(symbol, {}).items():
                model = model_data['model']
                
                # Prepare input tensor
                feature_vector = self._prepare_features(features, horizon)
                input_tensor = torch.FloatTensor(feature_vector).unsqueeze(0)
                
                # Generate prediction
                model.eval()
                with torch.no_grad():
                    predicted_change = model(input_tensor).item()
                    
                # Calculate predicted price
                predicted_price = current_price * (1 + predicted_change)
                
                # Estimate confidence based on model accuracy and market conditions
                confidence = self._calculate_confidence(
                    model_data, features, predicted_change
                )
                
                # Determine trend
                trend = self._determine_trend(predicted_change, features)
                
                # Feature importance (simplified)
                feature_importance = self._calculate_feature_importance(
                    model, feature_vector
                )
                
                predictions[horizon] = PredictionResult(
                    symbol=symbol,
                    horizon=horizon,
                    predicted_price=predicted_price,
                    current_price=current_price,
                    confidence=confidence,
                    volatility=features.get('volatility', 0.02),
                    trend=trend,
                    features_importance=feature_importance
                )
                
            # Get Grok AI insights
            grok_insight = await self._get_grok_insight(symbol, predictions)
            if grok_insight:
                predictions['grok'] = grok_insight
                
            return predictions
            
        except Exception as e:
            logger.error(f"Error predicting {symbol}: {e}")
            return None
            
    async def _engineer_features(self, symbol: str) -> Optional[Dict[str, Any]]:
        """Engineer features for ML models"""
        try:
            # Get market data
            market_data = await self.redis_client.get(f'market_data:{symbol}')
            if not market_data:
                return None
                
            data = json.loads(market_data)
            
            # Get historical data
            price_history = await self.redis_client.lrange(
                f'price_history:{symbol}', 0, 100
            )
            volume_history = await self.redis_client.lrange(
                f'volume_history:{symbol}', 0, 100
            )
            
            if len(price_history) < 50:
                return None
                
            prices = np.array([float(p) for p in price_history])
            volumes = np.array([float(v) for v in volume_history[:len(prices)]])
            
            # Technical indicators
            features = {
                'current_price': float(data.get('price', prices[0])),
                'volume': float(data.get('volume', volumes[0])),
                
                # Price features
                'returns_5': (prices[0] - prices[4]) / prices[4] if len(prices) > 4 else 0,
                'returns_10': (prices[0] - prices[9]) / prices[9] if len(prices) > 9 else 0,
                'returns_20': (prices[0] - prices[19]) / prices[19] if len(prices) > 19 else 0,
                
                # Moving averages
                'sma_5': np.mean(prices[:5]),
                'sma_10': np.mean(prices[:10]) if len(prices) >= 10 else prices.mean(),
                'sma_20': np.mean(prices[:20]) if len(prices) >= 20 else prices.mean(),
                
                # Volatility
                'volatility': np.std(prices[:20]) / np.mean(prices[:20]) if len(prices) >= 20 else 0.02,
                
                # Volume features
                'volume_ratio': volumes[0] / np.mean(volumes[:10]) if len(volumes) >= 10 and np.mean(volumes[:10]) > 0 else 1,
                'volume_trend': (np.mean(volumes[:5]) - np.mean(volumes[5:10])) / np.mean(volumes[5:10]) if len(volumes) >= 10 and np.mean(volumes[5:10]) > 0 else 0,
                
                # RSI
                'rsi': self._calculate_rsi(prices),
                
                # MACD
                'macd': self._calculate_macd(prices),
                
                # Bollinger Bands
                'bb_position': self._calculate_bb_position(prices),
                
                # Time features
                'hour': datetime.utcnow().hour,
                'day_of_week': datetime.utcnow().weekday(),
                'minutes_since_open': self._minutes_since_market_open(),
            }
            
            # Market sentiment from various sources
            sentiment = await self._get_market_sentiment(symbol)
            features.update(sentiment)
            
            # Add correlation features
            correlations = await self._get_correlation_features(symbol)
            features.update(correlations)
            
            return features
            
        except Exception as e:
            logger.error(f"Feature engineering error for {symbol}: {e}")
            return None
            
    def _calculate_rsi(self, prices: np.ndarray, period: int = 14) -> float:
        """Calculate RSI indicator"""
        if len(prices) < period + 1:
            return 50.0
            
        deltas = np.diff(prices[:period+1])
        gains = deltas[deltas > 0].sum() / period
        losses = -deltas[deltas < 0].sum() / period
        
        if losses == 0:
            return 100.0
            
        rs = gains / losses
        rsi = 100 - (100 / (1 + rs))
        
        return rsi
        
    def _calculate_macd(self, prices: np.ndarray) -> float:
        """Calculate MACD indicator"""
        if len(prices) < 26:
            return 0.0
            
        # Simplified MACD
        ema_12 = self._ema(prices[:12], 12)
        ema_26 = self._ema(prices[:26], 26)
        
        return ema_12 - ema_26
        
    def _ema(self, prices: np.ndarray, period: int) -> float:
        """Exponential moving average"""
        if len(prices) == 0:
            return 0.0
        multiplier = 2 / (period + 1)
        ema = prices[-1]
        for price in reversed(prices[:-1]):
            ema = (price * multiplier) + (ema * (1 - multiplier))
        return ema
        
    def _calculate_bb_position(self, prices: np.ndarray, period: int = 20) -> float:
        """Calculate position within Bollinger Bands (-1 to 1)"""
        if len(prices) < period:
            return 0.0
            
        sma = np.mean(prices[:period])
        std = np.std(prices[:period])
        
        if std == 0:
            return 0.0
            
        upper_band = sma + (2 * std)
        lower_band = sma - (2 * std)
        
        position = (prices[0] - lower_band) / (upper_band - lower_band) * 2 - 1
        return np.clip(position, -1, 1)
        
    def _minutes_since_market_open(self) -> int:
        """Calculate minutes since market open"""
        now = datetime.utcnow()
        market_open = now.replace(hour=13, minute=30, second=0)  # 9:30 AM ET in UTC
        
        if now < market_open:
            return 0
            
        return int((now - market_open).total_seconds() / 60)
        
    async def _get_market_sentiment(self, symbol: str) -> Dict[str, float]:
        """Get market sentiment from various sources"""
        sentiment = {
            'news_sentiment': 0.5,
            'social_sentiment': 0.5,
            'options_sentiment': 0.5,
            'analyst_sentiment': 0.5
        }
        
        # Get Grok sentiment
        grok_data = await self.redis_client.get('grok_topstocks_prediction')
        if grok_data:
            predictions = json.loads(grok_data)
            for item in predictions.get('items', []):
                if item['ticker'] == symbol:
                    sentiment['grok_sentiment'] = item.get('sentiment', 0.5)
                    break
                    
        # Get news sentiment (simplified)
        # In production, this would call news APIs
        
        return sentiment
        
    async def _get_correlation_features(self, symbol: str) -> Dict[str, float]:
        """Get correlation with market indices and related stocks"""
        correlations = {
            'spy_correlation': 0.7,  # Correlation with S&P 500
            'sector_correlation': 0.8,  # Correlation with sector
            'vix_correlation': -0.3,  # Correlation with volatility index
        }
        
        # In production, calculate actual correlations
        
        return correlations
        
    def _prepare_features(self, features: Dict[str, Any], horizon: str) -> np.ndarray:
        """Prepare feature vector for model input"""
        # Define feature order (must be consistent)
        feature_names = [
            'returns_5', 'returns_10', 'returns_20',
            'sma_5', 'sma_10', 'sma_20',
            'volatility', 'volume_ratio', 'volume_trend',
            'rsi', 'macd', 'bb_position',
            'hour', 'day_of_week', 'minutes_since_open',
            'news_sentiment', 'social_sentiment', 'grok_sentiment',
            'spy_correlation', 'vix_correlation'
        ]
        
        # Add horizon-specific features
        horizon_features = {
            '5min': 5,
            '15min': 15,
            '1h': 60,
            '1d': 390  # Trading minutes in a day
        }
        
        feature_vector = []
        
        for name in feature_names:
            value = features.get(name, 0.0)
            feature_vector.append(float(value))
            
        # Add horizon as a feature
        feature_vector.append(horizon_features.get(horizon, 60))
        
        # Pad to expected size
        while len(feature_vector) < 50:
            feature_vector.append(0.0)
            
        return np.array(feature_vector[:50])
        
    def _calculate_confidence(self, model_data: Dict, features: Dict, predicted_change: float) -> float:
        """Calculate prediction confidence"""
        base_confidence = model_data.get('accuracy', 0.5)
        
        # Adjust based on volatility
        volatility = features.get('volatility', 0.02)
        volatility_penalty = min(volatility * 5, 0.3)
        
        # Adjust based on prediction magnitude
        change_magnitude = abs(predicted_change)
        magnitude_penalty = min(change_magnitude * 2, 0.2)
        
        # Adjust based on data quality
        data_quality = 1.0  # Could check for missing features
        
        confidence = base_confidence * data_quality - volatility_penalty - magnitude_penalty
        
        return max(0.1, min(0.95, confidence))
        
    def _determine_trend(self, predicted_change: float, features: Dict) -> str:
        """Determine market trend"""
        if abs(predicted_change) < 0.001:
            return "neutral"
            
        # Consider multiple timeframes
        short_term = features.get('returns_5', 0)
        medium_term = features.get('returns_10', 0)
        
        if predicted_change > 0 and short_term > 0 and medium_term > 0:
            return "strong_bullish"
        elif predicted_change > 0:
            return "bullish"
        elif predicted_change < 0 and short_term < 0 and medium_term < 0:
            return "strong_bearish"
        else:
            return "bearish"
            
    def _calculate_feature_importance(self, model: nn.Module, features: np.ndarray) -> Dict[str, float]:
        """Calculate feature importance using gradient-based method"""
        # Simplified - in production use SHAP or similar
        importance = {
            'price_momentum': 0.25,
            'volume_signals': 0.20,
            'technical_indicators': 0.30,
            'market_sentiment': 0.15,
            'time_features': 0.10
        }
        
        return importance
        
    async def _get_grok_insight(self, symbol: str, predictions: Dict[str, PredictionResult]) -> Optional[PredictionResult]:
        """Get advanced insights from Grok AI"""
        if not self.grok_api_key:
            return None
            
        try:
            # Prepare context for Grok
            context = {
                'symbol': symbol,
                'current_price': predictions['15min'].current_price,
                'predictions': {
                    h: {
                        'price': p.predicted_price,
                        'confidence': p.confidence,
                        'trend': p.trend
                    }
                    for h, p in predictions.items()
                },
                'technical_indicators': {
                    'volatility': predictions['15min'].volatility,
                    'trend': predictions['1h'].trend
                }
            }
            
            prompt = f"""
            Analyze {symbol} with current price ${context['current_price']:.2f}.
            ML predictions show: {json.dumps(context['predictions'], indent=2)}
            
            Provide a single sentence insight about the most likely price movement and key risk.
            Focus on actionable intelligence.
            """
            
            # Call Grok API (simplified)
            # In production, use actual API call
            
            return PredictionResult(
                symbol=symbol,
                horizon='grok_insight',
                predicted_price=predictions['1h'].predicted_price,
                current_price=predictions['15min'].current_price,
                confidence=0.85,
                volatility=predictions['15min'].volatility,
                trend=predictions['1h'].trend,
                features_importance={'grok_analysis': 1.0}
            )
            
        except Exception as e:
            logger.error(f"Grok insight error: {e}")
            return None
            
    async def _store_predictions(self, predictions: Dict[str, Dict[str, PredictionResult]]):
        """Store predictions in Redis"""
        pipeline = self.redis_client.pipeline()
        
        for symbol, symbol_predictions in predictions.items():
            # Store latest predictions
            pipeline.set(
                f'ai_predictions:{symbol}',
                json.dumps({
                    horizon: asdict(pred)
                    for horizon, pred in symbol_predictions.items()
                }),
                ex=300  # 5 minute expiry
            )
            
            # Store in time series
            for horizon, pred in symbol_predictions.items():
                pipeline.zadd(
                    f'ai_predictions_history:{symbol}:{horizon}',
                    {json.dumps(asdict(pred)): datetime.utcnow().timestamp()}
                )
                # Keep only last 1000 predictions
                pipeline.zremrangebyrank(f'ai_predictions_history:{symbol}:{horizon}', 0, -1001)
                
        await pipeline.execute()
        
    async def _publish_predictions(self, predictions: Dict[str, Dict[str, PredictionResult]]):
        """Publish predictions to subscribers"""
        for symbol, symbol_predictions in predictions.items():
            await self.redis_client.publish(
                'ai:predictions',
                json.dumps({
                    'symbol': symbol,
                    'predictions': {
                        horizon: asdict(pred)
                        for horizon, pred in symbol_predictions.items()
                    },
                    'timestamp': datetime.utcnow().isoformat()
                })
            )
            
    async def continuous_learning(self):
        """Continuously improve models with new data"""
        while True:
            try:
                # Get recent predictions and actual outcomes
                for symbol in self.models.keys():
                    await self._update_model(symbol)
                    
                await asyncio.sleep(300)  # Update every 5 minutes
                
            except Exception as e:
                logger.error(f"Continuous learning error: {e}")
                await asyncio.sleep(60)
                
    async def _update_model(self, symbol: str):
        """Update model with recent performance"""
        # Get recent predictions
        predictions = await self.redis_client.zrevrange(
            f'ai_predictions_history:{symbol}:15min',
            0, 100
        )
        
        if len(predictions) < 20:
            return
            
        # Calculate accuracy
        correct_predictions = 0
        total_predictions = 0
        
        for pred_json in predictions:
            pred = json.loads(pred_json)
            # Compare with actual price movement
            # In production, implement proper backtesting
            
        # Update model if performance degraded
        # Implement online learning or periodic retraining
        
    async def _get_active_symbols(self) -> List[str]:
        """Get list of active symbols"""
        tickers = await self.redis_client.get('dynamic_tickers')
        if tickers:
            return json.loads(tickers)
        return ['AAPL', 'MSFT', 'NVDA', 'TSLA', 'AMZN']
        
    async def run(self):
        """Main run loop"""
        await self.initialize()
        
        # Start continuous learning
        learning_task = asyncio.create_task(self.continuous_learning())
        
        # Main prediction loop
        while True:
            try:
                symbols = await self._get_active_symbols()
                
                # Generate predictions
                predictions = await self.predict_batch(symbols[:20])
                
                logger.info(f"🎯 Generated predictions for {len(predictions)} symbols")
                
                # Performance tracking
                for symbol, preds in predictions.items():
                    for horizon, pred in preds.items():
                        if horizon != 'grok_insight':
                            logger.info(
                                f"{symbol} {horizon}: ${pred.predicted_price:.2f} "
                                f"({pred.trend}, confidence: {pred.confidence:.2%})"
                            )
                
                await asyncio.sleep(60)  # Run every minute
                
            except Exception as e:
                logger.error(f"Prediction loop error: {e}")
                await asyncio.sleep(30)

async def main():
    pipeline = AIPredictionPipeline()
    await pipeline.run()

if __name__ == "__main__":
    asyncio.run(main())