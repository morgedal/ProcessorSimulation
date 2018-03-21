-module('ProgramMemory').
-author("maciek").

%% API
-export([ run_Program_Memory/2 ]).
%-compile(export_all).

run_Program_Memory( HexList, Actual_Ptr ) ->
  receive
    { From, getNext } ->
      From ! {self(), lists:nth( Actual_Ptr, HexList )},
      run_Program_Memory( HexList, Actual_Ptr+1 );

    { From, toString } ->
      From ! {self(), io_lib:format( "~s", [HexList] )},
      run_Program_Memory( HexList, Actual_Ptr )
  end.
