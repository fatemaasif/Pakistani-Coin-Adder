%%%% 1. Synthesizing image 

% coin filter size (to be used in Steps 1 and 2)
filtsize = 85;

% Creating test image 'im' by converting image from camera to 2D matrix
% A rectangular border of 0s added around image 
% width = 0.5 x filter size - known as zero-padding 
% to center filter pixel on test image pixel
% coins are kept on dark green background

im1 = imread('1.jpeg');
converted_im = rgb2gray(im1);
[r,c] = size(converted_im);
im = zeros(r+filtsize,c+filtsize);
filtsizeh = floor(filtsize/2);
im(filtsizeh+1:filtsizeh+r,filtsizeh+1:filtsizeh+c) = converted_im;
[r,c] = size(im);
imagesc(im);colormap(gray);title('test image');axis equal;

% Masking with Otsu threshold function (created in seperate file)
mask = OtsuThreshold(im);
figure; imagesc(mask); colormap(gray); title('Otsu'); axis equal;

% Dilate 9x9
mask_dilated = imdilate(mask,ones(9,9));
figure; imagesc(mask_dilated); colormap(gray); title('Dilated'); axis equal;

% Erode 23x23
mask_eroded = imerode(mask_dilated,ones(23,23));
figure; imagesc(mask_eroded); colormap(gray); title('Eroded'); axis equal;

%%%%% 2. Measuring features for the coins 

% Finding coin centroids and size from 
connectedComps = bwconncomp(mask_eroded);
regionProperties = regionprops(connectedComps);
regionCentroid = zeros(length(regionProperties),2);
componentSize = zeros(length(regionProperties),1);
for i=1:length(regionProperties)
    regionCentroid(i,:) = round(regionProperties(i).Centroid);
    componentSize(i) = regionProperties(i).Area;
end

% make matching filters to create features
% Define diameters to use for filters
fiverupeediameter = 21;   
tenrupeediameter = 51;   
tworupeediameter = 41;  

% Use the MakeCircleMatchingFilter function to create matching filters for
% Rs.2, Rs.5 and Rs.10 coin 
% MakeCircleMatchingFilter function created in seperate file
fiverupeefilter = MakeCircleMatchingFilter(fiverupeediameter, filtsize);
tenrupeefilter = MakeCircleMatchingFilter(tenrupeediameter,filtsize);
tworupeefilter = MakeCircleMatchingFilter(tworupeediameter,filtsize);

figure;
subplot(1,3,1); imagesc(fiverupeefilter); colormap(gray); title('Rs. 5 filter'); axis tight equal;
subplot(1,3,2); imagesc(tworupeefilter); colormap(gray); title('Rs. 2 filter'); axis tight equal;
subplot(1,3,3); imagesc(tenrupeefilter); colormap(gray); title('Rs. 10 filter'); axis tight equal;

% Evaluate each of the 3 matching filters on each coin to serve as 3 feature measurements 
D = zeros(size(regionCentroid, 1), 3);
for i = 1:size((regionCentroid),1)
    x_cord = regionCentroid(i,2);
    y_cord = regionCentroid(i,1);
    correlation_vector = reshape(mask_eroded(x_cord-filtsizeh:x_cord+filtsizeh,y_cord-filtsizeh:y_cord+filtsizeh), [filtsize^2,1]);
    D(i,1) = corr(fiverupeefilter(:), correlation_vector);
    D(i,2) = corr(tenrupeefilter(:), correlation_vector);
    D(i,3) = corr(tworupeefilter(:), correlation_vector);
end

%%%%% 3. Coin segmentation 

% random number generator set to 0 for same mapping on every execution 
rng(0); 

%Perform k-means clustering of features for unsupervised learning classifier
[cls_init,C] = kmeans(D,3);

% relabel centroid classes based on average size of the objects in each
% class. smallest will be Rs.5, next Rs.2, and largest Rs.10
class_ave_object_size = zeros(3,1);
component1count = 0; component2count = 0; component3count = 0;
for i = 1:size(cls_init,1)
    if cls_init(i) == 1
        class_ave_object_size(1) = class_ave_object_size(1) + componentSize(i);
        component1count = component1count + 1;
    elseif cls_init(i) == 2
        class_ave_object_size(2) = class_ave_object_size(2) + componentSize(i);
        component2count = component2count + 1;
    else
        class_ave_object_size(3) = class_ave_object_size(3) + componentSize(i);
        component3count = component3count + 1;
    end
end
class_ave_object_size(1) = round(class_ave_object_size(1)/component1count);
class_ave_object_size(2) = round(class_ave_object_size(2)/component2count);
class_ave_object_size(3) = round(class_ave_object_size(3)/component3count);

[A, classmap] = sort(class_ave_object_size);

cls = zeros(size(cls_init,1),1);
for i = 1:size(cls_init,1)
    if cls_init(i) == classmap(1)
        cls(i)=1;
    elseif cls_init(i) == classmap(2)
        cls(i)=2;
    elseif cls_init(i) == classmap(3)
        cls(i)=3;
    end
end

% Visualize the result
figure; imagesc(im);colormap(gray); title('Test Image'); hold on; axis equal;

% plot circles around each coin with different color/diameter unique to
% each type and count the change - function created in seperate file
totcount = 0;
for i = 1:size(cls,1)
    x = regionCentroid(i,1);
    y = regionCentroid(i,2);
    [coin_val] = AddCoinToPlotAndCount(x,y,cls(i));
    totcount = totcount + coin_val;
end
title([num2str(totcount),' Rupees'])
