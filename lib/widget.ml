open Types
open Buffer
open Format

(* https://hal.science/hal-01503081/file/format-unraveled.pdf *)
module type Widget = sig
    val render : Area.t  -> ?custom_formatter:Format.formatter -> Types.t-> unit
end

(* https://ocaml.org/manual/5.0/api/Format_tutorial.html#1_Refinementonhovboxes *)
module Widget = struct
   type Format.stag += Highlight

   let tui_stag_functions = {
     Format.print_open_stag = (fun stag ->
       match stag with
       | Format.String_tag s -> (* Printf.printf "%s" s; *)
                                print_string "\x1b[43;30m";
       | _ -> ()
     );
     Format.print_close_stag = (fun _ -> print_string "\x1b[0m");
     Format.mark_open_stag = (fun _ -> "");
     Format.mark_close_stag = (fun _ -> "");
   }

   let render_styled_text() =
     Format.pp_set_tags Format.std_formatter true;
     Format.pp_set_formatter_stag_functions Format.std_formatter tui_stag_functions;

     Format.printf "@.@\n@{<Highlight>Collaborative editor\nCollaborative editor\nCollaborative editor.@}@.@\n"

   let pp_linebreak ppf () = Format.pp_print_break ppf Format.pp_infinity 0

   let render area ?( custom_formatter = Format.std_formatter) buf =
           (* pp_open_vbox custom_formatter  0; *)
           (* print_string "\x1b[43;30mHello World!\x1b[0m\n"; *)
           (* pp_print_string custom_formatter  "H" ; *)
           (* pp_print_string custom_formatter  "E" ; *)
           (* pp_print_string custom_formatter  "L"; *)
           (* pp_print_string custom_formatter  "L" ; *)
           (* pp_print_string custom_formatter  "O" ; *)
           (* pp_close_box custom_formatter  (); *)
           render_styled_text()
end
