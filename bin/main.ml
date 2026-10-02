open Collaborative_editor.Server
open Cmdliner


let boot la =
  let _ = boot_server  la in
  ()



let la = Arg.(required & pos 0 (some string) None & info [])
let cmd = Cmd.(v (info "app") Term.(const boot$ la ))
let () = exit (Cmd.eval cmd)
