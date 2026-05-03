;; -*- lexical-binding: t; -*-
;; 15. Using the given built-in functions:
;; `let', `point', `insert', `put-text-property', `get-text-property', `message'
;;
;; Write an interactive command named `test-text-memory' that:
;; 1. Uses `let' to bind a variable named `start-pos' to your current `point'.
;; 2. Uses `insert' to add the string "I am an AI response." to the buffer.
;; 3. Uses `put-text-property' to tag the text you just inserted.
;;    - Use `start-pos' and `point' for the boundaries.
;;    - Use `'speaker' as the property name and "LLM" as the value.
;; 4. Uses `get-text-property' at `start-pos' to retrieve the value and prints
;;    it to the echo area.
(defun test-text-memory ()
  "Inserts placeholder text, add then read it's text property."
  (interactive)
  (let ((start-pos (point)))
    (insert "I am an AI response.")
    (put-text-property start-pos (point) 'speaker "LLM")
    (message "%s" (get-text-property start-pos 'speaker))))

;; This exact mechanism is the beating heart of `gptel''s memory. When you send a
;; prompt, `gptel' doesn't just read the whole file; it needs to chunk the plain
;; text into a structured JSON payload that looks like this:
;;
;; [
;;   {"role": "user", "content": "Hello!"},
;;   {"role": "assistant", "content": "I am an AI response."},
;;   {"role": "user", "content": "What is my next task?"}
;; ]

;; 16. Using the given built-in functions:
;; `let', `point', `next-single-property-change', `if', `goto-char', `message'
;;
;; Write an interactive command named `jump-to-next-turn' that:
;; 1. Uses `let' to bind a local variable named `boundary' to the result of
;;    `(next-single-property-change (point) 'speaker)'.
;; 2. Uses an `if' statement to check if `boundary' successfully found a
;;    position (is not nil).
;; 3. If true, uses `goto-char' to move the point to `boundary' and prints
;;    "Moved to boundary at: %s"
;; 4. If false, prints "No property boundaries found."
(defun jump-to-next-turn ()
  "Jumps to the next change of text property."
  (interactive)
  (let ((boundary (next-single-property-change (point) 'speaker)))
    (if boundary
        (progn
          (goto-char boundary)
          (message "Moved to boundary at: %s" boundary))
      (message "No property boundaries found"))))
;; NOTE: Since Lisp expects exactly one expression for TRUE and one expression
;; for FALSE in this `if' statement we should use the `progn' macro.
;;
;; `progn' (program sequentially) groups multiple expressions into a single
;; valid block. It evaluates them in order and returns the value of the final
;; expression.
;;
;; Why not just add another set of parenthesis around these expressions?
;; Well, suppose that you have a branch that looks like this:
;;
;; ((goto-char boundary) (message "Moved to boundary: %s" boundary))
;;
;; Let's see what will happen with our evaluation order in this case:
;; 1. Emacs evaluates the first element: (goto-char boundary). This moves your
;; cursor and returns a number.
;; 2. Then it evaluates the second element successfully printing the message.
;; 3. Then it attempts to take the of step 1 (a number) and execute it as a
;; function, passing the result of the step 2 as an argument.
;;
;; If you're running any checker on your buffer, you will probably receive a
;; "Malformed function".

;; Now, looking out for how `gptel' is structured, it does not use any Emacs
;; mechanism to work with the text streams that comes from LLM APIs, instead it
;; spawns a silent background `curl' process and attach a process filter to it.
;;
;; A process filter is a simple Elisp function that Emacs automatically
;; triggers every single time a new packet of text arrives from standard output.
;;
;; ;; 17. Using the given built-in functions and macros:
;; `get-buffer-create', `with-current-buffer', `save-excursion', `goto-char', `point-max', `insert'
;;
;; Write a non-interactive function named `mock-stream-filter' that:
;; 1. Accepts two arguments: `process' and `chunk-string'.
;; 2. Uses `with-current-buffer' targeting `(get-buffer-create "*Stream-Test*")'.
;;    (This creates the buffer if it doesn't exist, or just switches to it if it does).
;; 3. Inside that buffer context, uses `save-excursion' to protect the user's cursor.
;; 4. Inside the excursion, moves to the end of the buffer using `(goto-char (point-max))'.
;; 5. Uses `insert' to append the `chunk-string'.
(defun mock-stream-filter (process chunk-string)
  "Use or create a *Stream-Test* buffer and appends string chunks from process to it."
  (with-current-buffer (get-buffer-create "*Stream-Test*")
    (save-excursion
      (goto-char (point-max))
      (insert chunk-string))))
;; NOTE: `save-excursion' is strictly literal. If you are at position 500, it
;; saves the number 500. It moves to the end, inserts 20 characters, and then
;; forces your cursor back to 500. The new text is inserted below your cursor,
;; meaning the screen never scrolls down to follow the new text.
;;
;; To solve this, Emacs provides a specialized variant of insert called
;; `insert-before-markers'. When you use this, Emacs knows to push your cursor
;; forward with the new text if you were already sitting at the end of the
;; buffer, allowing for that smooth, real-time scrolling effect.
