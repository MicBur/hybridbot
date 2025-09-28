#!/usr/bin/env python3
"""
📊 REAL-TIME ANALYTICS ENGINE
Advanced analytics with streaming metrics, ML insights, and predictive analytics
"""
import asyncio
import json
import numpy as np
import pandas as pd
from datetime import datetime, timedelta
import redis.asyncio as redis
from typing import Dict, List, Any, Optional, Tuple
import logging
from dataclasses import dataclass, field, asdict
from collections import defaultdict, deque
import statistics
from sklearn.linear_model import LinearRegression
from scipy import stats
import warnings
warnings.filterwarnings('ignore')

logging.basicConfig(
    level=logging.INFO,
    format='[%(asctime)s] %(levelname)s [%(name)s] %(message)s'
)
logger = logging.getLogger('Analytics')

@dataclass
class MetricPoint:
    timestamp: datetime
    value: float
    metadata: Dict[str, Any] = field(default_factory=dict)

@dataclass 
class AnalyticsResult:
    metric_name: str
    current_value: float
    trend: str  # up, down, stable
    change_1h: float
    change_24h: float
    volatility: float
    forecast_1h: float
    confidence: float
    anomaly_score: float
    insights: List[str] = field(default_factory=list)
    
class StreamingMetrics:
    """Handles streaming calculation of metrics"""
    def __init__(self, window_size: int = 1000):
        self.window_size = window_size
        self.data_points = defaultdict(lambda: deque(maxlen=window_size))
        self.aggregates = defaultdict(dict)
        
    def add_point(self, metric: str, value: float, timestamp: Optional[datetime] = None):
        """Add a data point to the stream"""
        if timestamp is None:
            timestamp = datetime.utcnow()
            
        point = MetricPoint(timestamp, value)
        self.data_points[metric].append(point)
        
        # Update aggregates
        self._update_aggregates(metric)
        
    def _update_aggregates(self, metric: str):
        """Update aggregate statistics"""
        points = self.data_points[metric]
        if not points:
            return
            
        values = [p.value for p in points]
        
        self.aggregates[metric] = {
            'count': len(values),
            'mean': statistics.mean(values),
            'std': statistics.stdev(values) if len(values) > 1 else 0,
            'min': min(values),
            'max': max(values),
            'p25': np.percentile(values, 25),
            'p50': np.percentile(values, 50),
            'p75': np.percentile(values, 75),
            'p95': np.percentile(values, 95),
            'p99': np.percentile(values, 99)
        }
        
    def get_stats(self, metric: str) -> Dict[str, float]:
        """Get current statistics for a metric"""
        return self.aggregates.get(metric, {})

