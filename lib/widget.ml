open Types
open Buffer

module type Widget = sig
    val render : Area.t  -> ?custom_formatter:Format.formatter -> Types.t-> unit
end

(* https://ocaml.org/manual/5.0/api/Format_tutorial.html#1_Refinementonhovboxes *)
module Widget = struct

    let render area ?( custom_formatter = Format.std_formatter) buf =
           let open Format in
           pp_open_vbox custom_formatter  0;
           pp_print_string custom_formatter  ("H" ^ "\x1bE") ;
           pp_print_string custom_formatter  ("E" ^ "\x1bE") ;
           pp_print_string custom_formatter  ("L" ^ "\x1bE") ;
           pp_print_string custom_formatter  ("L" ^ "\x1bE") ;
           pp_print_string custom_formatter  ("O" ^ "\x1bE") ;
           pp_close_box custom_formatter  ()

end
