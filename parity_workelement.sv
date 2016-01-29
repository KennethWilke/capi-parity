import CAPI::*;

function logic [0:63] swap_endianness(logic [0:63] in);
  return {in[56:63], in[48:55], in[40:47], in[32:39], in[24:31], in[16:23],
          in[8:15], in[0:7]};
endfunction

module parity_workelement (
  input clock,
  input enable,
  input reset,
  input JobInterfaceInput job_in,
  input CommandInterfaceInput command_in,
  output CommandInterfaceOutput command_out,
  input BufferInterfaceInput buffer_in,
  output BufferInterfaceOutput buffer_out,
  input ResponseInterface response);

  reg wed_requested;
  reg wed_received;
  longint unsigned buffer_size;
  pointer_t stripe1_addr, stripe2_addr, parity_addr;

  assign command_out.abt = 3'b000,
         command_out.context_handle = 0,
         // Parity bits
         command_out.command_parity = ~^command_out.command,
         command_out.address_parity = ~^command_out.address,
         command_out.tag_parity = ~^command_out.tag;

  // Runtime logic
  always_ff @ (posedge clock)
  begin
    // Reset logic
    if (reset) begin
      command_out.valid <= 0;
      wed_requested <= 0;
      wed_received <= 0;
      command_out.size <= 32;
    // Running logic
    end else if(enable) begin
      if(!wed_requested) begin
        command_out.command <= 12'h0A00;
        command_out.tag <= 8'b11111111;
        command_out.address <= job_in.address;
        command_out.valid <= 1;
        wed_requested <= 1;
      end else if (wed_requested & !wed_received & buffer_in.write_valid) begin
        $display("Got WED buffer");
        // Swizzle all these inputs into big-endian byte order
        buffer_size <= swap_endianness(buffer_in.write_data[0:63]);
        stripe1_addr <= swap_endianness(buffer_in.write_data[64:127]);
        stripe2_addr <= swap_endianness(buffer_in.write_data[128:191]);
        parity_addr <= swap_endianness(buffer_in.write_data[192:255]);
        wed_received <= 1;
        command_out.address <= stripe1_addr;
        command_out.valid <= 0;
      end else begin
        command_out.valid <= 0;
      end
    end
  end

endmodule