class RealTimeAnalytics:
    def __init__(self, redis_url: str = 'redis://:pass123@localhost:6379/0'):
        self.redis_url = redis_url
        self.redis_client: Optional[redis.Redis] = None
        self.streaming_metrics = StreamingMetrics()
        self.anomaly_detectors = {}
        self.forecasters = {}
        self.performance_trackers = defaultdict(lambda: {
            'trades': [],
            'positions': [],
            'pnl_curve': [],
            'risk_metrics': []
        })
        
    async def initialize(self):
        """Initialize analytics engine"""
        logger.info("📊 Initializing Real-Time Analytics Engine...")
        
        # Redis connection
        self.redis_client = await redis.from_url(self.redis_url)
        
        # Initialize ML models
        await self._init_ml_models()
        
        # Start metric collectors
        await self._start_metric_collectors()
        
        logger.info("✅ Analytics Engine initialized")
        
    async def _init_ml_models(self):
        """Initialize ML models for analytics"""
        # Initialize anomaly detection models
        self.anomaly_detectors = {
            'price': IsolationForestDetector(),
            'volume': ZScoreDetector(threshold=3),
            'volatility': MADDetector(),
            'orders': QuantileDetector()
        }
        
        # Initialize forecasting models
        self.forecasters = {
            'short_term': ARIMAForecaster(horizon=60),  # 1 hour
            'medium_term': ProphetForecaster(horizon=1440),  # 24 hours
            'long_term': LSTMForecaster(horizon=10080)  # 1 week
        }
        
    async def analyze_trading_performance(self) -> Dict[str, Any]:
        """Comprehensive trading performance analysis"""
        # Get trading data
        trades = await self._get_trades_data()
        positions = await self._get_positions_data()
        
        if not trades:
            return {'status': 'no_data'}
            
        # Calculate performance metrics
        metrics = {
            'returns': self._calculate_returns(trades),
            'risk_metrics': self._calculate_risk_metrics(trades, positions),
            'efficiency': self._calculate_efficiency_metrics(trades),
            'behavioral': self._analyze_trading_behavior(trades),
            'optimization': self._suggest_optimizations(trades, positions)
        }
        
        # Generate insights
        insights = await self._generate_insights(metrics)
        
        # Store results
        await self._store_analytics_results({
            'timestamp': datetime.utcnow().isoformat(),
            'metrics': metrics,
            'insights': insights
        })
        
        return {
            'performance_score': self._calculate_performance_score(metrics),
            'metrics': metrics,
            'insights': insights,
            'recommendations': self._generate_recommendations(metrics)
        }
        
    def _calculate_returns(self, trades: List[Dict]) -> Dict[str, Any]:
        """Calculate return metrics"""
        if not trades:
            return {}
            
        # Extract P&L data
        pnl_values = [float(t.get('pnl', 0)) for t in trades if t.get('pnl')]
        
        if not pnl_values:
            return {}
            
        # Calculate returns
        total_pnl = sum(pnl_values)
        winning_trades = [p for p in pnl_values if p > 0]
        losing_trades = [p for p in pnl_values if p < 0]
        
        # Time-weighted returns
        daily_returns = self._calculate_daily_returns(trades)
        
        # Sharpe ratio
        sharpe = self._calculate_sharpe_ratio(daily_returns)
        
        # Sortino ratio (downside deviation)
        sortino = self._calculate_sortino_ratio(daily_returns)
        
        # Calmar ratio (return / max drawdown)
        calmar = self._calculate_calmar_ratio(daily_returns, total_pnl)
        
        return {
            'total_pnl': total_pnl,
            'win_rate': len(winning_trades) / len(pnl_values) if pnl_values else 0,
            'average_win': statistics.mean(winning_trades) if winning_trades else 0,
            'average_loss': statistics.mean(losing_trades) if losing_trades else 0,
            'profit_factor': abs(sum(winning_trades) / sum(losing_trades)) if losing_trades else float('inf'),
            'sharpe_ratio': sharpe,
            'sortino_ratio': sortino,
            'calmar_ratio': calmar,
            'max_consecutive_wins': self._max_consecutive(pnl_values, lambda x: x > 0),
            'max_consecutive_losses': self._max_consecutive(pnl_values, lambda x: x < 0),
            'expectancy': total_pnl / len(pnl_values) if pnl_values else 0
        }
        
    def _calculate_risk_metrics(self, trades: List[Dict], positions: List[Dict]) -> Dict[str, Any]:
        """Calculate risk metrics"""
        # Portfolio metrics
        position_values = [float(p.get('market_value', 0)) for p in positions]
        total_value = sum(position_values)
        
        # Value at Risk (VaR)
        returns = self._calculate_daily_returns(trades)
        var_95 = self._calculate_var(returns, 0.95)
        var_99 = self._calculate_var(returns, 0.99)
        
        # Conditional VaR (CVaR)
        cvar_95 = self._calculate_cvar(returns, 0.95)
        
        # Maximum drawdown
        max_dd, dd_duration = self._calculate_max_drawdown(trades)
        
        # Position concentration
        concentration = self._calculate_concentration(position_values, total_value)
        
        # Beta calculation (market correlation)
        beta = self._calculate_portfolio_beta(trades)
        
        return {
            'var_95': var_95,
            'var_99': var_99,
            'cvar_95': cvar_95,
            'max_drawdown': max_dd,
            'max_drawdown_duration_days': dd_duration,
            'position_concentration': concentration,
            'portfolio_beta': beta,
            'risk_adjusted_return': self._calculate_risk_adjusted_return(trades),
            'downside_deviation': self._calculate_downside_deviation(returns),
            'ulcer_index': self._calculate_ulcer_index(trades)
        }
        
    def _calculate_efficiency_metrics(self, trades: List[Dict]) -> Dict[str, Any]:
        """Calculate trading efficiency metrics"""
        # Trade timing analysis
        entry_efficiency = self._analyze_entry_efficiency(trades)
        exit_efficiency = self._analyze_exit_efficiency(trades)
        
        # Slippage analysis
        slippage_stats = self._analyze_slippage(trades)
        
        # Trade duration analysis
        durations = self._analyze_trade_durations(trades)
        
        return {
            'entry_efficiency': entry_efficiency,
            'exit_efficiency': exit_efficiency,
            'average_slippage_bps': slippage_stats['average'],
            'slippage_cost': slippage_stats['total_cost'],
            'average_trade_duration_minutes': durations['average'],
            'optimal_trade_duration': durations['optimal'],
            'trade_velocity': len(trades) / max(durations['total_days'], 1),
            'win_loss_ratio': self._calculate_win_loss_ratio(trades)
        }
        
    def _analyze_trading_behavior(self, trades: List[Dict]) -> Dict[str, Any]:
        """Analyze trading patterns and behavior"""
        # Time-based patterns
        hourly_distribution = self._analyze_hourly_pattern(trades)
        daily_distribution = self._analyze_daily_pattern(trades)
        
        # Symbol preferences
        symbol_stats = self._analyze_symbol_preferences(trades)
        
        # Strategy performance
        strategy_stats = self._analyze_strategy_performance(trades)
        
        # Emotional indicators
        emotion_indicators = self._detect_emotional_trading(trades)
        
        return {
            'most_active_hours': hourly_distribution['peak_hours'],
            'most_profitable_hours': hourly_distribution['profitable_hours'],
            'weekly_pattern': daily_distribution,
            'favorite_symbols': symbol_stats['top_symbols'],
            'most_profitable_symbols': symbol_stats['profitable_symbols'],
            'strategy_performance': strategy_stats,
            'overtrading_score': emotion_indicators['overtrading'],
            'revenge_trading_score': emotion_indicators['revenge_trading'],
            'consistency_score': self._calculate_consistency_score(trades)
        }
        
    async def stream_market_analytics(self, symbol: str) -> Dict[str, Any]:
        """Real-time market analytics for a symbol"""
        # Get market data
        market_data = await self._get_market_data(symbol)
        
        if not market_data:
            return {'status': 'no_data'}
            
        # Add to streaming metrics
        self.streaming_metrics.add_point(f'{symbol}_price', market_data['price'])
        self.streaming_metrics.add_point(f'{symbol}_volume', market_data['volume'])
        
        # Get current stats
        price_stats = self.streaming_metrics.get_stats(f'{symbol}_price')
        volume_stats = self.streaming_metrics.get_stats(f'{symbol}_volume')
        
        # Detect anomalies
        price_anomaly = self.anomaly_detectors['price'].detect(
            market_data['price'], 
            price_stats
        )
        volume_anomaly = self.anomaly_detectors['volume'].detect(
            market_data['volume'],
            volume_stats
        )
        
        # Generate forecasts
        price_forecast = await self.forecasters['short_term'].forecast(
            f'{symbol}_price',
            self.streaming_metrics.data_points[f'{symbol}_price']
        )
        
        # Technical analysis
        technical_signals = self._calculate_technical_signals(
            self.streaming_metrics.data_points[f'{symbol}_price']
        )
        
        # Market microstructure
        microstructure = self._analyze_microstructure(market_data)
        
        return {
            'symbol': symbol,
            'current_price': market_data['price'],
            'price_stats': price_stats,
            'volume_stats': volume_stats,
            'anomalies': {
                'price_anomaly': price_anomaly,
                'volume_anomaly': volume_anomaly
            },
            'forecast': price_forecast,
            'technical_signals': technical_signals,
            'microstructure': microstructure,
            'market_quality': self._assess_market_quality(market_data, price_stats)
        }
        
    def _calculate_technical_signals(self, price_data: deque) -> Dict[str, Any]:
        """Calculate technical analysis signals"""
        if len(price_data) < 20:
            return {}
            
        prices = [p.value for p in price_data]
        
        # Moving averages
        sma_20 = statistics.mean(prices[-20:])
        sma_50 = statistics.mean(prices[-50:]) if len(prices) >= 50 else sma_20
        
        # RSI
        rsi = self._calculate_rsi_from_prices(prices)
        
        # MACD
        macd, signal = self._calculate_macd(prices)
        
        # Bollinger Bands
        bb_upper, bb_lower = self._calculate_bollinger_bands(prices)
        
        # Support/Resistance levels
        support, resistance = self._find_support_resistance(prices)
        
        return {
            'trend': 'bullish' if prices[-1] > sma_20 else 'bearish',
            'strength': abs(prices[-1] - sma_20) / sma_20,
            'sma_20': sma_20,
            'sma_50': sma_50,
            'rsi': rsi,
            'macd': macd,
            'macd_signal': signal,
            'bb_position': (prices[-1] - bb_lower) / (bb_upper - bb_lower),
            'support_level': support,
            'resistance_level': resistance,
            'pivot_points': self._calculate_pivot_points(prices)
        }
        
    async def generate_analytics_dashboard(self) -> Dict[str, Any]:
        """Generate comprehensive analytics dashboard data"""
        # Performance analytics
        performance = await self.analyze_trading_performance()
        
        # Market analytics for top symbols
        market_analytics = {}
        symbols = await self._get_active_symbols()
        
        for symbol in symbols[:5]:  # Top 5 symbols
            market_analytics[symbol] = await self.stream_market_analytics(symbol)
            
        # System analytics
        system_metrics = await self._get_system_analytics()
        
        # Risk dashboard
        risk_dashboard = await self._generate_risk_dashboard()
        
        # Predictive analytics
        predictions = await self._generate_predictive_analytics()
        
        return {
            'timestamp': datetime.utcnow().isoformat(),
            'performance': performance,
            'market': market_analytics,
            'system': system_metrics,
            'risk': risk_dashboard,
            'predictions': predictions,
            'alerts': await self._generate_analytics_alerts(
                performance, market_analytics, risk_dashboard
            )
        }
        
    async def _generate_predictive_analytics(self) -> Dict[str, Any]:
        """Generate predictive analytics"""
        predictions = {
            'market_regime': await self._predict_market_regime(),
            'volatility_forecast': await self._forecast_volatility(),
            'profit_probability': await self._predict_profit_probability(),
            'optimal_position_size': await self._calculate_optimal_position_sizing(),
            'risk_events': await self._predict_risk_events()
        }
        
        return predictions
        
    async def _predict_market_regime(self) -> Dict[str, Any]:
        """Predict current and future market regime"""
        # Get market data
        market_data = await self._get_broad_market_data()
        
        # Analyze regime indicators
        volatility = self._calculate_market_volatility(market_data)
        trend_strength = self._calculate_trend_strength(market_data)
        correlation = self._calculate_cross_asset_correlation(market_data)
        
        # Classify regime
        if volatility > 0.25:
            regime = 'high_volatility'
        elif trend_strength > 0.7:
            regime = 'trending'
        elif correlation > 0.8:
            regime = 'risk_on'
        else:
            regime = 'range_bound'
            
        return {
            'current_regime': regime,
            'confidence': 0.85,
            'indicators': {
                'volatility': volatility,
                'trend_strength': trend_strength,
                'correlation': correlation
            },
            'regime_change_probability': self._calculate_regime_change_prob(market_data),
            'recommended_strategies': self._recommend_strategies_for_regime(regime)
        }
        
    def _calculate_performance_score(self, metrics: Dict[str, Any]) -> float:
        """Calculate overall performance score (0-100)"""
        weights = {
            'sharpe_ratio': 0.25,
            'win_rate': 0.20,
            'profit_factor': 0.15,
            'consistency': 0.15,
            'risk_management': 0.15,
            'efficiency': 0.10
        }
        
        scores = {
            'sharpe_ratio': min(100, max(0, metrics['returns'].get('sharpe_ratio', 0) * 33.33)),
            'win_rate': metrics['returns'].get('win_rate', 0) * 100,
            'profit_factor': min(100, metrics['returns'].get('profit_factor', 0) * 20),
            'consistency': metrics['behavioral'].get('consistency_score', 0) * 100,
            'risk_management': 100 - (metrics['risk_metrics'].get('max_drawdown', 0) * 200),
            'efficiency': metrics['efficiency'].get('entry_efficiency', 0) * 100
        }
        
        total_score = sum(scores[key] * weights[key] for key in weights)
        
        return round(total_score, 2)
        
    def _generate_recommendations(self, metrics: Dict[str, Any]) -> List[Dict[str, Any]]:
        """Generate actionable recommendations"""
        recommendations = []
        
        # Check win rate
        win_rate = metrics['returns'].get('win_rate', 0)
        if win_rate < 0.4:
            recommendations.append({
                'category': 'strategy',
                'priority': 'high',
                'title': 'Improve Win Rate',
                'description': f'Your win rate is {win_rate:.1%}. Consider refining entry criteria.',
                'action': 'Review losing trades and identify common patterns'
            })
            
        # Check risk metrics
        max_dd = metrics['risk_metrics'].get('max_drawdown', 0)
        if max_dd > 0.15:
            recommendations.append({
                'category': 'risk',
                'priority': 'critical',
                'title': 'Reduce Maximum Drawdown',
                'description': f'Max drawdown of {max_dd:.1%} is too high.',
                'action': 'Implement stricter stop-loss rules and position sizing'
            })
            
        # Check efficiency
        slippage = metrics['efficiency'].get('average_slippage_bps', 0)
        if slippage > 5:
            recommendations.append({
                'category': 'execution',
                'priority': 'medium',
                'title': 'Reduce Slippage',
                'description': f'Average slippage of {slippage} bps is impacting returns.',
                'action': 'Use limit orders or improve execution timing'
            })
            
        return recommendations
        
    # Helper methods
    async def _get_trades_data(self) -> List[Dict]:
        """Get recent trades data"""
        trades = await self.redis_client.get('trades_log')
        return json.loads(trades) if trades else []
        
    async def _get_positions_data(self) -> List[Dict]:
        """Get current positions"""
        positions = await self.redis_client.get('portfolio_positions')
        return json.loads(positions) if positions else []
        
    async def _get_market_data(self, symbol: str) -> Optional[Dict]:
        """Get market data for symbol"""
        data = await self.redis_client.get(f'market_data:{symbol}')
        return json.loads(data) if data else None
        
    def _calculate_sharpe_ratio(self, returns: List[float], risk_free_rate: float = 0.02) -> float:
        """Calculate Sharpe ratio"""
        if not returns or len(returns) < 2:
            return 0.0
            
        excess_returns = [r - risk_free_rate/252 for r in returns]  # Daily risk-free rate
        
        if all(r == 0 for r in excess_returns):
            return 0.0
            
        return (statistics.mean(excess_returns) * 252) / (statistics.stdev(excess_returns) * np.sqrt(252))
        
    def _calculate_max_drawdown(self, trades: List[Dict]) -> Tuple[float, int]:
        """Calculate maximum drawdown and duration"""
        if not trades:
            return 0.0, 0
            
        # Build equity curve
        equity_curve = []
        cumulative_pnl = 0
        
        for trade in sorted(trades, key=lambda x: x.get('time', '')):
            cumulative_pnl += float(trade.get('pnl', 0))
            equity_curve.append({
                'timestamp': trade.get('time'),
                'value': cumulative_pnl
            })
            
        if not equity_curve:
            return 0.0, 0
            
        # Calculate drawdowns
        peak = equity_curve[0]['value']
        max_dd = 0
        max_duration = 0
        current_dd_start = None
        
        for point in equity_curve:
            if point['value'] > peak:
                peak = point['value']
                current_dd_start = None
            else:
                drawdown = (peak - point['value']) / peak if peak > 0 else 0
                if drawdown > max_dd:
                    max_dd = drawdown
                    
                if current_dd_start is None:
                    current_dd_start = point['timestamp']
                    
        return max_dd, max_duration
        
    async def _store_analytics_results(self, results: Dict[str, Any]):
        """Store analytics results in Redis"""
        await self.redis_client.set(
            'analytics:latest',
            json.dumps(results),
            ex=3600  # 1 hour expiry
        )
        
        # Add to time series
        await self.redis_client.zadd(
            'analytics:history',
            {json.dumps(results): datetime.utcnow().timestamp()}
        )
        
        # Keep only last 1000 entries
        await self.redis_client.zremrangebyrank('analytics:history', 0, -1001)

