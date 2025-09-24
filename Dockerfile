FROM debian:bullseye-slim

# Устанавливаем компилятор и Cairo
RUN apt-get update && apt-get install -y gfortran libcairo2-dev && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY candles.f90 /app/

RUN gfortran candles.f90 -o candle -lcairo

RUN mkdir -p /app/output

CMD ["./candle"]
