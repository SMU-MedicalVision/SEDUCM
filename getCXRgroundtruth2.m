function [ img, gt, img0,mask,originalImg] = getCXRgroundtruth2( imind,trnGtDir,pixelresolution)

trnImgDir = 'ImageData\JSRT Chest X-Ray\All247images\';
imgIds = dir([trnGtDir 'left lung\*.gif']);
num_img = length(imgIds);

if imind<=num_img
    [img,mask,originalImg] = NormalizeIMG([trnImgDir imgIds(imind).name(1:end-4) '.img']);
    img = imresize(img,0.5);
    img = single(img);
    img(img<0) = 0;
    mask = imresize(mask,0.5);
    mask = mask>=0.5;
    img0 = img;
    
    reflable1 = imread([trnGtDir 'left lung\' imgIds(imind).name]);
    reflable2 = imread([trnGtDir 'right lung\' imgIds(imind).name]);
    if pixelresolution == 1
        reflable1 =  imresize( mat2gray( double(reflable1)),0.25);
        reflable2 =  imresize( mat2gray( double(reflable2)), 0.25);
    elseif pixelresolution == 2
        reflable1 =  imresize( mat2gray( double(reflable1)),0.125);
        reflable2 =  imresize( mat2gray( double(reflable2)), 0.125);
    end
    
    reflable1 = reflable1>=0.5;
    reflable1 = bwareaopen(reflable1,10);
    reflable2 = reflable2>=0.5;
    reflable2 = bwareaopen(reflable2,10);
    Segmentation = uint8( reflable1 + 2*reflable2 );

    % Boundaries = seg2bdry(Segmentation);
    Boundaries = seg2bmap(Segmentation);
    gt = cell(1);
    gt{1}.Segmentation = Segmentation;
    gt{1}.Boundaries = Boundaries;

% %     img1 = guidedfilter(img, img, 4, 0.0001);
%     baselayer = guidedfilter(img, img, 8, 0.1);
     baselayer = guidedfilter_fast(img, img, 8, 0.1);
    detailenhancedLayer = img - baselayer;
%     mask = img>0;
    detailenhancedLayer = detailenhancedLayer - mean2(detailenhancedLayer);
    detailenhancedLayer = detailenhancedLayer./std(detailenhancedLayer(:));
%     detailenhancedLayer = single( mat2gray(detailenhancedLayer,[-3 3]) );
    baselayer = baselayer - mean2(baselayer);
    baselayer = baselayer./std(baselayer(:));
%     baselayer = single( mat2gray(baselayer,[-3 3]) );


   if pixelresolution == 2
      img0 = imresize(img0,0.5);
      detailenhancedLayer = imresize(detailenhancedLayer,0.5);
      baselayer = imresize(baselayer,0.5);  
      mask = imresize(mask,0.5);  
      mask = mask>=0.5;
    end
    img = cat(3,single(detailenhancedLayer),single(baselayer));
else
    n = floor(imind./num_img);
    imind = mod(imind,num_img);
    if imind<1
       imind =  num_img;
    end

    oris = [-5 -2.5 2.5 5];
    
    [img,mask,originalImg] = NormalizeIMG([trnImgDir imgIds(imind).name(1:end-4) '.img']);

     img = single(img);
    reflable1 = imread([trnGtDir 'left lung\' imgIds(imind).name]);
    reflable2 = imread([trnGtDir 'right lung\' imgIds(imind).name]);
    reflable1 =  imresize( mat2gray( double(reflable1)),0.5);
    reflable2 =  imresize( mat2gray( double(reflable2)), 0.5);
    
    temp = cat(3,single(img),single(mask),single(reflable1),single(reflable2));
    
    rndAngle = 10*(rand(1)-0.5);
    rndSz= round(512*[0.5*(1 + 0.2*(rand(1)-0.5))  0.5*(1 + 0.2*(rand(1)-0.5))]);
    img = imrotate(img,rndAngle,'crop');
    img = imresize(img,rndSz);
    mask = imrotate(single(mask),rndAngle,'crop');
    mask = imresize(mask,rndSz);
    reflable1 = imrotate(reflable1,rndAngle,'crop');
    reflable1 = imresize(reflable1,rndSz);
    reflable2 = imrotate(reflable2,rndAngle,'crop');
    reflable2 = imresize(reflable2,rndSz);
    
    if pixelresolution == 2
        reflable1 =  imresize( mat2gray( double(reflable1)),0.5);
        reflable2 =  imresize( mat2gray( double(reflable2)), 0.5);
    end
    
%     figure(20);im(img);title(num2str(imind));drawnow;
    
    mask = mask>=0.5;
    
    img(img<0) = 0;
    reflable1 = reflable1>=0.5;
    reflable1 = bwareaopen(reflable1,10);
    reflable2 = reflable2>=0.5;
    reflable2 = bwareaopen(reflable2,10);
    Segmentation = uint8( reflable1 + 2*reflable2 );
    
     img0 = img;
    
    baselayer = guidedfilter_fast(img, img, 8, 0.1);
    detailenhancedLayer = img - baselayer;
    detailenhancedLayer = detailenhancedLayer - mean2(detailenhancedLayer);
    detailenhancedLayer = detailenhancedLayer./std(detailenhancedLayer(:));
%     detailenhancedLayer = single( mat2gray(detailenhancedLayer,[-3 3]) );
    baselayer = baselayer - mean2(baselayer);
    baselayer = baselayer./std(baselayer(:));
%     baselayer = single( mat2gray(baselayer,[-3 3]) );
    
    if pixelresolution == 2
      img0 = imresize(img0,0.5);
      detailenhancedLayer = imresize(detailenhancedLayer,0.5);
      baselayer = imresize(baselayer,0.5);  
      mask = imresize(mask,0.5);  
      mask = mask>=0.5;
    end
    img = cat(3,single(detailenhancedLayer),single(baselayer));  

    Boundaries = seg2bmap(Segmentation);
    gt = cell(1);
    gt{1}.Segmentation = Segmentation;
    gt{1}.Boundaries = Boundaries;
    
end

end

