open Buffer
open Types
open Configurer_intf


module MockDriver =
struct

type t = test_driver

module Make( Config : Configurer_intf.Configurer) = struct


    let empty_buffer ()=
    let module Buffer  = Buffer.Make(Config) in
    let config= Config.set_size () in
      let nb =
      {
            buffer = Buffer.new_buffer();
            scroll_buffer = Buffer.new_buffer();
            pos = (config.width , config.height)
      }
      in nb

end
end
