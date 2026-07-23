module Window = struct

module Border = Set.Make(struct
  type t = string
  let compare a b = compare (String.lowercase_ascii a) (String.lowercase_ascii b)
end)

let default_window_style() =
  let init_border_style = Border.empty |>
    Border.add "│" |>

    Border.add "─" |>

    Border.add "┐" |>

    Border.add "┌" |>

    Border.add "┘" |>

    Border.add "└" |>

    Border.add "┤" |>

    Border.add "├" |>
    Border.add "┬" |>

    Border.add "┴" |>

    Border.add "┼"
    in init_border_style



end
