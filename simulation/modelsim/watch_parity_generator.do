echo "Watching parity generator"
add wave -position insertpoint -group "Parity Generator" \
	sim:/top/a0/work_element/wed_requested \
	sim:/top/a0/work_element/wed_received

add wave -position insertpoint -group "Parity Generator" -radix decimal \
	sim:/top/a0/work_element/buffer_size

add wave -position insertpoint -group "Parity Generator" -radix hexadecimal \
	sim:/top/a0/work_element/stripe1_addr sim:/top/a0/work_element/stripe2_addr \
	sim:/top/a0/work_element/parity_addr
