#!/bin/bash
# Setup Redis Slave for Frontend on port 6380

echo "🔧 Setting up Redis Slave Configuration..."

# Get Remote Master IP
if [ -z "$REMOTE_MASTER_IP" ]; then
    read -p "Enter Remote Redis Master IP: " REMOTE_MASTER_IP
fi

# Update redis-slave.conf with actual IP
sed -i "s/REMOTE_MASTER_IP/$REMOTE_MASTER_IP/g" redis-slave.conf

# Create log directory
sudo mkdir -p /var/log/redis
sudo chmod 755 /var/log/redis

# Start Redis Slave using Docker
echo "🚀 Starting Redis Slave on port 6380..."
docker-compose -f docker-compose.frontend.yml up -d redis-slave

# Wait for slave to start
sleep 5

# Test connection
echo "🔍 Testing Redis Slave connection..."
redis-cli -p 6380 -a pass123 ping

# Check replication status
echo "📊 Checking replication status..."
redis-cli -p 6380 -a pass123 info replication

echo "✅ Redis Slave setup complete!"
echo ""
echo "To connect from Qt Frontend:"
echo "  Host: localhost"
echo "  Port: 6380"
echo "  Password: pass123"
echo ""
echo "To monitor replication lag:"
echo "  redis-cli -p 6380 -a pass123 info replication | grep lag"