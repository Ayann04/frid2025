FROM python:3.11-bullseye

ENV DEBIAN_FRONTEND=noninteractive

# Install system deps
RUN apt-get update && apt-get install -y \
    wget curl unzip gnupg ca-certificates \
    fonts-liberation libasound2 libatk1.0-0 libcups2 \
    libdbus-1-3 libgdk-pixbuf2.0-0 libnspr4 libnss3 \
    libx11-xcb1 libxcomposite1 libxdamage1 libxrandr2 \
    xdg-utils --no-install-recommends \
 && rm -rf /var/lib/apt/lists/*

# Install Chromium + ChromeDriver (from Chrome for Testing)
RUN CHROME_VERSION=$(curl -s https://googlechromelabs.github.io/chrome-for-testing/LATEST_RELEASE_STABLE) && \
    wget -q https://storage.googleapis.com/chrome-for-testing-public/$CHROME_VERSION/linux64/chrome-linux64.zip -O /tmp/chrome.zip && \
    wget -q https://storage.googleapis.com/chrome-for-testing-public/$CHROME_VERSION/linux64/chromedriver-linux64.zip -O /tmp/chromedriver.zip && \
    unzip /tmp/chrome.zip -d /opt/ && \
    unzip /tmp/chromedriver.zip -d /opt/ && \
    mv /opt/chrome-linux64 /opt/chrome && \
    mv /opt/chromedriver-linux64 /opt/chromedriver && \
    ln -s /opt/chrome/chrome /usr/bin/chromium && \
    ln -s /opt/chromedriver/chromedriver /usr/bin/chromedriver && \
    rm -rf /tmp/*

# Env vars for Selenium
ENV CHROME_BIN=/usr/bin/chromium
ENV CHROMEDRIVER_PATH=/usr/bin/chromedriver

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

RUN python manage.py collectstatic --noinput

EXPOSE 8000

CMD gunicorn scrapping.wsgi:application --workers=1 --threads=1 --bind 0.0.0.0:$PORT




