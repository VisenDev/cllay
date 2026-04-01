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


#|
;;TODO                                        ;
typedef enum {                          ;
    CLAY_TRANSITION_PROPERTY_NONE = 0,
    CLAY_TRANSITION_PROPERTY_X = 1,
    CLAY_TRANSITION_PROPERTY_Y = 2,
    CLAY_TRANSITION_PROPERTY_POSITION = CLAY_TRANSITION_PROPERTY_X | CLAY_TRANSITION_PROPERTY_Y,
    CLAY_TRANSITION_PROPERTY_WIDTH = 4,
    CLAY_TRANSITION_PROPERTY_HEIGHT = 8,
    CLAY_TRANSITION_PROPERTY_DIMENSIONS = CLAY_TRANSITION_PROPERTY_WIDTH | CLAY_TRANSITION_PROPERTY_HEIGHT,
    CLAY_TRANSITION_PROPERTY_BOUNDING_BOX = CLAY_TRANSITION_PROPERTY_POSITION | CLAY_TRANSITION_PROPERTY_DIMENSIONS,
    CLAY_TRANSITION_PROPERTY_BACKGROUND_COLOR = 16,
    CLAY_TRANSITION_PROPERTY_OVERLAY_COLOR = 32,
    CLAY_TRANSITION_PROPERTY_CORNER_RADIUS = 64,
    CLAY_TRANSITION_PROPERTY_BORDER_COLOR = 128,
    CLAY_TRANSITION_PROPERTY_BORDER_WIDTH = 256,
    CLAY_TRANSITION_PROPERTY_BORDER = CLAY_TRANSITION_PROPERTY_BORDER_COLOR | CLAY_TRANSITION_PROPERTY_BORDER_WIDTH
} Clay_TransitionProperty;
|#

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

(deftype transition-interaction-handling-type ()
  '(member
    :disable-interactions-while-transitioning-position
    :allow-interactions-while-transitioning-position))

(deftype exit-transition-sibling-ordering ()
  '(member
    :underneath-siblings
    :natural-order
    :above-siblings))

(defstruct transition-element-config )




