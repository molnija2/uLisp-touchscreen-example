An example of a set of functions for working with a touch panel
for the Lisp interpreter for microcontrollers developed
by David Johnson-Davies. http://www.ulisp.com

This code was used in the ESP32-2432S028R device
- (ESP32-WROOM board with TFT and touchscreen)

You need to add the command "initTouchscreen();" into the setup() function.

esp32_dialog_lib.l   - lisp source of dialog library using of the simple object system which is sugguested by David Johnson-Davies (http://www.ulisp.com/show?37VY). At present moment the message-box function is written only.

Call examples :

(Message "message string")
(Message "message string", "Cancel")
(Message '("message string 1" "message string 2" "message string 3"))
(Message '("message string 1" "message string 2" "message string 3") "Cancel")
(Message '("message string 1" "message string 2" "message string 3") '("Cancel"))
