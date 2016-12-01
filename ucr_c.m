TRAIN = load('UEA_data/Coffee/Coffee_TRAIN'); 
TEST= load('UEA_data/Coffee/Coffee_TEST');
data1=TRAIN(1,2:287);
data2=TRAIN(28,2:287);
data3=TRAIN(8,2:287);
data18=TRAIN(18,2:287);
data25=TRAIN(21,2:287);


x=1:286;
plot(x,data1,'-b',x,data2,'-y',x,data3,'-r',x,data18,'-k',x,data25,'-g');


%%

subLen=25;
[matrixProfile, profileIndex] = V_interactiveMatrixProfile(data1,data18, subLen);

%%
[matrixProfileSelf, profileIndexSelf] =  V_interactiveMatrixProfile(data1,data1, subLen);
%%
%plot minus
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
