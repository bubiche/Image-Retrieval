**_The system only runs on Windows OS_**

###To run the system, follow these steps:
1. Put dataset images in data/images/, query images in query/images/ and code book in data/ renamed as codebook.hdf5(See below for code book download link)
2. Put groundtruth files in groundtruth/
3. Use Matlab to run step 1 -> step 2 -> step 3 -> step 4

###The results:
* ranklist/ contains the retrieved ranked lists
* ap/ contains average precision of each query
* MAP.txt contains the value of the mean average precision (it is also printed out on the screen when running step 4)
    
###Libraries from outside sources:
* lib/feature_detector/hesaff.exe: used to extract image features and compute descriptors, compiled from https://github.com/perdoch/hesaff, may need to install OpenCV to run
* lib/flann: used to compute neaest clusters for each feature, available at: http://www.cs.ubc.ca/research/flann/
* vlfeat/vlfeat-0.9.20: mainly used for functions like vl_binsum, etc... available at: http://www.vlfeat.org/
    
###Functions:
* extractFeatures: use lib/feature_detector/hesaff.exe to extract features from all images in a directory
* geometricVerification: used for query expansion, taken from https://github.com/vedaldi/practical-object-instance-recognition/blob/master/geometricVerification.m
* get_match_words: get the matched words between x and y
* makeBoW: make bag of words vectors for all images in a directory
* quantize_image: use flann kdtree to get the nearest bins, use a codebook for dataset when building kdtree, available at: https://drive.google.com/file/d/0By99LHjEgHvfVHlHbUcwdmNDQVE/view?pref=2&pli=1 (provided by fellow classmates)
    
MAP is calculated using groundtruth/compute_ap.exe compiled from the source code available at: https://www.robots.ox.ac.uk/~vgg/data/oxbuildings/compute_ap.cpp
