(local inspect (require :inspect))

(local utils (require :pl.utils))

(local fun (require :fun))
(local fennel (require :fennel))

(local filename (. arg 1))

(fn table-length [table]
  (length (icollect [_ _ (pairs table)]
            true)))

(fn parse-file [filename]
  (let [input {}]
    (print (.. "Reading file: " filename))
    (each [line (io.lines filename)]
      (let [[result-string & term-strings] (utils.split line "[: ]+")
            result (tonumber result-string)
            terms (icollect [_ v (ipairs term-strings)] (tonumber v))]
        (set (. input result) terms)))
    input))

(local operators [#(* $1 $2) #(+ $1 $2)])

;; maybe use dynamic programming instead?

(fn valid-result-helper? [target terms result-so-far]
  ;; (print (fennel.view [target terms result-so-far]))
  (case terms
    [a & rest] (accumulate [valid? false _ operator-fn (ipairs operators)]
                 (or (valid-result-helper? target rest
                                           (operator-fn result-so-far a))
                     valid?))
    _ (= target result-so-far)))

(fn valid-result? [target terms]
  (let [[first & rest] terms]
    (valid-result-helper? target rest first)))

(print (valid-result? 190 [10 19]))
(print (valid-result? 3267 [81 40 27]))

(fn find-valid-equations [result-terms-map]
  (accumulate [valid-results [] result terms (pairs result-terms-map)]
    (do
      (print (fennel.view [result terms]))
      (when (valid-result? result terms)
        (table.insert valid-results result))
      valid-results)))

(local valid-results (find-valid-equations (parse-file filename)))

(print (accumulate [sum 0 _ v (ipairs valid-results)]
         (+ sum v)))

;; (assert-repl false)
