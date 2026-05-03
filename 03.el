;; -*- lexical-binding: t; -*-
;; `search-forward' is the most basic building block of buffer manipulation
;; on Emacs.
;;
;; We can easily pair it with `if' statements to get more control over the
;; execution flow of our Elisp scripts. The general structure is this:
;;
;; (if condition
;;    (do-this-if-true)
;;  (do-this-if-false))
;;
;; 11. Using the given built-in functions and syntax:
;; `goto-char', `point-min', `search-forward', `if', `message', `point'
;;
;; Write an interactive command named `find-todo` that:
;; 1. Moves the point to the beginning of the buffer.
;; 2. Uses an `if` statement where the condition is a search for the exact
;;    string "TODO". (Remember to pass `nil` and `t` for the BOUNDARY and
;;    NOERROR arguments).
;; 3. If found, prints "TODO found at position: %s" using `(point)`.
;; 4. If not found, prints "No TODOs here."
(defun find-todo ()
  "Search for TODOs in the entire buffer."
  (interactive)
  (goto-char (point-min))
  (if (search-forward "TODO" nil t)
      (message "TODO found at position: %s" (point))
    (message "No TODOs here.")))

;; Now, let's make this function more useful by using a `while' statement to
;; search and return all the TODOs found in a given buffer.
;;
;; (while (search-forward "TODO" nil t)
;;  (do-something-at-point))
;;
;; Also, let's not limit our function to find only "TODO" on our file. We can
;; use `re-search-forward' to do the same but now with support for regular
;; expressions (RegEx).
;;
;; NOTE: Because regex uses backslashes for special characters (like \| for "OR"),
;; and Lisp strings also use backslashes for escape characters, you have to
;; "double escape" regex operators in Elisp strings.
;;
;; Standard regex for TODO or FIXME: TODO\|FIXME
;; Elisp string regex: "TODO\\|FIXME"
;;
;; 12. Using the given built-in functions/macros:
;; `let', `goto-char', `point-min', `while', `re-search-forward', `setq', `1+', `message'
;;
;; Write an interactive command named `count-tasks' that:
;; 1. Uses `let' to initialize a local variable named `count' to 0.
;; 2. Moves the point to the beginning of the buffer.
;; 3. Uses a `while' loop with `(re-search-forward "TODO\\|FIXME" nil t)' as the condition.
;; 4. Inside the loop, updates the `count' using `setq' and `1+'.
;; 5. After the loop finishes (outside the while block), uses `message' to print "Found %s tasks."
(defun count-tasks ()
  "Count and return how many TODO and FIXME where found in the current buffer."
  (interactive)
  (let ((count 0))
    (goto-char (point-min))
    (while (re-search-forward "TODO\\|FIXME" nil t)
      (setq count (1+ count)))
    (message "Found %s tasks." count)))

;; In Emacs Lisp, when a search function (like `re-search-forward')
;; successfully finds a match, Emacs temporarily remembers the exact location
;; and boundaries of that specific match. We can exploit this memory using the
;; built-in replace-match function.
;;
;; If you call `(replace-match "NEW-STRING")' immediately after a successful
;; search, it will swap out the matched text with your new string.
;;
;; 13. Using the given built-in functions:
;; `goto-char', `point-min', `while', `re-search-forward', `replace-match'
;;
;; Write an interactive command named `format-as-checklist' that:
;; 1. Moves the point to the beginning of the buffer.
;; 2. Uses a `while' loop to find all instances of "TODO\\|FIXME".
;; 3. Inside the loop, replaces the found text with the string "- [ ]".
(defun format-as-checklist ()
  "Change all TODO and FIXME occurrences to appropriate Markdown '- [ ]' task."
  (interactive)
  (goto-char (point-min))
  (while (re-search-forward "TODO\\|FIXME" nil t)
    (replace-match "- [ ]")))
;; NOTE: We can wrap our our code in a `save-excursion' macro that remembers our
;; cursor position seamlessly teleporting us back to where we started when the
;; destructive actions on our buffer ended.

;; In Elisp, you create a capture group by wrapping a regex pattern in
;; double-escaped parentheses: "\\( ... \\)". For example, "Context: \\(.*\\)"
;; will look for the word "Context: " and capture everything after it on that
;; same line.
;;
;; After a successful `re-search-forward', you can retrieve that captured text
;; using the `(match-string 1)' function, where 1 represents the first set of
;; parentheses.
;;
;; 14. Using the given built-in functions and macros:
;; `save-excursion', `goto-char', `point-min', `re-search-forward', `if', `match-string', `message'
;;
;; Write an interactive command named `extract-context' that:
;; 1. Uses `save-excursion' to ensure the user's cursor doesn't permanently move.
;; 2. Moves point to the beginning of the buffer.
;; 3. Uses an `if' statement to search for the regex pattern "Context: \\(.*\\)"
;;    (remember the nil and t arguments for boundaries and errors).
;; 4. If found, uses `match-string' to extract the first group and prints it using `message'.
(defun extract-context ()
  "Extracts context from a LLM buffer and prints to the echo area."
  (interactive)
  (save-excursion
    (goto-char (point-min))
    (if (re-search-forward "Context: \\(.*\\)" nil t)
        (message "%s" (match-string 1)))))
