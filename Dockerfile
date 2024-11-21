FROM python:3.11-buster

# Set work directory
WORKDIR /app

# Dependencies for psycopg2
RUN apt-get update && \
    apt-get install --no-install-recommends -y \
    dnsutils \
    libpq-dev \
    python3-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# Install dependencies
RUN python -m pip install --no-cache-dir pip==22.0.4
COPY requirements.txt requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Copy project
COPY . /app/

# Expose application port
EXPOSE 8000

# Run database migrations
RUN python3 /app/manage.py migrate

# Set final work directory
WORKDIR /app/pygoat/

# Start application
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "--workers", "6", "pygoat.wsgi"]

