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

(local [list1 list2] (parse-file filename))

; in place sort
(table.sort list1)
(table.sort list2)

(print (inspect list1))
(print (inspect list2))

(fn compute-difference-list [list1 list2]
  (icollect [index _ (ipairs list1)]
    (math.abs (- (. list1 index) (. list2 index)))))

(fn sum-list [list1]
  (accumulate [sum 0 _ n (ipairs list1)]
    (+ sum n)))

(print (inspect (sum-list (compute-difference-list list1 list2))))
