-module('ControlUnit').
-author("maciek").

%% API
%-export([ start/1, run_Control_Unit/9 ]).
-compile(export_all).

start( HexList ) ->
    ArgReg1 = spawn( 'Register', run_data_register, [ 0 ] ),
    ArgReg2 = spawn( 'Register', run_data_register, [ 0 ] ),
    RegA = spawn( 'Register', run_data_register, [ 0 ] ),
    RegB = spawn( 'Register', run_data_register, [ 0 ] ),
    RegC = spawn( 'Register', run_data_register, [ 0 ] ),
    Memory = spawn( 'Memory', run_memory, [ RegA, RegB, RegC, [ 0 || _<-lists:seq(1,32) ] ] ),
    ProgramMemory = spawn( 'ProgramMemory', run_Program_Memory, [ HexList, 1 ] ),
    OrdersRegister = spawn( 'OrdersRegister', run_orders_register, [ ProgramMemory, ArgReg1, ArgReg2, 666 ] ),
    ALU = spawn( 'ALU', run_ALU, [ RegA, RegB, RegC ] ),
    spawn( 'ControlUnit', run_Control_Unit, [ArgReg1, ArgReg2, RegA, RegB, RegC, Memory, ProgramMemory, OrdersRegister, ALU] ),
    'Printer':run_printer( ArgReg1, ArgReg2, RegA, RegB, RegC, Memory, ProgramMemory, OrdersRegister ).



run_Control_Unit( ArgReg1, ArgReg2, RegA, RegB, RegC, Memory, ProgramMemory, OrdersRegister, ALU ) ->
  OrdersRegister ! {self(),getNextOrder},
  timer:sleep(20),
  O = getOrderValue( OrdersRegister ),
  doOperation( O, ArgReg1, ArgReg2, RegA, RegB, RegC, Memory, ProgramMemory, OrdersRegister, ALU ),
  timer:sleep(3000),
  run_Control_Unit( ArgReg1, ArgReg2, RegA, RegB, RegC, Memory, ProgramMemory, OrdersRegister, ALU ).

getOrderValue( OrdersRegister ) ->
  OrdersRegister ! {self(),getOrderValue},
  receive
    { _, OrderValue } -> OrderValue
  end.

getArg( Register ) ->
  Register ! {self(),getState},
  receive
    { _, Arg } -> Arg
  end.

% 0 - Moving value from memory address 1 (ArgReg1) to memory address 2 (ArgReg2)
doOperation( 0, ArgReg1, ArgReg2, _, _, _, Memory, _, _, _ ) ->
  Memory ! {self(),{ mov, getArg( ArgReg1 ), getArg( ArgReg2 ) }};

% 1 - Saving argument (ArgReg1) to specified adress (ArgReg2) in memory
doOperation( 1, ArgReg1, ArgReg2, _, _, _, Memory, _, _, _ ) ->
  Memory ! {self(),{ save_Arg, getArg( ArgReg1 ), getArg( ArgReg2 ) }};

% 2 - Moving argument (ArgReg1) to register A
doOperation( 2, ArgReg1, _, RegA, _, _, _, _, _, _ ) ->
  RegA ! {self(), getArg( ArgReg1 )};

% 3 - Moving argument (ArgReg1) to register B
doOperation( 3, ArgReg1, _, _, RegB, _, _, _, _, _ ) ->
  RegB ! {self(), getArg( ArgReg1 )};

% 4 - Moving argument from specified adress (ArgReg1) in memory to register A
doOperation( 4, ArgReg1, _, _, _, _, Memory, _, _, _ ) ->
  Memory ! {self(),{ get_A, getArg( ArgReg1 ) }};

% 5 - Moving argument from specified adress (ArgReg1) in memory to register B
doOperation( 5, ArgReg1, _, _, _, _, Memory, _, _, _ ) ->
  Memory ! {self(),{ get_B, getArg( ArgReg1 ) }};

% 6 - Saving to specified adress (ArgReg1) in memory value from register C
doOperation( 6, ArgReg1, _, _, _, _, Memory, _, _, _ ) ->
  Memory ! {self(),{ save_C, getArg( ArgReg1 ) }};

% 7 - A XOR B -> C
doOperation( 7, _, _, _, _, _, _, _, _, ALU ) ->
  ALU ! {self(),"XOR"};

% 8 - A AND B -> C
doOperation( 8, _, _, _, _, _, _, _, _, ALU ) ->
  ALU ! {self(),"AND"};

% 9 - A OR B -> C
doOperation( 9, _, _, _, _, _, _, _, _, ALU ) ->
  ALU ! {self(),"OR"};

% 0xA - NOT A -> C
doOperation( 16#A, _, _, _, _, _, _, _, _, ALU ) ->
  ALU ! {self(),"NOT"};

% 0xB - A >> B -> C ( A bit shift right B times )
doOperation( 16#B, _, _, _, _, _, _, _, _, ALU ) ->
  ALU ! {self(),"BSR"};

% 0xC - A << B -> C ( A bit shift left B times )
doOperation( 16#C, _, _, _, _, _, _, _, _, ALU ) ->
  ALU ! {self(),"BSL"};

% 0xD - A + B -> C ( if result overflows register capacity first bit is deleted )
doOperation( 16#D, _, _, _, _, _, _, _, _, ALU ) ->
  ALU ! {self(),"+"};

% 0xE - abs(A - B) -> C ( difference between A and B )
doOperation( 16#E, _, _, _, _, _, _, _, _, ALU ) ->
  ALU ! {self(),"-"};

% 0xF - A * B -> C ( if result overflows register capacity overflowing bits are deleted )
doOperation( 16#F, _, _, _, _, _, _, _, _, ALU ) ->
  ALU ! {self(),"*"};

% 0x10 - floor(A / B) -> C
doOperation( 16#10, _, _, _, _, _, _, _, _, ALU ) ->
  ALU ! {self(),"/"};

% 0x11 - terminating
doOperation( 16#11, _, _, _, _, _, _, _, _, _  ) ->
  exit( endOfInstructions ).