#!/usr/bin/env python3
"""
Update Missing Backend Endpoints
Fügt fehlende Backend Response Keys hinzu, die das Frontend erwartet
"""
import os
import json
import redis
import logging
from datetime import datetime, timedelta
from typing import Dict, List, Any

logging.basicConfig(level=logging.INFO, format='[endpoint-updater] %(asctime)s %(levelname)s %(message)s')

REDIS_URL = os.getenv('REDIS_URL', 'redis://:pass123@redis:6379/0')
r = redis.from_url(REDIS_URL)

def update_grok_candidates():
    """Updates backend:grok_candidates from grok_topstocks_prediction"""
    try:
        # Get Grok predictions
        grok_data = r.get('grok_topstocks_prediction')
        if not grok_data:
            logging.warning("No grok_topstocks_prediction data found")
            return
        
        grok_predictions = json.loads(grok_data)
        candidates = []
        
        # Transform to frontend format
        for item in grok_predictions.get('items', []):
            ticker = item.get('ticker')
            if not ticker:
                continue
                
            # Get current price from market_data
            market_data = r.get('market_data')
            current_price = 100.0  # Default
            if market_data:
                market = json.loads(market_data)
                if ticker in market:
                    current_price = market[ticker].get('price', 100.0)
            
            expected_gain = item.get('expected_gain', 0.05)
            target_price = current_price * (1 + expected_gain)
            
            # Map sentiment to recommendation
            sentiment = item.get('sentiment', 0.5)
            if sentiment >= 0.8:
                recommendation = "STRONG_BUY"
            elif sentiment >= 0.6:
                recommendation = "BUY"
            elif sentiment >= 0.4:
                recommendation = "HOLD"
            elif sentiment >= 0.2:
                recommendation = "SELL"
            else:
                recommendation = "STRONG_SELL"
            
            candidates.append({
                'symbol': ticker,
                'score': sentiment,
                'recommendation': recommendation,
                'reason': item.get('reason', 'AI-based prediction'),
                'target_price': round(target_price, 2),
                'current_price': round(current_price, 2),
                'expected_return': expected_gain,
                'risk_level': 3 if expected_gain > 0.1 else 2,
                'confidence': max(0.7, min(0.95, sentiment + 0.1)),
                'time_horizon': '1D',
                'generated_at': datetime.utcnow().isoformat(),
                'expires_at': (datetime.utcnow() + timedelta(hours=24)).isoformat()
            })
        
        # Store in Redis
        r.set('backend:grok_candidates', json.dumps(candidates))
        logging.info(f"Updated backend:grok_candidates with {len(candidates)} candidates")
        
    except Exception as e:
        logging.error(f"Error updating grok_candidates: {e}")

def update_alerts_active():
    """Creates backend:alerts_active for frontend notifications"""
    try:
        alerts = []
        
        # Check system status for issues
        system_status = r.get('system_status')
        if system_status:
            status = json.loads(system_status)
            
            # Check API health
            if not status.get('finnhub_api_active'):
                alerts.append({
                    'alert_id': 'alert_finnhub_down',
                    'type': 'SYSTEM_ALERT',
                    'severity': 'WARNING',
                    'symbol': None,
                    'title': 'Finnhub API Offline',
                    'message': 'Finnhub data feed is currently unavailable',
                    'triggered_at': datetime.utcnow().isoformat(),
                    'acknowledged': False,
                    'auto_dismiss': True,
                    'expires_at': (datetime.utcnow() + timedelta(hours=1)).isoformat(),
                    'action_required': False
                })
            
            # Check market status
            if not status.get('market_open'):
                alerts.append({
                    'alert_id': 'alert_market_closed',
                    'type': 'SYSTEM_ALERT',
                    'severity': 'INFO',
                    'symbol': None,
                    'title': 'Market Closed',
                    'message': 'US Stock market is currently closed',
                    'triggered_at': datetime.utcnow().isoformat(),
                    'acknowledged': False,
                    'auto_dismiss': True,
                    'expires_at': (datetime.utcnow() + timedelta(hours=12)).isoformat(),
                    'action_required': False
                })
        
        # Check for large position changes
        portfolio_positions = r.get('portfolio_positions')
        if portfolio_positions:
            positions = json.loads(portfolio_positions)
            for pos in positions:
                if float(pos.get('unrealized_pl', 0)) < -1000:
                    alerts.append({
                        'alert_id': f'alert_loss_{pos["ticker"]}',
                        'type': 'PORTFOLIO_ALERT',
                        'severity': 'WARNING',
                        'symbol': pos['ticker'],
                        'title': f'Significant Loss on {pos["ticker"]}',
                        'message': f'{pos["ticker"]} position down ${abs(float(pos["unrealized_pl"]))}',
                        'triggered_at': datetime.utcnow().isoformat(),
                        'acknowledged': False,
                        'auto_dismiss': False,
                        'expires_at': (datetime.utcnow() + timedelta(days=1)).isoformat(),
                        'action_required': True
                    })
        
        # Add ML training status alert
        ml_status = r.get('ml_training_status')
        if ml_status:
            training = json.loads(ml_status)
            if training.get('active'):
                alerts.append({
                    'alert_id': 'alert_ml_training',
                    'type': 'SYSTEM_ALERT',
                    'severity': 'INFO',
                    'symbol': None,
                    'title': 'ML Model Training',
                    'message': f'ML model training in progress: {training.get("stage", "unknown")} ({int(training.get("progress", 0) * 100)}%)',
                    'triggered_at': datetime.utcnow().isoformat(),
                    'acknowledged': False,
                    'auto_dismiss': True,
                    'expires_at': (datetime.utcnow() + timedelta(hours=1)).isoformat(),
                    'action_required': False
                })
        
        # Store alerts
        r.set('backend:alerts_active', json.dumps(alerts))
        logging.info(f"Updated backend:alerts_active with {len(alerts)} alerts")
        
    except Exception as e:
        logging.error(f"Error updating alerts: {e}")

