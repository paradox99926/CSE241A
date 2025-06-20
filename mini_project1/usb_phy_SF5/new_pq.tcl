oo::class create PriorityQueue {
    variable heap
    
    constructor {} {
        set heap [list]
    }
    
    # Helper method to get parent index
    method parent {i} {
        return [expr {($i - 1) / 2}]
    }
    
    # Helper method to get left child index
    method leftChild {i} {
        return [expr {2 * $i + 1}]
    }
    
    # Helper method to get right child index
    method rightChild {i} {
        return [expr {2 * $i + 2}]
    }
    
    # Swap elements at indices i and j
    method swap {i j} {
        set temp [lindex $heap $i]
        set heap [lreplace $heap $i $i [lindex $heap $j]]
        set heap [lreplace $heap $j $j $temp]
    }
    
    # Heapify up (bubble up) - maintains heap property upward
    method heapifyUp {index} {
        while {$index > 0} {
            set parentIdx [my parent $index]
            set currentPriority [lindex [lindex $heap $index] 1]
            set parentPriority [lindex [lindex $heap $parentIdx] 1]
            
            if {$currentPriority > $parentPriority} {
                my swap $index $parentIdx
                set index $parentIdx
            } else {
                break
            }
        }
    }
    
    # Heapify down (bubble down) - maintains heap property downward
    method heapifyDown {index} {
        set size [llength $heap]
        
        while {1} {
            set largest $index
            set leftIdx [my leftChild $index]
            set rightIdx [my rightChild $index]
            
            # Check left child
            if {$leftIdx < $size} {
                set leftPriority [lindex [lindex $heap $leftIdx] 1]
                set largestPriority [lindex [lindex $heap $largest] 1]
                if {$leftPriority > $largestPriority} {
                    set largest $leftIdx
                }
            }
            
            # Check right child
            if {$rightIdx < $size} {
                set rightPriority [lindex [lindex $heap $rightIdx] 1]
                set largestPriority [lindex [lindex $heap $largest] 1]
                if {$rightPriority > $largestPriority} {
                    set largest $rightIdx
                }
            }
            
            if {$largest != $index} {
                my swap $index $largest
                set index $largest
            } else {
                break
            }
        }
    }
    
    # Insert element with priority
    method insert {value priority} {
        set element [list $value $priority]
        lappend heap $element
        set lastIndex [expr {[llength $heap] - 1}]
        my heapifyUp $lastIndex
    }
    
    # Remove and return element with highest priority (largest value)
    method pop {} {
        set size [llength $heap]
        
        if {$size == 0} {
            error "Priority queue is empty"
        }
        
        # Get the root element (highest priority)
        set result [lindex $heap 0]
        
        if {$size == 1} {
            set heap [list]
        } else {
            # Move last element to root and heapify down
            set heap [lreplace $heap 0 0 [lindex $heap [expr {$size - 1}]]]
            set heap [lreplace $heap [expr {$size - 1}] [expr {$size - 1}]]
            my heapifyDown 0
        }
        
        return $result
    }
    
    # Peek at the highest priority element without removing it
    method peek {} {
        if {[llength $heap] == 0} {
            error "Priority queue is empty"
        }
        
        return [lindex $heap 0]
    }
    
    # Check if queue is empty
    method is_empty {} {
        return [expr {[llength $heap] == 0}]
    }
    
    # Get queue size
    method size {} {
        return [llength $heap]
    }
    
    # Clear all elements from the queue
    method clear {} {
        set heap [list]
    }
    
    # Get all elements as a list (for debugging/inspection)
    method toList {} {
        return $heap
    }
    
    # Display queue contents (for debugging)
    method display {} {
        puts "Priority Queue contents:"
        if {[llength $heap] == 0} {
            puts "  (empty)"
            return
        }
        
        for {set i 0} {$i < [llength $heap]} {incr i} {
            set element [lindex $heap $i]
            puts "  Index $i: Value [lindex $element 0], Priority [lindex $element 1]"
        }
    }
    
    # String representation of the queue
    method toString {} {
        if {[llength $heap] == 0} {
            return "PriorityQueue(empty)"
        }
        
        set elements {}
        foreach element $heap {
            lappend elements "([lindex $element 0], [lindex $element 1])"
        }
        return "PriorityQueue([join $elements {, }])"
    }
    
    # Destructor
    destructor {
        # Cleanup if needed
        set heap [list]
    }
}

set pq [PriorityQueue new]

# Insert items with priorities
$pq insert [list "task1" 0] 10.5
$pq insert [list "task2" 1] 2.1
$pq insert [list "task3" 0] 15.7
$pq insert [list "task4" 0] 1.0
$pq insert [list "task5" 0] 8.3
$pq insert [list "task6" 0] 4.2
$pq insert [list "task7" 0] 17.6
$pq insert [list "task8" 0] 5.9
$pq insert [list "task9" 0] 23.4

# Peek at the highest priority item
puts "Top item: [$pq peek]"

# Pop all items
while {![$pq is_empty]} {
    set pop_element [$pq pop]
    puts "Popped: $pop_element"
    set firstElement [lindex $pop_element 0]
    set secondElement [lindex $pop_element 1]
    puts "the firstElement $firstElement"
    puts "the secondElenent $secondElement"
}