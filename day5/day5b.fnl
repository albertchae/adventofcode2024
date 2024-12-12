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

(fn take-middle-seq-table [page-map]
  (let [len (length page-map)
        midpoint (math.ceil (/ len 2))]
    (. page-map midpoint)))

(fn build-graph [page-map rules]
  (let [graph {}
        defaultmt {:__index (fn [] {})}]
    (setmetatable graph defaultmt)
    (each [page _ (pairs page-map)]
      (let [page-rules (. rules page)
            page-edges (. graph page)]
        (each [second-page _ (pairs page-rules)]
          (if (and (not= nil page-rules) (not= nil (. page-map second-page)))
              (do
                (tset page-edges second-page true)
                (tset graph page page-edges)))))) ; why didn't (tset graph page second-page true) work? oh, it sets the value on the ephemerally returned map but that needs to get explicitly saved back
    graph))

;(print (fennel.view (build-graph (. page-maps 4) rules)))
;(print (fennel.view (build-graph (. page-maps 5) rules)))
;(print (fennel.view (build-graph (. page-maps 6) rules)))

;(fn nodes-with-no-incoming-edges 
;(fn kahns-topological-sort [page-map rules])
; Actually because the input seems to only allow for graphs that can be sorted one way topologically,
; we can simplify this by just sorting by number of outgoing edges?

(fn flatten-graph [graph]
  (let [num-keys (table-length graph)
        num-nodes (+ 1 num-keys)
        flattened (icollect [_ _ (pairs graph)]
                    false)] ; build placeholder seq table of false
    (table.insert flattened false) ; add one more element because graph of edges is 1 less than number of nodes
    (each [page edges (pairs graph)]
      (let [num-outgoing-edges (table-length edges)
            index (- num-nodes num-outgoing-edges)]
        (tset flattened index (tonumber page))
        (if (= num-outgoing-edges 1)
            (each [last-page _ (pairs edges)]
              (tset flattened num-nodes (tonumber last-page))))))
    ;(print (fennel.view flattened))
    ;(print (take-middle-seq-table flattened))
    flattened))

;(print (fennel.view (flatten-graph (build-graph (. page-maps 4) rules))))
;(print (fennel.view (flatten-graph (build-graph (. page-maps 5) rules))))
;(print (fennel.view (flatten-graph (build-graph (. page-maps 6) rules))))

(local middle-of-corrected-updates
       (icollect [_ page-map (ipairs page-maps)]
         (if (valid-page-order? page-map rules)
             0
             (take-middle-seq-table (flatten-graph (build-graph page-map rules))))))

(print (accumulate [sum 0 _ v (ipairs middle-of-corrected-updates)] (+ sum v)))
