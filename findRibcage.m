function ribcageMask = findRibcage(img,E)

E = single(E);
%diaphragmMask
[m,n] = size(img);

m0 = round(m/3);
n0 = round(n/3);
grayProfile = img(m0,:);

[vv0,ind] = max(grayProfile(n0:2*n0));
centerPtr = n0 + ind - 1;%intensity peak for spine column

q0 =  round(n0/4);
[vv1,ind] = min(grayProfile(q0:centerPtr));
intenstiyValley0 = ind + q0 - 1;
q1 =  round(n/8);
[vv2,ind] = max(grayProfile(q1:intenstiyValley0));
intenstiyPeak0 = ind + q1 - 1;

[~,ind] = min(grayProfile(centerPtr:n-q0));
intenstiyValley1 = ind + centerPtr - 1;
[~,ind] = max(grayProfile(intenstiyValley1:n-q1));
intenstiyPeak1 = ind + intenstiyValley1 - 1;


R = max(intenstiyPeak1-centerPtr+1,centerPtr-intenstiyPeak0+1);
rMax = 1.4*R;
rMin = 0.5*R;

rBins = 128;
oriBins = 180;
[Rhos,thetas] = meshgrid(rMin:(rMax-rMin)/(rBins-1):rMax,pi:pi/oriBins:2*pi);
[Xi,Yi] = pol2cart(thetas,Rhos);
Xi = single(Xi) + centerPtr; %+ 0.5;
Yi = single(Yi) + m0;% +0.5;

energy0 = E(1:m0,:);
energy0_polar = interp2(energy0,Xi,Yi,'linear');
[Gx,~] = gradient2(energy0_polar);

Gx(isnan(Gx)) = 1e6;
M = padarray(Gx, [0 1],1e6);
[~,optSeamCurve] = findOptSeamMex(M,0.01,1);
optSeamCurve = optSeamCurve + 1;

idx = sub2ind(size(energy0_polar),optSeamCurve(:,1),optSeamCurve(:,2));
xs =  Yi(idx) ;
ys =  Xi(idx);

bw = roipoly(energy0, ys, xs);
% im(energy0); hold on; plot(ys,xs,'r.')

ribcageMask = true(m,n);
ribcageMask(1:m0,:) = bw;

start_ptr = find(bw(end,:),1,'first');
end_ptr = find(bw(end,:),1,'last');


[Gx,~] = gradient2(E);
Gx(m0,start_ptr) = 1e6;
Gx(m0,end_ptr) = -1e6;
Gx(:,1) = -1e6;
Gx(:,n) = 1e6;

lefthalf_energy = -Gx(m0:end,1:centerPtr-16);
M = padarray(lefthalf_energy, [0 1],1e6);
[optSeamMask,optSeamCurve1] = findOptSeamMex(M,0.2,1);
ribcageMask(m0:end,1:centerPtr-16) = optSeamMask>0;


righthalf_energy = Gx(m0:end,centerPtr+16:end);
M = padarray(righthalf_energy, [0 1],1e6);
[optSeamMask,optSeamCurve2] = findOptSeamMex(M,0.2,0);
ribcageMask(m0:end,centerPtr+16:end) =  optSeamMask>0;

%     bdry = seg2bmap(ribcageMask);
%     R = uint8(mat2gray(1-E)*255);
%     G = R;
%     B = R;
%     R(bdry)  = 255;
%     G(bdry)  = 0;
%     B(bdry)  = 0;
%     
%     figure(12); clf; im(cat(3,R,G,B));
%     drawnow;

