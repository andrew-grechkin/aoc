#!/usr/bin/env bun

const fs = require('fs')

/**
 * Sum of all elements in array
 * @param {Array<number>} arr - array of integers
 * @returns {number} - sum
 * @example
 * const arr = [1,2,3,4,5]
 *
 * const result = sum(arr);
 * console.log(result);
 * // Logs: 15
 */
function sum(arr) {
    return arr.reduce((acc, val) => {
        return acc + val
    }, 0)
}
const to_elf = (str) => str.split('\n').map((num) => parseInt(num))

const data = fs.readFileSync('2022/day1', 'utf8').trim()
const paragraphs = data.split('\n\n')
const elves = paragraphs.map(to_elf)
const calories = elves.map((it) => sum(it)).sort()

console.log(calories[calories.length - 1])
console.log(sum(calories.slice(-3)))
