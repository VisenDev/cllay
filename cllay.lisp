(defpackage #:cllay
  (:use #:cl))
(in-package #:cllay)

(declaim (optimize (debug 3)))

(defstruct vec2
  (x 0.0f0 :type single-float)
  (y 0.0f0 :type single-float))

(defstruct dimensions
  (w 0.0f0 :type single-float)
  (h 0.0f0 :type single-float))

(defstruct color
  (r 0.0f0 :type single-float)
  (g 0.0f0 :type single-float)
  (b 0.0f0 :type single-float)
  (a 0.0f0 :type single-float))

(defstruct bounding-box
  (x 0.0f0 :type single-float)
  (y 0.0f0 :type single-float)
  (w 0.0f0 :type single-float)
  (h 0.0f0 :type single-float))

(defstruct element-id
  (id 0 :type fixnum)
  (offset 0 :type fixnum)
  (base-id 0 :type fixnum)
  (string-id "" :type string))

(defstruct corner-radius
  (top-left 0.0f0 :type single-float)
  (top-right 0.0f0 :type single-float)
  (bottom-left 0.0f0 :type single-float)
  (bottom-right 0.0f0 :type single-float))

(deftype layout-direction () '(member :left-to-right :top-to-bottom))

(deftype layout-alignment-x () '(member :align-x-left :align-x-right :align-x-center))

(deftype layout-alignment-y () '(member :align-y-left :align-y-right :align-y-center))

(deftype sizing-type ()
  '(member
    :fit
    :grow
    :percent
    :fixed))

(defstruct child-alignment
  (x 0.0f0 :type single-float)
  (y 0.0f0 :type single-float))

(defstruct sizing-min-max
  (min 0.0f0 :type single-float)
  (max 0.0f0 :type single-float))

(defstruct sizing-axis size type)

(defstruct sizing
  (width (make-sizing-axis) :type sizing-axis)
  (height (make-sizing-axis) :type sizing-axis))

(defstruct padding
  (left 0 :type fixnum)
  (right 0 :type fixnum)
  (top 0 :type fixnum)
  (bottom 0 :type fixnum))

(defstruct layout-config
  (sizing (make-sizing) :type sizing)
  (padding (make-padding) :type padding)
  (child-gap 0 :type fixnum)
  (child-alignment (make-child-alignment) :type child-alignment)
  (layout-direction :left-to-right :type layout-direction))

(deftype text-element-config-wrap-mode ()
  '(member
    :words
    :newlines
    :none))

(deftype text-alignment ()
  '(member
    :left
    :center
    :right))

(defstruct text-element-config
  userdata
  (text-color (make-color) :type color)
  (font-id 0 :type fixnum)
  (font-size 0 :type fixnum)
  (letter-spacing 0 :type fixnum)
  (line-height 0 :type fixnum)
  (wrap-mode :words :type text-element-config-wrap-mode)
  (text-alignment :left :type text-alignment))

(defstruct aspect-ratio-element-config
  (aspect-ratio 0.0f0 :type single-float))

(defstruct image-element-config
  image-data)

(deftype floating-attach-point-type ()
  '(member
    :left-top
    :left-center
    :left-bottom
    :center-top
    :center-center
    :center-bottom
    :right-top
    :right-center
    :right-bottom))

(defstruct floating-attach-points
  (element :left-top :type floating-attach-point-type)
  (parent :left-top :type floating-attach-point-type))

(deftype pointer-capture-mode ()
  '(member :capture :passthrough))

(deftype floating-attach-to-element ()
  '(member :to-none :to-parent :to-element-with-id :to-root))

(deftype floating-clip-to-element ()
  '(member :to-none :to-attached-parent))

(defstruct floating-element-config
  (offset (make-vec2) :type vec2)
  (expand (make-dimensions) :type dimensions)
  (parent-id 0 :type fixnum)
  (z-index 0 :type fixnum)
  (attach-points (make-floating-attach-points) :type floating-attach-points)
  (pointer-capture-mode :capture :type pointer-capture-mode)
  (attach-to :to-none :type floating-attach-to-element)
  (clip-to :to-none :type floating-clip-to-element))

(defstruct custom-element-config
  custom-data)

(defstruct clip-element-config
  (horizonal nil :type boolean)
  (vertical nil :type boolean)
  (child-offset (make-vec2) :type vec2))

(defstruct border-width
  (left 0 :type fixnum)
  (right 0 :type fixnum)
  (top 0 :type fixnum)
  (bottom 0 :type fixnum)
  (between-children 0 :type fixnum))

(defstruct border-element-config
  (color (make-color) :type color)
  (width (make-border-width) :type border-width))

(defstruct transition-data
  (bounding-box (make-bounding-box) :type bounding-box)
  (background-color (make-color) :type color)
  (overlay-color (make-color) :type color)
  (border-color (make-color) :type color)
  (border-width (make-border-width) :type border-width))

(deftype transition-state ()
  '(member
    :idle
    :entering
    :transitioning
    :exiting))


(deftype transition-property-normalized ()
  '(member
    :none
    :x
    :y
    :width
    :height
    :background-color
    :overlay-color
    :corner-radius
    :border-color
    :border-width))

(deftype transition-property ()
  '(member
    :none
    :x
    :y
    :position ;; normalizes to :x :y
    :width
    :height
    :dimensions ;; normalizes to :width :height
    :bounding-box ;; normalizes to :x :y :width :height
    :background-color
    :overlay-color
    :corner-radius
    :border-color
    :border-width
    :border ;; normalizes to :border-height :border-width
    ))


(defun normalize-transition-properties (properties-list)
  (loop :for prop :in properties-list
        :append (case prop
                   (:position '(:x :y))
                   (:dimension '(:width :height))
                   (:bounding-box '(:x :y :width :height))
                   (:border '(:border-width :border-color))
                   (otherwise (list prop)))))

(defstruct transition-callback-arguments
  (transition-state nil :type transition-state)
  (initial nil :type transition-data)
  (current nil :type transition-data)
  (target nil :type transition-data)
  (elapsed-type 0.0f0 :type single-float)
  (duration 0.0f0 :type single-float)
  (properties nil :type list))

(deftype transition-enter-trigger-type ()
  '(member
    :skip-on-first-parent-frame
    :trigger-on-first-parent-frame))

(deftype transition-exit-trigger-type ()
  '(member
    :skip-when-parent-exits
    :trigger-when-parent-exits))

(deftype transition-interaction-handling-type ()
  '(member
    :disable-interactions-while-transitioning-position
    :allow-interactions-while-transitioning-position))

(deftype exit-transition-sibling-ordering ()
  '(member
    :underneath-siblings
    :natural-order
    :above-siblings))

(deftype transition-properties-list () 'list)

(defstruct transition-element-config-enter
  set-initial-state;;(function (transition-data transition-properties-list) transition-data)
  (trigger :skip-on-first-parent-frame :type transition-enter-trigger-type))

(defstruct transition-element-config-exit
  set-final-state ;;(function (transition-data transition-properties-list) transition-data)
  (trigger :skip-when-parent-exits :type transition-exit-trigger-type)
  (sibling-ordering :underneath-siblings :type exit-transition-sibling-ordering)
  )

(defstruct transition-element-config
  handler ;; (function (transition-callbacl-arguments) boolean)
  (duration 0.0f0 :type single-float)
  (properties nil :type list)
  (enter (make-transition-element-config-enter) :type transition-element-config-enter)
  (exit (make-transition-element-config-exit) :type transition-element-config-exit))

(defstruct text-render-data
  (string-contents "" :type string)
  (text-color (make-color) :type color)
  (font-id 0 :type fixnum)
  (font-size 0 :type fixnum)
  (letter-spacing 0 :type fixnum)
  (line-height 0 :type fixnum))

(defstruct rectangle-render-data
  (background-color (make-color) :type color)
  (corner-radius (make-corner-radius) :type corner-radius))

(defstruct image-render-data
  (background-color (make-color) :type color)
  (corner-radius (make-corner-radius) :type corner-radius)
  image-data)

(defstruct custom-render-data
  (background-color (make-color) :type color)
  (corner-radius (make-corner-radius) :type corner-radius)
  custom-data)

(defstruct clip-render-data
  (horizontal nil :type boolean)
  (vertical nil :type boolean))

(defstruct overlay-color-render-data
  (color (make-color) :type color))

(defstruct border-render-data
  (color (make-color) :type color)
  (corner-radius (make-corner-radius) :type corner-radius)
  (width (make-border-width) :type border-width))

(deftype render-data ()
  '(or
    null
    text-render-data
    rectangle-render-data
    image-render-data
    custom-render-data
    clip-render-data
    overlay-color-render-data
    border-render-data))

(defstruct scroll-container-data
  (scroll-position (make-vec2) :type vec2)
  (scroll-container-dimensions (make-dimensions) :type dimensions)
  (content-dimensions (make-dimensions) :type dimensions)
  (config (make-clip-element-config) :type clip-element-config)
  (found nil :type boolean))

(defstruct element-data
  (bounding-box (make-bounding-box) :type bounding-box)
  (found nil :type boolean))

(deftype render-command-type ()
  '(member
    :none
    :rectangle
    :border
    :text
    :image
    :scissor-start
    :scissor-end
    :overlay-color-start
    :overlay-color-end
    :custom))

(defstruct render-command
  (bounding-box (make-bounding-box) :type bounding-box)
  (render-data nil :type render-data)
  userdata
  (id 0 :type fixnum)
  (z-index 0 :type fixnum)
  (command-type :none :type render-command-type))

(deftype pointer-data-interaction-state ()
  '(member
    :pressed-this-frame
    :pressed
    :released-this-frame
    :released))

