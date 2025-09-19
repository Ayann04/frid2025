# Use a lightweight Python base
FROM python:3.11-slim

# Prevent interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies (including Chromium & ChromeDriver)
RUN apt-get update && apt-get install -y \
    wget gnupg ca-certificates curl unzip \
    chromium chromium-driver \
    fonts-liberation libasound2 libatk1.0-0 libcups2 \
    libdbus-1-3 libgdk-pixbuf2.0-0 libnspr4 libnss3 \
    libx11-xcb1 libxcomposite1 libxdamage1 libxrandr2 \
    xdg-utils --no-install-recommends \
 && rm -rf /var/lib/apt/lists/*

# Set Chromium path for Selenium
ENV CHROME_BIN=/usr/bin/chromium
ENV CHROMEDRIVER_PATH=/usr/bin/chromedriver

# Create app directory
WORKDIR /app

# Install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy project files
COPY . .

# Collect static files
RUN python manage.py collectstatic --noinput

# Expose Render’s port
EXPOSE 8000

# Run with Gunicorn
CMD ["gunicorn", "scrapping.wsgi:application", "--workers=2", "--threads=2", "--bind=0.0.0.0:8000"]
