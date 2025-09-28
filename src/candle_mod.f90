module candle_mod
    use iso_c_binding
    use cairo_interface
    implicit none
contains
    subroutine draw_candle(cr, x, open, high, low, close, min_price, max_price, height, candle_width)
        type(c_ptr), value :: cr
        real(c_double), intent(in) :: x, open, high, low, close, min_price, max_price, height, candle_width
        real(c_double) :: candle_height, body_height, top, bottom, open_y, close_y, half_width, line_width = 1.0d0
        real(c_double) :: r, g, b

        half_width = candle_width / 2.0d0

        ! Нормализуем цены к высоте изображения
        candle_height = height
        top = height * (1.0d0 - (high - min_price) / (max_price - min_price))
        bottom = height * (1.0d0 - (low - min_price) / (max_price - min_price))
        open_y = height * (1.0d0 - (open - min_price) / (max_price - min_price))
        close_y = height * (1.0d0 - (close - min_price) / (max_price - min_price))

! Определяем цвет свечи
        if (close > open) then
            r = 0.0d0
            g = 1.0d0
            b = 0.0d0   ! Зеленый для восходящей свечи
        else if (close < open) then
            r = 1.0d0
            g = 0.0d0
            b = 0.0d0   ! Красный для нисходящей свечи
        else
            r = 0.7d0
            g = 0.7d0
            b = 0.7d0   ! Серый для доджи
        end if

        ! Рисуем тень свечи
        call cairo_set_source_rgb(cr, r, g, b)
        call cairo_set_line_width(cr, line_width)
        call cairo_move_to(cr, x, top)
        call cairo_line_to(cr, x, bottom)
        call cairo_stroke(cr)

        ! Рисуем тело свечи
        call cairo_set_source_rgb(cr, r, g, b)
        if (close > open) then
            body_height = close_y - open_y
            call cairo_rectangle(cr, x - half_width, open_y, candle_width, body_height)
        else if (close < open) then
            body_height = open_y - close_y
            call cairo_rectangle(cr, x - half_width, close_y, candle_width, body_height)
        else
            body_height = 1.0d0  ! Минимальная высота для доджи
            call cairo_rectangle(cr, x - half_width, open_y, candle_width, body_height)
        end if
        call cairo_fill(cr)
    end subroutine draw_candle
end module candle_mod
