

program main
    use iso_c_binding
    use cairo_interface
    use candle_mod
    use levels_mod
    use csv_utils
    use bybit_api_mod
    implicit none

    ! --- Типы ---
    type :: candle_t
        real(c_double) :: x, open, high, low, close
    end type candle_t

    ! --- Переменные ---
    type(c_ptr) :: surface, cr
    integer(c_int) :: status
    integer, parameter :: img_height = 600
    integer :: img_width, candle_width = 10, candle_spacing = 5
    type(candle_data), allocatable :: candles(:)
    type(candle_t), allocatable :: candles_for_plot(:)
    integer :: i, n, error, ios
    real(c_double) :: min_price, max_price

    ! --- Для чтения параметров ---
    character(len=50) :: symbol, interval
    integer :: limit
    integer :: unit
    character(len=30) :: timestamp
    character(len=256) :: filename
    character(len=30) :: base_dir = "output"

    ! --- Создаем директорию для вывода ---
    call execute_command_line("mkdir -p output", wait=.true.)

    ! --- Открываем файл параметров ---
    open(newunit=unit, file="input/params.txt", status="old", action="read", iostat=ios)
    if (ios /= 0) then
        print *, "Не удалось открыть файл params.txt"
        stop
    end if

    ! --- Цикл по всем строкам файла ---
    do
        read(unit, *, iostat=ios) symbol, limit, interval
        if (ios /= 0) exit  ! конец файла

        symbol = adjustl(trim(symbol))
        interval = adjustl(trim(interval))

        ! Получаем timestamp
        call get_timestamp(timestamp)

        ! Формируем имя PNG
        filename = trim(base_dir)//"/"//trim(symbol)//"_"//trim(interval)//"_"//trim(timestamp)//".png"

        ! --- Запрашиваем данные ---
        if (allocated(candles)) deallocate(candles)
        call fetch_ohlc_data(trim(symbol), limit, trim(interval), candles, error)
        if (error /= 0) then
            print *, "Ошибка при запросе данных для ", trim(symbol)
            cycle
        end if

        n = size(candles)
        allocate(candles_for_plot(n))

        ! --- Преобразуем данные для графика ---
        img_width = n * (candle_width + candle_spacing) + candle_spacing
        do i = 1, n
            candles_for_plot(i) = candle_t( &
                real(i, c_double)*(candle_width + candle_spacing), &
                candles(i)%open, candles(i)%high, candles(i)%low, candles(i)%close)
        end do

        ! Определяем min/max цены
        min_price = minval([(candles_for_plot(i)%low, i=1,n)])
        max_price = maxval([(candles_for_plot(i)%high, i=1,n)])

        ! --- Рисуем график ---
        surface = cairo_image_surface_create(CAIRO_FORMAT_ARGB32, img_width, img_height)
        cr = cairo_create(surface)

        ! Фон
        call cairo_set_source_rgb(cr, 8/255d0, 22/255d0, 32/255d0)
        call cairo_rectangle(cr, 0.0d0, 0.0d0, real(img_width, c_double), real(img_height, c_double))
        call cairo_fill(cr)

        ! Ключевые уровни
        call draw_levels(cr, min_price, max_price, 5, real(img_height, c_double))

        ! Свечи
        do i = 1, n
            call draw_candle(cr, candles_for_plot(i)%x, candles_for_plot(i)%open, &
                             candles_for_plot(i)%high, candles_for_plot(i)%low, &
                             candles_for_plot(i)%close, min_price, max_price, &
                             real(img_height, c_double), real(candle_width, c_double))
        end do

        ! --- Сохраняем PNG ---
        status = cairo_surface_write_to_png(surface, trim(filename)//char(0))
        if (status /= 0) then
            print *, "Ошибка сохранения PNG: ", trim(filename)
        else
            print *, "График успешно сохранен: ", trim(filename)
        end if

        call cairo_destroy(cr)
        call cairo_surface_destroy(surface)

        ! --- Сохраняем CSV с данными ---
        call save_candles_csv(candles, n, filename)

        ! --- Очистка ---
        deallocate(candles_for_plot)
        deallocate(candles)
    end do

    close(unit)
end program main


! ------------------------
subroutine get_timestamp(ts)
    character(len=*), intent(out) :: ts
    character(len=8) :: date
    character(len=10) :: time
    character(len=5) :: zone
    integer :: values(8)
    call date_and_time(date, time, zone, values)
    write(ts,'(I4.4,"_",I2.2,"_",I2.2,"_",I2.2,"_",I2.2,"_",I2.2)') &
        values(1), values(2), values(3), values(5), values(6), values(7)
end subroutine get_timestamp



