let diff (numbers: seq<int>) : seq<int> =
    (Seq.windowed 2 numbers) |> Seq.map (fun a -> a[1] - a[0])

let next (numbers: seq<int>) : int =
    let rec loop (numbers: seq<int>, acc: int) : int =
        if numbers |> Seq.forall (fun n -> n = 0) then
            acc
        else
            loop (diff numbers, acc + Seq.last numbers)

    loop (numbers, 0)

let previous (numbers: seq<int>) : int =
    let rec loop (numbers: seq<int>, acc: int, alt: int) : int =
        if numbers |> Seq.forall (fun n -> n = 0) then
            acc
        else
            loop (diff numbers, acc + alt * Seq.head numbers, -alt)

    loop (numbers, 0, 1)

let lines =
    System.IO.File.ReadLines "ninth.txt"
    |> Seq.map (fun line -> line.Split " " |> Seq.map int)

printfn $"Part 1: %d{lines |> Seq.map next |> Seq.sum}"
printfn $"Part 2: %d{lines |> Seq.map previous |> Seq.sum}"
