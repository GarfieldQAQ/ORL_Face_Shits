%function correct_rat=pca2dtest
% Find similar faces,  variable 'image_index' defines face used in comparison

load face_save_pca2d;

%image decomposition coefficients
error=0;
correct=0;
for ii=1:40
    for jj=m+1:10
        filename  = sprintf('orl-faces\\s%d\\%d.pgm',ii,jj);%16,10%cbcl-face-database
        T = imread(filename);T1=T;
        T = double(T)/255;
        T=T.^0.5;
        B =  Vpca1'*(T - avrgx)*Vpca;

      
         %单个样本作为聚类中心
            for i=1:nImages
                A=B-Y(:,:,i);
                distsum=0;
                for j=1:kkk
                    dist = dot(A(:,j),A(:,j)); %euclidean
                    distsum=distsum+dist;
                end;
                dist_comp(i)=distsum;
                strDist(i) = cellstr(sprintf('%2.2f\n',dist_comp(i)));
            end;
            [sorted, sorted_index] = sort(dist_comp); % sort distances
            iii=sorted_index(1);
            sorted_class=fix(iii/m)+1;
            j_j=mod(iii,m);
            if (j_j==0) sorted_class=sorted_class-1;end;
            if (sorted_class==ii) correct=correct+1;
            else error=error+1;
                figure
                subplot(2,1,1); imshow(T1); title('original image');
                subplot(2,1,2);
                filename  = sprintf('orl-faces\\s%d\\%d.pgm',sorted_class,1);
                T = imread(filename); imshow(T); title('error image');
                %%pause
            end;

    end;
end;
select
% kkk
% kkk1
% correct
% error
correct_rat=correct/((10-m)*40)

