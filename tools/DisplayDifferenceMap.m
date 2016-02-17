function DisplayDifferenceMap(diff, mask, range, height, width, figNum)

len = length(diff);
r = zeros(len ,1);
g = zeros(len ,1);
b = zeros(len ,1);

diff = diff/range;
diff(diff>1) = 1;
diff(diff<-1) = -1;

mask = logical(mask);
% + region
r(diff>=0) = 1;
g(diff>=0) = 1-diff(diff>=0);
b(diff>=0) = 1-diff(diff>=0);

% - region
r(diff<=0) = 1+diff(diff<=0);
g(diff<=0) = 1+diff(diff<=0);
b(diff<=0) = 1;

% masked region
r(~mask) = 0;
g(~mask) = 1;
b(~mask) = 0;

r = reshape(r, height, width);
g = reshape(g, height, width);
b = reshape(b, height, width);

displayImg = zeros(height, width,3);
displayImg(:,:,1) = r;
displayImg(:,:,2) = g;
displayImg(:,:,3) = b;
figure(figNum)
imshow(displayImg)

% % bar
% barHeight = 400;
% gap = 2/barHeight;
% halfBarHeight = barHeight/2;
% barWidth = 40;
% barr = [ones(halfBarHeight,1); 1; ((1-gap):-gap:0)'];
% barb = [(0:gap:(1-gap))'; 1; ones(halfBarHeight,1)];
% barg = [(0:gap:(1-gap))'; 1; ((1-gap):-gap:0)'];
% 
% barr = repmat(barr,1,barWidth);
% barb = repmat(barb,1,barWidth);
% barg = repmat(barg,1,barWidth);
% 
% colorBarDisp = zeros(barHeight+1,barWidth,3);
% colorBarDisp(:,:,1) = barr;
% colorBarDisp(:,:,2) = barg;
% colorBarDisp(:,:,3) = barb;
% 
% figure(20000)
% imshow(colorBarDisp);