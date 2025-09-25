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
COPY cairo_interface.f90 levels_mod.f90 candle_mod.f90 bybit_api_mod.f90 main.f90 /app/

# Компилируем программу
RUN gfortran -c cairo_interface.f90 candle_mod.f90 levels_mod.f90 bybit_api_mod.f90 main.f90 && \
    gfortran cairo_interface.o candle_mod.o levels_mod.o bybit_api_mod.o main.f90 -o candle_app -lcairo -lcurl

# Этап 2: Финальный образ
FROM debian:bullseye-slim

# Устанавливаем минимальные зависимости для запуска
RUN apt-get update && \
    apt-get install -y \
    libcairo2 \
    libcurl4 \
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
