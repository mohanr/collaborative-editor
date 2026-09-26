open Types

type key = [ | `ASCII of char ]

  (*  Viewport etc.*)
type frame = {
    cursor_position: location Option.t;

    viewport_area:Area.t;

}
