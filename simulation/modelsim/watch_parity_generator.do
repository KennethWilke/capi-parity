echo "Watching parity generator"
add wave -position insertpoint -group "Parity Generator" -label "Current State" \
	sim:/top/a0/svAFU/workelement/current_state

add wave -position insertpoint -group "Parity Generator" -label "Request Size" \
	-radix decimal sim:/top/a0/svAFU/workelement/request.size

add wave -position insertpoint -group "Parity Generator" -radix hexadecimal \
	-label "Stripe1 Pointer" sim:/top/a0/svAFU/workelement/request.stripe1
add wave -position insertpoint -group "Parity Generator" -radix hexadecimal \
	-label "Stripe2 Pointer" sim:/top/a0/svAFU/workelement/request.stripe2
add wave -position insertpoint -group "Parity Generator" -radix hexadecimal \
	-label "Parity Pointer" sim:/top/a0/svAFU/workelement/request.parity
