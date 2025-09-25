module candle_mod
    use iso_c_binding
    use cairo_interface
    implicit none
contains
    subroutine draw_candle(cr, x, open, high, low, close, min_price, max_price, height)
        type(c_ptr), value :: cr
        real(c_double), value :: x, open, high, low, close
        real(c_double), value :: min_price, max_price, height
        real(c_double) :: y_open, y_close, y_high, y_low
        real(c_double) :: candle_width

        candle_width = 20.0d0

        ! преобразуем цены в экранные координаты
        y_open  = height - (open  - min_price) / (max_price - min_price) * height
        y_close = height - (close - min_price) / (max_price - min_price) * height
        y_high  = height - (high  - min_price) / (max_price - min_price) * height
        y_low   = height - (low   - min_price) / (max_price - min_price) * height

        ! цвет свечи
        if (close >= open) then
            call cairo_set_source_rgb(cr, 0.0d0, 0.8d0, 0.0d0) ! зелёная
        else
            call cairo_set_source_rgb(cr, 0.8d0, 0.0d0, 0.0d0) ! красная
        end if

        ! тень (high-low)
        call cairo_set_line_width(cr, 1.5d0)
        call cairo_move_to(cr, x, y_high)
        call cairo_line_to(cr, x, y_low)
        call cairo_stroke(cr)

        ! тело свечи
        call cairo_rectangle(cr, x - candle_width/2.0d0, min(y_open,y_close), &
                             candle_width, abs(y_close - y_open))
        call cairo_fill(cr)
    end subroutine draw_candle
end module candle_mod
