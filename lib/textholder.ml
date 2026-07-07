open Widget
open Buffer

module Textholder = struct

type location = {

  x : int;

  y: int

}


(* An existential is an abstraction of data representation *)

type 'text representation= {

  self : 'text ;

  text_length : 'text -> int
}
type text = Text : 'text representation-> text

let text_length (Text {text_length; self}) = text_length self

type textholder  = {

    data : text;                (*Existential  *)

    scroll : location

}

    let make text = text       (* No embellishments like style for now *)

    let scroll offset =
        {
            x =  fst offset;
            y =  snd offset
        }

let render area ( buf : (module BufferMaker)) ( widget : (module Widget)) =
   let  module W  =(val widget : Widget) in
   W.render area buf

end
