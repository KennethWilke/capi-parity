import CAPI::*;

function logic [0:63] swap_endianness(logic [0:63] in);
  return {in[56:63], in[48:55], in[40:47], in[32:39], in[24:31], in[16:23],
          in[8:15], in[0:7]};
endfunction

typedef struct {
  longint unsigned size;
  pointer_t stripe1;
  pointer_t stripe2;
  pointer_t parity;
} parity_request;

typedef enum {
  START,
  WAITING_FOR_REQUEST,
  REQUEST_STRIPES,
  WAITING_FOR_STRIPES,
  WRITE_PARITY,
  DONE
} state;

typedef enum logic [0:7] {
  REQUEST_READ,
  STRIPE1_READ,
  STRIPE2_READ,
  PARITY_WRITE,
  DONE_WRITE
} request_tag;

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

  state current_state;
  parity_request request;
  longint unsigned offset;
  logic [0:1023] stripe1_data;
  logic [0:1023] stripe2_data;
  logic [0:1023] parity_data;
  logic stripe_valid;

  assign command_out.abt = 3'b000,
         command_out.context_handle = 0,
         buffer_out.read_latency = 1,
         // Parity bits
         command_out.command_parity = ~^command_out.command,
         command_out.address_parity = ~^command_out.address,
         command_out.tag_parity = ~^command_out.tag,
         parity_data = stripe1_data ^ stripe2_data,
         buffer_out.read_parity = ^buffer_out.read_data;

  // Runtime logic
  always_ff @ (posedge clock)
  begin
    // Reset logic
    if (reset) begin
      current_state = START;
      command_out.valid <= 0;
      command_out.size <= 0;
      request.size = 0;
      request.stripe1 = 0;
      request.stripe2 = 0;
      request.parity = 0;
      offset <= 0;
      stripe_valid <= 0;
    // Running logic
    end else if(enable) begin
      case (current_state)
        START: begin
          command_out.size <= 128;
          command_out.command <= READ_CL_NA;
          command_out.tag <= REQUEST_READ;
          command_out.address <= job_in.address;
          command_out.valid <= 1;
          current_state = WAITING_FOR_REQUEST;
        end
        WAITING_FOR_REQUEST: begin
          command_out.valid <= 0;
          // Swizzle all these inputs into big-endian byte order
          request.size <= swap_endianness(buffer_in.write_data[0:63]);
          request.stripe1 <= swap_endianness(buffer_in.write_data[64:127]);
          request.stripe2 <= swap_endianness(buffer_in.write_data[128:191]);
          request.parity <= swap_endianness(buffer_in.write_data[192:255]);
          if (buffer_in.write_valid & buffer_in.write_tag == REQUEST_READ) begin
            current_state <= REQUEST_STRIPES;
          end
        end
        REQUEST_STRIPES: begin
          command_out.valid <= 1;
          if (command_out.tag == REQUEST_READ) begin
            command_out.address <= request.stripe1;
            command_out.tag <= STRIPE1_READ;
          end else begin
            command_out.address <= request.stripe2;
            command_out.tag <= STRIPE2_READ;
            current_state <= WAITING_FOR_STRIPES;
          end
        end
        WAITING_FOR_STRIPES: begin
          command_out.valid <= 0;
          if (buffer_in.write_valid) begin
            case (buffer_in.write_tag)
              STRIPE1_READ: begin
                if (buffer_in.write_address == 0) begin
                  stripe1_data[0:511] <= buffer_in.write_data;
                end else begin
                  stripe1_data[512:1023] <= buffer_in.write_data;
                end
              end
              STRIPE2_READ: begin
                if (buffer_in.write_address == 0) begin
                  stripe2_data[0:511] <= buffer_in.write_data;
                end else begin
                  stripe2_data[512:1023] <= buffer_in.write_data;
                end
              end
            endcase
          end
          if (response.valid &
              (response.tag == STRIPE1_READ |
               response.tag == STRIPE2_READ)) begin
            if (stripe_valid) begin
              current_state <= WRITE_PARITY;
            end else begin
              stripe_valid <= 1;
            end
          end
        end
        WRITE_PARITY: begin
          $display("Parity!");
          command_out.command <= WRITE_NA;
          command_out.size <= 1;
          command_out.address <= job_in.address + 32;
          command_out.tag <= PARITY_WRITE;
          command_out.valid <= 1;
          buffer_out.read_data[256:263] <= 1;
          current_state <= DONE;
        end
        DONE: begin
          $display("Done");
          command_out.valid <= 0;
          /*if (command_out.tag == DONE_WRITE) begin
            command_out.valid <= 0;
          end else begin
            command_out.valid <= 1;
          end*/
        end
      endcase
    end
  end

endmodule
