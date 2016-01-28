echo "Watching parity generator"
add wave -position insertpoint -group "Parity Generator" \
	sim:/top/a0/svAFU/workelement/wed_requested \
	sim:/top/a0/svAFU/workelement/wed_received

add wave -position insertpoint -group "Parity Generator" -radix decimal \
	sim:/top/a0/svAFU/workelement/buffer_size

add wave -position insertpoint -group "Parity Generator" -radix hexadecimal \
	sim:/top/a0/svAFU/workelement/stripe1_addr sim:/top/a0/svAFU/workelement/stripe2_addr \
	sim:/top/a0/svAFU/workelement/parity_addr
