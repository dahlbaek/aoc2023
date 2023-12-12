def parse
    data = File.open("eleventh.txt").readlines.map(&:chomp)

    data_expanded = []
    
    data.each do |line|
        if !line.include?("#") then
            data_expanded.push("*"*line.length())
        else
            data_expanded.push(line)
        end
    end
    
    (0..data[0].length()).reverse_each do |i|
        if data.all? { |line| line[i] == "." } then
            data.each { |line| line[i] = "*" }
        end
    end

    return data_expanded
end

Position = Struct.new(:x, :y) do
end

$data = parse

$galaxies = []
$data.each.with_index do |line, y|
    line.each_char.with_index do |char, x|
        if char == "#" then
            $galaxies.push(Position[x,y])
        end
    end
end

def steps(m)
    s = 0
    (0...$galaxies.length()).each do |i|
        (i+1...$galaxies.length()).each do |j|
            g1 = $galaxies[i]
            g2 = $galaxies[j]
            ([g1.x,g2.x].min...[g1.x,g2.x].max).each do |x|
                if $data[g1.y][x] == "*" then
                    s += m
                else
                    s += 1
                end
            end
            ([g1.y,g2.y].min...[g1.y,g2.y].max).each do |y|
                if $data[y][g2.x] == "*" then
                    s += m
                else
                    s += 1
                end
            end
        end
    end
    return s
end

puts "Part 1: %s" % [steps(2)]
puts "Part 2: %s" % [steps(1000000)]
