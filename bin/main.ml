open Eio.Std
open Event

let run env =
  ()

let render ()=
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

let main() =
  Fmt.pr "main";
  Eio_main.run @@ fun env ->
  Switch.run  @@ fun sw ->
  Fiber.fork ~sw ( fun () -> run env  );
  ()
