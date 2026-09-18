open Types

module TuiState = struct

type tui_editor_view = {
    cursor_position: location Option.t;
}

type state = { next : tui_editor_view }

let change_cursor_position var (state : state) =
  (
      {
          cursor_position = Some{ x = 1;y = 1 };
      }
    , state)

end
