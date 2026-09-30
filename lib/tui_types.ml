open Types
open Configurer
open Buffer
open Textholder


  (*  Viewport etc.*)
type frame = {
    cursor_position: location Option.t;

    viewport_area:Area.t;

}
type tui_editor_view = {
    cursor_position: location Option.t;
    buf : Stdlib.Buffer.t;
    holder : Textholder.textholder;
}

type state = { next : tui_editor_view }

type 'a t = state -> 'a * state


module  W  =Widget
module C = Make
module A = Area
module B = Buffer(A)

type _ Effect.t += Set_cursor_blinking :  tui_editor_view   ->
                                          tui_editor_view   Effect.t
