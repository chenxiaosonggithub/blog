
```sh
                    1.  +------------+ 6.
                   +----|   client   |>>>>>>>>>>+
                   |    +------------+          | 
           hey man,|          ^               你好像在逗我
    can you tell me|          |额，你猜？
 whose inode is 12?|        5.|                 |         
                   |    +------------+          |   
                   +--->|   server   |<<<<<<<<<<+  
                        +------------+
                         |  ^    ^  |
                     2.1.|  |    |  |2.2.
               +---------+  |    |  +---------+
               |            |    |            |
       hey boy |       i know   i know too    |hey girl
   do you know?|            |    |            |do you know?
               v            |    |            v      
          +----------+ 4.1. |    |4.2.   +----------+ 
          | /dev/sda |------+    +-------| /dev/sdb |
          +----------+                   +----------+
               ^                              ^      
        i am 12|                              |i am 12
               |3.1.                      3.2.|
          +----------+                   +----------+
          |   file   |                   |   file   |
          +----------+                   +----------+
```