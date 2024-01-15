import math


class Module:
    def __init__(self, name: str, inputs: list[str], outputs: list[str]):
        self.name = name
        self.inputs = inputs
        self.outputs = outputs

    def __repr__(self):
        return f"{type(self).__name__}({self.name}, {self.inputs}, {self.outputs})"

    def pulse(self, high: bool, origin: str, names: dict[str, "Module"]) -> list[tuple["Module | None", bool, str]]:
        raise NotImplementedError


class Broadcaster(Module):
    def pulse(self, high: bool, origin: str, names: dict[str, Module]) -> list[tuple["Module | None", bool, str]]:
        pulses = []
        for output in self.outputs:
            module = names.get(output)
            # module_name = module and module.name or output
            # print(f"{self.name} -{'high' if high else 'low'}-> {module_name}")
            pulses.append((module, high, self.name))
        return pulses


class FlipFlop(Module):
    def __init__(self, name: str, inputs: list[str], outputs: list[str]):
        super().__init__(name, inputs, outputs)
        self.on = False

    def pulse(self, high: bool, origin: str, names: dict[str, Module]) -> list[tuple["Module | None", bool, str]]:
        pulses = []
        if not high:
            self.on = not self.on
            for output in self.outputs:
                module = names.get(output)
                # module_name = module and module.name or output
                # print(f"{self.name} -{'high' if self.on else 'low'}-> {module_name}")
                pulses.append((module, self.on, self.name))
        return pulses


class Conjunction(Module):
    def __init__(self, name: str, inputs: list[str], outputs: list[str]):
        super().__init__(name, inputs, outputs)
        self._inputs = {i: False for i in inputs}

    def pulse(self, high: bool, origin: str, names: dict[str, Module]) -> list[tuple["Module | None", bool, str]]:
        pulses = []
        self._inputs[origin] = high
        for output in self.outputs:
            module = names.get(output)
            # module_name = module and module.name or output
            # print(f"{self.name} -{'high' if not all(self._inputs.values()) else 'low'}-> {module_name}")
            pulses.append((module, not all(self._inputs.values()), self.name))
        return pulses


def get_name(line: str) -> str:
    return line.removeprefix("%").removeprefix("&").split(" -> ", maxsplit=1)[0]


def get_outputs(line: str) -> list[str]:
    return line.split(" -> ", maxsplit=1)[1].split(", ")


def get_constructor(line: str) -> type[Broadcaster] | type[FlipFlop] | type[Conjunction]:
    if line.startswith("broadcaster"):
        return Broadcaster
    if line.startswith("%"):
        return FlipFlop
    if line.startswith("&"):
        return Conjunction
    raise RuntimeError


def parse() -> dict[str, Module]:
    content = open("twentieth.txt").read()
    outputs_for_name = [(get_name(line), get_outputs(line)) for line in content.splitlines()]
    names = {}
    for line in content.splitlines():
        name = get_name(line)
        outputs = get_outputs(line)
        inputs = [input_name for input_name, input_outputs in outputs_for_name if name in input_outputs]
        names[name] = get_constructor(line)(name, inputs, outputs)
    # print("names:\n" + "\n".join(f"  {k}: {v}" for k, v in names.items()))
    return names


def button(names: dict[str, Module], penultimate_names: tuple[str, ...]) -> tuple[int, int, list[str]]:
    # print(f"button -low-> broadcaster")
    lows, highs, penultimates = 1, 0, []
    pulses = names["broadcaster"].pulse(False, "button", names)
    pulses_2 = []
    while pulses:
        for module, high, origin in pulses:
            lows += not high
            highs += high
            if module is not None:
                if origin in penultimate_names and high:
                    penultimates.append(origin)
                pulses_2.extend(module.pulse(high, origin, names))
        pulses, pulses_2 = pulses_2, []
    return lows, highs, penultimates


def main():
    names = parse()
    lows, highs = 0, 0
    for j in range(1000):
        _lows, _highs, _ = button(names, ())
        lows += _lows
        highs += _highs
    print(f"Part 1: {lows*highs}")

    names = parse()
    ultimate = next(module for module in names.values() if "rx" in module.outputs)
    penultimate: dict[str, int] = {n: 0 for n in ultimate.inputs}
    j = 0
    while not all(penultimate.values()):
        j += 1
        _, _, penultimates = button(names, tuple(penultimate.keys()))
        for origin in penultimates:
            if penultimate[origin] == 0:
                penultimate[origin] = j
    print(f"Part 2: {math.prod(penultimate.values())}")


if __name__ == "__main__":
    main()
