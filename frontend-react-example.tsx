// 🚀 Modern React Trading Dashboard Example
// This shows how to connect to the new dynamic backend

import React, { useState, useEffect, useCallback } from 'react';
import { Line, Bar } from 'react-chartjs-2';
import { useQuery, useSubscription, gql } from '@apollo/client';
import { w3cwebsocket as W3CWebSocket } from 'websocket';

// GraphQL Queries
const MARKET_DATA_QUERY = gql`
  query GetMarketData($symbols: [String!]!) {
    marketData(symbols: $symbols) {
      symbol
      price
      change
      changePct
      volume
      timestamp
    }
  }
`;

const POSITIONS_QUERY = gql`
  query GetPositions {
    positions {
      symbol
      quantity
      avgPrice
      currentPrice
      marketValue
      unrealizedPnl
      unrealizedPnlPct
    }
  }
`;

// GraphQL Subscriptions
const MARKET_UPDATES_SUBSCRIPTION = gql`
  subscription MarketUpdates($symbols: [String!]!) {
    marketUpdates(symbols: $symbols) {
      symbol
      price
      bid
      ask
      volume
      timestamp
    }
  }
`;

const SIGNAL_STREAM_SUBSCRIPTION = gql`
  subscription SignalStream {
    signalStream {
      symbol
      action
      strength
      confidence
      strategy
      reason
      targetPrice
      stopLoss
      timestamp
    }
  }
`;

// WebSocket connection for real-time data
const createWebSocket = (channel: string) => {
  return new W3CWebSocket(`ws://localhost:8000/ws/${channel}`);
};

// Main Dashboard Component
const TradingDashboard: React.FC = () => {
  const [selectedSymbols, setSelectedSymbols] = useState(['AAPL', 'MSFT', 'NVDA']);
  const [tradingEnabled, setTradingEnabled] = useState(false);
  const [realtimeData, setRealtimeData] = useState<any>({});
  const [signals, setSignals] = useState<any[]>([]);
  const [performance, setPerformance] = useState<any>(null);

  // GraphQL queries
  const { data: marketData, loading: marketLoading } = useQuery(MARKET_DATA_QUERY, {
    variables: { symbols: selectedSymbols },
    pollInterval: 5000
  });

  const { data: positionsData } = useQuery(POSITIONS_QUERY, {
    pollInterval: 10000
  });

  // GraphQL subscriptions
  useSubscription(MARKET_UPDATES_SUBSCRIPTION, {
    variables: { symbols: selectedSymbols },
    onSubscriptionData: ({ subscriptionData }) => {
      const update = subscriptionData.data?.marketUpdates;
      if (update) {
        setRealtimeData(prev => ({
          ...prev,
          [update.symbol]: update
        }));
      }
    }
  });

  useSubscription(SIGNAL_STREAM_SUBSCRIPTION, {
    onSubscriptionData: ({ subscriptionData }) => {
      const signal = subscriptionData.data?.signalStream;
      if (signal) {
        setSignals(prev => [signal, ...prev].slice(0, 50));
      }
    }
  });

  // WebSocket connections
  useEffect(() => {
    const marketWs = createWebSocket('market');
    const portfolioWs = createWebSocket('portfolio');
    const systemWs = createWebSocket('system');

    marketWs.onmessage = (message) => {
      const data = JSON.parse(message.data);
      if (data.type === 'market_update') {
        // Handle market updates
      }
    };

    portfolioWs.onmessage = (message) => {
      const data = JSON.parse(message.data);
      if (data.type === 'portfolio_update') {
        setPerformance(data.data);
      }
    };

    return () => {
      marketWs.close();
      portfolioWs.close();
      systemWs.close();
    };
  }, []);

  // Trading controls
  const toggleTrading = async () => {
    const action = tradingEnabled ? 'stop' : 'start';
    const response = await fetch(`http://localhost:8000/api/v1/trading/${action}`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer YOUR_TOKEN'
      }
    });
    
    if (response.ok) {
      setTradingEnabled(!tradingEnabled);
    }
  };

  // Place order
  const placeOrder = async (symbol: string, side: 'BUY' | 'SELL', quantity: number) => {
    const response = await fetch('http://localhost:8000/api/v1/orders', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer YOUR_TOKEN'
      },
      body: JSON.stringify({
        symbol,
        side,
        quantity,
        order_type: 'MARKET'
      })
    });

    const result = await response.json();
    console.log('Order placed:', result);
  };

  return (
    <div className="trading-dashboard">
      {/* Header */}
      <header className="dashboard-header">
        <h1>🚀 QBot Dynamic Trading System</h1>
        <div className="trading-controls">
          <button 
            className={`trading-toggle ${tradingEnabled ? 'active' : ''}`}
            onClick={toggleTrading}
          >
            {tradingEnabled ? '⏸️ Stop Trading' : '▶️ Start Trading'}
          </button>
        </div>
      </header>

      {/* Market Overview */}
      <section className="market-overview">
        <h2>📊 Market Overview</h2>
        <div className="market-grid">
          {marketData?.marketData.map((item: any) => (
            <MarketCard key={item.symbol} data={item} realtime={realtimeData[item.symbol]} />
          ))}
        </div>
      </section>

      {/* Portfolio Performance */}
      <section className="portfolio-section">
        <h2>💼 Portfolio Performance</h2>
        {performance && <PerformanceChart data={performance} />}
        <PositionsTable positions={positionsData?.positions || []} />
      </section>

      {/* Trading Signals */}
      <section className="signals-section">
        <h2>📡 Live Trading Signals</h2>
        <SignalsStream signals={signals} onTrade={placeOrder} />
      </section>

      {/* Analytics Dashboard */}
      <section className="analytics-section">
        <h2>📈 Real-Time Analytics</h2>
        <AnalyticsDashboard />
      </section>
    </div>
  );
};