# Anomaly Detection Classes
class IsolationForestDetector:
    """Isolation Forest for anomaly detection"""
    def detect(self, value: float, stats: Dict[str, float]) -> Dict[str, Any]:
        # Simplified implementation
        if not stats:
            return {'is_anomaly': False, 'score': 0}
            
        z_score = abs(value - stats['mean']) / stats['std'] if stats['std'] > 0 else 0
        
        return {
            'is_anomaly': z_score > 3,
            'score': min(z_score / 3, 1.0),
            'severity': 'high' if z_score > 4 else 'medium' if z_score > 3 else 'low'
        }

class ZScoreDetector:
    """Z-score based anomaly detection"""
    def __init__(self, threshold: float = 3):
        self.threshold = threshold
        
    def detect(self, value: float, stats: Dict[str, float]) -> Dict[str, Any]:
        if not stats or stats['std'] == 0:
            return {'is_anomaly': False, 'score': 0}
            
        z_score = abs(value - stats['mean']) / stats['std']
        
        return {
            'is_anomaly': z_score > self.threshold,
            'score': min(z_score / self.threshold, 1.0),
            'z_score': z_score
        }

class MADDetector:
    """Median Absolute Deviation detector"""
    def detect(self, value: float, stats: Dict[str, float]) -> Dict[str, Any]:
        # Implementation using median absolute deviation
        return {'is_anomaly': False, 'score': 0}  # Simplified

