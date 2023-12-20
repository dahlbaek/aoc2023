package main

import (
	"fmt"
	"os"
	"slices"
	"strings"
)

func parse() [][]byte {
	content, err := os.ReadFile("fourteenth.txt")
	if err != nil {
		panic(err)
	}
	lineLength := slices.Index(content, '\n') + 1
	columns := make([][]byte, lineLength-1)
	for columnIndex := range columns {
		column := make([]byte, (len(content)+1)/lineLength)
		for rowIndex := range column {
			column[rowIndex] = content[columnIndex+rowIndex*lineLength]
		}
		columns[columnIndex] = column
	}
	return columns
}

func tilt(columns [][]byte) {
	for _, column := range columns {
		stop := 0
		for idx := range column {
			if column[idx] == 'O' {
				column[stop], column[idx] = column[idx], column[stop]
				stop += 1
			}
			if column[idx] == '#' {
				stop = idx + 1
			}
		}
	}
}

func load(columns [][]byte) int {
	part1 := 0
	for _, column := range columns {
		for idx, char := range column {
			if char == 'O' {
				part1 += len(column) - idx
			}
		}
	}
	return part1
}

func part1() int {
	columns := parse()
	tilt(columns)
	return load(columns)
}

func spin(columns [][]byte) {
	maxIndex := len(columns) - 1
	for j := 0; j < len(columns)/2; j++ {
		for i := 0; i < len(columns)/2; i++ {
			columns[maxIndex-i][j], columns[maxIndex-j][maxIndex-i], columns[i][maxIndex-j], columns[j][i] =
				columns[j][i], columns[maxIndex-i][j], columns[maxIndex-j][maxIndex-i], columns[i][maxIndex-j]
		}
	}
}

func printColumns(columns [][]byte) {
	for j := 0; j < len(columns); j++ {
		for i := 0; i < len(columns); i++ {
			fmt.Print(string(columns[i][j]))
		}
		fmt.Println()
	}
}

func stringifyColumns(columns [][]byte) string {
	s := strings.Builder{}
	for _, column := range columns {
		s.Write(column)
	}
	return s.String()
}

func spin_cycle(columns [][]byte) {
	for j := 0; j < 4; j++ {
		tilt(columns)
		spin(columns)
	}
}

func part2(until int) int {
	columns := parse()
	seen := map[string]int{}
	for j := 0; j < until; j++ {
		key := stringifyColumns(columns)
		seenAt, alreadySeen := seen[key]
		if alreadySeen {
			fmt.Printf("first seen %d, now again at %d\n", seenAt, j)
			return part2(seenAt + (1000000000-seenAt)%(j-seenAt))
		}
		seen[key] = j
		spin_cycle(columns)
	}
	return load(columns)
}

func main() {
	fmt.Printf("Part 1: %d\n", part1())
	fmt.Printf("Part 2: %d\n", part2(1000000000))
}
