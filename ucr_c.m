%% sort TRAIN and TEST by class
TRAIN=sortrows(TRAIN,1);
TEST=sortrows(TEST,1);


%%set class from 0
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
%% reshape train body
TRAIN1=TRAIN;

mthres=9;

tic
mlen=size(TRAIN,2);
numcls=unique(TRAIN(:,1));
len=length(numcls);


newtrain=[];

for i=0:len-1
    fclass=TRAIN(:,1)==i;
    finstance = TRAIN(fclass,:);
    mnum=size(finstance,1);
    mpos=1:1:mnum;
    while(length(mpos)>1)
        x=finstance(mpos(1),2:mlen);
        dist=[];
        for j=1:length(mpos)
            dist=[dist norm(x-finstance(mpos(j),2:mlen))];
        end
        locate=find(dist<=mthres);
        mpos(locate)=[];
        newtrain=[newtrain;[i x]];
    end
    if(length(mpos)>0)
      newtrain=[newtrain;finstance(mpos(1),1:mlen)];
    end
end

TRAIN=newtrain;

toc
%%
subLen=13;
threshold=0.4;

numcls=unique(TRAIN(:,1));
len=length(numcls);
B=cell(len,1);
for i=1:len
    index=(TRAIN(:,1)==numcls(i));
    B{i}=TRAIN(index,:);
end

%%init diffMatrix

numRow=0;
for i=1:len-1
    for j=i+1:len
        numRow=numRow+size(B{i},1)*size(B{j},1);
    end
end

datalen=size(B{1},2)-1;
diffMatrix=zeros(numRow,datalen - subLen + 3);


%%
tic

% index=1;
% for i=1:len-1  % find group
%     for j=2:len  % find second group
%         for firstIndex=1:size(B{i},1) %data len in 1 group
%               data=B{i}(firstIndex,2:size(B{i},2));
%               [matrixProfileSelf] = V_interactiveMatrixProfile(data,data, subLen);
%             for secondIndex=1:size(B{j},1)  %data len in 2 group
%                  data1=B{j}(secondIndex,2:size(B{j},2));
%                  [matrixProfile] = V_interactiveMatrixProfile(data,data1, subLen);
%                  posDiffMatrixProfile=abs(matrixProfile-matrixProfileSelf);
%                  diffMatrix(index,:)=posDiffMatrixProfile.';
%                  index=index+1;
%             end
%         end
%     end
% end

 index=1;
for i=1:len-1  % find group  
    for firstIndex=1:size(B{i},1) %data len in 1 group
         data=B{i}(firstIndex,2:size(B{i},2));
         [matrixProfileSelf] = V_interactiveMatrixProfile(data,data, subLen);
         for j=i+1:len  % find second group
            for secondIndex=1:size(B{j},1)  %data len in 2 group
                 data1=B{j}(secondIndex,2:size(B{j},2));
                 [matrixProfile] = V_interactiveMatrixProfile(data,data1, subLen);
                 posDiffMatrixProfile=abs(matrixProfile-matrixProfileSelf);
                 tempProfile=[B{i}(firstIndex,1) firstIndex];
                 diffMatrix(index,:)=[tempProfile posDiffMatrixProfile.'];
                 index=index+1;
            end
        end
    end
end

toc
%% pre-generate shapelet
%[m,n]=find(sss>threshold);

index_Class_Instance=cell(len-1,1);
for i=1:len-1
    index_Class_Instance{i}=cell(size(B{i},1),1);
end

% index=1;
% dl= size(diffMatrix,1);
% for i=1:dl
%     temps=find(diffMatrix(i,3:size(diffMatrix,2))>threshold);
%     index_Class_Instance{diffMatrix(i,1)+1}{diffMatrix(i,2)}=...
%     [index_Class_Instance{diffMatrix(i,1)+1}{diffMatrix(i,2)} temps];
% end


for i=1:size(index_Class_Instance,1)
    for j=1:size(index_Class_Instance{i},1)
         class=diffMatrix(:,1)==i-1;
         instance = diffMatrix(class,:);
         cii=instance(:,2)==j;
         pcim=instance(cii,:);
         cim=pcim(:,3:size(pcim,2));
         insnum=size(cim,1);
         cim=sum(cim);
         cim=cim/insnum;
         m=find(cim>threshold);
         index_Class_Instance{i}{j}=m;
    end
end

%%index_Class_Instance adjust shape size

index_Class_Instance_adj=index_Class_Instance;
index_Class_Instance_length=index_Class_Instance;

step=1;
for i=1:size(index_Class_Instance,1)
    for j=1:size(index_Class_Instance{i},1)
        temp=index_Class_Instance{i}{j};
        if length(temp)>0
            r_len=[subLen];
            r_d=[temp(1)];
            for x=2:size(temp,2)
                if(temp(x)-temp(x-1)<=step)
                    r_len(size(r_len,2))=r_len(size(r_len,2))+temp(x)-temp(x-1);
                else
                    r_d=[r_d temp(x)];
                    r_len=[r_len subLen];
                end
            end
            index_Class_Instance_adj{i}{j}=r_d;
            index_Class_Instance_length{i}{j}=r_len;
        else
             index_Class_Instance_adj{i}{j}=temp;
             index_Class_Instance_length{i}{j}=[];
        end
    end
end


%%generate shapelet

slen=0;
for i=1:size(index_Class_Instance_adj,1)
    for j=1:size(index_Class_Instance_adj{i},1)
        slen=slen+length(index_Class_Instance_adj{i}{j});
    end
end

shapelet=cell(slen,1);
sindex=zeros(slen,1);

index=1;
for i=1:size(index_Class_Instance_adj,1)
    tclass=TRAIN(:,1)==i-1;
    tins = TRAIN(tclass,:);
    tins=tins(:,2:size(tins,2));
    for j=1:size(index_Class_Instance_adj{i},1)      
        for x=1:length(index_Class_Instance_adj{i}{j})
            shapelet{index}=tins(j,index_Class_Instance_adj{i}{j}(x):index_Class_Instance_adj{i}{j}(x)+index_Class_Instance_length{i}{j}(x)-1);
            sindex(index)=index_Class_Instance_adj{i}{j}(x);
            index=index+1;
        end
    end
end

% dl=size(index_Class_Instance,1);
% for i=1:dl
%     for j=1:size(index_Class_Instance{i},1)
%         index_Class_Instance{i}{j}=unique(index_Class_Instance{i}{j});
%     end
% end
%% use z-normalized euclidean distance to transform the data
TRAIN=TRAIN1;
D_tr=zeros(size(TRAIN,1),slen);
D_ts=zeros(size(TEST,1),slen);

for i=1:size(TRAIN,1)
    data=TRAIN(i,2:size(TRAIN,2));  
    for j=1:slen
        D_tr(i,j)=norm(data(sindex(j):sindex(j)+ length(shapelet{j})-1)-shapelet{j});       
    end
end

for i=1:size(TEST,1)
    data=TEST(i,2:size(TEST,2));  
    for j=1:slen
        D_ts(i,j)=norm(data(sindex(j):sindex(j)+ length(shapelet{j})-1)-shapelet{j});       
    end
end

TRAIN_class_labels=TRAIN(:,1);
TEST_class_labels=TEST(:,1);
%% svm classifier

SVMStruct = svmtrain(TRAIN_class_labels,D_tr,'-t 1 -c 100');
 [~,accu,~] = svmpredict(TEST_class_labels,D_ts,SVMStruct);
 acc = accu(1);

