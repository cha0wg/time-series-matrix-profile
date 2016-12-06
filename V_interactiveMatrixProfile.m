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
% radius = 2;

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

