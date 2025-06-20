# oo::class create PriorityQueue {
#     variable items  ;# list of {data priority}

#     constructor {} {
#         set items {}
#     }

#     method insert {data priority} {
#         lappend items [list $data $priority]
#         set items [lsort -index 1 -real $items]
#     }

#     method pop {} {
#         if {[llength $items] == 0} {
#             return ""
#         }
#         set first [lindex $items 0]
#         set items [lrange $items 1 end]
#         return $first
#     }

#     method peek {} {
#         if {[llength $items] == 0} {
#             return ""
#         }
#         return [lindex $items 0]
#     }

#     method size {} {
#         return [llength $items]
#     }

#     method is_empty {} {
#         expr {[llength $items] == 0}
#     }

#     method print {} {
#         puts "Queue contents:"
#         foreach entry $items {
#             puts "  [lindex $entry 0] => [lindex $entry 1]"
#         }
#     }
# }

set pq [PriorityQueue new]

# Insert items with priorities
$pq insert [list "task1" 0] 3
$pq insert [list "task2" 1] 1
$pq insert [list "task3" 0] 5

# Peek at the highest priority item
puts "Top item: [$pq peek]"

# Pop all items
while {![$pq empty]} {
    set pop_element [$pq pop]
    puts "Popped: [$pq pop]"
    set firstElement [lindex $pop_element 0]
    set secondElement [lindex $pop_element 1]
    puts "the firstElement $firstElement"
    puts "the secondElenent $secondElement"
}
