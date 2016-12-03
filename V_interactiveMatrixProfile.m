% The prototype for interactive matrix profile calculation
% Chin-Chia Michael Yeh 01/26/2016
%
% [matrixProfile, profileIndex, motifIndex, discordIndex] = interactiveMatrixProfile(data, subsequenceLength);
% Output:
%     matrixProfile: matrix porfile of the self-join (vector)
%     profileIndex: matrix porfile index of the self-join (vector)
%     motifIndex: index of the first, second, and third motifs and their associated nearest neighbors when stopped (3x2 cell)
%                +--------------------------------+-------------------------------------------+
%                | pair of index for first motif  | nearest neighbor of the first motif pair  |
%                +--------------------------------+-------------------------------------------+
%                | pair of index for second motif | nearest neighbor of the second motif pair |
%                +--------------------------------+-------------------------------------------+
%                | pair of index for third motif  | nearest neighbor of the third motif pair  |
%                +--------------------------------+-------------------------------------------+
%     discordIndex: index of discords when stopped (vector)
% Input:
%     data: input time series (vector)
%     SubsequenceLength: interested subsequence length (scalar)
%
% Chin-Chia Michael Yeh, Yan Zhu, Liudmila Ulanova, Nurjahan Begum, Yifei Ding, Hoang Anh Dau, 
% Diego Furtado Silva, Abdullah Mueen, and Eamonn Keogh, "Matrix Profile I: All Pairs Similarity 
% Joins for Time Series," ICDM 2016, http://www.cs.ucr.edu/~eamonn/MatrixProfile.html
%

function [matrixProfile] = ...
    V_interactiveMatrixProfile(data,data1, subLen)
%% set trivial match exclusion zone
exclusionZone = round(subLen/2);
% exclusionZone = round(subLen/4);
radius = 2;

%% check input
dataLen = length(data);
dataLen1=length(data1);

if dataLen~=dataLen1
    error('Error: Input length of data is not equal to data1');
end
if subLen > dataLen/2
    error('Error: Time series is too short relative to desired subsequence length');
end
if subLen < 4
    error('Error: Subsequence length must be at least 4');
end

if subLen > dataLen / 20
    %error('Error: subsequenceLength > dataLength/20')
end

if dataLen == size(data, 2)
    data = data';
end

if dataLen1 == size(data1, 2)
    data1 = data1';
end

%% spawn main window
mainWindow.fig = figure('name', 'UCR Interactive Matrix Profile Calculation', ...
    'visible', 'off', 'toolbar', 'none', 'ResizeFcn', @mainResize);

%% add UI element into the window
backColor = get(mainWindow.fig, 'color');
mainWindow.dataAx = axes('parent',mainWindow.fig, 'units', 'pixels');
mainWindow.data1Ax = axes('parent',mainWindow.fig, 'units', 'pixels');

mainWindow.profileAx = axes('parent',mainWindow.fig, 'units', 'pixels');
mainWindow.dataMx = axes('parent',mainWindow.fig, 'units', 'pixels');
%mainWindow.profileSelfAx = axes('parent',mainWindow.fig, 'units', 'pixels');
%mainWindow.minusProfileAx = axes('parent',mainWindow.fig, 'units', 'pixels');



mainWindow.dataText = uicontrol('parent',mainWindow.fig, 'style', 'text',...
    'string', '', 'fontsize', 10, 'backgroundcolor', backColor, ...
    'horizontalalignment', 'left');
mainWindow.profileText = uicontrol('parent',mainWindow.fig, 'style', 'text',...
    'string', 'The best-so-far matrix profile', 'fontsize', 10, ...
    'backgroundcolor', backColor,'horizontalalignment', 'left');

mainWindow.data1Text = uicontrol('parent',mainWindow.fig, 'style', 'text',...
    'string', 'Second data time string', 'fontsize', 10, ...
    'backgroundcolor', backColor,'horizontalalignment', 'left');

% mainWindow.data1Text = uicontrol('parent',mainWindow.fig, 'style', 'text',...
%     'string', '', 'fontsize', 10, 'backgroundcolor', backColor, ...
%     'horizontalalignment', 'left');

mainWindow.mixText = uicontrol('parent',mainWindow.fig, 'style', 'text',...
    'string', 'Diff between data and data1', 'fontsize', 10, ...
    'backgroundcolor', backColor,'horizontalalignment', 'left');


%% modify the properties of the axis
set(mainWindow.dataAx,'xlim',[1, dataLen]);
set(mainWindow.dataAx,'ylim',[-0.05, 1.05]);
set(mainWindow.dataAx,'ytick',[]);
set(mainWindow.dataAx,'ycolor',[1 1 1]);

set(mainWindow.data1Ax,'xlim',[1, dataLen1]);
set(mainWindow.data1Ax,'ylim',[-0.05, 1.05]);
set(mainWindow.data1Ax,'ytick',[]);
set(mainWindow.data1Ax,'ycolor',[1 1 1]);

