FROM python:3.11.0-slim

WORKDIR /app

COPY . .
# ARG BACKEND_PORT
# ENV BACKEND_PORT=${BACKEND_PORT}
EXPOSE 80
RUN pip install -r requirements.txt

CMD ["sh", "-c", "python3 main.py 0.0.0.0:80"]