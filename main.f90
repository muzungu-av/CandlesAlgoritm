program main
    use iso_c_binding
    use cairo_interface
    use candle_mod
    use levels_mod
    use bybit_api_mod
    implicit none
    type :: candle_t
        real(c_double) :: x, open, high, low, close
    end type candle_t
    type(c_ptr) :: surface, cr
    integer(c_int) :: status
    character(len=30) :: filename = "output/chart.png"
    integer, parameter :: img_height = 600
    integer :: img_width, candle_width = 10, candle_spacing = 5
    type(candle_data), allocatable :: candles(:)
    type(candle_t), allocatable :: candles_for_plot(:)
    integer :: i, n, error
    real(c_double) :: min_price, max_price

    ! Создаем директорию для вывода, если она не существует
    call execute_command_line("mkdir -p output", wait=.true.)

    ! Запрашиваем данные с Bybit
    call fetch_ohlc_data("DOGEUSDT", 100, "D", candles, error)
    if (error /= 0) then
        print *, "Ошибка при запросе данных: ", error
        stop
    end if

    n = size(candles)
    allocate(candles_for_plot(n))

    ! Рассчитываем ширину изображения
    img_width = n * (candle_width + candle_spacing) + candle_spacing

    ! Преобразуем данные в формат для графика
    do i = 1, n
        candles_for_plot(i) = candle_t( &
            real(i, c_double) * (candle_width + candle_spacing), &  ! x-координата
            candles(i)%open, &
            candles(i)%high, &
            candles(i)%low, &
            candles(i)%close &
        )
    end do

    ! Определяем min и max цены
    min_price = minval([(candles_for_plot(i)%low, i=1, n)])
    max_price = maxval([(candles_for_plot(i)%high, i=1, n)])

    ! Создаём поверхность и контекст Cairo
    surface = cairo_image_surface_create(CAIRO_FORMAT_ARGB32, img_width, img_height)
    cr = cairo_create(surface)

    ! Фон
    call cairo_set_source_rgb(cr, 8/255d0, 22/255d0, 32/255d0)
    call cairo_rectangle(cr, 0.0d0, 0.0d0, real(img_width, c_double), real(img_height, c_double))
    call cairo_fill(cr)

    ! Ключевые уровни
    call draw_levels(cr, min_price, max_price, 5, real(img_height, c_double))

    ! Рисуем свечи
    do i = 1, n
        call draw_candle(cr, candles_for_plot(i)%x, candles_for_plot(i)%open, &
                         candles_for_plot(i)%high, candles_for_plot(i)%low, &
                         candles_for_plot(i)%close, min_price, max_price, &
                         real(img_height, c_double), real(candle_width, c_double))
    end do

    ! Сохраняем PNG
    status = cairo_surface_write_to_png(surface, filename // char(0))
    if (status /= 0) then
        print *, "Ошибка сохранения PNG: ", status
    else
        print *, "График успешно сохранен в ", filename
    end if

    ! Освобождаем ресурсы
    call cairo_destroy(cr)
    call cairo_surface_destroy(surface)
end program main
