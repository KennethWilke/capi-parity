package CAPI;
  typedef longint unsigned pointer_t;

  typedef struct packed {
    bit valid;
    byte command;
    bit command_parity;
    pointer_t address;
    bit address_parity;
  } JobInterfaceInput;

  typedef struct packed {
    bit running;
    bit done;
    bit cack;
    pointer_t error;
    bit yield;
  } JobInterfaceOutput;

  typedef struct packed {
    byte unsigned room;
  } CommandInterfaceInput;

  typedef struct packed {
    bit valid;
    byte tag;
    bit tag_parity;
    bit [0:12] command;
    bit command_parity;
    bit [0:2] abt;
    pointer_t address;
    bit address_parity;
    bit [0:15] context_handle;
    bit [0:11] size;
  } CommandInterfaceOutput;

  typedef struct packed {
    bit read_valid;
    byte read_tag;
    bit read_tag_parity;
    bit [0:5] read_address;
    bit write_valid;
    byte write_tag;
    bit write_tag_parity;
    bit [0:5] write_address;
    bit [0:511] write_data;
    byte write_parity;
  } BufferInterfaceInput;

  typedef struct packed {
    bit [0:3] read_latency;
    bit [0:511] read_data;
    byte read_parity;
  } BufferInterfaceOutput;

  typedef struct packed {
    bit valid;
    byte tag;
    bit tag_parity;
    byte response;
    bit [0:8] credits;
    bit [0:1] cache_state;
    bit [0:12] cache_pos;
  } ResponseInterface;

  typedef struct packed {
    bit valid;
    bit cfg;
    bit read;
    bit doubleword;
    bit [0:23] address;
    bit address_parity;
    bit [0:63] data;
    bit data_parity;
  } MMIOInterfaceInput;

  typedef struct packed {
    bit ack;
    bit [0:63] data;
    bit data_parity;
  } MMIOInterfaceOutput;

endpackage
