program candle
    use iso_c_binding
    implicit none

    ! Определяем интерфейсы к функциям Cairo
    interface
        type(c_ptr) function cairo_image_surface_create(format, width, height) bind(C, name="cairo_image_surface_create")
            import :: c_int, c_ptr
            integer(c_int), value :: format, width, height
        end function

        type(c_ptr) function cairo_create(surface) bind(C, name="cairo_create")
            import :: c_ptr
            type(c_ptr), value :: surface
        end function

        subroutine cairo_set_source_rgb(cr, r, g, b) bind(C, name="cairo_set_source_rgb")
            import :: c_ptr, c_double
            type(c_ptr), value :: cr
            real(c_double), value :: r, g, b
        end subroutine

        subroutine cairo_rectangle(cr, x, y, width, height) bind(C, name="cairo_rectangle")
            import :: c_ptr, c_double
            type(c_ptr), value :: cr
            real(c_double), value :: x, y, width, height
        end subroutine

        subroutine cairo_fill(cr) bind(C, name="cairo_fill")
            import :: c_ptr
            type(c_ptr), value :: cr
        end subroutine

        subroutine cairo_move_to(cr, x, y) bind(C, name="cairo_move_to")
            import :: c_ptr, c_double
            type(c_ptr), value :: cr
            real(c_double), value :: x, y
        end subroutine

        subroutine cairo_line_to(cr, x, y) bind(C, name="cairo_line_to")
            import :: c_ptr, c_double
            type(c_ptr), value :: cr
            real(c_double), value :: x, y
        end subroutine

        subroutine cairo_stroke(cr) bind(C, name="cairo_stroke")
            import :: c_ptr
            type(c_ptr), value :: cr
        end subroutine

        integer(c_int) function cairo_surface_write_to_png(surface, filename) bind(C, name="cairo_surface_write_to_png")
            import :: c_ptr, c_char, c_int
            type(c_ptr), value :: surface
            character(c_char), dimension(*), intent(in) :: filename
        end function

        subroutine cairo_destroy(cr) bind(C, name="cairo_destroy")
            import :: c_ptr
            type(c_ptr), value :: cr
        end subroutine

        subroutine cairo_surface_destroy(surface) bind(C, name="cairo_surface_destroy")
            import :: c_ptr
            type(c_ptr), value :: surface
        end subroutine
    end interface

    ! Константы Cairo
    integer, parameter :: CAIRO_FORMAT_ARGB32 = 0

    type(c_ptr) :: surface, cr
    integer(c_int) :: status
    character(len=20), parameter :: filename = "output/chart.png"//char(0)

    ! Создаём поверхность PNG 400x300
    surface = cairo_image_surface_create(CAIRO_FORMAT_ARGB32, 400, 300)
    cr = cairo_create(surface)

    ! Фон белый
    call cairo_set_source_rgb(cr, 1.0d0, 1.0d0, 1.0d0)
    call cairo_rectangle(cr, 0.0d0, 0.0d0, 400.0d0, 300.0d0)
    call cairo_fill(cr)

    ! Рисуем фитиль свечи (чёрный)
    call cairo_set_source_rgb(cr, 0.0d0, 0.0d0, 0.0d0)
    call cairo_move_to(cr, 200.0d0, 80.0d0)
    call cairo_line_to(cr, 200.0d0, 220.0d0)
    call cairo_stroke(cr)

    ! Рисуем тело свечи (зелёный прямоугольник)
    call cairo_set_source_rgb(cr, 0.0d0, 1.0d0, 0.0d0)
    call cairo_rectangle(cr, 180.0d0, 120.0d0, 40.0d0, 100.0d0)
    call cairo_fill(cr)

    ! Сохраняем результат
    status = cairo_surface_write_to_png(surface, filename)

    ! Освобождаем ресурсы
    call cairo_destroy(cr)
    call cairo_surface_destroy(surface)
end program candle
