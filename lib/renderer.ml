open Frame.Frame
open Types


module Renderer = struct


  let get_frame() =
    (* Create frame  *)
    {
      cursor_position = Some ({x = 0; y = 0});

      viewport_area = Area.get_area()
    }
end
