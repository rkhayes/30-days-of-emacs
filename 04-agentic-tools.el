;; -*- lexical-binding: t; -*-
(defun format-as-checklist ()
  "Change all TODO and FIXME occurrences to appropriate Markdown '- [ ]' task."
  (interactive)
  (goto-char (point-min))
  (while (re-search-forward "TODO\\|FIXME" nil t)
    (replace-match "- [ ]")))

(defun extract-context ()
  "Extracts context from a LLM buffer and prints to the echo area."
  (interactive)
  (save-excursion
    (goto-char (point-min))
    (if (re-search-forward "Context: \\(.*\\)" nil t)
        (message "%s" (match-string 1)))))

;; In Elisp, a keymap is created using `make-sparse-keymap'. We then bind keys
;; to it using `define-key' and the `kbd' macro (which translates human-readable
;; keys like "C-c c" into Emacs's internal key codes).
;;
;; NOTE: By convention, the keymap variable for a mode should be named
;;       [mode-name]-map.
;;
;; NOTE: In standard Emacs, shortcuts starting with C-c followed by a single
;;       letter are strictly reserved for user-defined bindings, meaning no
;;       built-in package will ever overwrite them.
;;
;; Emacs provides a massive, powerful macro called define-minor-mode that
;; handles all the heavy lifting of creating variables, toggles, and status
;; bar updates.
;;
;; 18. Using the given functions and macros:
;; `defvar', `make-sparse-keymap', `define-key', `kbd', `define-minor-mode'
;;
;; Part A: Create the Keymap
;; 1. Define a variable named `agentic-tools-mode-map'.
;; 2. Use a `let' block to create a `make-sparse-keymap'.
;; 3. Bind the key "C-c c" to your `format-as-checklist' function.
;; 4. Bind the key "C-c e" to your `extract-context' function.
;; 5. Return the map at the end of the `let' block.
;;
;; Part B: Create the Minor Mode
;; 1. Use `define-minor-mode' to create `agentic-tools-mode'.
;; 2. Provide a docstring describing the mode.
;; 3. Set the `:init-value' to nil.
;; 4. Set the `:lighter' to " Agentic" (note the leading space for UI padding).
;; 5. Set the `:keymap' to your `agentic-tools-mode-map'.
(defvar agentic-tools-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "C-c c") 'format-as-checklist)
    (define-key map (kbd "C-c e") 'extract-context)
    map)
  "Keybindings for `agentic-tools-mode'")

(define-minor-mode agentic-tools-mode
  "Define functions and keymaps related to AI agentic workflows."
  :init-value nil
  :lighter " Agentic"
  :keymap agentic-tools-mode-map)

;; Now we can activate our minor mode with M-x `agentic-tools-mode-map'.
;;
;; We can also use `agentic-tools-mode-hook' to perform some actions everytime
;; our minor mode is activated in a buffer.
