open Types
open Stdlib
open Textholder

module EditorState = struct

type tui_editor_view = {
    cursor_position: location Option.t;
    buf : Buffer.t;
    holder : Textholder.textholder;
}

type state = { next : tui_editor_view }

type 'a t = state -> 'a * state

let make text state =
  let var = state.next in
  let state =
      {next = {
          cursor_position = Some{ x = 1;y = 1 };
          buf =  Buffer.create 256;
          holder =  Textholder.make text;
      }
      }
  in
  (var, state)

(* Probably buffer size change after creation *)
let make_buffer var (state : state) =
  (
      {
         var with buf = Buffer.create 256;
      }
  , state )

let change_cursor_position var (state : state) x y =
  (
      {                         (*  Position within the buffer*)
         var with cursor_position = Some{ x = x ;y = y  };
      }
  , state )

let bind (t : 'a t) ~(f : 'a -> 'b t) : 'b t =
 fun state ->
  (* apply the first state transition first *)
  let a, transient_state = t state in
  (* and then the second *)
  let b, final_state = f a transient_state in
  (* return these *)
  (b, final_state)


let return (editor_state : tui_editor_view) (state : state) = (editor_state , state)

end
