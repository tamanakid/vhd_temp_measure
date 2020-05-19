onerror {resume}
quietly virtual signal -install /test_temp_conv/dut_medt { (context /test_temp_conv/dut_medt )(pulse_timing & pulse_units & toggle_timing & toggle_units )} pulses
quietly WaveActivateNextPane {} 0
add wave -noupdate /test_temp_conv/dut_medt/clk
add wave -noupdate /test_temp_conv/dut_medt/nRst
add wave -noupdate -expand -group Pulses /test_temp_conv/dut_medt/pulse_timing
add wave -noupdate -expand -group Pulses /test_temp_conv/dut_medt/pulse_units
add wave -noupdate -expand -group Pulses /test_temp_conv/dut_medt/pulses_filter/timing_sync
add wave -noupdate -expand -group Pulses /test_temp_conv/dut_medt/pulses_filter/units_sync
add wave -noupdate -expand -group Pulses /test_temp_conv/dut_medt/toggle_timing
add wave -noupdate -expand -group Pulses /test_temp_conv/dut_medt/toggle_units
add wave -noupdate -expand -group SPI_interface /test_temp_conv/dut_medt/spi_SI
add wave -noupdate -expand -group SPI_interface /test_temp_conv/dut_medt/spi_SC
add wave -noupdate -expand -group SPI_interface /test_temp_conv/dut_medt/spi_nCS
add wave -noupdate -expand -group SPI_interface /test_temp_conv/dut_medt/data_sensor
add wave -noupdate -expand -group SPI_Controller_signals /test_temp_conv/dut_medt/ena_rd
add wave -noupdate -expand -group SPI_Controller_signals /test_temp_conv/dut_medt/read_done
add wave -noupdate -expand -group SPI_Controller_signals /test_temp_conv/dut_medt/timer_ena_nCS
add wave -noupdate -expand -group SPI_Controller_signals /test_temp_conv/dut_medt/spi_SC_down
add wave -noupdate -expand -group SPI_Controller_signals /test_temp_conv/dut_medt/spi_SC_up
add wave -noupdate -expand -group SPI_Controller_signals /test_temp_conv/dut_medt/spi_SI_read
add wave -noupdate -expand -group SPI_Controller_status /test_temp_conv/dut_medt/spi_controller/state
add wave -noupdate -expand -group SPI_Controller_status -radix unsigned /test_temp_conv/dut_medt/spi_controller/read_bit_count
add wave -noupdate -expand -group Timer /test_temp_conv/dut_medt/timer/timer_wait_done
add wave -noupdate -expand -group Timer -radix unsigned /test_temp_conv/dut_medt/timer/read_interval
add wave -noupdate -expand -group Timer -radix unsigned /test_temp_conv/dut_medt/timer/timer_2sec
add wave -noupdate -expand -group Timer /test_temp_conv/dut_medt/timer/timer_2sec_eoc
add wave -noupdate -expand -group Timer -radix unsigned /test_temp_conv/dut_medt/timer/timer_2ms5
add wave -noupdate -expand -group Timer /test_temp_conv/dut_medt/timer/timer_2ms5_eoc
add wave -noupdate -expand -group Timer -radix unsigned /test_temp_conv/dut_medt/timer/timer_spi
add wave -noupdate -expand -group Timer /test_temp_conv/dut_medt/timer/timer_spi_eoc
add wave -noupdate -expand -group Temperature /test_temp_conv/dut_medt/read_done
add wave -noupdate -expand -group Temperature -radix decimal /test_temp_conv/dut_medt/temp_conversion/temp_celsius_2c
add wave -noupdate -expand -group Temperature -radix decimal /test_temp_conv/dut_medt/temp_conversion/temp_fahrenheit_2c
add wave -noupdate -expand -group Temperature -radix decimal /test_temp_conv/dut_medt/temp_conversion/temp_kelvin_2c
add wave -noupdate -expand -group Temperature -radix decimal /test_temp_conv/dut_medt/temp_conversion/temperature_2c
add wave -noupdate -expand -group Temperature -radix unsigned /test_temp_conv/dut_medt/temp_conversion/temperature_bin
add wave -noupdate -expand -group Temperature /test_temp_conv/dut_medt/temp_conversion/temperature_sgn
add wave -noupdate -expand -group Temperature /test_temp_conv/dut_medt/temp_binary_to_bcd/temperature_bcd
add wave -noupdate -expand -group Display /test_temp_conv/dut_medt/disp_mux
add wave -noupdate -expand -group Display /test_temp_conv/dut_medt/disp_seg
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {303765512 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 187
configure wave -valuecolwidth 100
configure wave -justifyvalue right
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {301492969 ps} {306854751 ps}
