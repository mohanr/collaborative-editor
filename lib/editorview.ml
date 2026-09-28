open Types
open Buffer
open Logger.Logger
open Configure
open Window
open Terminal

module Renderable = struct
  type widget_type = Editor     (* | Other widget types *)
  module type R = sig
    val widget_type : widget_type
   val render : Area.t  -> ?custom_formatter:Format.formatter ->
                                        t -> Stdlib.Buffer.t
  end
end

module EditorView : Renderable.R = struct

let plain_style = Window.get_plain_style ()

 let widget_type  = Renderable.Editor
let draw_vborder_in_buffer border width =
  let open Stdlib in
  let draw b buffer =
    match b with
    | VeBorder s ->  let l = width in
        Buffer.add_string buffer "\x1b[0;38;5;15;48;5;12m";
        Buffer.add_string buffer s;
        Buffer.add_string  buffer (String.make (l - 2) ' ');
        Buffer.add_string buffer s;
        Buffer.add_string buffer "\x1b[0m";
         buffer
    |  _-> buffer
  in
   try
     draw border (Buffer.create width)
      with e ->
       let msg = Printexc.to_string e
       and stack = Printexc.get_backtrace () in
         Printf.eprintf "there was an error: %s%s\n" msg stack;
         raise e


  let draw_hborder_in_buffer (border : style ) width bottom_or_top =
  let open Stdlib in
  let rec repeat ?(n = 0) s =
      if n = 0 then "" else s ^ repeat s ~n:(n - 1)
  in
  let draw b buffer =
    match b with
    | HoBorder s ->
                    Buffer.add_string buffer "\x1b[0;38;5;15;48;5;12m";
                   if bottom_or_top then
                    Buffer.add_string  buffer  plain_style.top_left_ascii
                   else
                    Buffer.add_string  buffer  plain_style.bottom_left_ascii    ;
                    Buffer.add_string  buffer (repeat ~n:(width - 2)
                                                  s ) ;
                   if bottom_or_top then
                    Buffer.add_string  buffer  plain_style.top_right_ascii
                   else
                    Buffer.add_string  buffer  plain_style.bottom_right_ascii    ;
                    Buffer.add_string buffer "\x1b[0m";
                    buffer
    |  _-> buffer
  in
     draw border (Buffer.create width)
let render (area : Area.t) ?( custom_formatter = Format.std_formatter) (buf : t) : Stdlib.Buffer.t =
       let open Stdlib in
       let b = buf.contents in

       let start_loc = ref { x = area.x ; y = area.y } in
       Buffer.add_string b (Terminal.Cursor.set_cursor_position start_loc);
       Buffer.add_buffer b (draw_hborder_in_buffer
                               (HoBorder plain_style.horizontal_top) area.width true);

       let rec loop i h =
         if i < h then
           let new_location = ref { x = area.x + i ; y = area.y } in
           Buffer.add_string b (Terminal.Cursor.set_cursor_position new_location);
           let v = (Buffer.contents (draw_vborder_in_buffer
                                                   (VeBorder plain_style.vertical_left) area.width)) in
           Buffer.add_string b v;

           loop (i + 1) h
         else ()
       in
       loop 1 area.height;

       let end_loc = ref { x = area.x + area.height ; y = area.y } in
       Buffer.add_string b (Terminal.Cursor.set_cursor_position end_loc);
       Buffer.add_buffer b (draw_hborder_in_buffer
                               (HoBorder plain_style.horizontal_bottom) area.width false);

           (* let _ = log_m *)
           (*   "V: value=%S\n%!" *)
           (*   (Buffer.contents b) in *)
       b


let render_child_view buf child child_width dst_row dst_col height =
  let open Stdlib in
  let len = String.length child in
    let rec loop r h =
    if r <= h then (
       Buffer.add_string buf
         (Terminal.Cursor.set_cursor_position
            (ref { x = dst_row + r; y = dst_col }));
       let start = r * child_width in
       let n = max 0 (min child_width (len - start)) in
       if n > 0 then
         Buffer.add_substring buf child start n
       else ();
       loop (r + 1) h
    )
    else ()
    in
    loop 0 (height - 1)

end
