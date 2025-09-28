module csv_utils
    use iso_c_binding
    use bybit_api_mod
    implicit none
contains
    subroutine save_candles_csv(candles, n, filename)
        type(candle_data), intent(in) :: candles(:)
        integer, intent(in) :: n
        character(len=*), intent(in) :: filename
        integer :: i, csv_unit, ios
        character(len=256) :: csv_filename

        csv_filename = trim(filename)
        if (len_trim(csv_filename) > 4 .and. csv_filename(len_trim(csv_filename)-3:) == ".png") then
            csv_filename(len_trim(csv_filename)-3:) = ".csv"
        else
            csv_filename = trim(csv_filename) // ".csv"
        end if

        open(newunit=csv_unit, file=csv_filename, status="replace", action="write", iostat=ios)
        if (ios /= 0) then
            print *, "Ошибка при создании CSV: ", csv_filename
            return
        end if

        write(csv_unit, '(A)') "start_time,open,high,low,close"
        do i = 1, n
            write(csv_unit,'(I0,1X,F0.6,1X,F0.6,1X,F0.6,1X,F0.6,1X,F0.6)') &
                candles(i)%start_time, candles(i)%open, candles(i)%high, candles(i)%low, candles(i)%close
        end do
        close(csv_unit)
        print *, "Данные сохранены в CSV: ", trim(csv_filename)
    end subroutine save_candles_csv
end module csv_utils
