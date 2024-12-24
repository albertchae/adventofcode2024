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

(local blocking-position-increment-to-orientation
       {[-1 0] :v [0 1] "<" [1 0] "^" [0 -1] ">"})

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
        current-visited (. visited (fennel.view current-position))
        ; (. grid (table.unpack current-position) doesn't work?
        direction-coordinates (direction-to-move current-guard)
        next-row (+ current-row (. direction-coordinates 1))
        next-col (+ current-col (. direction-coordinates 2))
        next-tile (. grid next-row next-col)]
    (tset current-visited current-guard true) ; (print (fennel.view grid)) ; convert position to string so we don't need to use faith deep equality ; failed trying to use __eq for indexing with sequential table so far
    (tset visited (fennel.view current-position) current-visited)
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
        defaultmt {:__index (fn [] {})}
        starting-position (find-guard grid)]
    (setmetatable visited defaultmt)
    (simulate-helper grid visited starting-position)))

(local visited (simulate grid))

(print (fennel.view visited))
(print (table-length visited))

(fn is-valid-loop-blocker? [position visited]
  (accumulate [result false position-increment orientation (pairs blocking-position-increment-to-orientation)]
    (let [(row col) (table.unpack position)
          turn-right-orientation (turn-right-90-degrees orientation)
          check-row (+ row (. position-increment 1))
          check-col (+ col (. position-increment 2))
          check-position (. visited (fennel.view [check-row check-col]))]
      (or (and (not= nil check-position)
               (not= nil (. check-position orientation))
               (not= nil (. check-position turn-right-orientation)))
          result))))

(print (fennel.view (is-valid-loop-blocker? [7 4] visited)))

(fn find-loop-blockers [grid visited]
  (accumulate [blockers [] position-string _ (pairs visited)]
    (let [position (fennel.eval position-string)]
      (if (is-valid-loop-blocker? position visited)
          (do
            (table.insert blockers position) blockers)
          blockers))))

(print (fennel.view (find-loop-blockers grid visited)))
(print (length (find-loop-blockers grid visited)))