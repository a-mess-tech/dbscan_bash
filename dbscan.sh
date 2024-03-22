#!/bin/bash

#issues:
# 1. bash does not support sqrt natively and bc is not installed on all systems
# 2. cannot compare floats with -le or -ge - found a workaround using an awk function (result=$(awk -v int="$integer" -v flt="$float" 'BEGIN { print (int < flt) ? "true" : "false" }'))
# 3. cannot store arrays in arrays - difficult to track clusters as a result

#good notes:
# $(echo "$neighbors" | wc -l) $(echo $neighbors | wc -l) - difference is that the first one with " " around neighbors maintains newlines so the count is accurate. the one without " " does not maintain new lines so everything comes out as one line

# This is a bash implementation of the DBSCAN algorithm.


### Variables ###

# User-defined variables:
epsilon=3
minPts=3
sqrt_sensitivity=1
byte_size=3
verbose="trueq"
very_verbose="trueq"

# points=(
#     "1 1 1 1"
#     "1 1 2 2"
#     "1 2 1 2"
#     "1 2 2 1"
#     "2 1 1 2"
#     "2 1 2 1"
#     "10 1 1 10"
#     "10 11 1 1"
# )

# points=(
#     # .ppt files:
#     "208 207 17 224 161 177 26 225 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 62 0 3 0 254 255 9 0 6 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 1 0 0 0 0 0 0 0 0 16 0 0 2 0 0 0 1 0 0 0 254 255 255 255 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255"
#     "208 207 17 224 161 177 26 225 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 62 0 3 0 254 255 9 0 6 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 1 0 0 0 0 0 0 0 0 16 0 0 2 0 0 0 1 0 0 0 254 255 255 255 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255"
#     "208 207 17 224 161 177 26 225 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 62 0 3 0 254 255 9 0 6 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 1 0 0 0 0 0 0 0 0 16 0 0 2 0 0 0 1 0 0 0 254 255 255 255 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255"
#     "208 207 17 224 161 177 26 225 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 62 0 3 0 254 255 9 0 6 0 0 0 0 0 0 0 0 0 0 0 19 0 0 0 0 0 0 0 0 0 0 0 0 16 0 0 174 6 0 0 1 0 0 0 254 255 255 255 0 0 0 0 1 0 0 0 9 0 0 0 97 4 0 0 110 1 0 0 111 1 0 0 112 1 0 0"
#     "208 207 17 224 161 177 26 225 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 62 0 3 0 254 255 9 0 6 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 1 0 0 0 0 0 0 0 0 16 0 0 2 0 0 0 1 0 0 0 254 255 255 255 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255"
#     # .dll file:
#     "77 90 144 0 3 0 0 0 4 0 0 0 255 255 0 0 184 0 0 0 0 0 0 0 64 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 248 0 0 0 14 31 186 14 0 180 9 205 33 184 1 76 205 33 84 104 105 115 32 112 114 111 103 114 97 109 32 99 97 110 110 111 116 32 98 101"
# )

points=(
    "1 3 4"
    "2 8 7"
    "1 1 1"
    "1 1 2"
    "2 1 2"
    "1 1 3"
    "5 10 7"
    "7 7 7"
    "7 8 7"
    "7 7 8"
    "7 8 9"
    "7 7 9"
    "7 7 10"
    "11 18 20"
    "1 45 60"
    "50 50 50"
    "51 54 51"
    "50 51 50"
    "51 52 51"
    "8 7 7"
    "-1 -1 -1"
    "-1 -1 -2"
    "-1 -2 -1"
    "-1 -2 -2"
    "1 1 1"
)

# points=(
#     "1 3"
#     "2 2"
#     "2 3"
#     "3 3"
#     "8 8"
#     "8 9"
#     "9 9"
#     "9 8"
#     "3 2"
#     "5 5"
#     "12 12"
#     "18 18"
#     "1 1"
#     "2 2"
# )

# points=(
#     "1"
#     "2"
#     "3"
#     "2"
#     "10"
#     "20"
#     "21"
#     "22"
#     "23"
# )




### Functions ###

