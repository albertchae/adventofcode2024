(local inspect (require :inspect))

(local utils (require :pl.utils))

(local fun (require :fun))
(local fennel (require :fennel))

(local filename (. arg 1))

(fn parse-file [filename]
  (let [list1 {}
        list2 {}]
    (print (.. "Reading file: " filename))
    (each [line (io.lines filename)]
      (let [[list1-str list2-str] (utils.split line "[ ]+")
            list1-num (tonumber list1-str)
            list2-num (tonumber list2-str)]
        (do
          (table.insert list1 list1-num)
          (table.insert list2 list2-num))))
    [list1 list2]))

(local [list1 freq-list] (parse-file filename))

(fn tally [lst]
  (accumulate [tbl {} _ n (ipairs lst)]
    (do
      (tset tbl n (+ (or (. tbl n) 0) 1))
      tbl)))

(print (inspect list1))
(local freq-table (tally freq-list))
(print (inspect freq-table))

(fn compute-similarity-score [lst freq-table]
  (icollect [index val (ipairs lst)]
    (* val (or (. freq-table val) 0))))

(local similarity-score-list (compute-similarity-score list1 freq-table))

(print (inspect similarity-score-list))

(fn sum-list [list1]
  (accumulate [sum 0 _ n (ipairs list1)]
    (+ sum n)))

(print (inspect (sum-list similarity-score-list)))