(defstruct pointer-data
  (position (make-vec2) :type vec2)
  (state :pressed-this-frame :type pointer-data-interaction-state))

(defstruct element-declaration
  (layout (make-layout-config) :type layout-config)
  (background-color (make-color) :type color)
  (overlay-color (make-color) :type color)
  (corner-radius (make-corner-radius) :type corner-radius)
  (aspect-ratio (make-aspect-ratio-element-config) :type aspect-ratio-element-config)
  (image (make-image-element-config) :type image-element-config)
  (floating (make-floating-element-config) :type floating-element-config)
  (custom (make-custom-element-config) :type custom-element-config)
  (clip (make-clip-element-config) :type clip-element-config)
  (border (make-border-element-config) :type border-element-config)
  (transition (make-transition-element-config) :type transition-element-config)
  userdata)

;; TODO
;; Clay_LayoutConfig CLAY_LAYOUT_DEFAULT = CLAY__DEFAULT_STRUCT;
;; Clay_Color Clay__Color_DEFAULT = CLAY__DEFAULT_STRUCT;
;; Clay_CornerRadius Clay__CornerRadius_DEFAULT = CLAY__DEFAULT_STRUCT;
;; Clay_BorderWidth Clay__BorderWidth_DEFAULT = CLAY__DEFAULT_STRUCT;


