# dbscan_bash

## Introduction

This is a DBSCAN implementation written completely in Bash (shell).

### Features

- Lightweight - written completely in Bash (shell), it requires no dependencies to cluster
- Documented - there's a lot of documentation in the script in order to enable machine learning aspirants from all skill levels to understand and build upon the code
- Extensible - written in Bash, the input and output methods are adjustable for the user's applications
- Flexible - works in Linux systems without any dependencies (see 'Lightweight' above) utilizing Heron's method to do non-integer calculations that Linux can't natively handle... or it will automatically use bc for complex calculations if it's installed

## How to Use

In it's current state, this script requires input as an array of strings as n-dimensional points. As mentioned above, though, this is completely changeable by the user. Future versions of this script may use a different format. Four test sets of points are included in the first few lines of code for user testing (comment/uncomment to activate which set of points to use).

Unfamiliar with DBSCAN? Start here: https://www.geeksforgeeks.org/dbscan-clustering-in-ml-density-based-clustering/

1. Download dbscan_bash
2. Run the following to enable execution:
~~~~
chmod +x ./dbscan_bash.sh
~~~~
3. Set your parameters in the script:
- epsilon - the radius of of the neighborhood around each point. Points within this radius will be considered part of the same cluster.
- minPts - the minimum number of points with an epsilon distance required to form a cluster
- sqrt_sensitivity - if bc is not installed on the system, the script will use Heron's method to estimate square roots (which is necessary to calculate the Euclidean distance between points). This variable establishes how close to the actual square root value the estimate must be to be considered acceptable (I recommend you leave this as 1).
- trun_size - how many dimensions the user wants to truncate all points to (useful if each data point has 100 dimensions but you only want to cluster on the first 10)
- verbose - provides the user some details about each step of the process (useful for troubleshooting). "true" will print some details - any other value will turn off details
- very_verbose - provides the user MANY details about each step of the process. "true" will print MANY details - any other value will turn off all details. This is very loud.
4. If using the test points provided in the script, then uncomment the selected array and comment all other arrays. If using other points, input them in the same format as those in the script.

## Results

In its current state, this script will simply print results to STDOUT along with some helpful messaging and metadata. Thanks to the extensibility of the script, however, there's no end to what could be done with this output - write it to a file, pass it to another function, or just look at it sit there in your terminal... it's up to the user!

### Example

Here's a sample output from running the script on the 3 dimensional set of example points included in the script.

~~~
zeek@Ubuntu:~/Desktop$ ./dbscan.sh
All points are size: 3 dimensions
Points are already 3 dimensions. No need to truncate.
bc will be used for clustering calculations.
Clustering . . . . . . . . . . . . . . . . . . . . . . . . . . . . 
Points labels: 1 -1 1 1 1 1 2 2 2 2 2 2 2 -1 -1 3 3 3 3 2 4 4 4 4 1
Clustering completed in 5 seconds.
~~~

## Considerations

- Since Linux can't handle non-integer calculations natively, if you intend to cluster points with decimal values (or anything non integer!), you must have bc installed on the system.
- All of the points you input into the algorithm must be of the same size (ie the same number of dimensions). The script will check for this and exit if there are discrepancies in the supplied data.
- In the results, -1 represents an outlier. Any other value represents the cluster that point was associated with. The printed output is in the same order as the points applied (first label to the first point, second to the second...)
