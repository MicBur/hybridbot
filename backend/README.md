# QBot Trading Backend

🤖 **Multi-Horizon ML Trading System** with Real-time Market Data Integration

## Features

### 🧠 Machine Learning
- **AutoGluon Multi-Horizon Models**: 15min, 30min, 60min prediction horizons
- **Automatic Retraining**: Triggers when prediction deviation >8%
- **Model Types**: LightGBM, XGBoost, CatBoost, Neural Networks, Ensemble Methods
- **Performance Tracking**: MAE, MAPE, R² metrics with historical tracking

### 📊 Multi-API Data Integration
- **Finnhub** ✅ (Primary): Real-time market data
- **TwelveData** ✅ (Secondary): Enhanced market coverage  
- **FMP** ⚡ (Available): Financial fundamentals
- **Marketstack** ⚡ (Available): Additional market data
- **Cross-Validation**: Data quality through source comparison

### 💰 Trading Engine
- **Alpaca API**: Real-time trading execution
- **Risk Management**: Daily caps, position limits, cooldowns
- **Market Hours Safety**: Auto-stop during market closure
- **Trade Logging**: Comprehensive trade history and analytics

### 🏗️ Architecture
- **Docker Containerized**: Redis, PostgreSQL, Python Worker
- **Celery Tasks**: Scheduled data fetching, ML training, trading
- **Real-time Communication**: Redis pub/sub for frontend integration
- **Comprehensive Monitoring**: System health, API status, performance metrics

## Quick Start

```bash
# 1. Setup environment
cp .env.example .env
# Edit .env with your API keys

# 2. Start services
docker-compose up -d

# 3. Check system status
docker-compose logs -f worker
```

## API Documentation

See `redis-endpoints.txt` for complete Redis API documentation including:
- Trading controls and status
- ML model metrics and predictions  
- Market data and analytics
- System monitoring endpoints

## ML Model Performance

Current model metrics (example):
```json
{
  "15min": {"mae": 148.42, "mape": 1.93, "r2": 0.85},
  "30min": {"mae": 156.78, "mape": 2.14, "r2": 0.82}, 
  "60min": {"mae": 165.23, "mape": 2.45, "r2": 0.79}
}
```

## System Requirements

- Docker & Docker Compose
- 4GB+ RAM (for AutoGluon ML models)
- API keys for market data and trading services

## Development

```bash
# Install dependencies
pip install -r requirements.txt

# Run worker locally
python worker.py

# Run specific ML training
docker exec qbot-worker-1 python -c "from worker import train_model; train_model.delay('manual')"
```

## Architecture Diagram

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Market APIs   │    │   ML Training   │    │   Trading API   │
│  Finnhub/Twelve│────│   AutoGluon     │────│   Alpaca API    │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         └───────────────────────┼───────────────────────┘
                                 │
                    ┌─────────────────┐
                    │  Redis + Postgres│
                    │   Data Layer     │
                    └─────────────────┘
                                 │
                    ┌─────────────────┐
                    │  Worker Process │
                    │   (Celery)      │
                    └─────────────────┘
```

## License

MIT License - See LICENSE file for details.
