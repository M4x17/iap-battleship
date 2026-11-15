// battleship_git.swift

import Foundation

// BONUS : true (program runs git), false (have to type git everytime)
let autoGit = true

// Battleship_v2
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

// For 2 players
let sea = randomSea()
var received = Array(repeating: Array(repeating: false, count: 5), count: 5)
var shots = Array(repeating: Array(repeating: 0, count: 5), count: 5)
var remaining = [0, 3, 2, 2]
var shipsLeft = 3
func input(_ question: String) -> String {
    print(question)
    guard let line = readLine() else { exit(0) }
    return line.trimmingCharacters(in: .whitespaces)
}
func askNumber(_ question: String) -> Int {
    while true {
        if let n = Int(input(question)), n >= 0, n < 5 { return n }
        print("Enter a number between 0 and 4")
    }
}

// Answer to a shot on my sea (never crashes, whatever the numbers)
func answer(_ r: Int, _ c: Int) -> String {
    if r < 0 || r > 4 || c < 0 || c > 4 || received[r][c] { return "Miss" }
    received[r][c] = true
    let id = sea[r][c]
    if id == 0 { return "Miss" }
    remaining[id] -= 1
    if remaining[id] == 0 {
        shipsLeft -= 1
        return "Sunk"
    }
    return "Hit"
}

// The game file: non-empty lines
func readLines(_ path: String) -> [String] {
    let text = (try? String(contentsOfFile: path, encoding: .utf8)) ?? ""
    var lines: [String] = []
    for part in text.components(separatedBy: .newlines) {
        let line = part.trimmingCharacters(in: .whitespaces)
        if line != "" { lines.append(line) }
    }
    return lines
}

// Rebuild my shots from the whole file: "me shot r c" followed by "opponent answer"
func rebuildShots(_ lines: [String], _ me: String, _ opponent: String) {
    shots = Array(repeating: Array(repeating: 0, count: 5), count: 5)
    var i = 0
    while i + 1 < lines.count {
        let a = lines[i].split(separator: " ").map { String($0) }
        let b = lines[i + 1].split(separator: " ").map { String($0) }
        if a.count == 4 && a[0] == me && a[1] == "shot" && b.count == 2 && b[0] == opponent {
            if let r = Int(a[2]), let c = Int(a[3]), r >= 0, r < 5, c >= 0, c < 5 {
                if b[1] == "Miss" { shots[r][c] = 1 }
                if b[1] == "Hit" || b[1] == "Sunk" { shots[r][c] = 2 }
            }
        }
        i += 1
    }
}
func git(_ args: [String]) {
    let p = Process()
    p.executableURL = URL(fileURLWithPath: "/usr/bin/env")
    p.arguments = ["git"] + args
    do {
        try p.run()
        p.waitUntilExit()
    } catch {
        print("Could not run git")
    }
}

// Add a line to the game file, then commit and push
func send(_ path: String, _ line: String) {
    var text = (try? String(contentsOfFile: path, encoding: .utf8)) ?? ""
    if text != "" && !text.hasSuffix("\n") { text += "\n" }
    text += line + "\n"
    try? text.write(toFile: path, atomically: true, encoding: .utf8)
    if autoGit {
        git(["add", path])
        git(["commit", "-m", line])
        git(["push"])
    } else {
        print("Now run: git add, commit and push")
    }
}

// Both terminals use the same folder, so there is nothing to pull: just read the file again
func waitOther() {
    print("Waiting for the other player...")
    sleep(1)
}

// Start
var name = ""
while name == "" { name = input("Game name?") }
let path = name + ".txt"
if !FileManager.default.fileExists(atPath: path) {
    FileManager.default.createFile(atPath: path, contents: nil)
}
var me = ""
while me != "A" && me != "B" { me = input("Player? (A or B)").uppercased() }
let opponent = (me == "A") ? "B" : "A"
let results = ["Hit", "Miss", "Sunk"]

// Game
while true {
    let lines = readLines(path)
    var words: [String] = []
    if let last = lines.last { words = last.split(separator: " ").map { String($0) } }
    var who = ""
    var second = ""
    if words.count > 0 { who = words[0] }
    if words.count > 1 { second = words[1] }
    if words.count == 2 && second == "Lost" && (who == "A" || who == "B") {
        print("Player \((who == "A") ? "B" : "A") wins")
        break
    } else if who == opponent && words.count == 4 && second == "shot" {
        // The opponent shot on my sea
        var result = "Miss"
        if let r = Int(words[2]), let c = Int(words[3]) { result = answer(r, c) }
        print("Opponent shot \(words[2]) \(words[3]): \(result)")
        send(path, "\(me) \(result)")
        if shipsLeft == 0 {
            send(path, "\(me) Lost")
            print("Player \(opponent) wins")
            break
        }
    } else if (who == me && words.count == 2 && results.contains(second)) || (lines.isEmpty && me == "A") {
        // My turn to shoot
        rebuildShots(lines, me, opponent)
        printBoard(shots)
        var row = 0
        var col = 0
        var ok = false
        while !ok {
            row = askNumber("Shot row?")
            col = askNumber("Shot column?")
            if shots[row][col] != 0 {
                print("Already played")
            } else {
                ok = true
            }
        }
        send(path, "\(me) shot \(row) \(col)")
    } else {
        // Wait for the other player
        waitOther()
    }
}