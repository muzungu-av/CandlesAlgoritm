module cairo_interface
    use iso_c_binding
    implicit none

    integer(c_int), parameter :: CAIRO_FORMAT_ARGB32 = 0

    interface
        function cairo_image_surface_create(format, width, height) bind(C, name="cairo_image_surface_create")
            import :: c_int, c_ptr
            integer(c_int), value :: format, width, height
            type(c_ptr) :: cairo_image_surface_create
        end function

        function cairo_create(target) bind(C, name="cairo_create")
            import :: c_ptr
            type(c_ptr), value :: target
            type(c_ptr) :: cairo_create
        end function

        subroutine cairo_destroy(cr) bind(C, name="cairo_destroy")
            import :: c_ptr
            type(c_ptr), value :: cr
        end subroutine

        subroutine cairo_surface_destroy(surface) bind(C, name="cairo_surface_destroy")
            import :: c_ptr
            type(c_ptr), value :: surface
        end subroutine

        function cairo_surface_write_to_png(surface, filename) bind(C, name="cairo_surface_write_to_png")
            import :: c_ptr, c_char, c_int
            type(c_ptr), value :: surface
            character(c_char), dimension(*) :: filename
            integer(c_int) :: cairo_surface_write_to_png
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

        subroutine cairo_set_line_width(cr, width) bind(C, name="cairo_set_line_width")
            import :: c_ptr, c_double
            type(c_ptr), value :: cr
            real(c_double), value :: width
        end subroutine

        subroutine cairo_set_dash(cr, dashes, ndash, offset) bind(C, name="cairo_set_dash")
            import :: c_ptr, c_double, c_int
            type(c_ptr), value :: cr
            real(c_double), dimension(*), intent(in) :: dashes
            integer(c_int), value :: ndash
            real(c_double), value :: offset
        end subroutine

        subroutine cairo_show_text(cr, text) bind(C, name="cairo_show_text")
            import :: c_ptr, c_char
            type(c_ptr), value :: cr
            character(c_char), dimension(*) :: text
        end subroutine
    end interface
end module cairo_interface
