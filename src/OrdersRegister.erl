-module('OrdersRegister').
-author("maciek").

%% API
-export([run_orders_register/4]).
%-compile(export_all).

run_orders_register( ProgramMemory, ArgReg1, ArgReg2, ActualOrder ) ->
  receive
    { From, getOrderValue } ->
      From ! {self(), ActualOrder },
      run_orders_register( ProgramMemory, ArgReg1, ArgReg2, ActualOrder );

    { _, getNextOrder } ->
      NewOrder = getValue( ProgramMemory ),
      getArgs( NewOrder, ArgReg1, ArgReg2, ProgramMemory ),
      run_orders_register( ProgramMemory, ArgReg1, ArgReg2, NewOrder );

    { From, toString } ->
      From ! {self(), io_lib:format( "~w", [ActualOrder] ) },
      run_orders_register( ProgramMemory, ArgReg1, ArgReg2, ActualOrder )
  end.


getValue( ProgramMemory ) ->
  ProgramMemory ! {self(),getNext} ,
  receive
    { _ , Value } -> Value
  end.


getArgs( OrderNumber, ArgReg1, ArgReg2, ProgramMemory )
  when ( (OrderNumber >= 16#0) and (OrderNumber =< 16#1) ) ->
    ArgReg1 ! {self(),getValue( ProgramMemory )},
    ArgReg2 ! {self(),getValue( ProgramMemory )};

getArgs( OrderNumber, ArgReg1, _, ProgramMemory )
  when ( (OrderNumber > 16#1) and (OrderNumber < 16#7) ) ->
    ArgReg1 ! {self(), getValue( ProgramMemory )};

getArgs( _, _, _, _ ) ->
  { ok }.

