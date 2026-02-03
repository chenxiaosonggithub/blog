xmodmap -pke > origin_xmodmap.txt

cat <<EOF >> origin_xmodmap.txt
clear shift  
clear lock   
clear control
clear mod1   
clear mod2   
clear mod3 
clear mod4   
clear mod5   

! xmodmap:  up to 4 keys per modifier, (keycodes in parentheses):
 
! shift       Shift_L (0x32),  Shift_R (0x3e)
! lock        Caps_Lock (0x42)
! control     Control_L (0x25),  Control_R (0x69)
! mod1        Alt_L (0x40),  Alt_R (0x6c),  Meta_L (0xcd)
! mod2        Num_Lock (0x4d)
! mod3      
! mod4        Super_L (0x85),  Super_R (0x86),  Super_L (0xce),  Hyper_L (0xcf)
! mod5        ISO_Level3_Shift (0x5c),  Mode_switch (0xcb)

add shift       = Shift_L  Shift_R
add lock        = Caps_Lock
add control     = Control_L Control_R
add mod1        = Alt_L Alt_R Meta_L
add mod2        = Num_Lock
! add mod3      
add mod4        = Super_L Super_R Super_L Hyper_L
add mod5        = ISO_Level3_Shift Mode_switch

EOF


