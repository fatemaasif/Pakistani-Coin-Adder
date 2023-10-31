function [coinvalue,x_plot,y_plot,col] = AddCoinToPlotAndCount(x,y,cls)
% initialize radians for defining x_plot and y_plot using cos and sin functions
rads = 0:2*pi/32:2*pi;
% initialize parameters for radius and color of circle for each type of coin
fiverupee_radius = 40;
fiverupee_color = 'r';
tworupee_radius = 44;
tworupee_color = 'g';
tenrupee_radius = 55;
tenrupee_color = 'm';
% use if-elseif statement to define x_plot, y_plot, col
%   when cls is 1, we found a one rupee
%   when cls is 2, we found a five rupee
%   when cls is 3, we found a two rupee
if cls == 1
    coinvalue = 5;
    col = fiverupee_color;
    x_plot = fiverupee_radius*cos(rads)+x;
    y_plot = fiverupee_radius*sin(rads)+y;
elseif cls == 2
    coinvalue = 2;
    col = tworupee_color;
    x_plot = tworupee_radius*cos(rads)+x;
    y_plot = tworupee_radius*sin(rads)+y;
else
    coinvalue = 10;
    col = tenrupee_color;
    x_plot = tenrupee_radius*cos(rads)+x;
    y_plot = tenrupee_radius*sin(rads)+y;
end
plot(x_plot,y_plot,col);
end