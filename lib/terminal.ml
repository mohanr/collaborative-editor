open Term_driver
open Buffer

module type TERMINAL_OPERATIONS  = sig
    val render : unit -> unit
end

module Terminal                 (* Consider adding a state Monad *)
  : TERMINAL_OPERATIONS  = struct

let render() = ()

type terminal = {
    driver : MockDriver.t;
    buffers :  Buffer.t;
}

end
