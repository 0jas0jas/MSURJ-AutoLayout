# MSURJ AutoLayout – production image for Render (or any Docker host)
# Uses Python 3.12, pandoc, and anystyle-cli (Ruby gem).

FROM python:3.12-slim

# Install system deps: pandoc, Ruby (for anystyle-cli), and build deps for gems
RUN apt-get update && apt-get install -y --no-install-recommends \
    pandoc \
    ruby \
    ruby-dev \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install anystyle-cli (citation parsing)
RUN gem install anystyle-cli

# App lives in /app; run from project root so `processing` and `webapp` resolve
WORKDIR /app

# Python deps first for better layer caching
COPY webapp/requirements.txt webapp/requirements.txt
RUN pip install --no-cache-dir -r webapp/requirements.txt

# Copy app (see .dockerignore). Include output/template_dir in repo for Render.
COPY . .
RUN mkdir -p output/template_dir

# Render (and most PaaS) set PORT; default for local Docker
ENV PORT=10000
EXPOSE 10000

# Run from project root so `python -m webapp.app` and imports work
CMD gunicorn -w 1 -b 0.0.0.0:${PORT} --timeout 120 webapp.app:app