set(mainWindow.dataMx,'xlim',[1, dataLen1]);
set(mainWindow.dataMx,'ylim',[-0.05, 1.05]);
set(mainWindow.dataMx,'ytick',[]);
set(mainWindow.dataMx,'ycolor',[1 1 1]);


set(mainWindow.profileAx,'xlim',[1, dataLen]);
set(mainWindow.profileAx,'ylim',[0, 2*sqrt(subLen)]);



%% plot data
% dataPlot = zeroOneNorm(data);
% hold(mainWindow.dataAx, 'on');
% plot(1:dataLen, dataPlot, 'r', 'parent', mainWindow.dataAx);
% hold(mainWindow.dataAx, 'off');
% 
% dataPlot1 = zeroOneNorm(data1);
% hold(mainWindow.data1Ax, 'on');
% plot(1:dataLen1, dataPlot1, 'b', 'parent', mainWindow.data1Ax);
% hold(mainWindow.data1Ax, 'off');
% 
% hold(mainWindow.dataMx, 'on');
% plot(1:dataLen, dataPlot, 'r', 'parent', mainWindow.dataMx);
% plot(1:dataLen1, dataPlot1, 'b', 'parent', mainWindow.dataMx);
% hold(mainWindow.dataMx, 'off');

%% locate nan and inf
profileLen = dataLen - subLen + 1;
isSkip = false(profileLen, 1);
for i = 1:profileLen
    if any(isnan(data(i:i+subLen-1))) || any(isinf(data(i:i+subLen-1)))
        isSkip(i) = true;
    end
end
data(isnan(data)|isinf(data)) = 0;

for i = 1:profileLen
    if any(isnan(data1(i:i+subLen-1))) || any(isinf(data1(i:i+subLen-1)))
        isSkip(i) = true;
    end
end
data1(isnan(data1)|isinf(data1)) = 0;
    
%% preprocess for matrix profile
[dataFreq, data2Sum, dataSum, dataMean, data2Sig, dataSig] = ...
    fastfindNNPre(data1, dataLen1, subLen); % change data to data1, data1 is the second B
idxOrder = randperm(profileLen);
matrixProfile = inf(profileLen, 1);
profileIndex = zeros(profileLen, 1);

%% iteratively plot
mainWindow.stopping = false;
mainWindow.discardIdx = [];
set(mainWindow.fig, 'userdata', mainWindow);
%firstUpdate = true;
%timer = tic();
for i = 1:profileLen
    % compute the distance profile
    idx = idxOrder(i);
    if isSkip(idx)
       continue 
    end
    query = data(idx:idx+subLen-1);
    if i == 1
        distanceProfile = fastfindNN(dataFreq, query, dataLen, subLen, ...
            data2Sum, dataSum, dataMean, data2Sig, dataSig);
        distanceProfile = abs(distanceProfile);
    else
        % replace with yan's method
        distanceProfile = fastfindNN(dataFreq, query, dataLen, subLen, ...
            data2Sum, dataSum, dataMean, data2Sig, dataSig);
        distanceProfile = abs(distanceProfile);
    end
    
    % apply skip zone
    distanceProfile(isSkip) = inf;
    
    % apply exclusion zone
    exclusionZoneStart = max(1, idx-exclusionZone);
    exclusionZoneEnd = min(profileLen, idx+exclusionZone);
    distanceProfile(exclusionZoneStart:exclusionZoneEnd) = inf;
    
    % figure out and store the neareest neighbor
    if i == 1
        matrixProfile = distanceProfile;
        profileIndex(:) = idx;
    else
        updatePos = distanceProfile < matrixProfile;
        profileIndex(updatePos) = idx;
        matrixProfile(updatePos) = distanceProfile(updatePos);
    end
    [matrixProfile(idx), profileIndex(idx)] = min(distanceProfile);
    
    % plotting
%     if toc(timer) > 1 || i == profileLen
%         % plot matrix profile
%         if exist('prefilePlot', 'var')
%             delete(prefilePlot);
%         end
%         hold(mainWindow.profileAx, 'on');
%         prefilePlot = plot(1:profileLen, matrixProfile, 'b', 'parent', mainWindow.profileAx);
%         hold(mainWindow.profileAx, 'off');
        
        % remove motif
%         if exist('motifDataPlot', 'var')
%             for j = 1:2
%                 delete(motifDataPlot(j));
%             end
% %         end
%         if exist('discordPlot', 'var')
%             for j = 1:length(discordPlot)
%                 delete(discordPlot(j));
%             end
% %         end
%         if exist('motifMotifPlot', 'var')
%             for j = 1:3
%                 for k = 1:2
%                     for l = 1:length(motifMotifPlot{j, k})
%                         delete(motifMotifPlot{j, k}(l));
%                     end
%                 end
%             end
%         end
        
        % apply discard
