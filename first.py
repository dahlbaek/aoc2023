out = []
for line in open("first.txt", mode="rt"):
    for char in line:
        if char in "1234567890":
            first = char
            break
    for char in reversed(line):
        if char in "1234567890":
            last = char
            break
    out.append((first, last))
ints = [int(l[0] + l[1]) for l in out]
print(sum(ints))

NUMBERS = [
    "zero",
    "one",
    "two",
    "three",
    "four",
    "five",
    "six",
    "seven",
    "eight",
    "nine",
]


def get_number(line, reverse):
    ran = reversed(range(len(line))) if reverse else range(len(line))
    for idx in ran:
        for number, word in enumerate(NUMBERS):
            if line[idx] == str(number) or line[idx:].startswith(word):
                return number
    raise RuntimeError


out = []
for line in open("first.txt", mode="rt"):
    first = get_number(line, False)
    last = get_number(line, True)
    out.append((first, last))
ints = [int(str(l[0]) + str(l[1])) for l in out]
print(sum(ints))
