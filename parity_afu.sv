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

  logic jdone;

  assign timebase_request = 0,
    parity_enabled = 1,
    job_out.yield = 0;

  shift_register jdone_shift(
    .clock(clock),
    .in(jdone),
    .out(job_out.done));

  mmio mmio_handler(
    .clock(clock),
    .mmio_in(mmio_in),
    .mmio_out(mmio_out));

  parity_workelement workelement(
    .clock(clock),
    .enable(job_out.running),
    .reset(job_out.done),
    .job_in(job_in),
    .command_in(command_in),
    .command_out(command_out),
    .buffer_in(buffer_in),
    .buffer_out(buffer_out),
    .response(response));

  always_ff @(posedge clock) begin
    if(job_in.valid) begin
      case(job_in.command)
        RESET: begin
          $display("Reset");
          job_out.running <= 0;
          jdone <= 1;
        end
        START: begin
          $display("Start");
          job_out.running <= 1;
          jdone <= 0;
        end
      endcase
    end else begin
      jdone <= 0;
    end
  end

endmodule
