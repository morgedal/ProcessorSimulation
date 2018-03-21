-module('Register').
-author("maciek").

%% API
-export([ run_data_register/1 ]).
%-compile(export_all).

run_data_register( State ) ->
  receive
    { From, getState } ->
      From ! {self(),State},
      run_data_register( State );

    { _, { sendState, PID } } ->
      PID ! {self(),State},
      run_data_register( State );

    { From, toString } ->
      From ! {self(), io_lib:format( "~B", [State] )},
      run_data_register( State );

    { _, NewState } ->
      run_data_register( NewState )

  end.