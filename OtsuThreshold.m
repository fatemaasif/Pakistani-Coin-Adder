function [msk,thrsh] = OtsuThreshold(img)
% Define the Otsu threshold 'thrsh' using the histogram of img
hist = imhist(img);
thrsh = otsuthresh(hist)*255;
% Apply the threshold to 'img' to make 'msk'
msk = img>thrsh;
end