
! «nice axis ticks» (красивые деления осей)
module levels_mod
    use iso_c_binding
    use cairo_interface
    implicit none
contains
    function nice_number(x, round) result(nice)
        real(c_double), intent(in) :: x
        logical, intent(in) :: round
        real(c_double) :: nice
        integer :: expv
        real(c_double) :: f

        expv = floor(log10(x))
        f = x / (10.0d0**expv)

        if (round) then
            if (f < 1.5d0) then
                f = 1.0d0
            else if (f < 3.0d0) then
                f = 2.0d0
            else if (f < 7.0d0) then
                f = 5.0d0
            else
                f = 10.0d0
            end if
        else
            if (f <= 1.0d0) then
                f = 1.0d0
            else if (f <= 2.0d0) then
                f = 2.0d0
            else if (f <= 5.0d0) then
                f = 5.0d0
            else
                f = 10.0d0
            end if
        end if

        nice = f * (10.0d0**expv)
    end function nice_number

    subroutine draw_levels(cr, min_price, max_price, n_levels, height)
        type(c_ptr), value :: cr
        real(c_double), value :: min_price, max_price
        integer, value :: n_levels
        real(c_double), value :: height
        integer :: i
        real(c_double) :: range, step, graph_min, graph_max, level, y
        character(len=32) :: label

        ! шаг по nice number
        range = nice_number(max_price - min_price, .false.)
        step  = nice_number(range / real(n_levels, c_double), .true.)

        ! подгоняем min и max
        graph_min = floor(min_price / step) * step
        graph_max = ceiling(max_price / step) * step

        ! рисуем линии
        do level = graph_min, graph_max, step
            if (level <= max_price .and. level >= min_price) then
                y = height - (level - min_price) / (max_price - min_price) * height

                call cairo_set_source_rgb(cr, 0.0d0, 0.0d0, 0.0d0)
                call cairo_set_dash(cr, [5.0d0, 5.0d0], 2, 0.0d0)
                call cairo_move_to(cr, 0.0d0, y)
                call cairo_line_to(cr, 300.0d0, y)
                call cairo_stroke(cr)
                call cairo_set_dash(cr, [0.0d0], 0, 0.0d0)

                ! формат подписи
                if (abs(level - nint(level)) < 0.05d0) then
                    write(label, '(F6.0)') level
                else if (step >= 1.0d0) then
                    write(label, '(F6.1)') level
                else
                    write(label, '(F7.3)') level
                end if

                call cairo_move_to(cr, 5.0d0, y - 2.0d0)
                call cairo_show_text(cr, trim(adjustl(label))//char(0))
            end if
        end do
    end subroutine draw_levels
end module levels_mod
