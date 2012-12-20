
`define assert(condition) \
   if (!(condition)) begin \
      $fdisplay(file, "ERROR: assertion failed"); \
      #10000; \
      $finish(1); \
   end

`define assert_eq(value, expected) \
   if (value !== expected) begin \
      $fdisplay(file, "ERROR: expected %x, found %x", expected, value); \
      #10000; \
      $finish(1); \
   end

