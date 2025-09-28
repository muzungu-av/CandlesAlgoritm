# Компилятор и флаги
FC = gfortran
MOD_DIR = include
OBJ_DIR = build
SRC_DIR = src
FFLAGS = -O2 -Wall -J$(MOD_DIR) -I$(MOD_DIR)
LDFLAGS = -lcairo -lcurl

SRC = $(wildcard $(SRC_DIR)/*.f90)
OBJ = $(patsubst $(SRC_DIR)/%.f90, $(OBJ_DIR)/%.o, $(SRC))

TARGET = candle_app

all: $(TARGET)

# Линковка
$(TARGET): $(OBJ)
	$(FC) $(OBJ) -o $@ $(LDFLAGS)

# Компиляция
$(OBJ_DIR)/%.o: $(SRC_DIR)/%.f90 | $(OBJ_DIR) $(MOD_DIR)
	@echo "Compiling $< ..."
	$(FC) $(FFLAGS) -c $< -o $@

# Создание директорий
$(OBJ_DIR):
	mkdir -p $(OBJ_DIR)

$(MOD_DIR):
	mkdir -p $(MOD_DIR)

clean:
	rm -rf $(OBJ_DIR) $(MOD_DIR) $(TARGET)

.PHONY: all clean
