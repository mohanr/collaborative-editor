open Tui_types
open Event_stream
open Textholder
open Terminal.Terminal.Cursor
open Editorstate
open Logger.Logger

module EditorContext( EventStream: STREAMER )
                    ( EditorState : EState  ) = struct


      let init_state text =
        let effectful_init_state () =
           let string_text =
             Textholder.Text {
               self = text ;
               text_length = String.length;
             } in

           Effect.perform (Set_cursor_blinking
                   {
                       cursor_position = Some{ x = 6;y = 11 }; (* Should be Location *)
                       buf =  Stdlib.Buffer.create 256;
                       holder =  Textholder.make string_text ;
                   }) in
        (match effectful_init_state ()  with
        | effect Set_cursor_blinking v, k ->
                                let () =
                                (match v.cursor_position with
                                | Some l -> set_cursor_new_position {x=l.x;y=l.y}
                                | None -> ()
                                ) in
                                let _ = log_m "Set cursor blinking" in
                                let () = set_cursor_blinking() in
                                v
        | state-> state
       )
end
