module Crdt = struct

type identity = {
  agent : string;
  seq : int
}

type item = {
  content : string;
  id : identity ;
  origin_left : identity Option.t;
  origin_right :identity Option.t;
  deleted :  bool
}

type item_list =
  | Item of item
  | Empty

type doc ={
  content : item_list list
}

  module Crdt_buffer = struct

    let make() =
      {
        content = List.init 1 (fun _ -> Empty)
      }

    let content c =
      List.filter (fun item -> Bool.equal item.deleted false ) c
  end

end
