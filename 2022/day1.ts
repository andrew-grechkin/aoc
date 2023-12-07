#!/usr/bin/env bun

import {readFileSync} from 'fs';

const data = readFileSync('2022/day1', 'utf8').trim()
const paragraphs = data.split('\n\n')
const elves = paragraphs.map((str) => str.split('\n').map((num) => parseInt(num)))
const calories = elves
    .map((arr) =>
        arr.reduce((acc, val) => {
            return acc + val
        }, 0),
    )
    .sort()

console.log(calories[calories.length - 1])
console.log(
    calories.slice(-3).reduce((acc, val) => {
        return acc + val
    }, 0),
)
