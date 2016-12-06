function plotDiffMatrix(Y1)
%CREATEFIGURE(Y1)
%  Y1:  y 数据的矢量

%  由 MATLAB 于 05-Dec-2016 15:43:52 自动生成

% 创建 figure
figure1 = figure;

% 创建 axes
axes1 = axes('Parent',figure1,...
    'Position',[0.0189764232317424 0.11 0.968947671075331 0.815]);
hold(axes1,'on');

% 创建 plot
plot(Y1);

% 取消以下行的注释以保留坐标轴的 X 范围
 xlim(axes1,[0 265]);
view(axes1,[0.399999999999977 90]);
box(axes1,'on');
% 设置其余坐标轴属性
set(axes1,'XGrid','on','XMinorTick','on','XTick',...
    [0 5 10 15 20 25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100 105 110 115 120 125 130 135 140 145 150 155 160 165 170 175 180 185 190 195 200 205 210 215 220 225 230 235 240 245 250 255 260 265],...
    'YGrid','on','YMinorTick','on');
