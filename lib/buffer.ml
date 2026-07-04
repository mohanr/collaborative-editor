open Configurer_intf

module Buffer = struct

module Buffer_area = struct

type t = {
    (* The x coordinate of the top left corner of the `Area` *)
    x : int;
     (* The y coordinate of the top left corner of the `Rect` *)
    y : int;
     (* The width of the `Area` *)
    width : int;
     (* The height of the `Area` *)
    height : int
}

end

type t = {
    area : Buffer_area.t;

    contents : Bytes.t;
}

module Make( Config : Configurer_intf.Configurer) = struct

  let new_buffer () : t =
    let config= Config.set_size () in
    let area = { Buffer_area.x = 0;Buffer_area.y = 0;
                 Buffer_area.width = config.width; Buffer_area.height  = config.height } in
    {area = area; contents = Bytes.create 100}


end

end
