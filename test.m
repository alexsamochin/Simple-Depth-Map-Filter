

clear 
close all
clc

tsuL = imread('tsuL.png');
tsuR = imread('tsuR.png');

%% Disparity calculation
[dispMap, timeTaken]=denseMatch('tsuR.png', 'tsuL.png', 9, 0, 16, 'SAD');

figure, imagesc(dispMap); axis image

%% Disparity filtering
im0 = dispMap(:,1:size(tsuL,2));
del = 10;
im = im0(del:size(im0,1) - del, del:size(im0,2) - del);

x = imhist(uint8(im));
th = 1500;
k = [];
for i = 1:length(x)
    if x(i)>th
        k = [k i-1];    
    end
end

tharea = 150;
dispout = zeros(size(im));
for j = 2:length(k)
    
    layer = im==k(j);
    Labels = bwlabel(layer);
    for n = 1:max(Labels(:))
        layer_n = Labels == n;
        area = sum(layer_n(:));
        if area < tharea
            layer(find(layer_n)) = 0;
        end
    end
    layer = layer*k(j);
    
    dispout = imfill(dispout + layer,'holes');

end

dispfill = dispout;
dispfill(1,:) = max(dispfill(1,:));
dispfill(end-1:end,:) = max(max(dispfill(end-1:end,:)));
dispfill(:,1) = max(dispfill(:,1));
dispfill(:,end-1:end) = max(max(dispfill(:,end-1:end)));
dispfill = imfill(dispfill,'holes');
figure, imagesc(im)
figure, imagesc(dispout)
figure, imagesc(dispfill)

