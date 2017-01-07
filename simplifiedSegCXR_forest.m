function [lungfield, E0, U, segmentNum, E] = simplifiedSegCXR_forest(img,model)

img = single(img);

baselayer = guidedfilter_fast(img, img, 8, 0.1);
detailenhancedLayer = img - baselayer;
detailenhancedLayer = detailenhancedLayer - mean2(detailenhancedLayer);
detailenhancedLayer = detailenhancedLayer./std2(detailenhancedLayer);
baselayer = baselayer - mean2(baselayer);
baselayer = baselayer./std2(baselayer);
baselayer = single(baselayer);
detailenhancedLayer = single(detailenhancedLayer);

I = cat(3,detailenhancedLayer,baselayer);

[E,~,~,segs] = edgesDetect(I,model); 
if model.opts.multiscale
    segs = segs{2};
end
E0 = E;

E = convTri(E,1);

baselayer = convTri(baselayer, 8);
sz = size(img);
x0 = round(sz(2)/3);
y0 = round(sz(1)/3);
gray_sum = sum( baselayer(y0:end,x0:2*x0) );
[~,ind] = max(gray_sum);
half_ptr = x0 + ind - 1;

% %detect spine column
gray_sum = sum( baselayer(1:y0,x0:2*x0) );
[~,ind] = max(gray_sum);
half_ptr0 = x0 + ind - 1;

M = 1 - baselayer + E;
M(1,half_ptr0) = -1e6;
M(end,half_ptr) = -1e6;
[~,ind] = max(baselayer(y0,x0:2*x0));
M(y0,ind+x0-1) = -1e6;
M = padarray(M, [0 1],1e6);
[spineMask,optSeamCurve] = findOptSeamMex(M,0.3,1);
spineMask = spineMask>0;
optSeamCurve = optSeamCurve + 1;


bw0 = false(sz);
bw0(sub2ind(sz,optSeamCurve(:,1),optSeamCurve(:,2))) = 1;
SE= strel('disk',2);
bw0 = ~imdilate(bw0,SE); %spine mask 

if model.opts.ribcageMasked
    % % find ribcage
    ribcageMask = findRibcage(baselayer,E);
    SE = strel('disk',3);
    ribcageMask = imdilate(ribcageMask,SE);

%     %botton edge of lung field
    E_profile = sum(convBox(E,8).*ribcageMask,2);
    y0 = round(0.5*sz(1));
    [~,ind] = min(E_profile(y0:end));
    E_peak1 = ind + y0 - 1 + 4;
    E_peak1 = min(E_peak1,sz(2));
    bw0(E_peak1:end,:) = 0;

    bw =  ribcageMask & bw0;% & convBox(E, 8)>0.01;
    bw(1:2,:) = 0;
    bw(end-1:end,:) = 0;
    bw(:,1) = 0;
    bw(:,end) = 0;
    
    E(~bw) = 0; %masked out
else
    E(~bw0) = 0; %masked out
end

sp_opts = spDetect1;
sp_opts.type = model.opts.superpixel; %watershed %sticky %w
sp_opts.nThreads = model.opts.nThreads;  % number of computation threads
sp_opts.k = 800;       % controls scale of superpixels (big k -> big sp)
sp_opts.alpha = .5;    % relative importance of regularity versus data terms
sp_opts.beta = .9;     % relative importance of edge versus color terms
sp_opts.merge = 0;     % set to small value to merge nearby superpixels at end                                      

S = spDetect1(img,E,sp_opts); 
% % S = uint32(watershed(E)); 
segmentNum = max(max(S));


% % compute ultrametric contour map from superpixels (see spAffinities.m)
[~,~,U] = spAffinities(S,E,segs,sp_opts);


rightU = U.*spineMask;
U_thresh = max(U(spineMask));
[rightLung, numSP] = bwlabel(rightU<U_thresh);
rightLung = rightLung==numSP;


spineMask = ~spineMask;
leftU = U.*spineMask;
U_thresh = max(U(spineMask));
[leftLung, numSP] = bwlabel(leftU<U_thresh);
leftLung = leftLung==numSP;


lungfield = rightLung | leftLung;
SE = strel('disk',1);
lungfield = imdilate(lungfield,SE);

