open Widget
open Buffer
open Types

module Textholder = struct

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

let render data  =
  {
    data = data;
    scroll = {x = 0; y = 0}     (*  Test location*)
  }

end
