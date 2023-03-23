# syntax=docker/dockerfile:1

FROM python:3.11.0-slim


WORKDIR /app

COPY requirements.txt .
RUN pip install -r requirements.txt

COPY . .

#EXPOSE 9000

CMD ["python3", "main.py", "0.0.0.0:9000"]