class QuantileDetector:
    """Quantile-based anomaly detection"""
    def detect(self, value: float, stats: Dict[str, float]) -> Dict[str, Any]:
        if not stats:
            return {'is_anomaly': False, 'score': 0}
            
        # Check if value is outside 99th percentile
        is_anomaly = value < stats.get('p1', 0) or value > stats.get('p99', float('inf'))
        
        return {
            'is_anomaly': is_anomaly,
            'score': 1.0 if is_anomaly else 0.0,
            'percentile': self._calculate_percentile(value, stats)
        }
        
    def _calculate_percentile(self, value: float, stats: Dict[str, float]) -> float:
        # Simplified percentile calculation
        if value <= stats.get('min', 0):
            return 0.0
        elif value >= stats.get('max', 0):
            return 100.0
        else:
            return 50.0  # Simplified

# Forecasting Classes
class ARIMAForecaster:
    """ARIMA-based forecasting"""
    def __init__(self, horizon: int):
        self.horizon = horizon
        
    async def forecast(self, metric: str, data: deque) -> Dict[str, Any]:
        if len(data) < 20:
            return {'status': 'insufficient_data'}
            
        values = [p.value for p in data]
        
        # Simplified linear forecast
        x = np.arange(len(values))
        y = np.array(values)
        
        model = LinearRegression()
        model.fit(x.reshape(-1, 1), y)
        
        # Forecast
        future_x = len(values) + self.horizon // 60  # Convert minutes to points
        forecast_value = model.predict([[future_x]])[0]
        
        # Calculate confidence
        residuals = y - model.predict(x.reshape(-1, 1))
        std_error = np.std(residuals)
        
        return {
            'metric': metric,
            'horizon': f'{self.horizon}min',
            'forecast': forecast_value,
            'confidence_interval': {
                'lower': forecast_value - 2 * std_error,
                'upper': forecast_value + 2 * std_error
            },
            'trend': 'up' if model.coef_[0] > 0 else 'down',
            'strength': abs(model.coef_[0])
        }

