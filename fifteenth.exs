defmodule Solution do
  def parse do
    {:ok, content} = File.read("fifteenth.txt")
    :binary.split(content, [<<",">>], [:global]) |> Enum.map(&:binary.bin_to_list/1)
  end

  defp hash_algorithm(b, acc), do: Kernel.rem(17 * (acc + b), 256)

  def part1(string, acc), do: acc + Enum.reduce(string, 0, &hash_algorithm/2)

  def fill_boxes(string, acc) do
    label = Enum.take_while(string, fn b -> <<b>> != <<"-">> and <<b>> != <<"=">> end)
    parse_no = fn no -> if no != nil, do: elem(Integer.parse(<<no>>), 0), else: nil end
    no = Enum.drop_while(string, fn b -> <<b>> != <<"=">> end) |> Enum.at(1) |> parse_no.()
    box_no = Enum.reduce(label, 0, &hash_algorithm/2)

    box = Enum.at(acc, box_no)

    updated_box =
      if no != nil and Enum.all?(box, fn {l, _} -> l != label end) do
        [{label, no} | box]
      else
        List.foldr(box, [], fn
          {^label, _}, acc when no == nil -> acc
          {^label, _}, acc -> [{label, no} | acc]
          e, acc -> [e | acc]
        end)
      end

    List.replace_at(acc, box_no, updated_box)
  end

  def part2({box, index}, acc) do
    single_lens = fn {{_, no}, elem_index}, box_acc -> index * elem_index * no + box_acc end
    List.foldl(box, acc, single_lens)
  end
end

part_1 = Solution.parse() |> Enum.reduce(0, &Solution.part1/2)
IO.puts("Part 1: #{part_1}")

part_2 =
  Solution.parse()
  |> Enum.reduce(List.duplicate([], 256), &Solution.fill_boxes/2)
  |> Enum.map(&Enum.reverse/1)
  |> Enum.map(&Enum.with_index(&1, 1))
  |> Enum.with_index(1)
  |> List.foldl(0, &Solution.part2/2)

IO.puts("Part 2: #{part_2}")
