%%

%%
tic
mlen=size(TRAIN,2);
numcls=unique(TRAIN(:,1));
len=length(numcls);

newtrain=cell(len,1);

for i=0:len-1
    fclass=TRAIN(:,1)==i;
    finstance = TRAIN(fclass,:);
    mm=[];
    for p=1:size(finstance,1)
        x=finstance(p,2:mlen);
        dist=[];
        for j=1:size(finstance,1)
            dist=[dist norm(x-finstance(j,2:mlen))];
        end
        mm=[mm;dist];
    end
    newtrain{i+1}=mm;
end

toc