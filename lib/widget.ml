open Buffer

module type Widget = sig
    val render : Area.t -> (module BufferMaker) -> unit
end
module Widget = struct

    let render area buf =
        Printf.printf("render");

end
