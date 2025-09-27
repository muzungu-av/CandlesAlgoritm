# Этап 1: Сборка приложения
FROM debian:bullseye-slim AS builder

# Устанавливаем зависимости
RUN apt-get update && \
    apt-get install -y \
    gfortran \
    libcairo2-dev \
    libcurl4-openssl-dev \
    jq && \
    rm -rf /var/lib/apt/lists/*

# Копируем исходники
WORKDIR /app
COPY save_candles_csv.f90 cairo_interface.f90 levels_mod.f90 candle_mod.f90 bybit_api_mod.f90 main.f90 /app/

RUN gfortran -c bybit_api_mod.f90 && \
    gfortran -c save_candles_csv.f90 && \
    gfortran -c cairo_interface.f90 && \
    gfortran -c candle_mod.f90 && \
    gfortran -c levels_mod.f90 && \
    gfortran -c main.f90 && \
    gfortran bybit_api_mod.o save_candles_csv.o cairo_interface.o candle_mod.o levels_mod.o main.o -o candle_app -lcairo -lcurl


# Этап 2: Финальный образ
FROM debian:bullseye-slim

# Устанавливаем минимальные зависимости для запуска
RUN apt-get update && \
    apt-get install -y \
    libcairo2 \
    libcurl4 \
    curl \
    libgfortran5 \
    jq && \
    rm -rf /var/lib/apt/lists/*

# Копируем только скомпилированное приложение из builder
COPY --from=builder /app/candle_app /app/candle_app

# Создаём папку для вывода
RUN mkdir -p /app/output

# Устанавливаем рабочую директорию
WORKDIR /app

# Запускаем программу
CMD ["./candle_app"]