(defstruct wrapped-text-line
  (dimensions (make-dimensions) :type dimensions)
  (line "" :type string))

(defstruct text-element-data
  (text "" :type string)
  (dimensions (make-dimensions) :type dimensions)
  wrapped-lines ;;list of wrapped-text-line
  )

(defstruct layout-element-children
  elements
  length)

(defstruct layout-element
  (children (make-layout-element-children) :type layout-element-children)
  (dimensions (make-dimensions) :type dimensions)
  (min-dimensiosn (make-dimensions) :type dimensions)
  (config (make-element-declaration) :type element-declaration)
  (text-config (make-text-element-config) :type text-element-config)
  (text-element-data (make-text-element-data) :type text-element-data)
  (id 0 :type fixnum)
  (floating-children-count 0 :type fixnum)
  (is-text-element-p nil :type boolean)
  (exiting-p nil :type boolean))

(defstruct scroll-container-data-internal
  (layout-element (make-layout-element) :type layout-element)
  (bounding-box (make-bounding-box) :type bounding-box)
  (content-size (make-dimensions) :type dimensions)
  (scroll-origin (make-vec2) :type vec2)
  (pointer-origin (make-vec2) :type vec2)
  (scroll-momentum (make-vec2) :type vec2)
  (scroll-position (make-vec2) :type vec2)
  (previous-delta (make-vec2) :type vec2)
  (momentum-time 0.0f0 :type single-float)
  (element-id 0 :type fixnum)
  (open-this-frame nil :type boolean)
  (pointer-scroll-active nil :type boolean))

(defstruct transition-data-internal
  (initial-state (make-transition-data) :type transition-data)
  (current-state (make-transition-data) :type transition-data)
  (target-state (make-transition-data) :type transition-data)
  (element-this-frame (make-layout-element) :type layout-element)
  (element-id 0 :type fixnum)
  (parent-id 0 :type fixnum)
  (sibling-index 0 :type fixnum)
  (elapsed-time 0.0f0 :type single-float)
  (state :idle :type transition-state)
  (transition-out nil :type boolean)
  (reparented nil :type boolean)
  (active-properties nil :type list) ;;list of transition-properties
  )

(defstruct debug-element-data
  (collision nil :type boolean)
  (collapsed nil :type boolean))

