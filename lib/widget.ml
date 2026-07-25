open Buffer

module type Widget = sig
    val render : Area.t -> (module BufferMaker) -> unit
end

(* https://ocaml.org/manual/5.0/api/Format_tutorial.html#1_Refinementonhovboxes *)
module Widget = struct

    let render area buf formatter =
           let open Format in
           pp_open_vbox formatter  0;
           pp_print_string formatter  ("H" ^ "\x1bE") ;
           pp_print_string formatter  ("E" ^ "\x1bE") ;
           pp_print_string formatter  ("L" ^ "\x1bE") ;
           pp_print_string formatter  ("L" ^ "\x1bE") ;
           pp_print_string formatter  ("O" ^ "\x1bE") ;
           pp_close_box formatter  ()

end
