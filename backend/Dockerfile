FROM python:3.11.0-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install -r requirements.txt

ARG BACKEND_PORT
ENV BACKEND_PORT=${BACKEND_PORT}

COPY . .
CMD ["sh", "-c", "python3 main.py 0.0.0.0:${BACKEND_PORT}"]