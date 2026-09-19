open Types
open Stdlib

module EditorState = struct

type tui_editor_view = {
    cursor_position: location Option.t;
    buf : Buffer.t
}

type state = { next : tui_editor_view }

type 'a t = state -> 'a * state

let make_buffer var (state : state) =
  (
      {
         var with buf = Buffer.create 256;
      }
  , state )

let change_cursor_position var (state : state) =
  (
      {
         var with cursor_position = Some{ x = 1;y = 1 };
      }
  , state )

end
