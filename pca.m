%һ���޸ĺ��PCA��������ʶ���Matlab����
% calc xmean,sigma and its eigen decomposition
clear,clc,close
allsamples=[];%����ѵ��ͼ��
for i=1:40
    for j=1:5
      a=imread(strcat('orl-faces\s',num2str(i),'\',num2str(j),'.pgm'));
      % imshow(a);
      b=a(:); % b����ʸ�� 1��N������N��10304����ȡ˳�������к��У������ϵ��£�������
      b=double(b);
      allsamples=[allsamples; b];  % allsamples ��һ��M * N ����allsamples ��ÿһ�����ݴ���һ��ͼƬ������M��200
  end
end
samplemean=mean(allsamples); % ƽ��ͼƬ��1 �� N
for i=1:200 
    xmean(i,:)=allsamples(i,:)-samplemean; % xmean��һ��M �� N����xmeanÿһ�б���������ǡ�ÿ��ͼƬ����-ƽ��ͼƬ��
end;

sigma=xmean*xmean';   % M * M �׾���
[v d]=eig(sigma);
d1=diag(d);
[d2 index]=sort(d1); %����������
cols=size(v,2);% �����������������
for i=1:cols
    vsort(:,i) = v(:, index(cols-i+1) ); % vsort ��һ��M*col(ע:colһ�����M)�׾��󣬱�����ǰ��������е���������,ÿһ�й���һ����������
    dsort(i)   = d1( index(cols-i+1) );  % dsort ������ǰ��������е�����ֵ����һά������
end  %��ɽ�������
%����ѡ��90%������
dsum = sum(dsort);
    dsum_extract = 0;
    p = 0;
    while( dsum_extract/dsum < 0.98)
        p = p + 1;
        dsum_extract = sum(dsort(1:p));
    end
i=1;
% (ѵ���׶�)�����������γɵ�����ϵ
while (i<=p && dsort(i)>0)
    base(:,i) = dsort(i)^(-1/2) * xmean' * vsort(:,i);   % base��N��p�׾��󣬳���dsort(i)^(1/2)�Ƕ�����ͼ��ı�׼�������������PCA������ʶ���㷨�о���p31
    i = i + 1;
end

% add by wolfsky �����������д��룬��ѵ������������ϵ�Ͻ���ͶӰ,�õ�һ�� M*p �׾���allcoor
allcoor = allsamples * base;
accu = 0;

% ���Թ���
for i=1:40
    for j=6:10 %����40 x 5 ������ͼ��
        a=imread(strcat('orl-faces\s',num2str(i),'\',num2str(j),'.pgm'));
        b=a(1:10304);
        b=double(b);
        tcoor= b * base; %�������꣬��1��p�׾���
        for k=1:200 
                mdist(k)=norm(tcoor-allcoor(k,:));
            end;
        %���׽��� 
 [dist,index2]=sort(mdist);
        class1=floor( index2(1)/5 )+1;
        class2=floor(index2(2)/5)+1;
        class3=floor(index2(3)/5)+1;
        if class1~=class2 && class2~=class3
            class=class1;
        elseif class1==class2
            class=class1;
        elseif class2==class3
            class=class2;
        end;
        if class==i
            accu=accu+1;
        end;
    end;
end;
accuracy=accu/200 %���ʶ����
