data = rlsiDat.data;
fSp1 = find(data(:,2)==data(:,3));
fSp2 = find(data(:,2)~=data(:,3));
fF02 = find(data(:,4)~=data(:,5));
fF01 = find(data(:,4)==data(:,5));
fNP = find(data(:,9)==0);
fP = find(data(:,9)~=0);
fC = find(data(:,8)==data(:,9));
fnC = find(data(:,8)~=data(:,9));
length(fnC)
length(fC)
length(fP)
length(fNP)
length(fF01)
length(fF02)
data(:,11) = data(:,7) == data(:,10);
sum(data(fC,11))/length(fC)
sum(data(fnC,11))/length(fnC)
sum(data(fNP,11))/length(fNP)
sum(data(fP,11))/length(fP)
sum(data(fF01,11))/length(fF01)
sum(data(fF02,11))/length(fF01)
sum(data(fSp2,11))/length(fF01)
sum(data(fSp1,11))/length(fF01)