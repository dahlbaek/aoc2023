import std/math
import std/sequtils
import std/strformat
import std/strutils


let layout: seq[string] = readFile("tenth.txt").splitLines()
type Position = tuple[x: int, y: int]

proc find(c: char): Position =
    for index, row in layout.pairs:
        if 'S' in row:
            return (x: row.find('S'), y: index)
    raise newException(Exception, "Did not find char")

proc first(pos: Position): Position =
    let directions: seq[Position] = (@[
        (x: - 1, y: 0),
        (x: 1, y: 0),
        (x: 0, y: -1),
        (x: 0, y: 1)
    ])
    .filterIt(it.x + pos.x >= 0)
    .filterIt(it.y + pos.y >= 0)
    for direction in directions:
        if direction == (-1, 0):
            if layout[pos.y][pos.x-1] in ['-', 'L', 'F']:
                return (x: pos.x-1, y: pos.y)
        if direction == (1, 0):
            if layout[pos.y][pos.x+1] in ['-', 'J', '7']:
                return (x: pos.x+1, y: pos.y)
        if direction == (0, -1):
            if layout[pos.y-1][pos.x] in ['|', 'L', 'J']:
                return (x: pos.x, y: pos.y-1)
        if direction == (0, 1):
            if layout[pos.y+1][pos.x] in ['|', '7', 'F']:
                return (x: pos.x, y: pos.y+1)
    raise newException(Exception, "Did not find first link")

proc next(pos: Position, prev: Position): Position =
    case layout[pos.y][pos.x]:
        of '|':
            return (x: pos.x, y: 2*pos.y - prev.y)
        of '-':
            return (x: 2*pos.x - prev.x, y: pos.y)
        of 'L':
            if prev.y == pos.y:
                return (x: pos.x, y: pos.y-1)
            else:
                return (x: pos.x + 1, y: pos.y)
        of 'J':
            if prev.y == pos.y:
                return (x: pos.x, y: pos.y-1)
            else:
                return (x: pos.x - 1, y: pos.y)
        of '7':
            if prev.y == pos.y:
                return (x: pos.x, y: pos.y+1)
            else:
                return (x: pos.x - 1, y: pos.y)
        of 'F':
            if prev.y == pos.y:
                return (x: pos.x, y: pos.y+1)
            else:
                return (x: pos.x + 1, y: pos.y)
        else:
            raise newException(Exception, "Did not find first link")

let s = find('S')
var prev = s
var o = first(s)
var pipe = newSeq[Position](0)
pipe.add(o)
while o != s:
    let tmp = o
    o = next(o, prev)
    prev = tmp
    pipe.add(o)
echo fmt"Part 1: {int(floor(pipe.len()/2))}"

proc rounds(k: int, row_len: int, pipe: seq[Position]): int =
    let y = int(floor(k/row_len))
    let pos = (x: k - y*row_len, y: y)

    if pos in pipe:
        return 0

    var prev = pipe[0]
    var rs = 0
    for curr in pipe.toOpenArray(1, pipe.len()-1):
        if curr.x == pos.x and curr.y < pos.y:
            rs += curr.x-prev.x
        if prev.x == pos.x and prev.y < pos.y:
            rs += curr.x-prev.x
        prev = curr
    return int(abs(rs)/2)

pipe.add(first(s))
var enclosed = 0
for k in 0..layout.len() * layout[0].len():
    enclosed += rounds(k, layout[0].len(), pipe)
echo fmt"Part 2: {enclosed}"
