open Term_driver
open Buffer
open Types


module type terminal_operations  = sig
    val draw : unit -> unit
    val ansi_escape_codes : unit -> ansi_escape_codes
    val get_out_channel: unit -> Unix.file_descr
    val get_in_channel: unit -> in_channel

  module Cursor : sig
    val hide_cursor  : unit -> string
    val set_cursor_position : location ref -> string
  end
end

module Terminal                 (* consider adding a state monad *)
  : terminal_operations  = struct

let get_out_channel() =
   let stdout_fd  = Unix.descr_of_out_channel stdout in
   if Unix.isatty Unix.stdin then
     let () = prerr_endline "Warning: getting stdin, which is a tty." in
     stdout_fd
   else
     let () = prerr_endline "Error: getting stdin, which is a tty." in
     failwith "Error: getting stdin, which is a tty."

let get_in_channel() =
   (* let stdin_fd = Unix.descr_of_in_channel stdin in *)

   if Unix.isatty Unix.stdin then
     let () = prerr_endline "Warning: getting stdin, which is a tty." in
     stdin
   else
     let () = prerr_endline "Error: getting stdin, which is a tty." in
     failwith "Error: getting stdin, which is a tty."

let enter_alt_screen () =
  let fd =get_out_channel () in
  ignore (Unix.write_substring fd "\x1b[?1049h" 0 8)

let leave_alt_screen () =
  let fd =get_out_channel () in
  ignore (Unix.write_substring fd "\x1b[?1049l" 0 8)



let draw() = ()

(*  TODO What is a mock driver ? *)
type terminal = {
    driver : MockDriver.t;
}

let ansi_escape_codes() = {
  text_cursor_enable = "\x1b[?25h";
  reset_text_cursor_enable = "\x1b[?25l";
  set_window_title1 = "\x1b]2;";
  set_window_title2 =  "\x07";
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

    let reset_text_cursor_enable() =
       let code = ansi_escape_codes() in
       code.reset_text_cursor_enable

    let set_cursor_position location=
        location := !location;
        Printf.sprintf "\x1b[%d;%dH" !location.x !location.y;
end
end
