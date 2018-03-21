-module('ALU').
-author("maciek").


%% API
-export([ run_ALU/3 ]).
%-compile(export_all).

run_ALU( A_register, B_register, C_register ) ->
  receive
    { _, OperationName } ->
      A = getRegisterState( A_register ),
      B = getRegisterState( B_register ),
      C_register ! {self(),doOperation( A, B, OperationName )},
      run_ALU( A_register, B_register, C_register )
  end.

getRegisterState( Register ) ->
  Register ! {self(),getState},
  receive
    { Register , State } -> State
  end.

doOperation( A, B, "AND" ) -> A and B;
doOperation( A, B, "OR" ) -> A or B;
doOperation( A, _, "NOT" ) -> not A;
doOperation( A, B, "XOR" ) -> A xor B;
doOperation( A, B, "BSR" ) -> A bsr B;
doOperation( A, B, "BSL" ) -> A bsl B;
doOperation( A, B, "+" ) ->
  R = A + B,
  R rem 512;
doOperation( A, B, "-" ) -> abs( A - B );
doOperation( A, B, "*" ) ->
  R = A * B,
  R rem 512;
doOperation( A, B, "/" ) -> A div B.

