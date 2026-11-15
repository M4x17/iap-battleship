// battleship_v2.swift

func canPlace(_ sea: [[Int]], _ row: Int, _ col: Int, _ length: Int, _ vertical: Bool) -> Bool {
    if row < 0 || col < 0 || row > 4 || col > 4 {
        return false
    }
    if vertical {
        if row + length - 1 > 4 { return false }
    } else {
        if col + length - 1 > 4 { return false }
    }
    for i in 0..<length {
        var r = row
        var c = col
        if vertical {
            r = row + i
        } else {
            c = col + i
        }
        if sea[r][c] != 0 {
            return false
        }
    }
    return true
}

func place(_ sea: [[Int]], _ id: Int, _ row: Int, _ col: Int, _ length: Int, _ vertical: Bool) -> [[Int]] {
    var newSea = sea
    for i in 0..<length {
        var r = row
        var c = col
        if vertical {
            r = row + i
        } else {
            c = col + i
        }
        newSea[r][c] = id
    }
    return newSea
}

func randomSea() -> [[Int]] {
    var sea = Array(repeating: Array(repeating: 0, count: 5), count: 5)
    let lengths = [3, 2, 2]
    for i in 0..<lengths.count {
        var placed = false
        while !placed {
            let row = Int.random(in: 0..<5)
            let col = Int.random(in: 0..<5)
            let vertical = Bool.random()
            if canPlace(sea, row, col, lengths[i], vertical) {
                sea = place(sea, i + 1, row, col, lengths[i], vertical)
                placed = true
            }
        }
    }
    return sea
}

func printBoard(_ shots: [[Int]]) {
    for r in 0..<5 {
        var line = ""
        for c in 0..<5 {
            var symbol = "."
            if shots[r][c] == 1 { symbol = "o" }
            if shots[r][c] == 2 { symbol = "X" }
            if c > 0 { line += " " }
            line += symbol
        }
        print(line)
    }
}

let sea = randomSea()
var shots = Array(repeating: Array(repeating: 0, count: 5), count: 5)
var remaining = [0, 3, 2, 2]
var shipsLeft = 3
var shotCount = 0

while shipsLeft > 0 {
    print("Shot row?")
    let rowLine = readLine()
    if rowLine == nil { break }
    print("Shot column?")
    let colLine = readLine()
    if colLine == nil { break }

    let rowValue = Int(rowLine!)
    let colValue = Int(colLine!)

    var rowLabel = "?"
    if rowValue != nil { rowLabel = String(rowValue!) }
    var colLabel = "?"
    if colValue != nil { colLabel = String(colValue!) }

    var result = "Invalid"
    if rowValue != nil && colValue != nil {
        let r = rowValue!
        let c = colValue!
        if r >= 0 && r < 5 && c >= 0 && c < 5 {
            if shots[r][c] != 0 {
                result = "Already played"
            } else {
                shotCount += 1
                let id = sea[r][c]
                if id == 0 {
                    shots[r][c] = 1
                    result = "Miss"
                } else {
                    shots[r][c] = 2
                    remaining[id] -= 1
                    if remaining[id] == 0 {
                        shipsLeft -= 1
                        result = "Sunk"
                    } else {
                        result = "Hit"
                    }
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
printBoard(shots)