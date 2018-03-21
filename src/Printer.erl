-module('Printer').
-author("maciek").

%% API
-export([ run_printer/8 ]).
%-compile(export_all).

run_printer( ArgReg1, ArgReg2, RegA, RegB, RegC, Memory, ProgramMemory, OrdersRegister ) ->
  timer:sleep(1000),

  S_ArgReg1 = getString( ArgReg1 ),
  S_ArgReg2 = getString( ArgReg2 ),
  S_A = getString( RegA ),
  S_B = getString( RegB ),
  S_C = getString( RegC ),
  S_Memory = getString( Memory ),
  S_ProgMem = getString( ProgramMemory ),
  S_OrdReg = getString( OrdersRegister ),

  format( 1, "Rejestr Argumentow 1:", S_ArgReg1 ),
  format( 2, "Rejestr Argumentow 2:", S_ArgReg2 ),
  format( 3, "Rejestr A:", S_A ),
  format( 4, "Rejestr B:", S_B ),
  format( 5, "Rejestr C:", S_C ),
  format( 6, "Rejestr rozkazow:", S_OrdReg ),
  format( 7, "Pamiec programu:", S_ProgMem ),
  format( 8, "Pamiec:", S_Memory ),

  run_printer( ArgReg1, ArgReg2, RegA, RegB, RegC, Memory, ProgramMemory, OrdersRegister ).

getString( From ) ->
  From ! {self(), toString},
  receive
    { _, String } -> String
  end.

print({gotoxy,X,Y}) ->
  io:format("\e[~p;~pH",[Y,X]);
print({printxy,X,Y,Msg}) ->
  io:format("\e[~p;~pH~p",[Y,X,Msg]);
print({clear}) ->
  io:format("\e[2J",[]).

printxy({X,Y,Msg}) ->
  io:format("\e[~p;~pH~p~n",[Y,X,Msg]).

format( Y, Msg1, Msg2 ) ->
  printxy( { 1, Y, Msg1 } ),
  printxy( { 40, Y, Msg2 } ).