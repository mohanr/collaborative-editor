open Buffer
open Widget
open Types

module Frame = struct

  (*  Viewport etc.*)
type frame = {
    cursor_position: location Option.t;

    viewport_area:Area.t;

}

let render_widget (widget : (module Widget)) area buffer =
        let module W = ( val widget : Widget) in
        W.render area buffer

end
