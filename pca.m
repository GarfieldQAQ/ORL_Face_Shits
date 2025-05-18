%一个修改后的PCA进行人脸识别的Matlab代码
% calc xmean,sigma and its eigen decomposition
clear,clc,close
allsamples=[];%所有训练图像
for i=1:40
    for j=1:5
      a=imread(strcat('orl-faces\s',num2str(i),'\',num2str(j),'.pgm'));
      % imshow(a);
      b=a(:); % b是行矢量 1×N，其中N＝10304，提取顺序是先列后行，即从上到下，从左到右
      b=double(b);
      allsamples=[allsamples; b];  % allsamples 是一个M * N 矩阵，allsamples 中每一行数据代表一张图片，其中M＝200
  end
end
samplemean=mean(allsamples); % 平均图片，1 × N
for i=1:200 
    xmean(i,:)=allsamples(i,:)-samplemean; % xmean是一个M × N矩阵，xmean每一行保存的数据是“每个图片数据-平均图片”
end;

sigma=xmean*xmean';   % M * M 阶矩阵
[v d]=eig(sigma);
d1=diag(d);
[d2 index]=sort(d1); %以升序排序
cols=size(v,2);% 特征向量矩阵的列数
for i=1:cols
    vsort(:,i) = v(:, index(cols-i+1) ); % vsort 是一个M*col(注:col一般等于M)阶矩阵，保存的是按降序排列的特征向量,每一列构成一个特征向量
    dsort(i)   = d1( index(cols-i+1) );  % dsort 保存的是按降序排列的特征值，是一维行向量
end  %完成降序排列
%以下选择90%的能量
dsum = sum(dsort);
    dsum_extract = 0;
    p = 0;
    while( dsum_extract/dsum < 0.98)
        p = p + 1;
        dsum_extract = sum(dsort(1:p));
    end
i=1;
% (训练阶段)计算特征脸形成的坐标系
while (i<=p && dsort(i)>0)
    base(:,i) = dsort(i)^(-1/2) * xmean' * vsort(:,i);   % base是N×p阶矩阵，除以dsort(i)^(1/2)是对人脸图像的标准化，详见《基于PCA的人脸识别算法研究》p31
    i = i + 1;
end

% add by wolfsky 就是下面两行代码，将训练样本对坐标系上进行投影,得到一个 M*p 阶矩阵allcoor
allcoor = allsamples * base;
accu = 0;

% 测试过程
for i=1:40
    for j=6:10 %读入40 x 5 副测试图像
        a=imread(strcat('orl-faces\s',num2str(i),'\',num2str(j),'.pgm'));
        b=a(1:10304);
        b=double(b);
        tcoor= b * base; %计算坐标，是1×p阶矩阵
        for k=1:200 
                mdist(k)=norm(tcoor-allcoor(k,:));
            end;
        %三阶近邻 
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
accuracy=accu/200 %输出识别率
