(local inspect (require :inspect))

(local pl (require :pl.utils))
(local tablex (require :pl.tablex))

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

(fn tick [grid current-position]
  (let [(current-row current-col) (table.unpack current-position)
        current-guard (. grid current-row current-col)
        direction-coordinates (direction-to-move current-guard)
        next-row (+ current-row (. direction-coordinates 1))
        next-col (+ current-col (. direction-coordinates 2))
        next-tile (. grid next-row next-col)]
    (case next-tile
      nil (values grid nil)
      "#" (do
            (tset grid current-row current-col
                  (turn-right-90-degrees current-guard))
            (values grid current-position))
      _ (do
          (tset grid current-row current-col ".")
          (tset grid next-row next-col current-guard)
          (values grid [next-row next-col])))))

(fn simulate-helper [grid visited current-position]
  (let [(current-row current-col) (table.unpack current-position)
        current-guard (. grid current-row current-col)
        current-visited (. visited (fennel.view current-position))
        (updated-grid next-position) (tick grid current-position)]
    (tset current-visited current-guard true) ; (print (fennel.view grid)) ; convert position to string so we don't need to use faith deep equality ; failed trying to use __eq for indexing with sequential table so far
    (tset visited (fennel.view current-position) current-visited)
    ;(print (fennel.view visited))
    ;(print (table-length visited))
    (if (= next-position nil) visited
        (simulate-helper grid visited next-position))))

(fn simulate [grid]
  (let [visited {}
        defaultmt {:__index (fn [] {})}
        starting-position (find-guard grid)]
    (setmetatable visited defaultmt)
    (simulate-helper grid visited starting-position)))

(local original-grid-no-guard (let [copied-grid (tablex.deepcopy grid)
                                    guard-position (find-guard grid)
                                    (current-row current-col) (table.unpack guard-position)]
                                (tset copied-grid current-row current-col ".")
                                copied-grid))

(local visited (simulate grid))

(print (fennel.view visited))
(print (table-length visited))

(fn simulate-until-loop [visited grid current-position]
  (let [(current-row current-col) (table.unpack current-position)
        current-guard (. grid current-row current-col)
        current-visited (. visited (fennel.view current-position))
        (updated-grid next-position) (tick grid current-position)]
    (if (. current-visited current-guard)
        true
        (if (= nil next-position)
            false
            (simulate-until-loop visited updated-grid next-position)))))

(fn is-valid-loop-blocker? [position visited]
  (accumulate [result false position-increment orientation (pairs blocking-position-increment-to-orientation)]
    (let [(row col) (table.unpack position)
          check-row (+ row (. position-increment 1))
          check-col (+ col (. position-increment 2))
          visited-orientations (. visited (fennel.view [check-row check-col]))]
      (or (and (not= nil visited-orientations)
               (not= nil (. visited-orientations orientation))
               (let [copied-grid (tablex.deepcopy original-grid-no-guard)]
                 (tset copied-grid row col "#")
                 (tset copied-grid check-row check-col (turn-right-90-degrees orientation))
                 (simulate-until-loop visited copied-grid [check-row check-col])))
          result))))

(assert-repl (not (is-valid-loop-blocker? [7 4] visited)))
(assert-repl (not (is-valid-loop-blocker? [8 7] visited)))
(assert-repl (not (is-valid-loop-blocker? [8 8] visited)))
(assert-repl (not (is-valid-loop-blocker? [9 2] visited)))
(assert-repl (not (is-valid-loop-blocker? [9 4] visited)))
(assert-repl (not (is-valid-loop-blocker? [10 8] visited)))
(assert-repl (is-valid-loop-blocker? [4 5] visited))
(assert-repl (is-valid-loop-blocker? [2 8] visited))


(fn find-loop-blockers [grid visited]
  (accumulate [blockers [] position-string _ (pairs visited)]
    (let [position (fennel.eval position-string)]
      (if (is-valid-loop-blocker? position visited)
          (do
            (table.insert blockers position)
            blockers)
          blockers))))

(print (fennel.view (find-loop-blockers grid visited)))
(print (length (find-loop-blockers grid visited)))
