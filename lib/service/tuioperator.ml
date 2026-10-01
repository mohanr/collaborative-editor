open Eio.Std
open Event
open Terminal.Terminal
open Types
open Widget
open Event_stream
open Logger.Logger
open Editorstate
open Editorcontext
open Tui_types

module type TUIHandler = sig
  val periodic_timer : Eio_unix.Stdenv.base -> unit
end

module Ed : sig
    val init_state : string -> tui_editor_view
  end = EditorContext (EventStream) (EditorState)
module TUIOperator = struct

let unpaused = ref (Promise.create_resolved ())

let await_timeout timeout_mutex =
    Eio.Condition.await_no_mutex timeout_mutex

(* https://github.com/ocaml-community/lambda-term/blob/master/src/lTerm.ml *)
let parse p flow ~max_size =
  let buf = Eio.Buf_read.of_flow flow ~max_size in
  Eio.Buf_read.format_errors p buf

let message =
        let open Eio.Buf_read.Syntax in
        let+ msg = Eio.Buf_read.uint8 in
         msg

let get_flow_buffer env =
 Eio.Stdenv.stdin env

let read_eio_stdin buf =
        match parse message buf ~max_size:1024 with
        | Ok  msg  -> let _ = log_m "%d " msg in ()
        | Error (`Msg err) -> Eio.traceln "Parse failed: %s" err

let receive_event buf =
    let _stream = EventStream.get_event_stream() in
    let stdin_fd =get_in_channel () in
    let open Stdlib in

    let loop_while_event () =

      try while true do
        read_eio_stdin buf
      done with End_of_file -> ()
    in
    loop_while_event ()


let run env =
   let _ = log_m "periodic timer " in
   Eio.Switch.run @@ fun _ ->
   let cond = Eio.Condition.create () in
   let clock = Eio.Stdenv.clock env in

   Renderer.render();           (* Event handlers for this is pending *)
   let _view = Ed.init_state "Test" in
   let stdin_buf = get_flow_buffer env in
   Fiber.both  (fun () ->
     while true do
        Promise.await !unpaused;
        Eio.Condition.broadcast cond;
        Eio.Time.sleep clock 3.5;
      done
  )
  (fun () ->
    let rec loop () =
      await_timeout cond;
      receive_event stdin_buf;
      flush stdout;
      Fiber.yield ();
      loop ()
    in
    loop ()
  )

let change_mode ()=
     let enable_raw_mode () =
       let stdin_fd = Unix.descr_of_in_channel stdin in
       let termios = Unix.tcgetattr stdin_fd in
       let new_termios =
         Unix.
           { termios with c_icanon = false; c_echo = false;
                          c_vmin = 0; c_vtime = 1 ; c_opost =false }
       in
       Unix.tcsetattr stdin_fd Unix.TCSAFLUSH new_termios;
       termios
    in enable_raw_mode()


let end_loop()  =
  Printf.printf "End loop"

let periodic_timer env =
  Switch.run  @@ fun sw ->
  let _ = change_mode () in
  Fiber.fork ~sw ( fun () -> run env  );
  ()

end


module TUIOp = TUIOperator
