;;; toc-org-internal-link.el --- add internal link to toc-org

;; Copyright (C) 2015 Yufan Lou

;; Author: Yufan Lou <loganlyf [at] gmail.com>
;; Version: 1.0
;; Keywords: org-mode org-toc toc-org org toc table of contents link
;; URL: https://github.com/louy2/toc-org

;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License as
;; published by the Free Software Foundation; either version 2, or (at
;; your option) any later version.

;; This program is distributed in the hope that it will be useful, but
;; WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;; General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to the
;; Free Software Foundation, Inc., 59 Temple Place - Suite 330,
;; Boston, MA 02111-1307, USA.

;;; Commentary:

;; toc-org-internal-link makes links of toc-org go to headings in
;; Emacs as well. Using :CUSTOM_ID: property which org-mode supports.

;; For details, see https://github.com/louy2/toc-org

;;; Code:

(require 'org)
(require 'toc-org)

(defcustom toc-org-enable-custom-id nil
  "Enable internal link with :CUSTOM_ID: property. Only works with
gh style href."
  :group 'toc-org)

(defconst toc-org-toc-tag-regexp
  "-{toc\\([@_][0-9]\\|\\([@_][0-9][@_][a-zA-Z]+\\)\\)?}")

(defun toc-org--set-custom-id ()
  "Set :CUSTOM_ID: property of current entry to current heading
hrefified."
  (org-set-property "CUSTOM_ID"
                    ;; strip leading # from hrefify
                    (substring-no-properties
                     (toc-org-hrefify-gh (org-get-heading t))
                     1 nil)))

(defun toc-org-set-custom-id-all ()
  "Set :CUSTOM_ID: property of each entry to its heading hrefified."
  (interactive)
  (if (equal toc-org-hrefify-default "gh")
      (org-map-entries '(toc-org--set-custom-id)
                       toc-org-toc-tag-regexp))) ;; skip toc itself

(defun toc-org--get-property-block ()
  "Get the property block (from beginning of :PROPERTIES: to end of
 :END:) of the current heading."
  (let* ((prop (org-get-property-block))
         (beg (car-safe prop))  ; 1st line of prop
         (end (cdr-safe prop))) ; beg of :END:
    (unless (null prop)         ; nil if no property
      (let ((prop-beg           ; beg of :PROPERTIES:
             (save-excursion
               (set-window-point nil beg)
               (forward-line -1) (point)))
            (prop-end           ; end of :END:
             (save-excursion
               (set-window-point nil end)
               (end-of-line) (point))))
        (cons prop-beg prop-end)))))

(defun toc-org-hide-properties ()
  "Hide properties under the current heading."
  (interactive)
  (let* ((prop (toc-org--get-property-block))
         (beg (car-safe prop))
         (end (cdr-safe prop)))
    (unless (null prop)
      (outline-flag-region beg end t))))

(defun toc-org-hide-all-properties ()
  (interactive)
  (org-map-entries '(toc-org-hide-properties)))

(provide 'toc-org-internal-link)
;;; toc-org-internal-link.el ends here
