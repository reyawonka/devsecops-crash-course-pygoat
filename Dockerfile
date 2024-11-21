# Use a newer and stable base image
FROM python:3.11-slim-bullseye

# Set work directory
WORKDIR /app

# Install system dependencies
# Removed dnsutils and only kept libpq-dev and python3-dev
RUN apt-get update && apt-get install --no-install-recommends -y \
    libpq-dev \
    python3-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Set environment variables to improve performance
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# Upgrade pip and install project dependencies
RUN python -m pip install --no-cache-dir pip==22.0.4
COPY requirements.txt requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Copy application source code to the container
COPY . /app/

# Expose the application port
EXPOSE 8000

# Run database migrations
RUN python3 /app/manage.py migrate

# Set the working directory for the application
WORKDIR /app/pygoat/

# Start the application with Gunicorn
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "--workers", "6", "pygoat.wsgi"]

