program main
    use iso_c_binding
    use cairo_interface
    use candle_mod
    use levels_mod
    implicit none

    type(c_ptr) :: surface, cr
    integer(c_int) :: status
    character(len=30), parameter :: filename = "output/chart.png"//char(0)

    integer, parameter :: n = 5
    real(c_double), dimension(n) :: x, open, high, low, close
    integer :: i
    real(c_double) :: min_price, max_price
    integer, parameter :: img_width = 300, img_height = 200

    ! ------------------------
    ! Пример данных OHLC
    ! ------------------------
    x     = (/50.0d0, 100.0d0, 150.0d0, 200.0d0, 250.0d0/)
    open  = (/10.0d0, 12.0d0, 11.0d0, 12.5d0, 13.0d0/)
    close = (/12.0d0, 11.0d0, 12.5d0, 13.0d0, 10.0d0/)
    high  = (/12.5d0, 12.0d0, 13.0d0, 13.5d0, 13.5d0/)
    low   = (/9.5d0, 10.5d0, 11.0d0, 12.0d0, 12.0d0/)

    ! диапазон цен
    min_price = minval(low)
    max_price = maxval(high)

    ! поверхность PNG
    surface = cairo_image_surface_create(CAIRO_FORMAT_ARGB32, img_width, img_height)
    cr = cairo_create(surface)

    ! фон
    call cairo_set_source_rgb(cr, 1.0d0, 1.0d0, 1.0d0)
    call cairo_rectangle(cr, 0.0d0, 0.0d0, real(img_width, c_double), real(img_height, c_double))
    call cairo_fill(cr)

    ! ключевые уровни
    call draw_levels(cr, min_price, max_price, 5, real(img_height, c_double))

    ! свечи
    do i = 1, n
        call draw_candle(cr, x(i), open(i), high(i), low(i), close(i), &
                         min_price, max_price, real(img_height, c_double))
    end do

    ! сохранить PNG
    status = cairo_surface_write_to_png(surface, filename)

    call cairo_destroy(cr)
    call cairo_surface_destroy(surface)
end program main
