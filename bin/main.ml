open Collaborative_editor.Server
open Cmdliner


let boot la cap_file_id =
  let _ = boot_server  la cap_file_id in
  ()



let la = Arg.(required & pos 0 (some string) None & info [])
let cap_file_id  = Arg.(required & pos 1 (some int) None & info [])
let cmd = Cmd.(v (info "app") Term.(const boot $ la $ cap_file_id ))
let () = exit (Cmd.eval cmd)
