open Eio.Std
open Event

let run env =
  ()

let render ()=
()

let end_loop()  =
  Printf.printf "End loop"

let main() =
  Fmt.pr "main";
  Eio_main.run @@ fun env ->
  Switch.run  @@ fun sw ->
  Fiber.fork ~sw ( fun () -> run env  );
  ()
