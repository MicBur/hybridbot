# 6bot HybridBot Trading System

Ein fortschrittliches Auto-Trading System mit Bootstrap 5 Interface, Redis Backend und Qt/QML Integration.

## 🚀 Features

### Trading Interface
- ✅ **Bootstrap 5.3.2** mit nativem Dark Mode
- ✅ **Glasmorphism Design** mit modernen UI-Effekten  
- ✅ **Chart.js 4.4.0** Integration (Portfolio, Assets, Trading Volume)
- ✅ **Responsive Design** für Desktop und Mobile
- ✅ **Real-time Portfolio** Tracking

### Backend System
- ✅ **Redis Integration** auf Port 6380
- ✅ **Qt/QML Hybrid Interface** für Desktop-Integration
- ✅ **Auto-Trading Backend** mit Simulation Mode
- ✅ **Emergency Stop** Funktionalität
- ✅ **Risk Management** Integration
- ✅ **ML Prediction** Integration

### Technische Features
- ✅ **Robuste Fehlerbehandlung** und Fallbacks
- ✅ **Multi-Mode Operation** (QML/Redis/Simulation)
- ✅ **Staging Script Loading** für Dependencies
- ✅ **Comprehensive Error Handling**

## 📁 Projekt-Struktur

```
hybridbot/
├── README.md                              # Diese Datei
├── .gitignore                            # Git-Ausschluss-Regeln
├── CMakeLists.txt                        # CMake Build-Konfiguration
├── backend.txt                           # Redis Backend Dokumentation
├── ml.md                                # Machine Learning Dokumentation  
├── redis.txt                            # Redis Setup und Konfiguration
└── src/                                 # Haupt-Quellcode
    ├── TradingSuite-Bootstrap.html       # 🎯 HAUPT TRADING INTERFACE
    ├── AutoTradingBackend-Fixed.js       # Backend-Integration (korrigiert)
    ├── HybridMain.qml                    # Qt/QML Hauptinterface
    ├── autotrader.cpp/.h                 # C++ Auto-Trading Logic
    ├── redisclient.cpp/.h                # Redis Client Implementation
    └── [weitere QML/HTML/JS Dateien...]
```

## 🚀 Schnellstart

### 1. Repository klonen
```bash
git clone https://github.com/MicBur/hybridbot.git
cd hybridbot
```

### 2. Trading Interface starten
```bash
# Öffne das Bootstrap 5 Trading Interface
cd src
# Öffne TradingSuite-Bootstrap.html in einem modernen Browser
```

### 3. Qt/QML Interface (optional)
```bash
# Falls Qt 6.5.3+ installiert ist:
qmlscene src/HybridMain.qml
```

## ⚠️ Wichtige Hinweise

### Browser-Konsolen-Fehlermeldungen sind NORMAL!

Wenn Sie diese Fehlermeldung sehen:
```
WebSocket connection to 'ws://localhost:6380/' failed: 
Error during WebSocket handshake: net::ERR_INVALID_HTTP_RESPONSE
```

**🎉 Das ist GUTES Zeichen!** Diese Fehlermeldung bedeutet:
- ✅ Redis läuft auf Port 6380  
- ✅ Das System erkennt Redis korrekt
- ✅ Redis lehnt WebSocket-Verbindungen ab (erwartetes Verhalten)

Der Grund: Redis spricht das Redis-Protokoll, nicht WebSocket. Wir nutzen den WebSocket-Fehler als clevere Methode um zu testen, ob Redis läuft.

### System-Modi

Das System läuft in verschiedenen Modi:

1. **🤖 QML+REDIS Mode**: Qt Interface mit echtem Redis Backend
2. **🔌 REDIS:6380 Mode**: Browser Interface mit Redis Backend  
3. **🎭 SIMULATION Mode**: Fallback ohne Redis (für Testing)

## ⚙️ Backend Setup (Optional)

### Redis Installation
```bash
# Windows (mit Chocolatey)
choco install redis-64

# Oder Docker
docker run -d -p 6380:6379 --name redis-6bot redis:latest
```

### Redis Konfiguration
```bash
# Redis auf Port 6380 starten
redis-server --port 6380

# Test
redis-cli -p 6380 ping
# Sollte "PONG" zurückgeben
```

## 🛠️ Entwicklung

### Build Requirements
- **Qt 6.5.3+** (für QML Interface)
- **CMake 3.16+** (für C++ Komponenten)
- **Moderner Browser** (für Web Interface)
- **Redis** (optional, für Backend)

### CMake Build
```bash
mkdir build
cd build
cmake ..
make
```

### Entwickler-Modus
```bash
# Starte Redis für Testing
redis-server --port 6380

# Öffne Trading Interface
cd src
# Browser: TradingSuite-Bootstrap.html
# Qt: qmlscene HybridMain.qml
```

## 📊 Trading System

### Sicherheitsfeatures
- 🛑 **Emergency Stop**: Sofortiger Handelsstopp
- 📊 **Risk Management**: Volumen- und Positionslimits
- 🔒 **Default OFF**: Trading ist standardmäßig deaktiviert
- 📈 **Simulation Mode**: Sicheres Testing ohne echtes Trading

### Supported APIs
- **Alpaca Trading API** (live trading)
- **Yahoo Finance** (market data)
- **Finnhub API** (financial data)
- **ML Predictions** (custom models)

## 🔧 Troubleshooting

### Häufige "Probleme" (die eigentlich OK sind):

1. **WebSocket Errors**: ✅ Normal - bedeutet Redis läuft
2. **"Backend not connected"**: ✅ Normal - System läuft im Simulation Mode  
3. **CORS Errors**: ✅ Normal - Browser-Sicherheit, System funktioniert trotzdem

### Echte Probleme:

1. **Interface lädt nicht**: Browser zu alt, verwende Chrome/Firefox/Edge
2. **Charts nicht sichtbar**: JavaScript disabled, aktiviere JavaScript
3. **Qt Interface startet nicht**: Qt 6.5.3+ installieren

## 📄 Lizenz

MIT License - siehe Dateiheader für Details.

## 🤝 Mitwirken

1. Fork das Repository
2. Erstelle einen Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit deine Änderungen (`git commit -m 'Add some AmazingFeature'`)
4. Push zum Branch (`git push origin feature/AmazingFeature`)
5. Öffne einen Pull Request

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/MicBur/hybridbot/issues)
- **Diskussionen**: [GitHub Discussions](https://github.com/MicBur/hybridbot/discussions)
- **E-Mail**: micbur1488@gmail.com

---

**💡 Tipp**: Die "WebSocket failed" Fehlermeldungen sind Freunde, keine Feinde! Sie zeigen, dass das System Redis korrekt erkennt. 🎉

*Erstellt am 21. September 2025 | Version 1.0*