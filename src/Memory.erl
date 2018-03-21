-module('Memory').
-author("maciek").


%% API
-export([ run_memory/4 ]).
%-compile(export_all).

run_memory( A_register, B_register, C_register, Memory ) ->
  receive
    { _, { save_C, Address }  } ->
      State = getRegisterState( C_register ),
      NewMemory = memory_insert( Address, Memory, State ),
      run_memory( A_register, B_register, C_register, NewMemory );

    { _, { save_Arg, Arg, Address } } ->
      NewMemory = memory_insert( Address, Memory, Arg ),
      run_memory( A_register, B_register, C_register, NewMemory );

    { _, { mov , Src_Address, Dest_Address } } ->
      NewMemory = memory_insert( Dest_Address, Memory, lists:nth( Src_Address, Memory ) ),
      run_memory( A_register, B_register, C_register, NewMemory );

    { _, { get_A, Address } } ->
      A_register ! {self(),lists:nth( Address, Memory )},
      run_memory( A_register, B_register, C_register, Memory );

    { _, { get_B, Address } } ->
      B_register ! {self(),lisMets:nth( Address, Memory )},
      run_memory( A_register, B_register, C_register, Memory );

    { From, toString } ->
      From ! {self(), io_lib:format( "~s", [Memory]  ) },
      run_memory( A_register, B_register, C_register, Memory )
  end.


getRegisterState( Register ) ->
  Register ! {self(),getState},
  receive
    { Register , State } -> State
  end.

memory_insert(1, [_|Rest], New) -> [New|Rest];
memory_insert(I, [E|Rest], New) -> [E|memory_insert(I-1, Rest, New)].