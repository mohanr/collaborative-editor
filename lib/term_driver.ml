open Buffer
open Types
open Configurer_intf


module MockDriver =
struct

type t = test_driver

module Make( Config : Configurer_intf.Configurer)
           ( Buffer : BufferMaker)= struct


    let empty_buffer ()=
    let module B =   Buffer.Make(Config) in
    let config= Config.set_size 10 10 in
      let nb =
      {
            pos = (config.width , config.height)
      }
      in nb

end
end
