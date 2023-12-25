let parse filename =
  let ch = open_in_bin filename in
  let raw = really_input_string ch (in_channel_length ch) in
  close_in ch;
  (* Printf.printf "%s\n" raw; *)
  let filter_newline = fun s c  -> if c == '\n' then s else s ^ (String.make 1 c) in
  (String.index_from raw 0 '\n', String.fold_left filter_newline "" raw)

module Direction = struct
  type t = Up | Right | Down | Left
  let intify = function
    | Up -> 0
    | Right -> 1
    | Down -> 2
    | Left -> 3
  let compare a b = intify(a) - intify(b)
end

module IntTuple = struct
  type t = int * int
  let compare (x1, y1) (x2, y2) =
    if x2 != x1 then compare x2 x1
    else compare y2 y1
end

module State = struct
  type t = IntTuple.t * Direction.t
  let compare (tup1, d1) (tup2, d2) =
    let tup_comp = IntTuple.compare tup1 tup2 in
    if tup_comp != 0 then tup_comp
    else Direction.compare d2 d1
end

module Visited = Set.Make(State)

module IntTupleSet = Set.Make(IntTuple)

let part_2_input = 
  let from_top = List.map (fun index -> ((index, 0), Direction.Down)) (List.init 110 (fun x -> x)) in
  let from_right = List.map (fun index -> ((109, index), Direction.Left)) (List.init 110 (fun x -> x)) in
  let from_bottom = List.map (fun index -> ((index, 109), Direction.Up)) (List.init 110 (fun x -> x)) in
  let from_left = List.map (fun index -> ((0, index), Direction.Right)) (List.init 110 (fun x -> x)) in
  List.concat [from_top; from_right; from_bottom; from_left]


let () =
  let (row_length, s) = parse "sixteenth.txt" in
  let next ((x, y), dir) =
    (* Printf.printf "next (%d, %d, %d)\n" x y (Direction.intify dir); *)
    let next_steps = match (dir, s.[x + row_length * y]) with
      | (Direction.Up, '\\') -> [((x-1, y), Direction.Left)]
      | (Direction.Up, '/') -> [((x+1, y), Direction.Right)]
      | (Direction.Up, '-') -> [((x-1, y), Direction.Left); ((x+1, y), Direction.Right)]
      | (Direction.Up, _) -> [((x, y-1), Direction.Up)]
      | (Direction.Right, '\\') -> [((x, y+1), Direction.Down)]
      | (Direction.Right, '/') -> [((x, y-1), Direction.Up)]
      | (Direction.Right, '|') -> [((x, y+1), Direction.Down); ((x, y-1), Direction.Up)]
      | (Direction.Right, _) -> [((x+1, y), Direction.Right)]
      | (Direction.Down, '\\') -> [((x+1, y), Direction.Right)]
      | (Direction.Down, '/') -> [((x-1, y), Direction.Left)]
      | (Direction.Down, '-') -> [((x+1, y), Direction.Right); ((x-1, y), Direction.Left)]
      | (Direction.Down, _) -> [((x, y+1), Direction.Down)]
      | (Direction.Left, '\\') -> [((x, y-1), Direction.Up)]
      | (Direction.Left, '/') -> [((x, y+1), Direction.Down)]
      | (Direction.Left, '|') -> [((x, y-1), Direction.Up); ((x, y+1), Direction.Down)]
      | (Direction.Left, _) -> [((x-1, y), Direction.Left)]
      in
    let inside_tiles = fun ((x, y), _) ->
      x >= 0 && x < row_length && y >= 0 && y < (String.length s)/row_length in
    List.filter inside_tiles next_steps
  in

  let rec num_tiles visited remaining =
    match remaining with
      | [] ->
        let extract_tuple = fun (tup, _) acc -> IntTupleSet.add tup acc in
        let int_set = Visited.fold extract_tuple visited IntTupleSet.empty in
        IntTupleSet.cardinal int_set
      | head :: tail ->
        if Visited.mem head visited then num_tiles visited tail
        else num_tiles (Visited.add head visited) (List.append tail (next head))
  in

  let part_2 acc input = max acc (num_tiles Visited.empty [input]) in

  Printf.printf "Part 1: %d\n" (num_tiles Visited.empty [((0, 0), Direction.Right)]);
  Printf.printf "Part 2: %d\n" (List.fold_left part_2 0 part_2_input);
