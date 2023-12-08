import * as fs from 'fs'

function parseLine(l: string): [string, number] {
    var [l1, l2] = l.split(" ")
    return [l1, parseInt(l2)]
}

var TYPEMAPPER = [0, 0, 1, 3, 5, 6]

function type(hand: string, second: boolean): number {
    var counter: { [_: string]: number } = {}
    for (let i = 0; i < hand.length; i++) {
        var card = hand[i]
        if (card in counter) {
            counter[card]++
        } else {
            counter[card] = 1
        }
    }

    var jokers = 0
    if (second && "J" in counter && Object.keys(counter).length > 1) {
        jokers = counter["J"]
        var maxCard = "J"
        var maxValue = -1
        for (var card in counter) {
            if (counter[card] > maxValue && card != "J") {
                maxCard = card
                maxValue = counter[card]
            }
        }
        if (maxCard != "J") {
            counter[maxCard] += jokers
            delete counter["J"]
        }
    }

    var values: number[] = []
    for (var card in counter) {
        values.push(counter[card])
    }
    values.sort()

    var value = TYPEMAPPER[values[values.length - 1]]

    if (values.length > 1 && values[values.length - 2] == 2) {
        value += 1
    }

    return value
}

var STRENGTHMAPPER: { [_: string]: number } = { "A": 12, "K": 11, "Q": 10, "J": 9, "T": 8, "9": 7, "8": 6, "7": 5, "6": 4, "5": 3, "4": 2, "3": 1, "2": 0 }
var STRENGTHMAPPER2: { [_: string]: number } = { "A": 12, "K": 11, "Q": 10, "T": 9, "9": 8, "8": 7, "7": 6, "6": 5, "5": 4, "4": 3, "3": 2, "2": 1, "J": 0 }

function strength(inp: [string, number], second: boolean): [number, string, number] {
    var hand = inp[0]
    var str = type(hand, second) * 13 ** 6
    for (let i = 0; i < hand.length; i++) {
        var card = hand[hand.length - 1 - i]
        str += (second ? STRENGTHMAPPER2 : STRENGTHMAPPER)[card] * (13 ** (i + 1))
    }
    return [str, hand, inp[1]]
}

fs.readFile('seventh.txt', (err: NodeJS.ErrnoException | null, buffer: Buffer) => {
    if (err) throw err
    var parsed: [string, number][] = buffer
        .toString()
        .split("\n")
        .map(parseLine)
    console.log("Part 1: " + run(parsed, false))
    console.log("Part 2: " + run(parsed, true))
})

function run(parsed: [string, number][], second: boolean): number {
    return parsed
        .map((a) => strength(a, second))
        .sort((a, b) => { return a[0] - b[0] })
        .map((v, idx) => { return v[2] * (idx + 1) })
        .reduce((a, b) => a + b)
}
