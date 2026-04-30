;; S-expressions are lists enclosed in parenthesis with the structure:
;; (function arg1 arg2)
;;
;; These structures can be evaluated to mutate the state of Emacs.
;;
;; `setq' is used to define the values of variables.
;;
;; Boolean values are represented by `t' (true) and `nil' (false).
;;
;; For example, to change how line numbers are displayed, you might write:
(setq display-line-numbers-type 'relative)

;; The (') is used to indicate that `relative' must be interpreted literally
;; as a text intead of a symbol that can mean something else syntatically. We're
;; literally capturing the string as a value.
;;
;; We can trigger the `eval-last-sexp' with the C-x C-e keybinding to evaluate
;; the last S-expression with our pointer at the closing parenthesis of the
;; expression.

;; A standard Emacs functions has this general structure:
(defun hello ()
  "Print a greeting to the echo area."
  (interactive)
  (message "Hello, Emacs!"))

;; `interactive' turns a hidden background function into a command that you can
;; trigger via the M-x interface or bind to a keystroke.
;; `message' is a built-in function that logs the output to the `*Messages' buffer
;; and displays it in the minibuffer.

;;; EXERCISES
;; You can consult the documentation of the function at point with `K' in
;; Doom Emacs or by searching for them in `apropos' using C-h a on default Emacs.
;;
;; In Emacs, the cursor is called the "point". Text is always inserted at the
;; current point, and we can move the point programmatically before inserting.
;;
;; 1. Using the given built-in functions:
;; `point-min', `point-max', `count-words'
;; Write a command that count words in the current buffer and print to the minibuffer.
(defun buffer-word-count ()
  "Counts total words in current buffer and prints to the echo area."
  (interactive)
  (message "%s" (count-words (point-min) (point-max))))

;; 2. Using te given built-in function:
;; `buffer-substring-no-properties'
;; Write a command that prints the text of the entire current buffer and prints
;; to the echo area.
(defun print-buffer-text ()
  "Prints the entire content of the current buffer to the echo area."
  (interactive)
  (message "%s" (buffer-substring-no-properties (point-min) (point-max))))

;; 3. Using the given built-in functions:
;; `insert', `goto-char'
;; You're writing a package for Emacs integration with LLMs and want to put all responses
;; at the end of the current buffer. How would you write a command that inserts the string
;; "\n\n[LLM response goes here]" in the end of the current buffer?
(defun append-llm-placeholder ()
  "Appends a placeholder LLM response at the end of the current buffer."
  (interactive)
  (goto-char (point-max))
  (insert "\n\nLLM response goes here."))

;; Lisp uses the `let' macro to create temporary local variables.
(let ((variable-name 'value)
      (another-variable 'another-value))
  (message "My variable contains: %s" variable-name)
  (message "My other variable contains: %s" another-variable))

;; 4. Using the given built-in macro:
;; `let'
;; To prepare our buffer data for an API payload, we need to extract it and bind it locally.
;; Write a command named `extract-and-store` that extracts the entire buffer's text,
;; assigns it to a local variable named `my-text`, and then prints `my-text` to the echo area.
(defun extract-and-store ()
  "Extracts the entire buffer content and stores in a local variable, then
prints to the echo area."
  (interactive)
  (let ((my-text (buffer-substring-no-properties (point-min) (point-max))))
    (message "%s" my-text)))

;; In a real life scenario, we need to bridge the gap between the extracted text
;; and the external API, we need to format the data as a JSON payload. JSON
;; consists basically of key-value pairs and can be effectively represented in
;; ELisp by using association lists (alists) -- list of pairs -- which are then
;; converted into strings using the built-in `json-encode' function.
;;
;; In this context we can use Lisp quasiquotation to manage this structures
;; elegantly.
;; - Standard quote (') prevents a list from being evaluated entirely;
;; - Backquotes (`) allows you to selectively evaluate specific elements inside a
;;   list by prefixing them with a comma (,).
(let ((my-var "Hello"))
  `((role . "user") (content . ,my-var)))
;; Evaluates to: ((role . "user") (content . "Hello"))

;; A standard let evaluates all its variables in parallel. If you want to define
;; a variable that depends on another variable within the same block, you must
;; use let*, which binds them sequentially.

;; 5. Using the given built-in functions and syntax:
;; `let*', `json-encode', backquote (`), comma (,)
;; (Assume `(require 'json)` is active in the background).
;; Write a command named `generate-llm-payload' that:
;; 1. Uses `let*' to sequentially bind two local variables.
;; 2. Binds `buf-text' to the extracted text of the current buffer.
;; 3. Binds `payload' to an Alist structured as: ((model . "gpt-4") (prompt . ,buf-text))
;; 4. Prints the JSON-encoded `payload' to the echo area.
(defun generate-llm-payload ()
  "Generate and print JSON-encoded payload alist with current buffer content for LLM."
  (interactive)
  (let* ((buf-text (buffer-substring-no-properties (point-min) (point-max)))
         (payload `((model . "gpt-4") (prompt . ,buf-text))))
    (message "%s" (json-encode payload))))

;; To send this payload, we must configure Emacs's built-in HTTP client, the `url'
;; library.
;;
;; `url' relies on setting global variables like `url-request-method' and
;; `url-request-data'.
;;
;; Using `setq' here is dangerous because it permanently alters the state for any other
;; package that might need to make a standard GET request later.
;;
;; Happily Emacs Lisp dynamic scoping feature is powerful and let us use the same `let'
;; macro we learned about before to temporarily shadow global variables. Once the block
;; finishes executing, the global variables instantly revert to their previous state.
;;
;; NOTE: plz.el offer a more modern and robust API for network requests -- and is highly
;; recommended for production tooling

;; 6. Using the given built-in macro:
;; `let'
;; The `url' library requires configuring global variables for HTTP requests.
;; Write a command named `test-url-binding' that uses `let' to temporarily bind
;; the global variable `url-request-method' to the string "POST", and prints
;; the value of `url-request-method' to the echo area to verify the binding.
(defun test-url-binding ()
  "Set global variable `url-request-method' to 'POST' and prints it's value to
the echo area."
  (interactive)
  (let ((url-request-method "POST"))
    (message "%s" url-request-method)))

;; 7. Using the given built-in functions:
;; `url-retrieve-synchronously', `switch-to-buffer'
;; We will make a real HTTP request to a testing endpoint.
;; Write a command named `test-network-post' that:
;; 1. Uses `let' to bind:
;;    - `url-request-method' to "POST"
;;    - `url-request-extra-headers' to '(("Content-Type" . "application/json"))
;;    - `url-request-data' to "{\"test\":\"success\"}"
;; 2. Executes `url-retrieve-synchronously' targeting "https://httpbin.org/post"
;; 3. Passes the result of that network call directly into `switch-to-buffer'
;; so you can view the response.
(defun test-network-post ()
  "Make HTTP request to testing endpoint and returns response in a new buffer."
  (interactive)
  (let ((url-request-method "POST")
        (url-request-extra-headers '(("Content-Type" . "application/json")))
        (url-request-data "{\"test\":\"success\"}"))
    (switch-to-buffer (url-retrieve-synchronously "https://httpbin.org/post"))))

;; while raw string works perfectly for English/ASCII text, Emacs requires
;; explicit encoding for network transmission if your payload contains special
;; characters or accents. To prevent network errors when sending texts in other
;; languages, you would wrap your payload like this:
(encode-coding-string "{\"test\":\"sucesso\"}" 'utf-8)