(defstruct layout-element-hashmap-item
  (bounding-box (make-bounding-box) :type bounding-box)
  (element-id (make-element-id) :type element-id)
  (layout-element (make-layout-element) :type layout-element)
  on-hover-function ;; (function (element-id pointer-data t))
  hover-function-user-data
  (next-index 0 :type fixnum)
  (generation 0 :type fixnum)
  (appeared-this-frame nil :type boolean)
  (debug-data (make-debug-element-data) :type debug-element-data))

(defstruct measured-word
  (start-offset 0 :type fixnum)
  (length 0 :type fixnum)
  (width 0.0f0 :type single-float)
  (next 0 :type fixnum))

(defstruct measure-text-cache-item
  (unwrapped-dimensions (make-dimensions) :type dimensions)
  (measured-words-start-index 0 :type fixnum)
  (min-width 0.0f0 :type single-float)
  ;;hash map data
  (id 0 :type fixnum)
  (next-index 0 :type fixnum)
  (generation 0 :type fixnum))

(defstruct layout-element-tree-node
  (layout-element (make-layout-element) :type layout-element)
  (position (make-vec2) :type vec2)
  (next-child-offset (make-vec2) :type vec2)
  (parent-moved-this-frame nil :type boolean))

(defstruct layout-element-tree-root
  (layout-element-index 0 :type fixnum)
  (parent-id 0 :type fixnum)
  (clip-element-id 0 :type fixnum)
  (z-index 0 :type fixnum)
  (pointer-offset 0 :type fixnum))

(defmacro make-vector (type)
  `(make-array 0 :element-type ',type :fill-pointer 0 :adjustable t))

(defstruct context
  (max-element-count 0 :type fixnum)
  (max-measure-text-cache-word-count 0 :type fixnum)
  (exiting-elements-length 0 :type fixnum)
  (exiting-elements-children-length 0 :type fixnum)
  (warnings-enabled nil :type boolean)
  (root-resized-last-frame nil :type boolean)
  ;;  Clay_ErrorHandler errorHandler;
  ;;  Clay_BooleanWarnings booleanWarnings;
  ;;  Clay__WarningArray warnings;

  (pointer-info (make-pointer-data) :type pointer-data)
  (layout-dimensions (make-dimensions) :type dimensions)
  (dynamic-element-index-base-hash (make-element-id) :type element-id)
  (dynamic-element-index 0 :type fixnum)
  (debug-mode-enabled nil :type boolean)
  (disable-culling nil :type boolean)
  (external-scroll-handling-enabled nil :type boolean)
  (debug-selected-element-id 0 :type fixnum)
  (generation 0 :type fixnum)
  measure-text-userdata
  query-scroll-offset-userdata

  (layout-elements (make-vector layout-element) :type (vector layout-element))
  (render-commands (make-vector render-command) :type (vector render-command))
  (open-layout-element-stack (make-vector fixnum) :type (vector fixnum))
  (layout-element-children (make-vector fixnum) :type (vector fixnum))
  (layout-element-children-buffer (make-vector fixnum) :type (vector fixnum))
  (reusable-element-index-buffer (make-vector fixnum) :type (vector fixnum))
  (layout-element-clip-element-ids (make-vector fixnum) :type (vector fixnum))

  (layout-element-id-strings (make-vector string) :type (vector string))
  (wrapped-text-lines (make-vector wrapped-text-line) :type (vector wrapped-text-line))
  (layout-element-tree-node-array-1 (make-vector layout-element-tree-node)
   :type (vector layout-element-tree-node))
  (layout-element-tree-roots (make-vector layout-element-tree-node)
   :type (vector layout-element-tree-node))
  (layout-elements-hashmap-internal (make-hash-table)) ;;    Clay__LayoutElementHashMapItemArray layoutElementsHashMapInternal;
  (layout-elements-hashmap (make-vector fixnum) :type (vector fixnum))
  (measure-text-hashmap-internal (make-vector measure-text-cache-item)
   :type (vector measure-text-cache-item))
  (measure-text-hashmap-interal-free-list (make-vector fixnum))
  (measure-text-hashmap (make-vector fixnum))
  (measured-words (make-vector measured-word))
  (measured-words-free-list (make-vector fixnum))
  (open-clip-element-stack (make-vector fixnum))
  (pointer-over-ids (make-vector element-id))
  (scroll-container-datas (make-vector scroll-container-data-internal))
  (transition-datas (make-vector transition-data-internal))
  (tree-node-visited (make-vector boolean))
  (dynamic-string-data (make-vector character))
  (debug-element-data (make-vector debug-element-data)))

(declaim (ftype (function (vector) fixnum) array-length))
(defun array-length (array)
  (fill-pointer array))

(declaim (ftype (function (vector integer) t) array-reverse-reference))
(defun array-reverse-reference (array index-from-end)
  (aref array (- (array-length array) index-from-end)))

(declaim (ftype (function (vector) t) array-top))
(defun array-top (array)
  (array-reverse-reference array 1))

;;;; ==== CTX ====
(defparameter *ctx* nil)

(defun get-open-layout-element ()
  (aref (context-layout-elements *ctx*)
        (array-top (context-open-layout-element-stack *ctx*))))

(defun get-parent-element ()
  (aref (context-layout-elements *ctx*)
        (array-reverse-reference (context-open-layout-element-stack *ctx*) 2)))

(defun get-parent-element-id ()
  (layout-element-id (get-parent-element)))

(defun border-has-any-width-p (border-config)
  (let ((w (border-element-config-width border-config)))
    (or (> (border-width-left w) 0)
        (> (border-width-right w) 0)
        (> (border-width-top w) 0)
        (> (border-width-bottom w) 0))))

(defun hash-number (offset seed)
  (let* ((hash seed)
         (hash (+ hash (+ offset 40)))
         (hash (ash hash 10))
         (hash (logxor hash (ash hash -6)))

         (hash (+ hash (ash hash 3)))
         (hash (logxor (ash hash -11)))
         (hash (+ hash (ash hash 15))))
    (make-element-id :id (1+ hash) :offset offset :base-id seed :string-id "")))

(defmacro logxorf (place number)
  `(setf ,place (logxor ,place ,number)))

