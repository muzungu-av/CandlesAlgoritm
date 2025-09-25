program main
    use iso_c_binding
    use cairo_interface
    use candle_mod
    use levels_mod
    implicit none

    ! Определение типа для свечи
    type :: candle_t
        real(c_double) :: x, open, high, low, close
    end type candle_t

    type(c_ptr) :: surface, cr
    integer(c_int) :: status
    character(len=30), parameter :: filename = "output/chart.png"//char(0)
    integer, parameter :: n = 5
    type(candle_t), dimension(n) :: candles
    integer :: i
    real(c_double) :: min_price, max_price
    integer, parameter :: img_width = 300, img_height = 200

    ! Заполнение массива свечей
    candles(1) = candle_t(50.0d0, 10.0d0, 12.5d0, 9.5d0, 12.0d0)
    candles(2) = candle_t(100.0d0, 12.0d0, 12.0d0, 10.5d0, 11.0d0)
    candles(3) = candle_t(150.0d0, 11.0d0, 13.0d0, 11.0d0, 12.5d0)
    candles(4) = candle_t(200.0d0, 12.5d0, 13.5d0, 12.0d0, 13.0d0)
    candles(5) = candle_t(250.0d0, 13.0d0, 13.5d0, 12.0d0, 10.0d0)

    ! Определение min и max цен
    min_price = minval(candles%low)
    max_price = maxval(candles%high)

    ! Создание поверхности и контекста Cairo
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
        call draw_candle(cr, candles(i)%x, candles(i)%open, candles(i)%high, &
                         candles(i)%low, candles(i)%close, min_price, max_price, &
                         real(img_height, c_double))
    end do

    ! Сохранение PNG
    status = cairo_surface_write_to_png(surface, filename)
    call cairo_destroy(cr)
    call cairo_surface_destroy(surface)
end program main