%         mainWindow = get(mainWindow.fig, 'userdata');
%         discardIdx = mainWindow.discardIdx;
%         matrixProfileTemp = matrixProfile;
%         for j = 1:length(discardIdx)
%             discardZoneStart = max(1, discardIdx(j)-exclusionZone);
%             discardZoneEnd = min(profileLen, discardIdx(j)+exclusionZone);
%             matrixProfileTemp(discardZoneStart:discardZoneEnd) = inf;
%             matrixProfileTemp(abs(profileIndex - discardIdx(j)) < exclusionZone) = inf;
%         end
             
        % update process
%         set(mainWindow.dataText, 'string', ...
%             sprintf('We are %.1f%% done: The input time series: The best-so-far motifs are color coded (see bottom panel)', i*100/profileLen));
% %         set(mainWindow.discordText, 'string', ...
% %             sprintf('The top three discords %d(blue), %d(red), %d(green)', discordIdx(1), discordIdx(2), discordIdx(3)));
%         
%         % show the figure
%         if firstUpdate
%             set(mainWindow.fig, 'userdata', mainWindow);
%             set(mainWindow.fig, 'visible', 'on');
%             firstUpdate = false;
%         end
        
        % check for stop
%         mainWindow = get(mainWindow.fig, 'userdata');
%         %mainWindow.motifIdxs = motifIdxs;
%         set(mainWindow.fig, 'userdata', mainWindow);
%         if mainWindow.stopping
%             set(mainWindow.fig, 'name', 'UCR Interactive Matrix Profile Calculation (Stopped)');
%             return;
%         end
%         if i == profileLen
%             set(mainWindow.fig, 'name', 'UCR Interactive Matrix Profile Calculation (Completed)');
%             return;
%         end
        
       % pause(0.01);
       % timer = tic();
    %end
end





%% The following two functions are modified from the code provided in the following URL
%  http://www.cs.unm.edu/~mueen/FastestSimilaritySearch.html
function [dataFreq, data2Sum, dataSum, dataMean, data2Sig, dataSig] = ...
    fastfindNNPre(data, dataLen, subLen)
data(dataLen+1:2*dataLen) = 0;
dataFreq = fft(data);
cum_sumx = cumsum(data);
cum_sumx2 =  cumsum(data.^2); % square every elements in matrix square
data2Sum = cum_sumx2(subLen:dataLen)-[0;cum_sumx2(1:dataLen-subLen)];
dataSum = cum_sumx(subLen:dataLen)-[0;cum_sumx(1:dataLen-subLen)];
dataMean = dataSum./subLen;
data2Sig = (data2Sum./subLen)-(dataMean.^2);
dataSig = sqrt(data2Sig);

function distanceProfile = fastfindNN(dataFreq, query, dataLen, subLen, ...
    data2Sum, dataSum, dataMean, data2Sig, dataSig)
query = (query-mean(query))./std(query,1);
query = query(end:-1:1);
query(subLen+1:2*dataLen) = 0;
queryFreq = fft(query);
dataQueryProdFreq = dataFreq.*queryFreq;
dataQueryProd = ifft(dataQueryProdFreq);
querySum = sum(query);
query2Sum = sum(query.^2);
distanceProfile = (data2Sum - 2*dataSum.*dataMean + subLen*(dataMean.^2))./data2Sig ...
    - 2*(dataQueryProd(subLen:dataLen) - querySum.*dataMean)./dataSig + query2Sum;
distanceProfile = sqrt(distanceProfile);

function x = zeroOneNorm(x)
x = x-min(x(~isinf(x) & ~isnan(x)));
x = x/max(x(~isinf(x) & ~isnan(x)));

function mainResize(src, ~)
mainWindow = get(src, 'userdata');
figPosition = get(mainWindow.fig, 'position');
axGap = 38;
axesHeight = round((figPosition(4)-axGap*5-60)/4);

set(mainWindow.dataAx, 'position', [30, 3*axesHeight+3*axGap+30, figPosition(3)-160, axesHeight]);
set(mainWindow.data1Ax, 'position', [30, 2*axesHeight+2*axGap+30, figPosition(3)-160, axesHeight]);
set(mainWindow.dataMx, 'position', [30, 1*axesHeight+1*axGap+30, figPosition(3)-160, axesHeight]);
set(mainWindow.profileAx, 'position', [30, 30, figPosition(3)-160, axesHeight]);

set(mainWindow.dataText, 'position', [30, 4*axesHeight+3*axGap+30, figPosition(3)-160, 18]);
set(mainWindow.data1Text, 'position', [30, 3*axesHeight+2*axGap+30, figPosition(3)-160, 18]);
set(mainWindow.mixText, 'position', [30, 2*axesHeight+1*axGap+30, figPosition(3)-160, 18]);
set(mainWindow.profileText, 'position', [30, 1*axesHeight+30, figPosition(3)-160, 18]);