(defun hash-string (key seed)
  (let ((hash seed))
    (loop :for ch :across key
          :for code = (char-code ch)
          :do (incf hash code)
              (incf hash (ash hash 10))
              (logxorf hash (ash hash -6)))
    (incf hash (ash hash 3))
    (logxorf hash (ash hash -11))
    (incf hash (ash hash 15))
    (make-element-id :id (1+ hash) :offset 0 :base-id (1+ hash) :string-id key)))

(defun hash-string-with-offset (key offset seed)
  (let ((hash 0)
        (base seed))
    (loop :for ch :across key
          :for code = (char-code ch)
          :do (incf base code)
              (incf base (ash base 10))
              (logxorf base (ash base -6)))
    (setf hash base)
    (incf hash offset)
    (incf hash (ash hash 10))
    (logxorf hash (ash hash -6))
    
    (incf hash (ash hash 3))
    (incf base (ash base 3))
    (logxorf hash (ash hash -11))
    (logxorf base (ash base -11))
    (incf hash (ash hash 15))
    (incf base (ash base 15))
    (make-element-id :id (1+ hash) :offset offset :base-id (1+ base) :string-id key)))

(defun hash-data (data)
  (loop
    :with hash = 0
    :for ch :across data
    :for code = (char-code ch)
    :do (incf hash code)
        (incf hash (ash hash 10))
        (logxorf hash (ash hash -6))
    :finally (return hash)))

;; uint64_t Clay__HashData(const uint8_t* data, size_t length)
(defun hash-string-contents-with-config (text config)
  (let ((hash (hash-data text)))
    (incf hash (text-element-config-font-id config))
    (incf hash (ash hash 10))
    (logxorf hash (ash hash -6))

    (incf hash (text-element-config-font-size config))
    (incf hash (ash hash 10))
    (logxorf hash (ash hash -6))

    (incf hash (text-element-config-letter-spacing config))
    (incf hash (ash hash 10))
    (logxorf hash (ash hash -6))

    (incf hash (ash hash 3))
    (logxorf hash (ash hash -11))
    (incf hash (ash hash 15))
    
    (1+ hash)))

(declaim (ftype (function (vector) t) array-pop))
(defun array-pop (array)
  (assert (> (array-length array) 0))
  (let ((item (array-top array)))
    (decf (fill-pointer array))
    item))

(declaim (ftype (function (measured-word measured-word) measured-word) add-measured-word))
(defun add-measured-word (word previous-word)
  (cond
    ((> (array-length (context-measured-words-free-list *ctx*)) 0)
     (let ((new-item-index (array-pop (context-measured-words-free-list *ctx*))))
       (setf (aref (context-measured-words *ctx*) new-item-index) word)
       (setf (measured-word-next previous-word) new-item-index)
       (return-from add-measured-word
         (aref (context-measured-words *ctx*) new-item-index))))
    (t
     (setf (measured-word-next previous-word) (array-length (context-measured-words *ctx*)))
     (vector-push-extend word (context-measured-words *ctx*))
     (return-from add-measured-word (array-top (context-measured-words *ctx*))))))

()
