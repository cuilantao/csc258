vlib work

vlog -timescale 1ns/1ns part2.v

vsim fsm_datapath

log {/*}
add wave {/*}

force {ld} 0 0, 1 40, 0 60

force {reset_n} 0 0, 1 20

force {clk} 0 0, 1 10 -r 20

force {go} 0 0, 1 80, 0 0 100

force {coordinate} 0000000 0, 1100110 40, 1111000 80

force {color_in} 010 0, 100 100, 101 200

run 5000ns