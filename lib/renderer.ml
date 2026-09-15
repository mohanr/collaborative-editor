open Frame.Frame
open Types
open Buffer
open Widget
open Configure
open Textholder

module  W  =Widget
module C = Make
module A = Area
module B = Buffer(A)
module BF = BufferManipulator (C) (B)

module Renderer = struct

let create_buffer()  =
  BF.make_buffer()



  let get_frame() =
    (* Create frame  *)
    {
      cursor_position = Some ({x = 0; y = 0});

      viewport_area = Area.get_area()
    }

let render () =
    let _f = get_frame() in     (* TODO *)
    let text = Textholder.make "Text" in (* TODO *)
    render_widget text (module W) (create_buffer())
end
