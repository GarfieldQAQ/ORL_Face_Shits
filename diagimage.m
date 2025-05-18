 function C=diagimage(A) 
  
        imsize = size(A);       %size of image (they all should have the same size) 
        delta=0;
        B=repmat(A,1,2);
        for i=1:1:imsize(1)
             for j=1:1:imsize(2)
                wid=delta+j;
                if (wid<=2*imsize(2))  
                    C(i,j)=B(i,wid);
                else C(i,j)=B(i,wid-imsize(2));    
                end;
            end;
            delta=delta+1;       
        end;
     imshow(C);