# function filter_points_size will take the points array and limit the number of dimensions to the byte_size variable.
function filter_points_size() {
    if [[ $size -le $byte_size ]]; then
        echo "Points are already $size dimensions. No need to filter."
        return
    fi
    for ((i=0; i<${#points[@]}; i++)); do
        points[$i]=$(echo "${points[$i]}" | cut -d ' ' -f 1-$byte_size)
    done
    echo "Points filtered to $byte_size dimensions."
}

# function get_size is called during the initialization of the script.
# it checks the number of dimensions of each point in the points array.
# if the points are not all the same size, the script will exit.
function get_size() {
    #returns the number of dimensions of each point in the points array
    size=$(echo "${points[0]}" | wc -w)
    same_size="true"
    for point in "${points[@]}"; do
        if [[ $(echo "$point" | wc -w) -ne $size ]]; then
            same_size="false"
        fi
    done
    if [[ $same_size == "true" ]]; then
        echo "All points are size: $size dimensions"
        num_dimensions=$size
    else
        echo "Points are not all the same size (dimensions). Exiting!"
        exit 1
    fi
}

# function calc_distance is called during the get_neighbors function.
# it calculates the euclidean distance between two points in n dimensions.
# it returns a float value.
function calc_distance() {
    #calculate the euclidean distance between two points in n dimensions
    #need to convert the points from strings to arrays
    local p1_str="$1"
    local p2_str="$2"
    #declaring as local so they are exclusive to calc_distance function
    local -a p1
    local -a p2
    read -a p1 <<< "$p1_str"
    read -a p2 <<< "$p2_str"
    local sum=0
    # need to set flag for float values so that bc is used every time a float is in one of the dimensions of a point (even if other dimensions are integers)
    local float_flag="false"
    #fun fact: ${#p1[@]} is the length of the array
    for ((i=0; i<${#p1[@]}; i++)); do
        #here, sum squares of differences between points - $(( )) is arithmetic expression
        if [[ "${p1[$i]}" == *.* ]] || [[ "${p2[$i]}" == *.* ]] || [[ $float_flag == 'true' ]]; then
            # echo "Using bc for floating point calculations of ${p1[$i]} and ${p2[$i]} on index $i" >&2
            float_flag="true"
            diff=$(echo "${p1[$i]} - ${p2[$i]}" | bc)
            square=$(echo "$diff * $diff" | bc)
            sum=$(echo "$sum + $square" | bc)
        # bash arithmetic is faster than bc (requires spawning a subshell), so use it for integer calculations.
        else
            # echo "Using bash arithmetic for integer calculations of ${p1[$i]} and ${p2[$i]} on index $i." >&2
            diff=$((${p1[$i]}-${p2[$i]}))
            square=$((diff*diff))
            sum=$((sum+square))
        fi
    done
    float_flag="false"
    # bc -l is calculator - scale sets number of decimal points of precision
    if [[ $calculator == "bc" ]]; then
        euc_dist=$(echo "sqrt($sum)" | bc -l)
    fi
    if [[ $calculator == "Bash arithmetic" ]]; then
        euc_dist=$(sqrt_calc $sum)
    fi
    echo "$euc_dist"
}


# function sqrt_calc is called during the calc_distance function. 
# when bc isn't found on the system, this script relies on bash arithmetic and heron's formula to calculate square roots
# this method is less accurate than bc but is a workaround when bc isn't available.
function sqrt_calc() {
    #bash does not support non-integer arithmetic natively and if bc isnt' on system, we need to estimate the square root with Heron's method
    local val_to_sqrt=$1
    local guess=$((val_to_sqrt / 2 + 1))
    error=$((sqrt_sensitivity + 1))
    local -i failsafe=0
    while ((error > sqrt_sensitivity)); do
        guess=$(((guess + val_to_sqrt / guess) / 2))
        error=$(abs $((guess * guess - val_to_sqrt)))
        failsafe+=1
        # failsafe to prevent infinite loop - scrappy but does the trick
        if [[ $failsafe -gt 15 ]]; then
            break
        fi
    done
    echo "$guess"
}

# helper function for sqrt_calc - gets absolute value
function abs() {
    #get absolute value with ternary operators (condition ? if_true : if_false)
    echo $(( $1 < 0 ? -$1 : $1 ))
}

# function get_neighbors is called during the dbscan function. 
# it calculates the distance between a seed point and all other points in the points array using the calc_distance function
# get_neighbors returns all the points that are within epsilon distance of the seed point
function get_neighbors() {
    local -a all_points=("${points[@]}")
    index_of_seed=$1
    neighbor_group=()
    for ((i=0; i<${#points[@]}; i++)); do
        distance=$(calc_distance "${points[$i]}" "${points[$index_of_seed]}")
        result=$(awk -v epsilon="$epsilon" -v distance="$distance" 'BEGIN {print (distance <= epsilon) ? "true" : "false"}')
        # echo "Distance between ${points[$i]} and ${points[$index_of_seed]} is $distance" >&2

        # take your pick of the following two noisy statements (printed to standard error so that they go to the console):
        [[ $very_verbose == 'true' ]] && echo "Distance between index $i and index $index_of_seed is $distance" >&2
        # [[ $very_verbose == 'true' ]] && echo "Distance between index $i (point ${points[$i]}) and index $index_of_seed (point ${points[$index_of_seed]}) is $distance" >&2
        if [[ $result == "true" ]]; then
            # CHANGE: add the index, not the point itself to neighbor group
            neighbor_group+=("$i")
        fi
    done
    # indexes are now saved to neighbor_group, not the points themselves
    for position in "${neighbor_group[@]}"; do
        echo "$position"
    done
}

# grow_cluster is called during the dbscan function. it is called when a seed point is identified (ie the number of neighbors is greater than or equal to minPts).
# grow_cluster iterates over all the neighbors of the seed point (as identified by get_neighbors).
# if the neighbor is labeled as noise, it is assigned to the current cluster number (this is a leaf/border point).
# if the neighbor is undefined, it is assigned to the current cluster number and its neighbors are identified.
# this is accomplished by adding the neighbors of the neighbor to the neighbors_helper array (while loop limit)
# grow_cluster adds newly identified neighbors to the current cluster (by updating points_labels array) 
# and continues to grow the cluster until all neighbors are identified.
# this is how the DBSCAN algorithm identifies all points in a cluster regardless of their distance from the seed point (initial core point).
function grow_cluster() {
    [[ $very_verbose == 'true' ]] && echo "Entering growing cluster function around core point $idx with neighbors: $neighbors"
    #initialize another index here, i
    declare -i i=0
    # neighbors_helper is a helper array
    neighbors_helper=$neighbors
    # debug helper
    # echo "Neighbors helper: $neighbors_helper"
    # echo "Neighbors helper length: $(echo "$neighbors_helper" | wc -l)"
    # iterates over every point identified as a neighbor to the seed point (saved as pn_num by index)
    while ((i < $(echo "$neighbors_helper" | wc -l))); do
        pn_num=$(echo "$neighbors_helper" | sed -n "$((i+1))p")
        # debug: print the neighbor point number and the neighbor point itself
        [[ $verbose == 'true' ]] && echo "Now growing cluster on point number: $pn_num and point: ${points[$pn_num]} and label: ${points_labels[$pn_num]}"
        # set the label of the point to the current cluster number if it's defined as noise (can't be a seed but could be a leaf)
        if [[ "${points_labels[$pn_num]}" -eq -1 ]]; then
            [[ $verbose == 'true' ]] && echo "** Assigning cluster $C to noise point number: $pn_num **"
            points_labels[$pn_num]=$C
        # if the point is undefined, it might be a branch or a leaf. if the point is already assigned to a cluster, do not reassign (does not enter the if statement)
        elif [[ "${points_labels[$pn_num]}" -eq 0 ]]; then
            # first, assign the cluster number to the point
            [[ $verbose == 'true' ]] && echo "** Assigning cluster $C to point number: $pn_num **"
            points_labels[$pn_num]=$C
            # find the neighbors (indexes) of this neighbor point 
            pn_num_neighbors=$(get_neighbors "$pn_num")
            # if there are more than minPts neighbors, it's a branch and we need to add it to the neighbors array
            # if there are less than minPts neighbors, then it's a leaf and we don't need to do anything
            if [[ $(echo "$pn_num_neighbors" | wc -l) -ge $minPts ]]; then
                # find the neighbors in pn_num_neighbors that are not in neighbors and add them to neighbors
                neighbors_array=($neighbors_helper)
                pn_num_neighbors_array=($pn_num_neighbors)
                # Iterate over pn_num_neighbors_array and check if the neighbor is not already in neighbors_array
                # echo ${pn_num_neighbors_array[@]}
                for pn_neighbor in "${pn_num_neighbors_array[@]}"; do
                    # check if pn_neighbor is not in neighbors
                    if ! printf '%s\n' "${neighbors_array[@]}" | grep -q -P "^$pn_neighbor$"; then
                        # Add pn_neighbor to neighbors
                        [[ $very_verbose == 'true' ]] && echo "Adding new item to neighbors array: $pn_neighbor"
                        neighbors_array+=("$pn_neighbor")
                    fi
                done
                neighbors_helper=$(printf '%s\n' "${neighbors_array[@]}")
            fi
        fi
        i=$((i+1))
    done
}

# function dbscan initiates the DBSCAN algorithm. first, it initializes the cluster counter and the points_labels array. 
# then, it iterates over all points in the points array. if a point is already assigned to a cluster or labeled as noise, it skips the point.
# if the point is not assigned to a cluster or labeled as noise, it initiates the get_neighbors function to find the neighbors of the point. 
# if the number of neighbors is less than minPts, the point is labeled as noise (it cannot be a seed/core point - it may later be changed to a lead/border point). 
# if the number of neighbors is greater than or equal to minPts, the point is labeled as a seed point and the grow_cluster function is initiated.
function dbscan() {
    echo -n "Clustering . . . "
    neighbors=()
    # cluster counter:
    declare -i C=0
    # define labels for points (-1 is noise, 0 is undefined, anything else is it's cluster number)
    points_labels=()
    for ((i=0; i<${#points[@]}; i++)); do
        points_labels+=("0")
    done
    idx=0
    # iterate through all points except those that have been assigned a cluster or labeled as noise (ie not 0)
    for ((i=0; i<${#points[@]}; i++)); do
        echo -n ". "
        neighbors=()
        # debug - see point and index
        # echo "Point: $point and index: $idx"
        [[ $verbose == 'true' ]] && echo "===  Initiating seed point check for: ${points[$idx]} and index: $idx with label: ${points_labels[$idx]}  ==="
        if [[ "${points_labels[$idx]}" -ne 0 ]]; then
            [[ $verbose == 'true' ]] && echo "Point ${points[$idx]} and index $idx is already assigned to cluster ${points_labels[$idx]} or labeled as noise."
            idx=$((idx+1))
            continue
        fi
        neighbors=$(get_neighbors "$idx")
        # debug - see all neighbors
        # echo "Neighbors: $neighbors"
        # echo "Neighbors end"
        if [[ $(echo "$neighbors" | wc -l) -lt $minPts ]]; then
            # debug - see the noise points and number of neighbors
            [[ $verbose == 'true' ]] && echo "* Point: ${points[$idx]} is a noise point with only $(echo "$neighbors" | wc -l) neighbors. *"
            points_labels[$idx]="-1"
        else
            # increment cluster
            C=$((C+1))
            [[ $verbose == 'true' ]] && echo "**** Seed point identified: ${points[$idx]} with index: $idx. Growing cluster $C. ****"
            grow_cluster "${neighbors[@]}"
        fi
        #idx increase must be the last action in the loop - this idx follows the idx of the points array 
        idx=$((idx+1))
    done
    echo ""
    echo "Points labels: ${points_labels[@]}"
}

# function define_calc checks if bc is installed on the system. if bc is not installed, it will use bash arithmetic to perform calculations.
function define_calc() {
    bc_present=$(which bc)
    if [[ $bc_present =~ "not found" || -z $bc_present ]]; then
        echo "bc is not installed. Calculations will be performed with built-in bash arithmetic and may take more time. Installing bc will enable more accurate calculations."
        echo "Decimal values cannot be processed without bc. If you need to process decimal values, you must install bc."
        calculator="Bash arithmetic"
    else
        calculator="bc"
    fi    
    echo "$calculator will be used for clustering calculations."
}

### Execution ###

declare -a neighbors

declare -i num_dimensions=0

declare -i size=0

get_size

filter_points_size

define_calc

# calculator="Bash arithmetic"

dbscan

### Testing ###



# sqrt_calc 14

# calc_distance "${points[0]}" "${points[1]}"

# neighbors=$(get_neighbors "${points[@]}" "${points[0]}")
# echo "${#neighbors[@]}"
# echo "$neighbors" | sed -n '1p'
# echo "${neighbors[@]}"

# echo $(get_neighbors 17)

# calc_distance "${points[3]}" "${points[4]}"
