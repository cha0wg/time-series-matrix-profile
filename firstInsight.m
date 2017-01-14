TRAIN=sortrows(TRAIN,1);
TEST=sortrows(TEST,1);

%% set class from 0
if TRAIN(1,1)==1
    for i=1:size(TRAIN,1)
        TRAIN(i,1)=TRAIN(i,1)-1;
    end
end

if TEST(1,1)==1
    for i=1:size(TEST,1)
        TEST(i,1)=TEST(i,1)-1;
    end
end

%% plot train
figure
hold on

l = length(TRAIN(1,2:size(TRAIN,2)));
% Rplot(1:l, TRAIN(19,2:l+1), 'r');
 plot(1:l, TRAIN(4,2:l+1), 'm');
plot(1:l, TRAIN(5,2:l+1), 'b');
plot(1:l, TRAIN(6,2:l+1), 'g');
 plot(1:l, TRAIN(7,2:l+1), 'y');


%% 
subLen=15;
tic
data1=TRAIN(4,2:size(TRAIN,2));
data15=TRAIN(12,2:size(TRAIN,2)); 


[matrixProfile] = V_interactiveMatrixProfile(data1,data15, subLen);


[matrixProfileSelf] =  V_interactiveMatrixProfile(data1,data1, subLen);
toc

%%
%plot minus information 

diffMatrixProfile=matrixProfile-matrixProfileSelf;
posDiffMatrixProfile=abs(diffMatrixProfile);
dataLen = length(data1);
profileLen = dataLen - subLen + 1;

figure
subplot(4,1,1)
hold on
plot(1:dataLen, data1, 'r');
plot(1:dataLen, data15, 'b');

subplot(4,1,2)
hold on
plot(1:profileLen, matrixProfile, 'r');
plot(1:profileLen, matrixProfileSelf, 'b');

subplot(4,1,3)
plot(1:profileLen, diffMatrixProfile, 'b');

subplot(4,1,4)
plot(1:profileLen, posDiffMatrixProfile, 'b');

%% plot test
plotDiffMatrix(posDiffMatrixProfile);

%% 
figure
hold on

l = length(finstance(1,2:size(finstance,2)));
plot(1:l, finstance(1,2:l+1), 'r');
plot(1:l, finstance(2,2:l+1), 'm');
plot(1:l, finstance(3,2:l+1), 'b');
plot(1:l, finstance(6,2:l+1), 'g');
plot(1:l, finstance(12,2:l+1), 'y');