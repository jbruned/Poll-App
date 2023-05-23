FROM python:3.11.0-slim

WORKDIR /app

COPY . .

ARG BACKEND_PORT_INTERNAL=80
EXPOSE ${BACKEND_PORT_INTERNAL}
RUN pip install --no-cache-dir -r requirements.txt

CMD ["sh", "-c", "python3 main.py 0.0.0.0:$BACKEND_PORT_INTERNAL"]