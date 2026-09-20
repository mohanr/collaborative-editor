open Eio.Std
open Event
open Collaborative_editor__Terminal.Terminal
open Collaborative_editor__Types
open Collaborative_editor__Renderer
open Collaborative_editor__Event_stream.EventStream

let unpaused = ref (Promise.create_resolved ())

let await_timeout timeout_mutex =
    Eio.Condition.await_no_mutex timeout_mutex

(* https://github.com/ocaml-community/lambda-term/blob/master/src/lTerm.ml *)

let receive_event () =
    let _stream = get_event_stream() in
    let stdin_fd =get_in_channel () in
    let open Stdlib in

    let loop_while_event () =

      try while true do
        let key =   In_channel.input_line stdin_fd in
          match key with
          | Some s  ->  Printf.printf "%s" s;
          | None ->  ()
      done with End_of_file -> ()
    in
    loop_while_event ()


let run env =

   Eio.Switch.run @@ fun _ ->
   let cond = Eio.Condition.create () in
   let clock = Eio.Stdenv.clock env in
   Renderer.render();           (* Event handlers for this is pending *)
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
      receive_event ();
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

let () =
  Eio_main.run @@ fun env ->
  Switch.run  @@ fun sw ->
  let _ = change_mode () in
  Fiber.fork ~sw ( fun () -> run env  );
  ()
