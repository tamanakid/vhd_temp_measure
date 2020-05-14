onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider main
add wave -noupdate /test_interfaz_spi/dut_medt/clk
add wave -noupdate /test_interfaz_spi/dut_medt/nRst
add wave -noupdate -divider spi_signals
add wave -noupdate /test_interfaz_spi/dut_medt/spi_SI
add wave -noupdate /test_interfaz_spi/dut_medt/spi_SC
add wave -noupdate /test_interfaz_spi/dut_medt/spi_nCS
add wave -noupdate /test_interfaz_spi/dut_medt/data_sensor
add wave -noupdate -divider control
add wave -noupdate /test_interfaz_spi/dut_medt/ena_rd
add wave -noupdate -divider timing
add wave -noupdate /test_interfaz_spi/dut_medt/timer_ena_nCS
add wave -noupdate /test_interfaz_spi/dut_medt/spi_SC_down
add wave -noupdate /test_interfaz_spi/dut_medt/spi_SC_up
add wave -noupdate /test_interfaz_spi/dut_medt/spi_SI_read
add wave -noupdate /test_interfaz_spi/dut_medt/timer_2ms5_eoc
add wave -noupdate /test_interfaz_spi/dut_medt/timer_2sec_eoc
add wave -noupdate -divider timing_internal
add wave -noupdate -radix unsigned /test_interfaz_spi/dut_medt/timer/timer_2sec
add wave -noupdate -radix unsigned /test_interfaz_spi/dut_medt/timer/timer_2ms5
add wave -noupdate -radix unsigned /test_interfaz_spi/dut_medt/timer/timer_spi
add wave -noupdate /test_interfaz_spi/dut_medt/timer/timer_spi_eoc
add wave -noupdate -divider controller_internal
add wave -noupdate /test_interfaz_spi/dut_medt/spi_controller/state
add wave -noupdate -radix unsigned /test_interfaz_spi/dut_medt/spi_controller/read_bit_count
add wave -noupdate /test_interfaz_spi/dut_medt/spi_controller/read_done
add wave -noupdate -radix unsigned /test_interfaz_spi/dut_medt/spi_controller/wait_2sec_count
add wave -noupdate /test_interfaz_spi/dut_medt/spi_controller/wait_done
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {38 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
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
WaveRestoreZoom {0 ps} {28377088 ps}
