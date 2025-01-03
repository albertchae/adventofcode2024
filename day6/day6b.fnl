(local inspect (require :inspect))

(local utils (require :pl.utils))
(local tablex (require :pl.tablex))

(local fun (require :fun))
(local fennel (require :fennel))

;; profile.lua isn't in luarocks so need to vendor it locally
;; $ git clone https://github.com/2dengine/profile.lua profile
;; (local profile (require :profile.profile))

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

(fn position->table-key [position]
  (table.concat position ","))

(fn table-key->position [key]
  (icollect [_ v (ipairs (utils.split key ","))]
    (tonumber v)))

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
        current-visited (. visited (position->table-key current-position))
        (updated-grid next-position) (tick grid current-position)]
    (tset current-visited current-guard true) ; (print (fennel.view grid)) ; convert position to string so we don't need to use faith deep equality ; failed trying to use __eq for indexing with sequential table so far
    (tset visited (position->table-key current-position) current-visited)
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

(local original-grid (tablex.deepcopy grid))

(local visited (simulate grid))

(print (fennel.view visited))
(print (table-length visited))

(fn simulate-until-loop [visited grid current-position]
  (let [(current-row current-col) (table.unpack current-position)
        current-guard (. grid current-row current-col)
        current-visited (. visited (position->table-key current-position))
        (updated-grid next-position) (tick grid current-position)]
    (if (. current-visited current-guard)
        true
        (if (= nil next-position)
            false
            (do
              (tset current-visited current-guard true)
              (tset visited (position->table-key current-position)
                    current-visited)
              (simulate-until-loop visited updated-grid next-position))))))

(fn is-valid-loop-blocker? [grid
                            blocker-candidate-position
                            visited
                            starting-position]
  (let [(row col) (table.unpack blocker-candidate-position)
        copied-grid (tablex.deepcopy grid)
        new-visited {}
        defaultmt {:__index (fn [] {})}]
    (setmetatable new-visited defaultmt)
    (tset copied-grid row col "#")
    (simulate-until-loop new-visited copied-grid starting-position)))

; sample.input
; (print (assert-repl (is-valid-loop-blocker? original-grid [7 4] visited [7 5])))
; (print (assert-repl (is-valid-loop-blocker? original-grid [8 7] visited [7 5])))
; (print (assert-repl (is-valid-loop-blocker? original-grid [8 8] visited [7 5])))
; (print (assert-repl (is-valid-loop-blocker? original-grid [9 2] visited [7 5])))
; (print (assert-repl (is-valid-loop-blocker? original-grid [9 4] visited [7 5])))
; (print (assert-repl (is-valid-loop-blocker? original-grid [10 8] visited [7 5])))
; (print (assert-repl (not (is-valid-loop-blocker? original-grid [4 5] visited [7 5]))))
; (print (assert-repl (not (is-valid-loop-blocker? original-grid [2 8] visited [7 5]))))

(fn find-loop-blockers [grid visited]
  (let [starting-position (find-guard grid)]
    (accumulate [blockers [] position-string _ (pairs visited)]
      (let [position (table-key->position position-string)]
        (if (= (position->table-key starting-position) position-string)
            blockers
            (if (is-valid-loop-blocker? grid position visited starting-position)
                (do
                  (table.insert blockers position)
                  blockers)
                blockers))))))

;; (profile.start)

(local loop-blockers (find-loop-blockers original-grid visited))

;; (profile.stop)
;(print (fennel.view loop-blockers))

(print (length loop-blockers))
;; (print (profile.report 10))
