%demo for DICOM data of CXR

%Piotr's Computer Vision Matlab Toolbox (https://pdollar.github.io/toolbox/)
% and Structured Edge Detection Toolbox (https://github.com/pdollar/edges) are required


%load CXR image data
cxrFileName = 'cxrSamples\testCXR.dcm';
imginfo = dicominfo( cxrFileName );
originalImg = dicomread(imginfo);

%load SED model
opts.trnGtDir = 'trnfold1';
opts.modelFnm = strcat('model_', opts.trnGtDir);
model = edgesTrain_CXRLungfield( opts );

%settings for SED prediction
model.opts.multiscale = 0;          
model.opts.sharpen = 0;            
model.opts.nTreesEval = 4;          
model.opts.nThreads = 4;      
model.opts.useParfor = 1;
model.opts.superpixel = 'mwt';  
model.opts.ribcageMasked = 1;


% %downsampling of CXR
if isfield(imginfo,'ImagerPixelSpacing')
    inputCXR= imresize(originalImg, imginfo.ImagerPixelSpacing(1)/1.4);
elseif isfield(imginfo,'PixelSpacing')
    inputCXR= imresize(originalImg, imginfo.PixelSpacing(1)/1.4); 
else
    inputCXR= imresize(originalImg, [256, 256]); 
end

tic;
% %normalization of intensity
inputCXR = double(inputCXR);
validRange = prctile(inputCXR(:), [1,99]);
inputCXR = mat2gray(inputCXR, validRange);

%perform SEDUCM procedure for lung segmention
for iter=1:10
    [lungMask, boundaryMap, ucmMap, ~, ~] = simplifiedSegCXR_forest(inputCXR, model);
end

segTime = toc;
fprintf('size of input CXR: %d x %d\n', size(inputCXR,1), size(inputCXR,2));
fprintf('average running time of SEDUCM for one CXR: %2.4f second. \n', segTime/10);


%show segmentation results
bdry = seg2bmap(lungMask);
R = uint8(mat2gray(inputCXR)*255);
G = R;
B = R;
R(bdry)  = 255;
G(bdry)  = 0;
B(bdry)  = 0;

figure
subplot(1,2,1)
imshow(cat(3,R,G,B))
title('lung contours')

subplot(1,2,2)
imshow(1 - boundaryMap, [0, 1]);
title('boundary map by SED')


