import CAPI::*;

module parity_afu (
  input clock,
  output timebase_request,
  output parity_enabled,
  input JobInterfaceInput job_in,
  output JobInterfaceOutput job_out,
  input CommandInterfaceInput command_in,
  output CommandInterfaceOutput command_out,
  input BufferInterfaceInput buffer_in,
  output BufferInterfaceOutput buffer_out,
  input ResponseInterface response,
  input MMIOInterfaceInput mmio_in,
  output MMIOInterfaceOutput mmio_out);

  assign timebase_request = 0,
    parity_enabled = 1,
    job_out.yield = 0;

  always_ff @(posedge clock) begin
    $display("Clock!");
    job_out.running <= 0;
    job_out.done <= 0;
    buffer_out <= 0;
  end

endmodule
