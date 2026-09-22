open Service

module Client = struct
let mergedoc service =
         let open Lwt.Infix in
         let result = MergeClient.mergedoc service [] in
         result

end
