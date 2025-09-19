# Use slim Python image
FROM python:3.11-slim

ENV PYTHONUNBUFFERED=1
ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies + Chromium + chromedriver
RUN apt-get update && apt-get install -y \
    wget gnupg ca-certificates \
    chromium chromium-driver \
    fonts-liberation libasound2 libatk1.0-0 libcups2 \
    libdbus-1-3 libgdk-pixbuf2.0-0 libnspr4 libnss3 \
    libx11-xcb1 libxcomposite1 libxdamage1 libxrandr2 \
    xdg-utils --no-install-recommends && \
    rm -rf /var/lib/apt/lists/*

# Set working dir
WORKDIR /app

# Install Python deps
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy Django project
COPY . .

# Collect static files
RUN python manage.py collectstatic --noinput

# Start server
CMD gunicorn scrapping.wsgi --workers=2 --threads=2 --bind=0.0.0.0:$PORT
