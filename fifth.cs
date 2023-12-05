internal class Program
{
    private static void Main(string[] args)
    {
        IEnumerable<string> lines = File
            .ReadAllText("fifth.txt")
            .Split('\n')
            .Where(l => l != "");
        IEnumerable<long> seeds = lines
            .First()
            .Substring("seeds: ".Length)
            .Split(" ")
            .Select(long.Parse);
        Console.WriteLine("seeds " + string.Join(",", seeds));

        IEnumerable<CategoryMapper> categoryMappers = [];
        foreach (var line in lines.Skip(1))
        {
            if (line.EndsWith(":"))
            {
                string name = line.Substring(0, line.Length - 5);
                categoryMappers = categoryMappers.Append(new CategoryMapper { Mappers = [], Name = name });
            }
            else
            {
                long[] data = line.Split(" ").Select(long.Parse).ToArray();
                Mapper mapper = new Mapper
                {
                    Left = data[1],
                    Right = data[1] + data[2],
                    MapBy = data[0] - data[1]
                };
                CategoryMapper last = categoryMappers.Last();
                last.Mappers = last.Mappers.Append(mapper);
            }
        }
        foreach (var categoryMapper in categoryMappers)
        {
            Console.WriteLine("name: " + categoryMapper.Name + " count: " + categoryMapper.Mappers.Count());
            categoryMapper.Mappers = categoryMapper.Mappers.OrderBy(m => m.Left);

            foreach (var mapper in categoryMapper.Mappers)
            {
                Console.WriteLine("Left: " + mapper.Left + " Right: " + mapper.Right + " MapBy: " + mapper.MapBy);
            }
        }

        // Part 1
        long minLocation1 = long.MaxValue;
        foreach (var seed in seeds)
        {
            Console.WriteLine("Mapping seed " + seed);
            long toMap = seed;
            foreach (var categoryMapper in categoryMappers)
            {
                Console.WriteLine("CategoryMapper " + categoryMapper.Name);
                toMap = categoryMapper.map(toMap);
                Console.WriteLine("Mapped to " + toMap);
            }
            Console.WriteLine("Seed " + seed + " mapped to " + toMap);
            minLocation1 = long.Min(minLocation1, toMap);
        }
        Console.WriteLine("Minimum location 1: " + minLocation1);

        // Part 2
        Tuple<long, long>[] seeds2 = seeds
            .Chunk(2)
            .Select(x => new Tuple<long, long>(x.First(), x.Skip(1).First()))
            .ToArray();
        Console.WriteLine("seeds 2: " + string.Join(",", seeds2.Select(t => t.ToString())));
        CategoryMapper combinedMapper = categoryMappers.Skip(1).Aggregate(categoryMappers.First(), (c_1, c_2) => c_1.followedBy(c_2));
        long minLocation2 = long.MaxValue;
        foreach (var (start, len) in seeds2)
        {
            foreach (var mapper in combinedMapper.Mappers)
            {
                if (start + len > mapper.Left && start < mapper.Right)
                {
                    minLocation2 = long.Min(minLocation2, mapper.map(long.Max(start, mapper.Left)));
                }
            }
        }
        Console.WriteLine("Minimum location 2: " + minLocation2);
    }
}

public class Mapper
{
    public required long Left { get; set; }
    public required long Right { get; set; }
    public required long MapBy { get; set; }

    public long map(long x)
    {
        return x + MapBy;
    }
}

class Range
{
    public required long Left { get; set; }
    public required long Right { get; set; }

    public IEnumerable<Range> without(Range other)
    {
        long left_intersect = long.Max(Left, other.Left);
        long right_intersect = long.Max(Right, other.Right);
        Range first = new Range { Left = Left, Right = left_intersect };
        Range second = new Range { Left = right_intersect, Right = Right };
        Range[] array = [first, second];
        return array.Where(r => r.Left < r.Right);
    }
}

class CategoryMapper
{
    public required string Name { get; set; }
    public required IEnumerable<Mapper> Mappers { get; set; }
    Mapper DefaultMapper = new Mapper
    {
        Left = 0,
        Right = 0,
        MapBy = 0
    };

    public long map(long x)
    {
        long output = Mappers.FirstOrDefault(m => x < m.Right && x >= m.Left, DefaultMapper)!.map(x);
        Console.WriteLine("Mapping " + x + " to " + output);
        return output;
    }

    public CategoryMapper followedBy(CategoryMapper categoryMapper)
    {
        IEnumerable<Mapper> mappers = [];
        foreach (var mapper in Mappers)
        {

            IEnumerable<Range> remaining = [new Range { Left = mapper.Left, Right = mapper.Right }];

            foreach (var otherMapper in categoryMapper.Mappers)
            {
                if (otherMapper.Right > mapper.map(mapper.Left) && otherMapper.Left < mapper.map(mapper.Right))
                {
                    long left = long.Max(mapper.Left, otherMapper.Left - mapper.MapBy);
                    long right = long.Min(mapper.Right, otherMapper.Right - mapper.MapBy);
                    Range remove = new Range { Left = left, Right = right };
                    remaining = remaining.SelectMany(r => r.without(remove));

                    Mapper partialMapper = new Mapper
                    {
                        Left = left,
                        Right = right,
                        MapBy = mapper.MapBy + otherMapper.MapBy,
                    };
                    mappers = mappers.Append(partialMapper);
                    Console.WriteLine("push mapper");
                    Console.WriteLine(mappers.Count());
                }
            }

            Console.WriteLine("Remaining: " + remaining.Count());
            foreach (var r in remaining)
            {
                mappers = mappers.Append(new Mapper { Left = r.Left, Right = r.Right, MapBy = mapper.MapBy });
                Console.WriteLine("push mapper");
            }
        }
        string name = Name + "->" + categoryMapper.Name;
        Console.WriteLine("Creating combined category mapper " + name);
        return new CategoryMapper
        {
            Name = name,
            Mappers = mappers.OrderBy(m => m.Left)
        };
    }
}
