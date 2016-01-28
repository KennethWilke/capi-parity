import CAPI::*;

module mmio (
  input logic clock,
  input MMIOInterfaceInput mmio_in,
  output MMIOInterfaceOutput mmio_out);

  logic ack;
  logic [0:63] data;

  shift_register ack_shift(
    .clock(clock),
    .in(ack),
    .out(mmio_out.ack));

  shift_register #(64) data_shift(
    .clock(clock),
    .in(data),
    .out(mmio_out.data));

  assign mmio_out.data_parity = ~^mmio_out.data;

  // Handle MMIO AFU requests
  always_ff @ (posedge clock)
  begin
    if(mmio_in.valid & mmio_in.cfg & mmio_in.read)
    begin
      $display("AFU decriptor request");
      case(mmio_in.address)
        'h0: begin
          ack <= 1;
          data <= 64'h0000000100010010;
        end
        'h8: begin
          ack <= 1;
          data <= 64'h0000000000000001;
        end
        'hA: begin
          ack <= 1;
          data <= 64'h0000000000000100;
        end
        'hE: begin
          ack <= 1;
          data <= 64'h0100000000000000;
        end
        default: begin
          ack <= 1;
          data <= 64'h0000000000000000;
        end
      endcase
    end else begin
      ack <= 0;
      data <= 0;
    end
  end

endmodule
