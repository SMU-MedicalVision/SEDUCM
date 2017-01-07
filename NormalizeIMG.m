function I = NormalizeIMG(filename)

originalImg = ReadImgImage(filename, 2048, 2048);
originalImg = 4095-originalImg;
    
I = imresize(originalImg,[256 256]);
    
bw = I>1000;
[tt,x_centers] = hist(I(bw),1024);
tt = cumsum(tt)./sum(tt);
idx = find(tt>=0.01,1,'first');
adjustedminv = x_centers(idx);
idx = find(tt>=0.98,1,'first');
adjustedmaxv = x_centers(idx);

I = mat2gray(I,[adjustedminv,adjustedmaxv]);

 
 