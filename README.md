# SEDUCM
###################################################################
#                                                                 #
#    Fast and Accurate Lung Field Segmentation                   #
#    in Chest Radiographs                                         #
#                                                                 #
###################################################################

1. Introduction.

We present a fast and accurate method for lung field segmentation that is built on a high-quality boundary map detected by an efficient modern boundary detector, namely, a structured edge detector (SED).A SED is trained beforehand to detect lung boundaries in CXRs with manually outlined lung fields. Then, an ultrametric contour map (UCM) is transformed from the masked and marked boundary map. Finally, the contours with the highest confidence level in the UCM are extracted as lung contours. Our method is evaluated using the public JSRT database of scanned films. The average Jaccard index of our method is 95.2%, which is comparable with those of other state-of-the-art methods (95.4%). The computation time of our method is less than 0.1 s for a 256 × 256 CXR when executed on an ordinary laptop. Our method is also validated on CXRs acquired with different digital radiography units. The results demonstrate the generalization of the trained SED model and the usefulness of our method.


###################################################################

2. License.

This code is published under the License.
Please read license.txt for more info.

###################################################################


3. Getting Started.

 - Make sure you have download all the code and related kit.Then you can test it with your computer.

###################################################################

