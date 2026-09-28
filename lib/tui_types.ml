open Types
open Configure
open Buffer

type key = [ | `ASCII of char ]

  (*  Viewport etc.*)
type frame = {
    cursor_position: location Option.t;

    viewport_area:Area.t;

}

module  W  =Widget
module C = Make
module A = Area
module B = Buffer(A)
module BF = BufferManipulator (C) (B)
