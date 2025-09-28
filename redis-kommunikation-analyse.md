# Redis-Kommunikation zwischen Backend und Frontend - Analyse

## Überblick

Das System nutzt Redis als zentrale Kommunikationsschnittstelle zwischen:
- **Backend**: Python-basierte Services (Worker, Multi-API Services, YFinance Services)
- **Frontend**: Qt/QML-basierte GUI mit Redis-Client

## Architektur

### Backend-Komponenten

1. **Worker Service** (`worker.py`)
   - Hauptservice für Trading-Logik
   - Celery-basiert mit Redis als Broker
   - Verbindung: `redis://:pass123@redis:6379/0`

2. **Multi-API Enhanced Service** (`multi_api_enhanced_service.py`)
   - Aggregiert Marktdaten von mehreren APIs (Finnhub, FMP, MarketStack, TwelveData)
   - Schreibt aggregierte Daten nach Redis

3. **YFinance Services** (`yfinance_service.py`, `yfinance_enhanced_service.py`)
   - Holt historische und Echtzeitdaten
   - Speichert in Redis unter Keys wie `yfinance_enhanced:{TICKER}`

### Frontend-Komponenten

1. **Qt C++ Frontend** (`qt-frontend/`)
   - Nutzt `redis-cli` via QProcess für Redis-Verbindung
   - Polling alle 5 Sekunden
   - Mock-Daten als Fallback

2. **QML Frontend** (`qml/`)
   - Modernere Variante mit QML
   - Redis-Polling über C++ Backend
   - Status-Badges für Verbindungsstatus

## Redis-Keys und Datenfluss

### Wichtige Redis-Keys (laut `redis-endpoints.txt`)

#### Backend → Frontend (Lesezugriff für Frontend)
- `trading_settings` - Trading-Konfiguration
- `trading_status` - Aktueller Trading-Status
- `system_status` - System-Gesundheitsstatus
- `risk_settings` - Risiko-Management Einstellungen
- `portfolio_positions` - Aktuelle Portfolio-Positionen
- `trades_log` - Trading-Historie (max 200 Einträge)
- `market_data` - Aktuelle Marktdaten
- `predictions_current` - ML-Vorhersagen
- `multi_api_enhanced_data` - Aggregierte Multi-Source Daten

#### Frontend → Backend (Schreibzugriff für Frontend)
- `autotrading:enabled` - AutoTrading aktivieren/deaktivieren
- `autotrading:status` - Status (ACTIVE/STOPPED)
- `frontend:trading_config` - Trading-Konfiguration vom Frontend
- `frontend:bot_strategy` - Bot-Strategie Einstellungen
- `frontend:portfolio_settings` - Portfolio-Management
- `frontend:manual_orders` - Manuelle Orders
- `frontend:emergency_actions` - Notfall-Aktionen

#### Backend → Frontend (Antworten)
- `backend:trading_performance` - Performance-Metriken
- `backend:grok_candidates` - AI Trading-Kandidaten
- `backend:active_orders` - Aktive Orders
- `backend:recent_trades` - Kürzliche Trades
- `backend:portfolio_summary` - Portfolio-Zusammenfassung
- `backend:ml_predictions_enhanced` - Erweiterte ML-Vorhersagen
- `backend:system_health` - System-Gesundheit

## Kommunikationsablauf

### AutoTrading Aktivierung
1. Frontend schreibt `autotrading:enabled` mit Konfiguration
2. Backend Worker überwacht diesen Key kontinuierlich
3. Backend startet Trading und schreibt Status zurück
4. Frontend pollt Status-Updates alle 5 Sekunden

### Daten-Updates
1. Backend Services aktualisieren Marktdaten alle 5 Minuten
2. ML-Vorhersagen werden alle 15 Minuten generiert
3. Trading Bot läuft alle 10 Minuten
4. Frontend pollt alle 5 Sekunden für Updates

## Problembereiche und Verbesserungsmöglichkeiten

### 1. Frontend Redis-Client
- Nutzt `redis-cli` via QProcess (ineffizient)
- Besser: Native Redis-Library (hiredis) direkt einbinden
- Mock-Daten als Fallback zeigen fehlende Robustheit

### 2. Polling vs. Pub/Sub
- Aktuell: Frontend pollt alle 5 Sekunden
- Besser: Redis Pub/Sub für Echtzeit-Updates nutzen
- Würde Latenz reduzieren und Server-Last verringern

### 3. Datenvalidierung
- Keine explizite Schema-Validierung
- JSON-Parsing Fehler werden nur geloggt
- Besser: Schema-Validierung mit JSON Schema

### 4. Session Management
- Session IDs werden generiert aber nicht vollständig genutzt
- Mehrere Frontend-Sessions könnten sich gegenseitig stören
- Besser: Vollständiges Session-Tracking mit Timeouts

### 5. Error Handling
- Redis-Verbindungsfehler führen zu Mock-Daten
- Keine Retry-Logik im Frontend
- Besser: Exponential Backoff bei Verbindungsfehlern

## Docker Setup

Das System läuft in Docker-Containern:
- Redis auf Port 6379 (intern) mit Passwort `pass123`
- PostgreSQL auf Port 5432
- Alle Services im Netzwerk `qt_trade_network`

## Fazit

Die Redis-basierte Kommunikation funktioniert grundsätzlich, hat aber Optimierungspotential:
1. Effizienzere Redis-Anbindung im Frontend
2. Pub/Sub statt Polling
3. Bessere Fehlerbehandlung
4. Vollständiges Session-Management
5. Schema-Validierung für Datenintegrität

Das System ist modular aufgebaut und die Trennung von Backend/Frontend über Redis ermöglicht unabhängige Entwicklung und Skalierung.