// Market Card Component
const MarketCard: React.FC<{ data: any; realtime?: any }> = ({ data, realtime }) => {
  const currentData = realtime || data;
  const isPositive = currentData.change >= 0;

  return (
    <div className="market-card">
      <div className="symbol">{currentData.symbol}</div>
      <div className="price">${currentData.price.toFixed(2)}</div>
      <div className={`change ${isPositive ? 'positive' : 'negative'}`}>
        {isPositive ? '▲' : '▼'} {Math.abs(currentData.changePct).toFixed(2)}%
      </div>
      <div className="volume">Vol: {(currentData.volume / 1000000).toFixed(2)}M</div>
    </div>
  );
};

// Performance Chart Component
const PerformanceChart: React.FC<{ data: any }> = ({ data }) => {
  const chartData = {
    labels: ['1H', '1D', '1W', '1M', 'YTD'],
    datasets: [{
      label: 'Portfolio Performance',
      data: [0.5, 2.3, 5.1, 8.7, 15.2],
      borderColor: 'rgb(75, 192, 192)',
      backgroundColor: 'rgba(75, 192, 192, 0.2)',
      tension: 0.1
    }]
  };

  const options = {
    responsive: true,
    plugins: {
      legend: {
        position: 'top' as const,
      },
      title: {
        display: true,
        text: 'Performance Over Time'
      }
    }
  };

  return <Line data={chartData} options={options} />;
};

// Positions Table Component
const PositionsTable: React.FC<{ positions: any[] }> = ({ positions }) => {
  return (
    <table className="positions-table">
      <thead>
        <tr>
          <th>Symbol</th>
          <th>Qty</th>
          <th>Avg Price</th>
          <th>Current</th>
          <th>P&L</th>
          <th>P&L %</th>
          <th>Value</th>
        </tr>
      </thead>
      <tbody>
        {positions.map((pos, idx) => (
          <tr key={idx}>
            <td>{pos.symbol}</td>
            <td>{pos.quantity}</td>
            <td>${pos.avgPrice.toFixed(2)}</td>
            <td>${pos.currentPrice.toFixed(2)}</td>
            <td className={pos.unrealizedPnl >= 0 ? 'positive' : 'negative'}>
              ${pos.unrealizedPnl.toFixed(2)}
            </td>
            <td className={pos.unrealizedPnlPct >= 0 ? 'positive' : 'negative'}>
              {pos.unrealizedPnlPct.toFixed(2)}%
            </td>
            <td>${pos.marketValue.toFixed(2)}</td>
          </tr>
        ))}
      </tbody>
    </table>
  );
};

// Signals Stream Component
const SignalsStream: React.FC<{ signals: any[]; onTrade: Function }> = ({ signals, onTrade }) => {
  return (
    <div className="signals-stream">
      {signals.map((signal, idx) => (
        <div key={idx} className={`signal-card ${signal.action.toLowerCase()}`}>
          <div className="signal-header">
            <span className="symbol">{signal.symbol}</span>
            <span className="action">{signal.action}</span>
            <span className="confidence">{(signal.confidence * 100).toFixed(0)}%</span>
          </div>
          <div className="signal-body">
            <p>{signal.reason}</p>
            <div className="signal-details">
              <span>Target: ${signal.targetPrice.toFixed(2)}</span>
              <span>Stop: ${signal.stopLoss.toFixed(2)}</span>
              <span>Strategy: {signal.strategy}</span>
            </div>
          </div>
          <button 
            className="trade-button"
            onClick={() => onTrade(signal.symbol, signal.action, 100)}
          >
            Execute Trade
          </button>
        </div>
      ))}
    </div>
  );
};

