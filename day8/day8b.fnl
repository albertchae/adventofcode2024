(local inspect (require :inspect))

(local utils (require :pl.utils))

(local fun (require :fun))
(local fennel (require :fennel))

(local combine (require :luacombine.combine))

(local filename (. arg 1))

(print (.. "Reading file: " filename))

(fn split-string-to-chars [string]
  (fun.totable (fun.take_while (fn [_]
                                 true) string)))

(fn table-length [table]
  (length (icollect [_ _ (pairs table)]
            true)))

(print "This is red->\027[41mred\027[0m\n")

(fn parse-file-to-grid [filename]
  (let [grid {}
        defaultmt {:__index (fn [] {})}]
    (setmetatable grid defaultmt)
    (each [line (io.lines filename)] (local chars (split-string-to-chars line))
      (table.insert grid chars))
    grid))

(local grid (parse-file-to-grid filename))

(print (fennel.view grid))

(fn manhattan-distance [pt1 pt2]
  (let [[row1 col1] pt1
        [row2 col2] pt2]
    [(- row2 row1) (- col2 col1)]))

(print (fennel.view (manhattan-distance [4 5] [6 6])))

(print (fennel.view (manhattan-distance [6 6] [4 5])))

(fn add-manhattan-distance [pt distance]
  (let [[row col] pt
        [row-dist col-dist] distance]
    [(+ row row-dist) (+ col col-dist)]))

(fn negate [distance]
  (let [[row-dist col-dist] distance]
    [(- row-dist) (- col-dist)]))

(print (fennel.view (add-manhattan-distance [6 6] [2 1])))
(print (fennel.view (add-manhattan-distance [4 5] (negate [2 1]))))

(fn in-bounds? [point grid]
  (let [[row col] point]
    (not= nil (. grid row col))))

;; just change this to add as many in both directions that are in bounds

(fn inbound-antinodes [pt1 pt2 grid]
  (let [distance (manhattan-distance pt1 pt2)
        antinodes []]
    (var candidate-node1 (add-manhattan-distance pt1 distance))
    (while (in-bounds? candidate-node1 grid)
      (table.insert antinodes candidate-node1)
      (set candidate-node1 (add-manhattan-distance candidate-node1 distance)))
    (var candidate-node2 (add-manhattan-distance pt2 (negate distance)))
    (while (in-bounds? candidate-node2 grid)
      (table.insert antinodes candidate-node2)
      (set candidate-node2
           (add-manhattan-distance candidate-node2 (negate distance))))
    antinodes))

(print (fennel.view (inbound-antinodes [1 1] [2 4] grid)))
(print (fennel.view (inbound-antinodes [2 4] [1 1] grid)))

(print (fennel.view (inbound-antinodes [1 1] [3 2] grid)))

(fn position->table-key [position]
  (table.concat position ","))

(fn table-key->position [key]
  (icollect [_ v (ipairs (utils.split key ","))]
    (tonumber v)))

;; First pass - find coordinates of a frequency

(fn build-frequency-grid [grid]
  (let [frequency-grid {}
        defaultmt {:__index (fn [] [])}]
    (setmetatable frequency-grid defaultmt)
    ;; (each [i row (ipairs grid)] this is an infinite loop with a default metatable
    (for [i 1 (length grid)]
      (let [row (. grid i)]
        (for [j 1 (length row)]
          (let [value (. row j)
                position [i j]
                entry (. frequency-grid value)]
            (when (not= value ".")
              (table.insert entry position)
              (set (. frequency-grid value) entry))))))
    frequency-grid))

(local frequency-grid (build-frequency-grid grid))

(print (fennel.view frequency-grid))

;; Second pass - for every combination of 2 of a frequency, find antinodes in bounds

;; ./luarocks install --server=https://luarocks.org/dev luacombine

(fn build-antinodes-grid [frequency-grid grid]
  (let [antinodes-grid {}]
    (each [frequency points (pairs frequency-grid)]
      (when (>= (length points) 2)
        (each [pt1 pt2 (combine.combn points 2)]
          (print (fennel.view [pt1 pt2]))
          (let [antinodes (inbound-antinodes pt1 pt2 grid)]
            (print (fennel.view antinodes))
            (each [_ antinode (ipairs antinodes)]
              (set (. antinodes-grid (position->table-key antinode)) true))))))
  antinodes-grid))

(local antinodes-grid (build-antinodes-grid frequency-grid grid))

(print (fennel.view antinodes-grid))

(print (table-length antinodes-grid))

;; (fn simulate-helper [grid visited current-position]
;;   (let [(current-row current-col) (table.unpack current-position)
;;         current-guard (. grid current-row current-col)
;;         ; (. grid (table.unpack current-position) doesn't work?
;;         direction-coordinates (direction-to-move current-guard)
;;         next-row (+ current-row (. direction-coordinates 1))
;;         next-col (+ current-col (. direction-coordinates 2))
;;         next-tile (. grid next-row next-col)]
;;     ;(print (fennel.view grid))
;;     (tset visited (fennel.view current-position) true) ; convert position to string so we don't need to use faith deep equality or overwrite a metatable
;;     ;(print (fennel.view visited))
;;     ;(print (table-length visited))
;;     (case next-tile
;;       nil visited
;;       "#" (do
;;             (tset grid current-row current-col
;;                   (turn-right-90-degrees current-guard))
;;             (simulate-helper grid visited current-position))
;;       _ (do
;;           (tset grid current-row current-col ".")
;;           (tset grid next-row next-col current-guard)
;;           (simulate-helper grid visited [next-row next-col])))))
;; 
;; (fn simulate [grid]
;;   (let [visited {}
;;         starting-position (find-guard grid)]
;;     (simulate-helper grid visited starting-position)))
;; 
;; (local visited (simulate grid))
;; 
;; (print (fennel.view visited))
;; (print (table-length visited))
;; 
;; (assert-repl false)
