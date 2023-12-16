use std::{cmp, fs};

fn binary_encoder((index, b): (usize, u8)) -> u64 {
    match b {
        b'.' => 0,
        b'#' => 1 << index,
        _ => panic!(),
    }
}

fn get_h(i: &str) -> Vec<u64> {
    i.split('\n')
        .map(|l| l.bytes().enumerate().map(binary_encoder).sum())
        .collect()
}

fn get_v(i: &str) -> Vec<u64> {
    let lines = i.split('\n').collect::<Vec<&str>>();
    (0..lines[0].len())
        .map(|i| {
            lines
                .iter()
                .map(|l| l.bytes().nth(i).unwrap())
                .enumerate()
                .map(binary_encoder)
                .sum()
        })
        .collect()
}

fn parse() -> Vec<(Vec<u64>, Vec<u64>)> {
    fs::read_to_string("thirteenth.txt")
        .expect("Should have been able to read the file")
        .split("\n\n")
        .map(|i| (get_h(i), get_v(i)))
        .collect::<Vec<_>>()
}

fn reflection_line(numbers: Vec<u64>) -> Option<u64> {
    (0..numbers.len() - 1)
        .find(|&pos: &usize| {
            let diff = cmp::min(pos + 1, numbers.len() - 1 - pos);
            (0..diff).all(|j| numbers[pos - j] == numbers[pos + 1 + j])
        })
        .map(|w| 1 + u64::try_from(w).unwrap())
}

fn reflection_line_2(numbers: Vec<u64>) -> Option<u64> {
    (0..numbers.len() - 1)
        .find(|&pos: &usize| {
            let diff = cmp::min(pos + 1, numbers.len() - 1 - pos);
            (0..diff)
                .map(|j| (numbers[pos - j] ^ numbers[pos + 1 + j]).count_ones())
                .sum::<u32>()
                == 1
        })
        .map(|w| 1 + u64::try_from(w).unwrap())
}

fn summary((h, v): (Vec<u64>, Vec<u64>), f: impl Fn(Vec<u64>) -> Option<u64>) -> u64 {
    f(h).map(|w| 100 * w).or_else(|| f(v)).unwrap()
}

fn result(f: impl Fn((Vec<u64>, Vec<u64>)) -> u64) -> u64 {
    parse().into_iter().map(f).sum()
}

fn main() {
    println!("Part 1: {}", result(|i| summary(i, reflection_line)));
    println!("Part 2: {}", result(|i| summary(i, reflection_line_2)));
}
