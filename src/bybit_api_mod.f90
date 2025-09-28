module bybit_api_mod
    use iso_c_binding
    implicit none
    type :: candle_data
        real(c_double) :: open, high, low, close
        integer(c_long) :: start_time
    end type candle_data
contains
    subroutine fetch_ohlc_data(symbol, limit, interval, candles, error)
        character(len=*), intent(in) :: symbol, interval
        integer, intent(in) :: limit
        type(candle_data), allocatable, intent(out) :: candles(:)
        integer, intent(out) :: error
        character(len=1024) :: url, command, command_part1, json_response
        integer :: i, status, num_lines, file_unit = 10
        real(c_double) :: open_val, high_val, low_val, close_val
        integer(c_long) :: start_time_val
        character(len=1024) :: line

        error = 0 ! Сбрасываем ошибку в ноль

        ! Формируем URL для запроса
        url = "https://api.bybit.com/v5/market/kline?symbol=" // trim(symbol) // &
              "&limit=" // trim(int_to_str(limit)) // "&interval=" // trim(interval)

        ! Разбиваем команду на части
        command_part1 = "curl -s '" // trim(url) // "' > raw_response.json"
        call execute_command_line(command_part1, wait=.true., cmdstat=status)
        if (status /= 0) then
            print *, "Ошибка выполнения curl: ", status
            error = status
            return
        end if

        ! Используем jq для обработки JSON и tac для изменения порядка строк
        command_part1 = "jq -r '.result.list[] | [.[0], .[1], .[2], .[3], .[4]] | @tsv' raw_response.json | tac > response.txt"
        call execute_command_line(command_part1, wait=.true., cmdstat=status)
        if (status /= 0) then
            print *, "Ошибка выполнения jq или tac: ", status
            error = status
            return
        end if

        ! Проверяем количество строк в файле
        open(unit=file_unit, file="response.txt", status="old", action="read", iostat=status)
        if (status /= 0) then
            print *, "Ошибка открытия файла response.txt: ", status
            error = status
            return
        end if

        ! Подсчитываем количество строк
        num_lines = 0
        do
            read(file_unit, '(A)', iostat=status) line
            if (status < 0) exit
            num_lines = num_lines + 1
        end do
        rewind(file_unit)

        ! Выделяем память под массив candles
        if (num_lines == 0) then
            print *, "Файл response.txt пуст"
            error = -1
            return
        end if

        allocate(candles(min(limit, num_lines)))

        ! Читаем данные построчно
        do i = 1, min(limit, num_lines)
            read(file_unit, '(A)', iostat=status) line
            if (status /= 0) then
                print *, "Ошибка чтения строки из файла: ", status
                exit
            end if
            read(line, *, iostat=status) start_time_val, open_val, high_val, low_val, close_val
            if (status /= 0) then
                print *, "Ошибка парсинга строки: ", status, " Строка: ", trim(line)
                exit
            end if
            candles(i)%start_time = start_time_val
            candles(i)%open = open_val
            candles(i)%high = high_val
            candles(i)%low = low_val
            candles(i)%close = close_val
        end do
        close(file_unit)
    end subroutine fetch_ohlc_data

    ! Вспомогательная функция для преобразования целого числа в строку
    function int_to_str(i) result(str)
        integer, intent(in) :: i
        character(len=20) :: str
        write(str, '(I0)') i
        str = adjustl(str)
    end function int_to_str
end module bybit_api_mod
