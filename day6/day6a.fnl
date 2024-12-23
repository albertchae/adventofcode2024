(local inspect (require :inspect))

(local pl (require :pl.utils))

(local fun (require :fun))
(local fennel (require :fennel))

(local filename (. arg 1))

(print (.. "Reading file: " filename))

(fn split-string-to-chars [string]
  (fun.totable (fun.take_while (fn [_]
                                 true) string)))

(fn table-length [table]
  (length (icollect [_ _ (pairs table)]
            true)))

(fn parse-file-to-grid [filename]
  (let [grid {}
        defaultmt {:__index (fn [] {})}]
    (setmetatable grid defaultmt)
    (each [line (io.lines filename)] (local chars (split-string-to-chars line))
      (table.insert grid chars))
    grid))

(local grid (parse-file-to-grid filename))

(print (fennel.view grid))

(fn find-guard [grid]
  (var coordinates nil)
  (each [i (fun.range (length grid)) &until (not= coordinates nil)]
    (each [j (fun.range (length (. grid i)))]
      (if (= (. grid i j) "^") (set coordinates [i j]))))
  coordinates)

(print (fennel.view (find-guard grid)))

(fn direction-to-move [guard-orientation]
  (if (= guard-orientation "^") [-1 0]
      (= guard-orientation ">") [0 1]
      (= guard-orientation :v) [1 0]
      (= guard-orientation "<") [0 -1]))

(fn turn-right-90-degrees [guard-orientation]
  (if (= guard-orientation "^") ">"
      (= guard-orientation ">") :v
      (= guard-orientation :v) "<"
      (= guard-orientation "<") "^"))

; each iteration
; increment map of positions to number of times visited
; check current direction to move
; check next position
; if blocked, turn 90 degrees
; if out of bounds, done
; else move

(fn simulate-helper [grid visited current-position]
  (let [(current-row current-col) (table.unpack current-position)
        current-guard (. grid current-row current-col)
        ; (. grid (table.unpack current-position) doesn't work?
        direction-coordinates (direction-to-move current-guard)
        next-row (+ current-row (. direction-coordinates 1))
        next-col (+ current-col (. direction-coordinates 2))
        next-tile (. grid next-row next-col)]
    ;(print (fennel.view grid))
    (tset visited (fennel.view current-position) true) ; convert position to string so we don't need to use faith deep equality or overwrite a metatable
    ;(print (fennel.view visited))
    ;(print (table-length visited))
    (case next-tile
      nil visited
      "#" (do
            (tset grid current-row current-col
                  (turn-right-90-degrees current-guard))
            (simulate-helper grid visited current-position))
      _ (do
          (tset grid current-row current-col ".")
          (tset grid next-row next-col current-guard)
          (simulate-helper grid visited [next-row next-col])))))

(fn simulate [grid]
  (let [visited {}
        starting-position (find-guard grid)]
    (simulate-helper grid visited starting-position)))

(local visited (simulate grid))

(print (fennel.view visited))
(print (table-length visited))

(assert-repl false)
