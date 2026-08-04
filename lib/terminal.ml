open Term_driver
open Buffer
open Types


module type TERMINAL_OPERATIONS  = sig
    val draw : unit -> unit
    val ansi_escape_codes : unit -> ansi_escape_codes

  module Cursor : sig
    val hide_cursor  : unit -> string
    val set_cursor_position : location ref -> string
  end
end

module Terminal                 (* Consider adding a state Monad *)
  : TERMINAL_OPERATIONS  = struct

let draw() = ()

(*  TODO What is a mock driver ? *)
type terminal = {
    driver : MockDriver.t;
}

let ansi_escape_codes() = {
  text_cursor_enable = "\x1b[?25h";
  reset_text_cursor_enable = "\x1b[?25l"
}

module Cursor = struct

    let location = ref {x = 0 ; y = 0 }

    let hide_cursor ()=
       let code = ansi_escape_codes() in
       code.reset_text_cursor_enable

    let show_cursor ()=
       let code = ansi_escape_codes() in
       code.text_cursor_enable

    let get_cursor_location () =
        !location

    let set_cursor_position location=
        location := !location;
        Printf.sprintf "\x1b[%d;%dH" !location.x !location.y;
end
end
