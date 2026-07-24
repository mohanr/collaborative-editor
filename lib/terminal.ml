open Term_driver
open Buffer

module type TERMINAL_OPERATIONS  = sig
    val draw : unit -> unit
end

module Terminal                 (* Consider adding a state Monad *)
  : TERMINAL_OPERATIONS  = struct

let draw() = ()

(*  TODO What is a mock driver ? *)
type terminal = {
    driver : MockDriver.t;
}

end
