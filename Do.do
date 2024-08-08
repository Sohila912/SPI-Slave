vlib work
vlog finalSPI.v SPI_Slave.v RAM.v
vsim -voptargs=+acc work.tb_finalSPI
add wave *
run -all
#quit -sim