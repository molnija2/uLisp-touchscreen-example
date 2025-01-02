
(progn

#|  Objecs management library
  These functions for simple object system are sugguested by
  David Johnson-Davies (http://www.ulisp.com/show?37VY)
|#

  (defun object (&optional parent slots)
    (let ((obj (when parent (list (cons 'parent parent)))))
      (loop
        (when (null slots) (return obj))
        (push (cons (first slots) (second slots)) obj)
        (setq slots (cddr slots)))))
  (defun value (obj slot)
    (when (symbolp obj) (setq obj (eval obj)))
    (let ((pair (assoc slot obj)))
      (if pair
        (cdr pair)
        (let ((p (cdr (assoc 'parent obj)))) (and p (value p slot))))))
  (defun update (obj slot value)
    (when (symbolp obj) (setq obj (eval obj)))
    (let ((pair (assoc slot obj))) (when pair (setf (cdr pair) value))))

#|  keyboard keys definitions  |#
(defun key-forUp (key)    (if (or (eq key 16) (eq key 16) (eq key 19)) t nil))
(defun key-forDown (key)  (if (or (eq key 14) (eq key 14) (eq key 21)) t nil))
(defun key-forLeft (key)  (if (or (eq key 2) (eq key 2) (eq key 18)) t nil))
(defun key-forRight (key) (if (or (eq key 6) (eq key 6) (eq key 20)) t nil))
(defun key-forPgUp  (key) (if (or (eq key 23) (eq key 23) (eq key 122)) t nil))
(defun key-forPgDn  (key) (if (or (eq key 22) (eq key 22) (eq key 123)) t nil))
(defun key-forHelp  (key) (if (or (eq key 104) (eq key 72) (eq key 48)) t nil))
(defun key-forPrEd  (key) (if (or (eq key 108) (eq key 76) (eq key 51)) t nil))
(defun key-forQuit  (key) (if (or (eq key #\Q) (eq key #\q) (eq key 17) (eq key 57)) t nil))

#|  Several functions for graphics  |#
    (defun getmaxx () 320)
    (defun getmaxy () 240)
    (defun getfontheight () 8)
    (defun getfontwidth  () 6)
    (defun gettextwidth (str) (let ((len (length str))) (* len (getfontwidth))))
    (defun draw-string (s)
      (if (stringp s) ( with-gfx (str) (write-string s str)) ) )
    (defun read-key ()  (read-byte) )

#| Define class dialog-item  |#
    (defvar dialog-item (object
      nil
      '(enable
         'true
         color
         (rgb 0 0 0)
         colorbk
         (rgb 220 220 220)
         colordisable
         (rgb 180 180 180))))

#| Define class dialog-form |#
    (defvar dialog-form (object
      nil
      '(enable
         'true
         color
         (rgb 0 0 0)
         colorbk
         (rgb 220 220 220)
         colordisable
         (rgb 180 180 180)
         colorfr
         (rgb 150 150 150)
         headbkcolor
         (rgb 255 0 0)
         headtxtcolor
         (rgb 255 255 255))))

#| Define class push-button-class|#
    (defvar push-button-class (object
     dialog-item
     '(enable
       'true
       color
       (rgb 0 0 0)
       colorbk
       (rgb 220 220 220)
       colordisable
       (rgb 180 180 180)
       type
       'push-button
       triggered
       'false
       painter 'draw-push-button
       function
       '(print "push-button")
    )))

#| Define class label-class|#
    (defvar label-class (object
      dialog-item
     '(enable  'true
     width 0
     height (+ (getfontheight) 0)
     color
     (rgb 0 0 0)
     colorbk
     (rgb 220 220 220)
     colordisable
     (rgb 180 180 180)
     type
     'label
     triggered
     'false
     painter 'draw-label
     function
     '(print "label")
  )))
  

#| Define example buttons|#
  (defvar button-OK (object
      'push-button-class
      '(text
         "  OK  "
         function
         #'(progn (print "OK") 1))))
  (defvar button-ESC (object
      'push-button-class
      '(text
         "Cancel"
         function
         #'(progn (print "Cancel") -1))))

#| Define objects width and height automatic detection |#
   (defun get-dlgitem-width (item)
    (let ((item-w (eval (value item 'width)))
        (text-w (* (getfontwidth) (+ 1 (length (eval (value item 'text))))))
        (bitmap (eval (value item 'icon)))
        (bitmap-w 0))
      (if (not (eq bitmap nil)) (setq bitmap-w (+ 2 (bitmap-width bitmap))))
      (if (not (eq item-w nil)) (if (< text-w item-w) (setq text-w item-w)))
      text-w))
  (defun get-dlgitem-height (item)
    (let ((item-h (eval (value item 'height)))
        (text-h (+ 2 (truncate (/ (* (getfontheight) 6) 4))))
        (bitmap (eval (value item 'icon)))
        (bitmap-h 0))
      (if (not (eq bitmap nil)) (setq bitmap-h (+ 2 (bitmap-width bitmap))))
      (if (not (eq item-h nil))
          (setq text-h item-h))
      text-h))

#| Dialod items paint functions |#
(defun draw-push-button (item x y)
 (let ((w (get-dlgitem-width item))(h  (get-dlgitem-height item)))
  (draw-round-rect x y (1+ w) (1+ h)  3
    (eval (value item 'color)))
  (set-cursor
    (+ x
      (truncate
        (/
          (- w (gettextwidth (eval (value item 'text))))
          2)))
    (+ 1 y (truncate (/ (- h (getfontheight)) 2))))
  (if (equal (eval (value item 'enable)) 'true)
    (set-text-color
      (eval (value item 'color))
      (eval (value item 'colorbk)))
    (set-text-color
        (eval (value item 'colordisable))
        (eval (value item 'colorbk)))
  )
  (draw-string (eval (value item 'text)))))

(defun draw-label (item x y)
 (let ((w (get-dlgitem-width item))(h  (get-dlgitem-height item)))
  (set-cursor
    (+ x
      (truncate
        (/
          (- w (gettextwidth (eval (value item 'text))))
          2)))
    (+ 1 y (truncate (/ (- h (getfontheight)) 2))))
  (set-text-color
    (eval (value item 'color))
    (eval (value item 'colorbk)))
  (draw-string (eval (value item 'text)))))

#| Draw dialog form with head panel and tittle |#
  (defun get-forms-tittle-height nil (+ (getfontheight) 1))

  (defun draw-dialog (dialog x y h w)
    (let ((lst (eval (value dialog 'list)))
        (txt (eval (value dialog 'tittle))))
      (cls)
      (fill-rect x y w h (eval (value dialog 'colorbk)))
      (draw-rect x y (1- w) (1- h) (eval (value dialog 'colorfr)))
      (fill-rect
        (1+ x)
        (1+ y)
        (- w 2)
        (get-forms-tittle-height)
        (eval (value dialog 'headbkcolor)))
      (set-cursor (+ 1 x (truncate (/ (- w (gettextwidth txt)) 2))) (1+ y))
      (set-text-color
        (eval (value dialog 'headtxtcolor))
        (eval (value dialog 'headbkcolor)))
      (draw-string txt)))
      
#|  EXECUTE dialog form  |#
  (defun show-dialog (dialog &optional x y)
    (let* ((lst (eval (value dialog 'list)))
        (w (eval (value dialog 'width)))
        (h (eval (value dialog 'height)))
        (lst_len (length lst))
        (item_x 0)
        (item_y 0)
        (item_w 0)
        (item_h 0)
        (index 0)
        (form_h 0)
        (cursor_t 0)
        (key 0)
        (returned_v 0))
      (setq item_x (make-array lst_len))
      (setq item_y (make-array lst_len))
      (setq item_h (make-array lst_len))
      (setq item_w (make-array lst_len))
      (if (null x)  (setq x (truncate (/ (- (getmaxx) (eval (value dialog 'width))) 2))))
      (if (null y)  (setq y 0))
      (cond
        ((eq (eval (value dialog 'layout)) 'horisontal)
          (dolist (item lst)
            (setf (aref item_w index) (1+ (get-dlgitem-width item)))
            (setf (aref item_h index) (1+ (get-dlgitem-height item)))
            (setq index (1+ index)))
          (let ((xb 0)
              (yb (+ y 2 (get-forms-tittle-height)))
              (hmax 0)
              (index_bgn 0)
              (w_btns 0))
            (setq index 0)
            (dolist (item lst)
              (setf (aref item_x index) (+ x xb))
              (setf (aref item_y index) yb)
              (setq xb (+ xb (+ 2 (aref item_w index))))
              (if (>= xb w)
                (progn
                  (setq yb (+ yb hmax 4))
                  (setf (aref item_y index) yb)
                  (setf (aref item_x index) (+ x 0))
                  (setq hmax 0)
                  (let ((ww (truncate (/ (- w w_btns) (+ 2 (- index index_bgn)))))
                      (i index_bgn))
                    (loop
                      (if (and (>= xb w) (>= i index)) (return))
                      (setf (aref item_x i) (+ (aref item_x i) ww))
                      (setq ww (+ ww ww))
                      (setq i (1+ i))
                      (if (= i lst_len) (return))))
                  (setq xb 0)
                  (setq index_bgn index)
                  (setq w_btns 0)
                  (setq xb (+ 2 (aref item_w index)))))
              (if (>= (aref item_h index) hmax)
                    (progn
                       (setq hmax (aref item_h index))
                       (setq form_h (+ hmax (- (aref item_y index) y)))
              ))              (setq w_btns (+ w_btns (aref item_w index)))
              (if (= index (1- lst_len))
                (progn
                  (let ((ww (truncate (/ (- w w_btns) (+ 2 (- index index_bgn)))))
                      (i index_bgn))
                    (loop
                      (if (and (>= xb w) (> i index)) (return))
                      (setf (aref item_x i) (+ (aref item_x i) ww))
                      (setq ww (+ ww ww))
                      (setq i (1+ i))
                      (if (= i lst_len) (return))))
                  (setq xb 0)
                  (setq index_bgn index)
                  (setq w_btns 0)))
              (setq index (1+ index)))))
        (t 0))
      (set-text-color (eval (value dialog 'color)) (rgb 0 0 0))
      (cls)
      (setq form_h (+ form_h (truncate (/ (getfontheight) 2))) )
      (update dialog 'height form_h)
      (setq y (truncate (/ (- (getmaxy) (eval (value dialog 'height))) 2)))
      (setq index 0)
      (dolist (item lst)
        (setf (aref item_y index) (+ y (aref item_y index)))
        (setq index (1+ index)))
      (draw-dialog dialog x y form_h w)
      (do ((stopfl 0)) ((> stopfl 0))
        (setq index 0)
        (dolist (item lst)
          (funcall (eval (value item 'painter)) item (aref item_x index) (aref item_y index))
          (setq index (1+ index)))
        (setq index (1- lst_len))
        (set-cursor (+ (aref item_x index) 2)
            (1+ (aref item_y index)))
        (loop
          (if (touch-press)
            (let ((touch_x (touch-x)) (touch_y (touch-y)))
              (setq index 0)
              (dolist (item lst)
                (if (and
                    (> touch_x (aref item_x index))
                    (> touch_y (aref item_y index))
                    (< touch_x (+ (aref item_x index) (aref item_w index)))
                    (< touch_y (+ (aref item_y index) (aref item_h index))))
                  (progn (setq cursor_t index)))
                (setq index (1+ index)))
              (setq key 13)
              (return)))
          (if (kbhit) (progn (setq key (read-key)) (return))))
        (if (or (eq key 9) (key-forRight key) (key-forDown key))
          (progn
            (setq cursor_t (1+ cursor_t))
            (if (eq cursor_t lst_len) (setq cursor_t 0))))
        (if (or (key-forLeft key) (key-forUp key))
          (progn
            (setq cursor_t (1- cursor_t))
            (if (< cursor_t 0) (setq cursor_t (1- lst_len)))))
        (if (key-forQuit key) (setq stopfl 1))
        (if (eq key 13)
          (progn
            (if (eq (eval (value (nth cursor_t lst) 'type)) 'push-button)
              (progn
               (setq returned_v (eval (value (nth cursor_t lst) 'function)))
               (setq stopfl 1)
            ))
             )))
      (fill-rect x y w form_h (rgb 0 0 0))
      (set-text-color
        (eval (value dialog 'color))
        (eval (value dialog 'colorbk)))
      returned_v))
      
#|  Create and show Message box
  (Message message-string  buttons)
   message-string - the string which will be print on dialog panel
   buttons - additional buttons to be use. "OK" - button will be exist on silence
    (Message '("message string 1" "message string 2" "message string 3"))
    (Message '("message string 1" "message string 2" "message string 3") "Cancel")
    (Message '("message string 1" "message string 2" "message string 3") '("Cancel"))
|#
   (defun Message (text &optional buttons)
    (let ((msg-form 0)
        (btnlist 'nil)
        (w (- (getmaxx) (truncate (/ (getmaxx) 5))))
        (w_init (+ 2 (* (gettextwidth "0") 30))) )
      (if (stringp text)
        (progn
          (let ((new-item
                (object
                  'label-class
                  '(text
                     label-text
                     width
                     0
                     function
                     0))))
            (update new-item 'text text)
            (update new-item 'width (- w 10))
            (setq btnlist (append btnlist (cons new-item nil)))))
        (if (consp text)
          (dolist (item text)
            (if (< w (gettextwidth item)) (setq w (gettextwidth item)))
            (let ((new-item
                  (object
                    'label-class
                    '(text
                       label-text
                       width
                       0
                       function
                       0))))
              (update new-item 'text item)
              (update new-item 'width (- w 10))
              (setq btnlist (append btnlist (cons new-item nil)))))
          (setq w (gettextwidth "Empty message."))))
      (if (< w w_init) (setq w w_init))
      (if (>= w (getmaxx)) (setq w (1- (getmaxx))))
      (setq msg-form (object
          'dialog-form
          '(tittle
             "Message"
             type
             'dialog
             enable
             'true
             layout
             'horisontal
             list
             btnlist
             width
             (- (getmaxx) (truncate (/ (getmaxx) 5)))
             height
             0
             function
             27)))
      (setq btnlist (append btnlist '(button-OK)))
      (if (and (not (equal buttons nil)) (stringp buttons))
        (cond
          ((string= buttons "Cancel")
            (setq btnlist (append btnlist '(button-ESC))))
          (t nil)))
      (if (consp buttons)
        (dolist (btn buttons)
          (cond
            ((and (stringp btn) (string= btn "Cancel"))
              (setq btnlist (append btnlist '(button-ESC))))
            (t
              (if (not (stringp btn))
                (setq btnlist (append btnlist (cons btn))))))))
      (show-dialog msg-form)))

#|  Example of simple dialog |#
#|  (defvar dialog-example (object
      'dialog-form
      '(tittle
         '"Dialog"
         type
         'dialog
         enable
         'true
         layout
         'horisontal
; automatic horizontal layout of dialog items
         list
         '(button-OK button-ESC)
         width
         (- (getmaxx) (truncate (/ (getmaxx) 5)))
         height
         (+ (* (getfontheight) 3) 2)
         function
         27)))
|#

)