def fix_multi_api_enhanced_data():
    """Ensures multi_api_enhanced_data has all required fields"""
    try:
        data = r.get('multi_api_enhanced_data')
        if not data:
            logging.warning("No multi_api_enhanced_data found")
            return
        
        enhanced_data = json.loads(data)
        
        # Add missing fields to each ticker
        for ticker, info in enhanced_data.items():
            if 'market_cap' not in info:
                info['market_cap'] = None
            if 'pe_ratio' not in info:
                info['pe_ratio'] = None
            if 'primary_source' not in info:
                info['primary_source'] = 'unknown'
            if 'sources_count' not in info:
                info['sources_count'] = 1
            if 'sources_used' not in info:
                info['sources_used'] = [info.get('primary_source', 'unknown')]
        
        # Store updated data
        r.set('multi_api_enhanced_data', json.dumps(enhanced_data))
        logging.info(f"Fixed multi_api_enhanced_data for {len(enhanced_data)} tickers")
        
    except Exception as e:
        logging.error(f"Error fixing multi_api_enhanced_data: {e}")

def update_yfinance_fundamentals():
    """Ensures yfinance_enhanced data includes all fundamentals"""
    try:
        tickers = ['AAPL', 'MSFT', 'NVDA', 'TSLA', 'AMZN', 'GOOGL', 'META']
        
        for ticker in tickers:
            key = f'yfinance_enhanced:{ticker}'
            data = r.get(key)
            
            if not data:
                continue
                
            ticker_data = json.loads(data)
            
            # Ensure fundamentals section exists with all fields
            if 'fundamentals' not in ticker_data:
                ticker_data['fundamentals'] = {}
            
            fundamentals = ticker_data['fundamentals']
            
            # Add default values for missing fields
            defaults = {
                'market_cap': None,
                'pe_ratio': None,
                'peg_ratio': None,
                'price_to_book': None,
                'revenue_growth': None,
                'profit_margin': None,
                'operating_margin': None,
                'return_on_equity': None,
                'debt_to_equity': None,
                'current_ratio': None,
                'beta': 1.0,
                'fifty_two_week_high': None,
                'fifty_two_week_low': None,
                'dividend_yield': 0.0,
                'sector': 'Technology',
                'industry': 'Software'
            }
            
            for field, default_value in defaults.items():
                if field not in fundamentals:
                    fundamentals[field] = default_value
            
            # Store updated data
            r.set(key, json.dumps(ticker_data))
        
        logging.info(f"Updated fundamentals for {len(tickers)} tickers")
        
    except Exception as e:
        logging.error(f"Error updating yfinance fundamentals: {e}")

def main():
    """Run all endpoint updates"""
    logging.info("Starting endpoint updates...")
    
    # Update missing endpoints
    update_grok_candidates()
    update_alerts_active()
    fix_multi_api_enhanced_data()
    update_yfinance_fundamentals()
    
    logging.info("Endpoint updates completed")

if __name__ == "__main__":
    main()