open Buffer
open Widget
open Types


module Frame = struct
  (*  Viewport etc.*)
type frame = {
    cursor_position: location Option.t;

    viewport_area:Area.t;

}
let default_area ()= Area.get_area()

let render_widget text (widget : (module Widget)) ?(area=default_area()) buffer =
        let module W = ( val widget : Widget) in
        W.render area buffer

end
