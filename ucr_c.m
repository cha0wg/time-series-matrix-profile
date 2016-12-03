TRAIN = load('UEA_data/Coffee/Coffee_TRAIN'); 
TEST= load('UEA_data/Coffee/Coffee_TEST');

TRAIN=sortrows(TRAIN,1);


%%
subLen=25;


numcls=unique(TRAIN(:,1));
len=length(numcls);
B=cell(len,1);
for i=1:len
    index=(TRAIN(:,1)==numcls(i));
    B{i}=TRAIN(index,:);
end

diffMatrix=[];


for i=1:len-1  % find group
    for j=2:len  % find second group
        for firstIndex=1:size(B{i},1) %data len in 1 group
              data=B{i}(firstIndex,2:size(B{i},2));
              [matrixProfileSelf] = V_interactiveMatrixProfile(data,data, subLen);
            for secondIndex=1:size(B{j},1)  %data len in 2 group
                 data1=B{j}(secondIndex,2:size(B{j},2));
                 [matrixProfile] = V_interactiveMatrixProfile(data,data1, subLen);
                 posDiffMatrixProfile=abs(matrixProfile-matrixProfileSelf);
                 diffMatrix=[diffMatrix;posDiffMatrixProfile.'];
            end
        end
    end
end

%%
subLen=25;
data1=TRAIN(1,2:287);
data18=TRAIN(20,2:287);


[matrixProfile] = V_interactiveMatrixProfile(data1,data18, subLen);


[matrixProfileSelf] =  V_interactiveMatrixProfile(data1,data1, subLen);

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
plot(1:dataLen, data18, 'b');

subplot(4,1,2)
hold on
plot(1:profileLen, matrixProfile, 'r');
plot(1:profileLen, matrixProfileSelf, 'b');

subplot(4,1,3)
plot(1:profileLen, diffMatrixProfile, 'b');

subplot(4,1,4)
plot(1:profileLen, posDiffMatrixProfile, 'b');
