clc; clear all; close all;
I_orig = (imread('../images/49.png'));

if (size(I_orig, 3)>1)
    I = rgb2gray(I_orig);
else
    I = I_orig;
end
    
figure, imshow(I);

hy = fspecial('sobel');
hx = hy';
Iy = imfilter(double(I), hy, 'replicate');
Ix = imfilter(double(I), hx, 'replicate');
gradmag = sqrt(Ix.^2 + Iy.^2);


se = strel('disk', 20);
Io = imopen(I, se);


Ie = imerode(I, se);
Iobr = imreconstruct(Ie, I);


Ioc = imclose(Io, se);


Iobrd = imdilate(Iobr, se);
Iobrcbr = imreconstruct(imcomplement(Iobrd), imcomplement(Iobr));
Iobrcbr = imcomplement(Iobrcbr);


fgm_gray = (imread('../images/49_msk.png'));
fgm_ = im2bw(fgm_gray, 0.1);
fgm = fgm_;
% fgm = imcomplement(fgm_);

%fgm = imread('../images/50_msk.png');

I2 = I;
I2(fgm) = 255;

se2 = strel(ones(5,5));
fgm2 = imclose(fgm, se2);
fgm3 = imerode(fgm2, se2);

fgm4 = bwareaopen(fgm3, 20);
I3 = I;
I3(fgm4) = 255;

bw = im2bw(Iobrcbr, graythresh(Iobrcbr));

D = bwdist(bw);
DL = watershed(D);
bgm = DL == 0;


gradmag2 = imimposemin(gradmag, bgm | fgm4);
L = watershed(gradmag2);

I4 = I;
I4(imdilate(L == 0, ones(3, 3)) | bgm | fgm4) = 255;
figure
imshow(I4)
title('Markers and object boundaries superimposed on original image (I4)')

Lrgb = label2rgb(L, 'jet', 'w', 'shuffle');
figure
imshow(Lrgb)
title('Colored watershed label matrix (Lrgb)')


min_label = min(L(:));
max_label = max(L(:));
numLabel = max_label - min_label + 1;
masks = zeros(size(I, 1), size(I, 2), numLabel);

s = regionprops(L, I, 'FilledImage', 'BoundingBox');

imfinal = [];
old = 1;

for i=2:max_label
     B = (L==i);
     im_new = I_orig .* repmat(uint8(B), [1,1,3]);
     cropped = imcrop(im_new, s(i).BoundingBox);
     desiredResult(1: size(cropped, 1) , old: (old -1 + size(cropped, 2))) = cropped;
     old = old + size(cropped, 2);
     imwrite(cropped, sprintf('../results_tooth/cropped%02d.png', i));
end

imwrite(desiredResult, '../results_tooth/final.png');

%s = regionprops(L, I, 'FilledImage', 'BoundingBox');
%imshow(s(4).FilledImage);

%s = regionprops(L, I, 'BoundingBox');
%imshow(s(4).FilledImage);

% imshow(I_orig)
% hold on
% for i=2:max_label
%     rectangle('Position', s(i).BoundingBox, 'EdgeColor','r', 'LineWidth', 3);
% end
% 
% for i=2:max_label
%     cropped = imcrop(I_orig, s(i).BoundingBox);
%     
% %     %%%%%%%%%%%%%%%%%%%%%%%%%%
% %     masking = (s(i).FilledImage);
% %     
% %     % Create 3 channel mask
% %     mask_three_chan = repmat(masking, [1, 1, 3]);
% % 
% %     % Apply Mask
% %     cropped(~mask_three_chan) = 0;
% %     %%%%%%%%%%%%%%%%%%%%%%%%%%
% %     
%     imwrite(cropped,sprintf('../results_tooth/cropped%02d.png', i)); 
% end

