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

(fn parse-file [filename]
  (let [rules {}
        pages {}
        defaultmt {:__index (fn [] {})}
        file-iterator (io.lines filename)]
    (setmetatable rules defaultmt)
    (each [line file-iterator &until (= line "")]
      (let [(before after) (table.unpack (pl.split line "|"))
            before-rule (. rules before)]
        (tset before-rule after true)
        (tset rules before before-rule)))
    (each [line file-iterator]
      (table.insert pages line))
    (values rules pages)))

(local (rules pages) (parse-file filename))

(print (fennel.view rules))
(print (fennel.view pages))

; is there a better way to get length of k/v table??
(fn table-length [table]
  (length (icollect [_ _ (pairs table)]
            true)))

(local page-maps (icollect [_ page (ipairs pages)]
                   (tablex.index_map (pl.split page ","))))

(print (fennel.view page-maps))

; for each page
; look up the associated rule
; verify if any pages are after it
(fn valid-page-order? [page-map rules]
  (fun.all (fn [page _]
             (let [page-rules (. rules page)]
               (or (= nil page-rules)
                   (fun.all (fn [second-page _]
                              (let [second-page-index (. page-map second-page)
                                    first-page-index (. page-map page)]
                                (or (= nil (. second-page-index))
                                    (< first-page-index second-page-index))))
                            page-rules)))) page-map))

(fn take-middle [page-map]
  (let [len (table-length page-map)
        midpoint (math.ceil (/ len 2))]
    (accumulate [sum 0 k v (pairs page-map)]
      (if (= v midpoint) (+ sum k) sum))))

;(print (valid-page-order? (. page-maps 1) rules))

;(print (take-middle (. page-maps 1)))

(local middle-of-correct-updates (icollect [_ page-map (ipairs page-maps)]
  (if (valid-page-order? page-map rules)
      (take-middle page-map) 0)))

(print (fennel.view middle-of-correct-updates))

(print (accumulate [sum 0 _ v (ipairs middle-of-correct-updates)] (+ sum v)))

;(print (fennel.view (. page-maps 4)))
;(print (valid-page-order? (. page-maps 4) rules))
