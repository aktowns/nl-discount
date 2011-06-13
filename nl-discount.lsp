;; @module nl-discount
;; @index http://github.com/aktowns/nl-discount
;; @description libmarkdown(discount) wrapper for new lisp. abstracting from ffi
;; @location http://www.pell.portland.or.us/~orc/Code/discount/
;; @version 0.01
;; @author Ashley Towns <ashleyis@me.com>
;;
;; this is my first lisp script, it probably contains alot
;; of bugs / bad coding practice. Give me a shout if you see
;; anything out of place

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



(context 'nl-discount)

(setq libmarkdown "libmarkdown.dylib")

;; input functions

; MMIOT *mkd_in(FILE *f, int flags)
; reads a markdown input file and returns a MMIOT containing the preprocessed document. (which is then fed to markdown() for final formatting.)
(import libmarkdown "mkd_in")

; MMIOT *mkd_string(char *bfr, int size, int flags)
; reads the markdown input file that’s been written into bfr and returns a preprocessed blob suitable for feedin to markdown().
(import libmarkdown "mkd_string")

;; "Big Picture" - style processing functions

; int markdown(MMIOT *doc, FILE *out, int flags)
; formats a document (created with mkd_in() or mkd_string()) and writes the resulting HTML document to out.
(import libmarkdown "markdown")

; int mkd_line(char *bfr, int size, char **out, int flags)
; allocates a buffer, then formats the text string into that buffer. text string, allocates a buffer, The differences from markdown() are it doesn’t support quoting, footnotes (“reference links”,) multiple paragraphs, lists, code sections, or pure html sections.
(import libmarkdown "mkd_line")

;; Fine-grained access to the internals
; int mkd_generateline(char*bfr, int size, FILE *out, int flags)
; formats the text string and writes the resulting HTML fragment to out. It is exactly like mkd_line() except that it writes the output to a FILE*.
(import libmarkdown "mkd_generateline")

; int mkd_compile(MMIOT *doc, int flags)
; takes a document created by mkd_in() or mkd_string() and compiles it into a tree of block elements.
(import libmarkdown "mkd_compile")

; int mkd_generatehtml(MMIOT *doc, FILE *out)
; generates html from a compiled document.
(import libmarkdown "mkd_generatehtml")

; int mkd_document(MMIOT *doc, char **text)
; returns (in text) a pointer to the compiled html document, and (in the return code) the size of that document.
(import libmarkdown "mkd_document")

; int mkd_css(MMIOT *doc, char **out)
; allocates a buffer and populates it with any style blocks found in the document.
(import libmarkdown "mkd_css")

; int mkd_generatecss(MMIOT *doc, FILE *out)
; prints any style blocks in the document.
(import libmarkdown "mkd_generatecss")

; int mkd_toc(MMIOT *doc, char **out)
; allocates a buffer, populates it with a table of contents, assigns it to out, and returns the length of the buffer.
; To get a table of contents, you must compile() the document with the MKD_TOC flag (described below)
(import libmarkdown "mkd_toc")

; int mkd_generatetoc(MMIOT *doc, FILE *out)
; writes a table of contents to out; other than writing to a FILE*, it operates exactly like mkd_toc()
(import libmarkdown "mkd_generatetoc")

; int mkd_dump(MMIOT *doc, FILE *f, int flags, char *title)
; prints a block structure diagram of a compiled document.
(import libmarkdown "mkd_dump")

; void mkd_cleanup(MMIOT *doc)
; releases the MMIOT allocated for the document.
(import libmarkdown "mkd_cleanup")

;; Document header access functions

; char *mkd_doc_title(MMIOT *doc)
; returns the % title line.
(import libmarkdown "mkd_doc_title")

; char *mkd_doc_author(MMIOT *doc)
; returns the % author(s) line.
(import libmarkdown "mkd_doc_author")

; char *mkd_doc_date(MMIOT *doc)
; returns the % date line.
(import libmarkdown "mkd_doc_date")

;; URL callback functions

; void mkd_e_url(MMIOT*, char* (callback)(char*,int,void*))
; sets up a callback function that is called whenever discount processes a []() or <link> construct. The callback function is passed a pointer to the url, the size of the url, and a data pointer (null or supplied by mkd_e_data())
(import libmarkdown "mkd_e_url")

; void mkd_e_flags(MMIOT*, char *(callback)(char*,int,void*))
; sets up a callback to provide additional arguments to the tags generated by []() and <link> constructs. If, for instance, you wanted to add target="_blank" to every generated url, you could just make a callback function that returned that string.
(import libmarkdown "mkd_e_flags")

; void mkd_e_free(char *, void*)
; is called to free any allocated memory returned by the url or flags callbacks.
(import libmarkdown "mkd_e_free")

; void mkd_e_data(MMIOT*, void*)
; assigns a callback data area to the url & flags callbacks.
(import libmarkdown "mkd_e_data")

; The flags argument in markdown(), mkd_text(), mkd_in(), mkd_string(), mkd_compile(), and mkd_generatehtml() is a mask of the following flag bits:
(setq NOLINKS 				0x00000001)					; Don’t do link processing, block <a> tags
(setq NOIMAGE 				0x00000002)					; Don’t do image processing, block <img>
(setq NOPANTS 				0x00000004)					; Don’t run smartypants()
(setq NOHTML 					0x00000008)					; Don’t allow raw html through AT ALL
(setq STRICT					0x00000010)					; Disable SUPERSCRIPT, RELAXED_EMPHASIS
(setq TAGTEXT 				0x00000020)					; Process text inside an html tag; no <em>, no <bold>, no html or [] expansion
(setq NO-EXT 					0x00000040)					; Don’t allow pseudo-protocols
(setq CDATA						0x00000080)					; Generate code for xml ![CDATA[...]]
(setq NOSUPERSCRIPT		0x00000100)					; No A^B
(setq NORELAXED 			0x00000200)					; Emphasis happens everywhere
(setq NOTABLES				0x00000400)					; Don’t process PHP Markdown Extra tables.
(setq NOSTRIKETHROUGH 0x00000800)					; Forbid ~~strikethrough~~
(setq TOC 						0x00001000)					; Do table-of-contents processing
(setq ONE-COMPAT			0x00002000)					; Compatability with MarkdownTest_1.0
(setq AUTOLINK				0x00004000)					; Make http://foo.com a link even without <>s
(setq SAFELINK				0x00008000)					; Paranoid check for link protocol
(setq NOHEADER				0x00010000)					; Don’t process document headers
(setq TABSTOP					0x00020000)					; Expand tabs to 4 spaces
(setq NODIVQUOTE			0x00040000)					; Forbid >%class% blocks
(setq NOALPHALIST			0x00080000)					; Forbid alphabetic lists
(setq NODLIST					0x00100000)					; Forbid definition lists
(setq EXTRA-FOOTNOTE	0x00200000)					; Enable PHP Markdown Extra-style footnotes.

;; extra imports needed for dealing with files
(import "libc.dylib" "fopen")
(import "libc.dylib" "fclose")

;; @syntax (nl-discount:compile-markdown <input-file> <output-file> [<flags>])
;; @param <input-file> The markdown file you would like compiled to html
;; @param <output-file> The resulting file after compilation
;; @param <flags> - optional; flags for modifying the output
;; @return Returns nil
;;
;; The function 'compile-markdown' uses libc's fopen/fclose calls
;; in conjunction with mkd_in / markdown / mkd_cleanup to compile
;; a file into a html output. (abstracting away from directly dealing
;; with the C library)
;;
;; @example
;; (nl-discount:compile-markdown "test.md" "out.html" (| TOC NOSTRIKETHROUGH))
;; => nil
;;
(define (compile-markdown-file input-file output-file (flags 0))
	(letn
		((ifp (fopen input-file "r"))
		(ofp (fopen output-file "w"))
		(doc (mkd_in ifp flags)))

		(markdown doc ofp flags)
		(mkd_cleanup doc)
		(fclose ifp)
		(fclose ofp) nil))

;; @syntax (nl-discount:compile-markdown-file <input-string> <output-file> [<flags>])
;; @param <input-string> The string containing markdown you would like compiled to html
;; @param <output-file> The resulting file after compilation
;; @param <flags> - optional; flags for modifying the output
;; @return Returns nil
;;
;; The function 'compile-markdown-file' uses libc's fopen/fclose calls
;; in conjunction with mkd_string / markdown / mkd_cleanup to compile
;; a string containing markdown into a html output. (abstracting away 
;; from directly dealing with the C library)
;;
;; @example
;; (nl-discount:compile-markdown-file "*oh hai*" "out.html" (| TOC NOSTRIKETHROUGH))
;; => nil
;;
(define (compile-markdown-string input-string output-file (flags 0))
	(letn 
		((doc (mkd_string input-string (length input-string) flags))
		(ofp (fopen output-file "w")))

		(markdown doc ofp flags)
		(mkd_cleanup doc)
		(fclose ofp) nil ))

;; @syntax (nl-discount:markdown-string <input-string> [<flags>])
;; @param <input-string> The string containing markdown you would like markdown'd
;; @param <flags> - optional; flags for modifying the output
;; @return Returns nil
;;
;; The function 'markdown-string' compiles a string of markdown valid
;; syntax and returns it as a string
;;
;; @example
;; (nl-discount:markdown-string "*oh hai*" (| TOC NOSTRIKETHROUGH))
;; => "<p><em>Oh hai</em></p>"
;;
(define (markdown-string input-string (flags 0))
	(setq markdown-ptr-output (dup "\000" (length input-string)))
	(letn 
		((doc (mkd_string input-string (length input-string) flags)))
		
		(mkd_compile doc flags)
		(mkd_document doc markdown-ptr-output)
		(mkd_cleanup doc) 
		(get-string (utils:address-address markdown-ptr-output))))

; (exit)