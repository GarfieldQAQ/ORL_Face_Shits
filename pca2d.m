% 2Dpca for face recognition 
% By Pan Chen
clear all;
close all;

select=0;%select a type of discrimination:  ��ֵ����Ϊ��������1��������������Ϊ��������0������С�����б�
% Load the ATT image set
k = 0;m=7;%ѡ��ÿ������ѵ��������
t=0.30;%��ֵ������ֵ

for i=1:1:40
    for j=1:1:m
        filename  = sprintf('orl-faces\\s%d\\%d.pgm',i,j);%cbcl-face-database
        A = imread(filename);
      
        %A=edgeimage(A,t);
        %A=diagimage(A);
        k = k + 1;
        x(:,:,k) = A;  
        anot_name(k,:) = sprintf('%2d:%2d',i,j);   % for plot annotations
     end;
end;
nImages = k;                     %total number of images
imsize = size(A);       %size of image (they all should have the same size) 
nPixels = imsize(1)*imsize(2);   %number of pixels in image
x = double(x)/255;               %convert to double and normalize
x=x.^0.5;
%Calculate the average
sumx=x(:,:,1);
for i=2:nImages
    x1=x(:,:,i);
    sumx = sumx+x1;
end;
avrgx = 1/nImages*sumx;
for i=1:1:nImages
    xx(:,:,i) = x(:,:,i) - avrgx; % substruct the average
end;
%subplot(2,2,1); imshow(reshape(avrgx, imsize)); title('mean face')
%compute covariance matrix of row
cov_mat = xx(:,:,1)'*xx(:,:,1);
for i=2:nImages
    cov_mat=cov_mat+xx(:,:,i)'*xx(:,:,i);
end;
cov_mat = 1/nImages*cov_mat;
[V,D] = eig(cov_mat);         %eigen values of cov matrix
%compute covariance matrix of col
cov_mat1 = xx(:,:,1)*xx(:,:,1)';
for i=2:nImages
    cov_mat1=cov_mat1+xx(:,:,i)*xx(:,:,i)';
end;
cov_mat1 = 1/nImages*cov_mat1;
[V1,D1] = eig(cov_mat1);         %eigen values of cov matrix

kkk=5;kkk1=5;                         %******************** key dimensional��ѡ��������ͶӰά��
Vpca=V(:,imsize(2)-kkk+1:imsize(2));
Vpca1=V1(:,imsize(1)-kkk1+1:imsize(1));
deep_features = [];
for i=1:nImages
    Y(:,:,i)=Vpca1'*(x(:,:,i) - avrgx) * Vpca;%����������Ϊ��������
    

end
% ����ѵ�������Ѵ洢�� Y_train��n_samples �� 10 �� 10��
n_train = size(Y, 3); % Y��ѵ��������ͶӰ��������40���7����=280��
Y_flat = permute(Y, [3, 1, 2]);
Y_flat = reshape(Y_flat, n_train, kkk*kkk1);
% ��֤������
val_features = [];
val_labels = [];
for i = 1:40
    for j = m+1 : 10 % ��֤��������������8��
        filename = sprintf('orl-faces/s%d/%d.pgm', i, j);
        img = imread(filename);
        img = compressImageTo112x92Gray(img);
        % ��ѵ����һ�µ�Ԥ����
        img = double(img)/255;
        img = img.^0.5;         % �Աȶ���ǿ����ѵ���׶�ʹ�ã�
        img_centered = img - avrgx; % ʹ��ѵ������ƽ����
        
        % 2D-PCAͶӰ
        feature = Vpca1' * img_centered * Vpca;
        feature = reshape(feature, 1, kkk*kkk1);

        val_features = [val_features; feature];
        val_labels = [val_labels; i];
    end
end

save ("./mat/face_save_pca2d");
svm