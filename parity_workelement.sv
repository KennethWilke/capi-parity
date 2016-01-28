import CAPI::*;

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
        buffer_size <= {buffer_in.write_data[56:63],
                        buffer_in.write_data[48:55],
                        buffer_in.write_data[40:47],
                        buffer_in.write_data[32:39],
                        buffer_in.write_data[24:31],
                        buffer_in.write_data[16:23],
                        buffer_in.write_data[8:15],
                        buffer_in.write_data[0:7]};
        stripe1_addr <= {buffer_in.write_data[120:127],
                         buffer_in.write_data[112:119],
                         buffer_in.write_data[104:111],
                         buffer_in.write_data[96:103],
                         buffer_in.write_data[88:95],
                         buffer_in.write_data[80:87],
                         buffer_in.write_data[72:79],
                         buffer_in.write_data[64:71]};
        stripe2_addr <= {buffer_in.write_data[184:191],
                         buffer_in.write_data[176:183],
                         buffer_in.write_data[168:175],
                         buffer_in.write_data[160:167],
                         buffer_in.write_data[152:159],
                         buffer_in.write_data[144:151],
                         buffer_in.write_data[136:143],
                         buffer_in.write_data[128:135]};
        parity_addr <= {buffer_in.write_data[248:255],
                        buffer_in.write_data[240:247],
                        buffer_in.write_data[232:239],
                        buffer_in.write_data[224:231],
                        buffer_in.write_data[216:223],
                        buffer_in.write_data[208:215],
                        buffer_in.write_data[200:207],
                        buffer_in.write_data[192:199]};
        wed_received <= 1;
        command_out.address <= stripe1_addr;
        command_out.valid <= 0;
      end else begin
        command_out.valid <= 0;
      end
    end
  end

endmodule
