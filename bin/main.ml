open Eio.Std
open Event
open Collaborative_editor__Buffer
open Collaborative_editor__Configure

let unpaused = ref (Promise.create_resolved ())

let await_timeout timeout_mutex =
    Eio.Condition.await_no_mutex timeout_mutex

module C = Make
module A = Area
module B = Buffer(A)
module BF = BufferManipulator (C) (B)

let create_buffer() =
  BF.make_buffer()

let run env =

   Eio.Switch.run @@ fun _ ->
   let cond = Eio.Condition.create () in
   let clock = Eio.Stdenv.clock env in
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
      print_string "Collaborative Editor";
      flush stdout;
      Fiber.yield ();
      loop ()
    in
    loop ()
  )

let render frame =
    Printf.printf("render")


let change_mode ()=
     let enable_raw_mode () =
       let stdin_fd = Unix.descr_of_in_channel stdin in
       let termios = Unix.tcgetattr stdin_fd in
       let new_termios =
         Unix.
           { termios with c_icanon = false; c_echo = false; c_vmin = 0; c_vtime = 1 }
       in
       Unix.tcsetattr stdin_fd Unix.TCSAFLUSH new_termios;
       termios
    in enable_raw_mode()


let end_loop()  =
  Printf.printf "End loop"

let () =
  Fmt.pr "main";
  Eio_main.run @@ fun env ->
  Switch.run  @@ fun sw ->
  let _ = change_mode () in
  Fiber.fork ~sw ( fun () -> run env  );
  ()
