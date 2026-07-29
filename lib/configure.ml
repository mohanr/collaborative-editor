open Configurer_intf


module Make  = struct

  include MakeConfigurer


  let set_size w h =


  let conf = {

    width = w;
    height = h;

  } in conf

 end
