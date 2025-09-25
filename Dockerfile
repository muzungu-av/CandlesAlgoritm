FROM debian:bullseye-slim

# Устанавливаем компилятор и Cairo
RUN apt-get update && apt-get install -y gfortran libcairo2-dev && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY cairo_interface.f90 levels_mod.f90 candle_mod.f90 main.f90 /app/
RUN mkdir -p /app/output

# Компиляция модулей и main
RUN gfortran -c cairo_interface.f90
RUN gfortran -c candle_mod.f90
RUN gfortran -c levels_mod.f90
RUN gfortran cairo_interface.o levels_mod.o candle_mod.o main.f90 -o candle_app -lcairo

CMD ["./candle_app"]