class ProphetForecaster:
    """Prophet-based forecasting for medium term"""
    def __init__(self, horizon: int):
        self.horizon = horizon
        
    async def forecast(self, metric: str, data: deque) -> Dict[str, Any]:
        # Simplified implementation
        return {'status': 'not_implemented'}

class LSTMForecaster:
    """LSTM neural network for long-term forecasting"""
    def __init__(self, horizon: int):
        self.horizon = horizon
        
    async def forecast(self, metric: str, data: deque) -> Dict[str, Any]:
        # Simplified implementation
        return {'status': 'not_implemented'}

# Main execution
async def main():
    """Main entry point"""
    analytics = RealTimeAnalytics()
    await analytics.initialize()
    
    # Generate initial dashboard
    dashboard = await analytics.generate_analytics_dashboard()
    logger.info(f"📊 Analytics Dashboard: {json.dumps(dashboard, indent=2)}")
    
    # Run continuous analytics
    while True:
        try:
            # Update analytics every minute
            await asyncio.sleep(60)
            
            # Analyze performance
            performance = await analytics.analyze_trading_performance()
            logger.info(f"Performance Score: {performance.get('performance_score', 0)}/100")
            
            # Stream market analytics
            symbols = ['AAPL', 'MSFT', 'NVDA']
            for symbol in symbols:
                market_analytics = await analytics.stream_market_analytics(symbol)
                if market_analytics.get('anomalies', {}).get('price_anomaly', {}).get('is_anomaly'):
                    logger.warning(f"⚠️ Price anomaly detected for {symbol}")
                    
        except Exception as e:
            logger.error(f"Analytics error: {e}")
            await asyncio.sleep(5)

if __name__ == "__main__":
    asyncio.run(main())