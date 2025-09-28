import os, time, json, logging, redis, yfinance as yf
from datetime import datetime
from dotenv import load_dotenv

load_dotenv()
logging.basicConfig(level=logging.INFO, format='[yfinance] %(asctime)s %(levelname)s %(message)s')

REDIS_URL = os.getenv('REDIS_URL', 'redis://:pass123@redis:6379/0')
INTERVAL = int(os.getenv('YF_INTERVAL','60'))  # Sekunden zwischen Läufen
TICKERS_ENV = os.getenv('YF_TICKERS','')  # Optional Override
BATCH_SIZE = int(os.getenv('YF_BATCH_SIZE','20'))
KEY_QUOTES = 'yfinance_quotes'
KEY_STATUS = 'yfinance_status'

r = redis.from_url(REDIS_URL)

def get_tickers():
    if TICKERS_ENV:
        return [t.strip().upper() for t in TICKERS_ENV.split(',') if t.strip()]
    # fallback: dynamic_tickers aus Redis
    try:
        dyn_raw = r.get('dynamic_tickers')
        if dyn_raw:
            return json.loads(dyn_raw)
    except Exception:
        pass
    return ['AAPL','MSFT','NVDA','TSLA','AMZN']

def chunked(seq, size):
    for i in range(0, len(seq), size):
        yield seq[i:i+size]

while True:
    start = time.time()
    tickers = get_tickers()
    quotes = {}
    errors = []
    fetched = 0
    for batch in chunked(tickers, BATCH_SIZE):
        try:
            data = yf.download(batch, period='1d', interval='1m', progress=False, prepost=False, threads=True)
            # yfinance Rückgabeformat für mehrere Ticker: MultiIndex Columns
            # Wir nehmen den letzten Close je Ticker
            if isinstance(data, dict):
                # sehr alte oder fallback Struktur – ignorieren
                pass
            else:
                # Wenn mehrere Ticker: data['Close'][ticker]
                if 'Close' in data.columns:
                    close_df = data['Close'] if 'Close' in data.columns else None
                else:
                    # Single Ticker Mode
                    close_df = data.get('Close') if hasattr(data,'get') else None
                if close_df is not None:
                    if hasattr(close_df, 'columns'):
                        # mehrere Ticker
                        for t in close_df.columns:
                            series = close_df[t].dropna()
                            if not series.empty:
                                quotes[t] = float(series.iloc[-1])
                                fetched += 1
                    else:
                        series = close_df.dropna()
                        if not series.empty and len(batch)==1:
                            quotes[batch[0]] = float(series.iloc[-1]); fetched += 1
        except Exception as e:
            errors.append(str(e)[:140])
        time.sleep(0.3)
    # Schreibe Redis (atomic replace)
    payload = {
        'time': datetime.utcnow().isoformat(),
        'prices': quotes,
        'count': len(quotes)
    }
    r.set(KEY_QUOTES, json.dumps(payload))
    status = {
        'time': datetime.utcnow().isoformat(),
        'tickers_total': len(tickers),
        'fetched': fetched,
        'errors': errors,
        'interval_sec': INTERVAL
    }
    r.set(KEY_STATUS, json.dumps(status))
    logging.info(f"Fetched {fetched}/{len(tickers)} tickers (errors={len(errors)})")
    # Schlaf bis nächster Lauf
    elapsed = time.time()-start
    sleep_left = max(5, INTERVAL - int(elapsed))
    time.sleep(sleep_left)
