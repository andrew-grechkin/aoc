#!/usr/bin/env python


def get_calories(elf: list) -> int:
    return sum(map(int, elf))


with open("2022/day1") as f:
    data = f.read()

    paragraphs = data.strip().split("\n\n")
    elves = map(lambda s: s.split("\n"), paragraphs)
    calories = sorted(map(get_calories, elves))

    print(calories[-1])
    print(sum(calories[-3:]))