// Analytics Dashboard Component
const AnalyticsDashboard: React.FC = () => {
  const [analytics, setAnalytics] = useState<any>(null);

  useEffect(() => {
    const fetchAnalytics = async () => {
      const response = await fetch('http://localhost:8000/api/v1/analytics/performance');
      const data = await response.json();
      setAnalytics(data);
    };

    fetchAnalytics();
    const interval = setInterval(fetchAnalytics, 60000);
    return () => clearInterval(interval);
  }, []);

  if (!analytics) return <div>Loading analytics...</div>;

  return (
    <div className="analytics-grid">
      <div className="metric-card">
        <h3>Win Rate</h3>
        <div className="metric-value">{(analytics.win_rate * 100).toFixed(1)}%</div>
      </div>
      <div className="metric-card">
        <h3>Sharpe Ratio</h3>
        <div className="metric-value">{analytics.sharpe_ratio.toFixed(2)}</div>
      </div>
      <div className="metric-card">
        <h3>Total P&L</h3>
        <div className="metric-value">${analytics.total_pnl.toFixed(2)}</div>
      </div>
      <div className="metric-card">
        <h3>Max Drawdown</h3>
        <div className="metric-value">{(analytics.max_drawdown * 100).toFixed(1)}%</div>
      </div>
    </div>
  );
};

// CSS Styles (in a real app, use styled-components or CSS modules)
const styles = `
.trading-dashboard {
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
  max-width: 1400px;
  margin: 0 auto;
  padding: 20px;
  background: #0a0e27;
  color: #ffffff;
  min-height: 100vh;
}

.dashboard-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 30px;
  padding: 20px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border-radius: 12px;
}

.trading-toggle {
  padding: 12px 24px;
  font-size: 16px;
  font-weight: bold;
  border: none;
  border-radius: 8px;
  cursor: pointer;
  transition: all 0.3s;
  background: #1a1a2e;
  color: white;
}

.trading-toggle.active {
  background: #00d4ff;
  color: #0a0e27;
}

.market-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 20px;
  margin-bottom: 30px;
}

.market-card {
  background: #1a1a2e;
  padding: 20px;
  border-radius: 12px;
  border: 1px solid #2d3561;
  transition: transform 0.2s;
}

.market-card:hover {
  transform: translateY(-5px);
  border-color: #667eea;
}

.symbol {
  font-size: 20px;
  font-weight: bold;
  color: #00d4ff;
}

.price {
  font-size: 28px;
  font-weight: 300;
  margin: 10px 0;
}

.change.positive {
  color: #00ff88;
}

.change.negative {
  color: #ff4757;
}

.positions-table {
  width: 100%;
  background: #1a1a2e;
  border-radius: 12px;
  overflow: hidden;
  margin-top: 20px;
}

.positions-table th {
  background: #2d3561;
  padding: 15px;
  text-align: left;
  font-weight: 600;
}

.positions-table td {
  padding: 15px;
  border-bottom: 1px solid #2d3561;
}

.signal-card {
  background: #1a1a2e;
  border: 1px solid #2d3561;
  border-radius: 12px;
  padding: 20px;
  margin-bottom: 15px;
  transition: all 0.3s;
}

.signal-card.buy {
  border-left: 4px solid #00ff88;
}

.signal-card.sell {
  border-left: 4px solid #ff4757;
}

.signal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 15px;
}

.confidence {
  background: #667eea;
  padding: 4px 12px;
  border-radius: 20px;
  font-size: 14px;
}

.trade-button {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border: none;
  padding: 10px 20px;
  border-radius: 8px;
  cursor: pointer;
  font-weight: bold;
  transition: all 0.3s;
}

.trade-button:hover {
  transform: scale(1.05);
}

.analytics-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 20px;
}

.metric-card {
  background: #1a1a2e;
  padding: 20px;
  border-radius: 12px;
  text-align: center;
  border: 1px solid #2d3561;
}

.metric-card h3 {
  color: #8892b0;
  font-size: 14px;
  margin-bottom: 10px;
}

.metric-value {
  font-size: 32px;
  font-weight: bold;
  color: #00d4ff;
}
`;

export default TradingDashboard;