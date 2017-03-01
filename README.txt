
Matlab implementation of SEDUCM for lung segmentation in chest radiographs.

Installing toolboxes

You'll need to install the following:
Piotr's Computer Vision Matlab Toolbox (https://pdollar.github.io/toolbox/)
Structured Edge Detection Toolbox (https://github.com/pdollar/edges)


Usage
The main algorithm is in edgesTrain_CXRLungfield and simplifiedSegCXR_forest.m.
We provide two different examples of chest radiograph in "cxrSamples". The SED models trained on the JSRT dataset are in "models/forest".
Runing demo_JSRTfile.m or demo_dicomfile.m to see the segmentation result and how the SEDUCM works.


If you use this software in an academic article, please cite:
@article{Yang2017SEDUCM,
  title={Lung Field Segmentation in Chest Radiographs from Boundary Maps by a Structured Edge Detector},
  author={Wei Yang, Yunbi Liu, Liyan Lin, Zhaoqiang Yun, Zhentai Lu, Qianjin Feng, and Wufan Chen},
  journal={Journal of Biomedical and Health Informatics, under revision}
  year={2017}
}
