using Printf

inside(t::Tuple{Int,Int}) = t[1] >= 1 && t[1] <= rowlength && t[2] >= 1 && t[2] <= collength
onpath(t::Tuple{Int,Int}) = (content[t[1]][t[2]] != '#')

directions = Dict(
    '>' => [(0,1)],
    '<' => [(0,-1)],
    'v' => [(1,0)],
    '^' => [(-1,0)],
    '.' => [(0,1),(0,-1),(1,0),(-1,0)],
    '#' => [(0,1),(0,-1),(1,0),(-1,0)],
)

function possible_directions(current::Tuple{Int,Int}, previous::Set{Tuple{Int,Int}})
    nexts::Vector{Tuple{Int,Int}} = []
    for direction in directions[content[current[1]][current[2]]]
        next = (current[1] + direction[1], current[2] + direction[2])
        if inside(next) && onpath(next) && !(next in previous)
            push!(nexts, next)
        end
    end
    nexts
end

function nextbranch(current::Tuple{Int,Int}, previous::Set{Tuple{Int,Int}}, steps::Int)
    if current == finish
        current, [finish], steps
    else
        nexts = possible_directions(current, previous)
        push!(previous, current)
    
        if size(nexts)[1] == 1
            nextbranch(nexts[1], previous, steps+1)
        else
            current, nexts, steps + 1
        end    
    end
end

function longestwalk1(current::Tuple{Int,Int}, previous::Set{Tuple{Int,Int}})
    if current == finish
        return 0
    end

    if current in previous
        return nothing
    end

    previous = deepcopy(previous)

    _, bs, s = nextbranch(current, previous, 0)
    m = nothing
    for b in bs
        ls = longestwalk1(b, previous)
        if ls == nothing
            continue
        end
        m = max(m == nothing ? 0 : m, s + ls)
    end
    m
end

function connected_junctions(current::Tuple{Int,Int}, directions::Vector{Tuple{Int,Int}})
    js::Vector{Tuple{Tuple{Int,Int},Int}} = []
    for direction in directions
        b, _, s = nextbranch(direction, Set([current]), 0)
        push!(js, (b, b == finish ? s + 1 : s))
    end
    js
end

function junctions()
    empty::Set{Tuple{Int,Int}} = Set()

    j = Dict(start=>connected_junctions(start, possible_directions(start,empty)))
    for rowindex in range(length=rowlength)
        for colindex in range(length=collength)
            current = (rowindex,colindex)
            if onpath(current)
                directions = possible_directions(current,empty)
                if size(directions)[1] > 2
                    j[current] = connected_junctions(current, directions)
                end
            end
        end
    end
    j
end

function longestwalk2(current::Tuple{Int,Int}, previous::Set{Tuple{Int,Int}})
    if current == finish
        return 0
    end

    if current in previous
        return nothing
    end

    previous = deepcopy(previous)
    push!(previous, current)

    m = nothing
    for (junction, steps) in js[current]
        ls = longestwalk2(junction, previous)
        if ls == nothing
            continue
        end
        m = max(m == nothing ? 0 : m, steps + ls)
    end
    m
end

content = readlines("twentythird.txt")
collength = size(content)[1]
rowlength = sizeof(content[1])[1]
start = (1,findfirst((c -> c == '.'), content[1]))
finish = (collength, findfirst((c -> c == '.'), content[collength]))
empty::Set{Tuple{Int,Int}} = Set()

@printf("Part 1: %d\n", longestwalk1(start, empty))

for j in range(length=collength)
    content[j] = replace(content[j], r">|<|\^|v" => ".")
end
js = junctions()

@printf("Part 2: %d\n", longestwalk2(start, empty))
