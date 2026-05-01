;; -*- lexical-binding: t; -*-
;; 8. Using the given built-in function:
;; `message', `url-retrieve'
;;
;; Part A: Write a non-interactive function named `my-async-callback` that takes
;; one argument (`status`) and uses `message` to print "Async response received!"
;; to the echo area.
;;
;; Part B: Write an interactive command named `test-network-async` that calls
;; `url-retrieve` targeting "https://httpbin.org/get" and passes your callback
;; symbol.
(defun my-async-callback (status)
  "Return a message to the echo area indicating a response has been received."
  (message "Async response received!"))
;; NOTE: The argument responsible for capturing the endpoint response in a
;; callback function is traditionally called `status'.

(defun test-network-async ()
  "Retrive data asynchronously from a test endpoint and trigger test callback."
  (interactive)
  (url-retrieve "https://httpbin.org/get" 'my-async-callback-2))
;; When using `url-retrieve' instead of waiting for a return value, Emacs
;; fires off the HTTP request and immediately returns control to you. When the
;; response eventually arrives, Emacs triggers a callback function that you
;; provided.
;;
;; When Emacs triggers your callback, it automatically executes it inside the
;; newly created buffer containing the HTTP response.
;;
;; Also, when passing a callback function as argument for `url-retrieve', we use
;; the (') symbol so Lisp knows we're referencing the function's name and not
;; trying to evaluate it immediately.

;; The raw HTTP response contains protocol headers at the top, which we need to
;; bypass to get the clean JSON body. Emacs conveniently sets a local variable
;; in this buffer named `url-http-end-of-headers', which holds the exact numeric
;; position where the headers stop and the data begins.

;; 9. Using the given built-in functions and variables:
;; `let', `buffer-substring-no-properties', `url-http-end-of-headers', `point-max'
;;
;; Rewrite `my-async-callback' so that it:
;; 1. Accepts the `status' argument as before.
;; 2. Uses `let' to bind a local variable named `response-body'.
;; 3. Binds that variable to the text extracted from `url-http-end-of-headers' to the end of the buffer.
;; 4. Prints `response-body' to the echo area using `message'.
(defun my-async-callback-2 (status)
  "Return the entire response to the echo area with HTTP headers stripped out."
  (let ((response-body (buffer-substring-no-properties url-http-end-of-headers (point-max))))
    (message "%s" response-body)))
;; NOTE: Nesting (goto-char url-http-end-of-headers) technically works because
;; `goto-char' returns the new position as a number. However, since
;; `url-http-end-of-headers' is already a numeric variable holding that exact
;; position, you can bypass the cursor movement and pass it directly

;; If we use our old friend (insert response-body) inside the callback right now,
;; it will dump the text into that hidden network buffer, not your writing document!
;;
;; To solve this, we need to:
;; 1. Capture your original buffer before making the request using `current-buffer'.
;; 2. Switch back to it inside the callback using the `with-current-buffer' macro:
;;    (with-current-buffer my-saved-buffer (insert "text")).
;;
;; But how does a separate callback function has access to a variable from your
;; main command?
;;
;; Instead of defining a separate `defun' and passing its quoted name, modern
;; Elisp uses anonymous functions (lambdas). If you write a lambda directly
;; inside your `let' it has access to all the local variables around it this is
;; called lexical scoping.

;; 10. Using the given built-in functions and macros:
;; `current-buffer', `with-current-buffer', `lambda', `insert'
;;
;; Write an interactive command named `test-async-insert' that:
;; 1. Uses `let' to bind a variable named `orig-buffer' to the result of `current-buffer'.
;; 2. Calls `url-retrieve' targeting "https://httpbin.org/get".
;; 3. For the callback argument, passes an inline `lambda' that accepts `status'.
;; 4. Inside the lambda, extracts the response body.
;; 5. Uses `with-current-buffer' targeting `orig-buffer' to `insert' the extracted text.
(defun test-async-insert ()
  (interactive)
  (let ((orig-buffer (current-buffer)))
    (url-retrieve "https://httpbin.org/get"
                  (lambda (status)
                    (let ((response-body (buffer-substring-no-properties url-http-end-of-headers (point-max))))
                      (with-current-buffer orig-buffer (insert response-body)))))))
;; NOTE: If you evaluate this expression in a common file you will probably
;; receive this error on `*Messages':
;;
;; Contacting host: httpbin.org:443
;; error in process filter: save-current-buffer: Symbol’s value as variable is void: orig-buffer
;; error in process filter: Symbol’s value as variable is void: orig-buffer
;;
;; By default, Emacs uses dynamic scoping. This means a variable created with
;; `let' only exists while that specific let block is actively running.
;;
;; Because url-retrieve is asynchronous, here is what happens:
;; 1. Your `let' block creates `orig-buffer', fires off the request, and
;; finishes immediately. Emacs instantly destroys the `orig-buffer' variable.
;; 2. The server replies, and Emacs runs your lambda. The lambda looks around
;; for `orig-buffer' so it can switch back to it, but the variable is already
;; gone. Hence, the "void variable" error.
;;
;; To make your lambda truly "remember" the variables around it -- a concept
;; known as creating a closure -- we must tell Emacs to use lexical scoping for
;; your file instead of the dynamic default.
;;
;; To fix this, add ";; -*- lexical-binding: t; -*-" as the first line of your
;; file and trigger M-x `eval-buffer' then run `test-async-insert' again.
