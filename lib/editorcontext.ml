open Tui_types
open Event_stream
open Textholder
open Terminal.Terminal.Cursor
open Editorstate

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
                       cursor_position = Some{ x = 1;y = 1 };
                       buf =  Stdlib.Buffer.create 256;
                       holder =  Textholder.make string_text ;
                   }) in
        (match effectful_init_state ()  with
        | effect Set_cursor_blinking v, k ->
                                let () = set_cursor_blinking() in
                                v
        | state-> state
       )
end
