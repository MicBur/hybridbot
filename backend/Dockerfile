FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .
# System Abhängigkeiten für AutoGluon / LightGBM / XGBoost (OpenMP) installieren
RUN apt-get update \
	&& apt-get install -y --no-install-recommends libgomp1 libstdc++6 \
	&& rm -rf /var/lib/apt/lists/* \
	&& pip install --no-cache-dir -r requirements.txt

COPY . .

CMD ["celery", "-A", "worker", "worker", "--loglevel=info"]
