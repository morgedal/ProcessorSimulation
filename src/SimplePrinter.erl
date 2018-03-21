-module('SimplePrinter').
-author("maciek").

%% API
-export([ run_printer/8 ]).
%-compile(export_all).

run_printer( ArgReg1, ArgReg2, RegA, RegB, RegC, Memory, ProgramMemory, OrdersRegister ) ->
  timer:sleep(2000),

  S_ArgReg1 = getString( ArgReg1 ),
  S_ArgReg2 = getString( ArgReg2 ),
  S_A = getString( RegA ),
  S_B = getString( RegB ),
  S_C = getString( RegC ),
  S_Memory = getString( Memory ),
  S_ProgMem = getString( ProgramMemory ),
  S_OrdReg = getString( OrdersRegister ),

  io:format( "Rejestr Argumentow 1: ~s\n", S_ArgReg1 ),
  io:format( "Rejestr Argumentow 2: ~s\n", S_ArgReg2 ),
  io:format( "Rejestr A: ~s\n", S_A ),
  io:format( "Rejestr B: ~s\n", S_B ),
  io:format( "Rejestr C: ~s\n", S_C ),
  io:format( "Rejestr rozkazow: ~s\n", S_OrdReg ),
  io:format( "Pamiec programu: ~w\n", S_ProgMem ),
  io:format( "Pamiec: ~w\n", S_Memory ),
  io:format( "********************************\n"),

  run_printer( ArgReg1, ArgReg2, RegA, RegB, RegC, Memory, ProgramMemory, OrdersRegister ).

getString( From ) ->
  From ! {self(), toString},
  receive
    { _, String } -> String
  end.