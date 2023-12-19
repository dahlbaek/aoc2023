import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.stream.IntStream;
import java.util.stream.Stream;

class Tuple {

    public String arrangements;
    public List<Integer> groups;

    public Tuple(String arrangements, List<Integer> groups) {
        this.arrangements = arrangements;
        this.groups = groups;
    }

    public String toString() {
        return arrangements + " " + Arrays.toString(groups.toArray());
    }

    public static Tuple parseLine(String line) {
        String[] split = line.split(" ");
        return new Tuple(split[0], Stream.of(split[1].split(",")).map(Integer::parseInt).toList());
    }

    public static Tuple parseLine2(String line) {
        String[] split = line.split(" ");
        String arrangements = split[0] + "?" + split[0] + "?" + split[0] + "?" + split[0] + "?" + split[0];
        List<Integer> groups = Stream.of(split[1].split(",")).map(Integer::parseInt).toList();
        return new Tuple(arrangements, groups);
    }

    private boolean valid() {
        List<Integer> actual = Stream.of(arrangements.split("\\."))
                .filter(s -> !s.isEmpty())
                .map(String::length)
                .toList();
        if (actual.size() != groups.size()) {
            return false;
        }
        for (int i = 0; i < groups.size(); i++) {
            if (actual.get(i) != groups.get(i)) {
                return false;
            }
        }
        return true;
    }

    public Stream<Tuple> possibilities() {
        List<StringBuilder> tmpTrans = new ArrayList<StringBuilder>();
        tmpTrans.add(new StringBuilder());
        for (char c : arrangements.toCharArray()) {
            if (c == '?') {
                List<StringBuilder> toAdd = new ArrayList<StringBuilder>();
                for (StringBuilder s : tmpTrans) {
                    StringBuilder s2 = new StringBuilder(s);
                    s.append('.');
                    s2.append('#');
                    toAdd.add(s2);
                }
                tmpTrans.addAll(toAdd);
            } else {
                for (StringBuilder s : tmpTrans) {
                    s.append(c);
                }
            }
        }
        return tmpTrans.stream().map(x -> new Tuple(x.toString(), groups)).filter(x -> x.valid());
    }

    public Long possibilities2(int beginIndex, int groupIndex) {
        Stepper stepper = new Stepper(this);
        return stepper.step(new STuple(0, 1L))
                .flatMap(stepper::step)
                .flatMap(stepper::step)
                .flatMap(stepper::step)
                .flatMap(stepper::step)
                .filter(stuple -> arrangements.indexOf('#', stuple.index) == -1)
                .map(stuple -> stuple.possibilities)
                .reduce(Long::sum)
                .get();
    }

    public IntStream admissibleIndices(int beginIndex, int groupIndex) {
        Integer firstBroken = arrangements.indexOf('#', beginIndex);
        firstBroken = firstBroken == -1 ? arrangements.length() : firstBroken + 1;
        Integer groupSize = groups.get(groupIndex);

        return IntStream
                .range(beginIndex, firstBroken)
                .filter(index -> {
                    Integer firstDot = arrangements.indexOf('.', (int) index);
                    return arrangements.length() >= index + groupSize
                            && (firstDot < index || firstDot >= index + groupSize)
                            && (arrangements.length() == index + groupSize
                                    || arrangements.charAt((int) index + groupSize) != '#');
                })
                .map(index -> Integer.min(index + groupSize + 1, arrangements.length()));
    }
}

class STuple {
    Integer index;
    Long possibilities;

    public STuple(int index, Long possibilities) {
        this.index = index;
        this.possibilities = possibilities;
    }

    public String toString() {
        return "(" + index + ", " + possibilities + ")";
    }

    public STuple multiply(Long possibilities) {
        return new STuple(index, this.possibilities * possibilities);
    }
}

class Stepper {
    public List<List<STuple>> combined;

    public Stepper(Tuple t) {
        this.combined = new ArrayList<>();
        for (int j = 0; j < t.arrangements.length(); j++) {
            HashMap<Integer, Long> hm1 = new HashMap<Integer, Long>();
            t.admissibleIndices(j, 0).boxed().forEach(index -> hm1.put(index, 1L));
            for (int groupIndex = 1; groupIndex < t.groups.size(); groupIndex++) {
                HashMap<Integer, Long> hm2 = new HashMap<Integer, Long>();
                int gri = groupIndex;
                hm1.forEach((beginIndex, value) -> t.admissibleIndices(beginIndex, gri)
                        .forEach(index -> hm2.merge(index, value, Long::sum)));
                hm1.clear();
                hm1.putAll(hm2);
            }
            this.combined.add(hm1.entrySet().stream().map(e -> new STuple(e.getKey(), e.getValue())).toList());
        }
        this.combined.add(List.of());
    }

    public Stream<STuple> step(STuple stuple) {
        return combined.get(stuple.index).stream().map(nextStuple -> nextStuple.multiply(stuple.possibilities));
    }
}

class Solution {

    public static Stream<Tuple> parse(boolean first) throws IOException {
        Stream<String> lines = Stream.of(Files.readString(Paths.get("twelfth.txt")).split("\n"));
        return first ? lines.map(Tuple::parseLine) : lines.map(Tuple::parseLine2).toList().stream();
    }

    public static void main(String[] args) throws IOException {
        long part1 = parse(true).flatMap(t -> t.possibilities()).count();
        System.out.println("Part 1: " + part1);

        long part2 = parse(false).map(t -> t.possibilities2(0, 0)).reduce(0L, Long::sum);
        System.out.println("Part 2: " + part2);
    }
}
