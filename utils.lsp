(context 'utils)
;; @syntax (utils:address-address <pointer> [<big-endian>])
;; @param <pointer> The pointer you would like the pointer address of
;; @param <big-endian> - optional; for big-endian mode (don't reverse arrays)
;; @return Returns the pointer's pointer address
;;
;; The function 'address-address' retrieves the value of the pointers
;; pointer address, for usage in ffi..
;;
;; Is there an easier way to accomplish this?
;; getting the address of the pointer for pass by value
;; params (char ** etc)?
;;
;; @example
;; (set 'a-ptr (dup "\000" 30))
;; (c-method-that-changes pointers-location a-ptr)
;; (get-string (address-address a-ptr))
;; => content!
;;
(define (address-address ptr-find (big-endian nil))
	(letn
		((endian (if big-endian (lambda (x) x) reverse))
			(left (endian (unpack "bbbb" (+ (address ptr-find) 4)))) ; little endian
			(right (endian (unpack "bbbb" (address ptr-find))))
			(addr (join (map (fn (z) (format "%02x" z)) (flat (list left right))))))

		(eval-string (join (list "0x" addr)))))