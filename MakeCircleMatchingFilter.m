function [filter,xc,yc] = MakeCircleMatchingFilter(diameter,W)
% initialize filter
filter = zeros(W,W);
% define coordinates for the center of the WxW filter
xc = (W+1)/2;
yc = (W+1)/2;
r = diameter/2;
% Use double-for loops to check if each pixel lies in the foreground of the circle
for i = 1:W
    for j = 1:W
        if(sqrt((i-xc)^2+(j-yc)^2)<=r)
            filter(i,j) = 1;
        end
    end
end
end