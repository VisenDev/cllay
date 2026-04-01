(defpackage #:cllay
  (:use #:cl))
(in-package #:cllay)

(defstruct vec2
  (x 0.0f :type single-float)
  (y 0.0f :type single-float))

(defstruct dimensions
  (w 0.0f :type single-float)
  (h 0.0f :type single-float))

(defstruct color
  (r 0.0f :type single-float)
  (g 0.0f :type single-float)
  (b 0.0f :type single-float)
  (a 0.0f :type single-float))

(defstruct bounding-box
  (x 0.0f :type single-float)
  (y 0.0f :type single-float)
  (w 0.0f :type single-float)
  (h 0.0f :type single-float))

(defstruct element-id
  (id 0 :type fixnum)
  (offset 0 :type fixnum)
  (base-id 0 :type fixnum)
  (string-id 0 :type string))

(defstruct corner-radius
  (top-left 0.0f :type single-float)
  (top-right 0.0f :type single-float)
  (bottom-left 0.0f :type single-float)
  (bottom-right 0.0f :type single-float))

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
  (x 0.0f :type single-float)
  (y 0.0f :type single-float))

(defstruct sizing-min-max
  (min 0.0f :type single-float)
  (max 0.0f :type single-float))

(defstruct sizing-axis size type)

(defstruct sizing
  (width nil :type sizing-axis)
  (height nil :type sizing-axis))

(defstruct padding
  (left 0 :type fixnum)
  (right 0 :type fixnum)
  (top 0 :type fixnum)
  (bottom 0 :type fixnum))

(defstruct layout-config
  (sizing nil :type sizing)
  (padding nil :type padding)
  (child-gap 0 :type fixnum)
  (child-alignment nil :type child-alignment)
  (layout-direction nil :type layout-direction))

(deftype text-element-config-wrap-mode ()
  '(member
    :words
    :newlines
    :none))

(defstruct text-element-config
  userdata
  (text-color nil :type color)
  (font-id 0 :type fixnum)
  (font-size 0 :type fixnum)
  (letter-spacing 0 :type fixnum)
  (line-height 0 :type line-height)
  (wrap-mode nil :type text-element-config-wrap-mode)
  (text-alignment nil :type text-alignment))

(defstruct aspect-ratio-element-config
  (aspect-ratio 0.0f :type single-float))

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
  (element nil :type floating-attach-point-type)
  (parent nil :type floating-attach-point-type))

(deftype pointer-capture-mode ()
  '(member :capture :passthrough))

(deftype floating-attach-to-element ()
  '(member :to-none :to-parent :to-element-with-id :to-root))

(deftype floating-clip-to-element ()
  '(member :to-none :to-attached-parent))

(defstruct floating-element-config
  (offset nil :type vec2)
  (expand nil :type dimensions)
  (parent-id 0 :type fixnum)
  (z-index 0 :type fixnum)
  (attach-points nil :type attach-points)
  (pointer-capture-mode nil :type pointer-capture-mode)
  (attach-to nil :type floating-attach-to-element)
  (clip-to nil :type floating-clip-to-element))

(defstruct custom-element-config
  custom-data)

(defstruct clip-element-config
  (horizonal nil :type boolean)
  (vertical nil :type boolean)
  (child-offset nil :type child-offset))

(defstruct border-width
  (left 0 :type fixnum)
  (right 0 :type fixnum)
  (top 0 :type fixnum)
  (bottom 0 :type fixnum)
  (between-children 0 :type fixnum))

(defstruct border-element-config
  (color nil :type color)
  (width nil :type border-width))

(defstruct transition-data
  (bounding-box nil :type bounding-box)
  (background-color nil :type color)
  (overlay-color nil :type color)
  (border-color nil :type color)
  (border-width nil :type border-width))

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
  (elapsed-type 0.0f :type single-float)
  (duration 0.0f :type single-float)
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
  (duration 0.0f :type single-float)
  (properties nil :type list)
  (enter (make-transition-element-config-enter :type transition-element-config-enter))
  (exit (make-transition-element-config-exit :type transition-element-config-exit)))

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
  (render-data (make-render-data) :type render-data)
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
  (min-dimensiosn (make-dimensions) :type dimensions))
