// battleship_random.swift

var ship: [[Int]] = [
    [-1, -1, -1, -1, -1],
    [-1, -1, -1, -1, -1],
    [-1, -1, -1, -1, -1],
    [-1, -1, -1, -1, -1],
    [-1, -1, -1, -1, -1]
]
var lengths: [Int] = [3, 2, 2]
var id: Int = 0
while id < 3 {
    var row: Int = Int.random(in: 0...4)
    var col: Int = Int.random(in: 0...4)
    var direction: Int = Int.random(in: 0...1)
    var fits: Bool = true
    if row < 0 || row > 4 || col < 0 || col > 4 {
        fits = false
    } else {
        var endRow: Int = row
        var endCol: Int = col
        if direction == 0 {
            endCol = col + lengths[id] - 1
        } else {
            endRow = row + lengths[id] - 1
        }
        if endRow > 4 || endCol > 4 {
            fits = false
        }
    }
    if fits {
        var k: Int = 0
        while k < lengths[id] {
            var r: Int = row
            var c: Int = col
            if direction == 0 { c = col + k } else { r = row + k }
            if ship[r][c] != -1 {
                fits = false
            }
            k += 1
        }
    }
    if fits {
        var k: Int = 0
        while k < lengths[id] {
            var r: Int = row
            var c: Int = col
            if direction == 0 { c = col + k } else { r = row + k }
            ship[r][c] = id
            k += 1
        }
        id += 1
    }
}
var shots: [[Int]] = [
    [0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0]
]
var remaining: [Int] = [3, 2, 2]
var shipsLeft: Int = 3
var shotCount: Int = 0
while shipsLeft > 0 {
    print("Shot row?")
    let rowLine = readLine()
    if rowLine == nil { break }
    print("Shot column?")
    let colLine = readLine()
    if colLine == nil { break }
    shotCount += 1
    let rowValue = Int(rowLine!)
    let colValue = Int(colLine!)
    var rowLabel: String = "?"
    if rowValue != nil { rowLabel = String(rowValue!) }
    var colLabel: String = "?"
    if colValue != nil { colLabel = String(colValue!) }
    var result: String = "Invalid"
    if rowValue != nil && colValue != nil {
        let r: Int = rowValue!
        let c: Int = colValue!
        if r >= 0 && r < 5 && c >= 0 && c < 5 {
            if shots[r][c] != 0 {
                result = "Already played"
            } else if ship[r][c] == -1 {
                shots[r][c] = 1
                result = "Miss"
            } else {
                shots[r][c] = 2
                let s: Int = ship[r][c]
                remaining[s] -= 1
                if remaining[s] == 0 {
                    shipsLeft -= 1
                    result = "Sunk"
                } else {
                    result = "Hit"
                }
            }
        }
    }
    print("Shot \(rowLabel) \(colLabel): \(result)")
}
if shipsLeft == 0 {
    print("All ships sunk in \(shotCount) shots")
} else {
    print("Game over: \(shipsLeft) ships left")
}
var i: Int = 0
while i < 5 {
    var line: String = ""
    var j: Int = 0
    while j < 5 {
        var symbol: String = "."
        if shots[i][j] == 1 { symbol = "o" }
        if shots[i][j] == 2 { symbol = "X" }
        if j > 0 { line += " " }
        line += symbol
        j += 1
    }
    print(line)
    i += 1
}