function ycbcr = bayer2ycbcr(img_bayer)
    [img_height,img_width] = size(img_bayer);
    Red = ones(img_height,img_width);
    Green = ones(img_height,img_width);
    Blue = ones(img_height,img_width);
    
    %%% Covert from bayer to RGB full color %%%%%%
    for m = 1:(img_height)  %height of image
        for n = 1:(img_width) %width of image
                
            if (m == 1) || (n == 1) || (m == img_height) || (n == img_width)
                Red(m,n) = img_bayer(m,n);
                Green(m,n) = img_bayer(m,n);
                Blue(m,n) = img_bayer(m,n);

            else
                %check pixel value and assign new value
                if (rem(m,2)==1) && (rem(n,2)==0)  %At red
                    Red(m,n) = img_bayer(m,n);
                    Green(m,n) = (img_bayer(m-1,n)+ img_bayer(m+1,n) + img_bayer(m,n-1) + img_bayer(m,n+1))/4;
                    Blue(m,n) = (img_bayer(m-1,n+1) + img_bayer(m+1,n+1) + img_bayer(m-1,n-1) + img_bayer(m+1,n-1))/4; 
                elseif (rem(m,2)==0) && (rem(n,2)==1)  %At blue
                    Red(m,n) = (img_bayer(m-1,n+1) + img_bayer(m+1,n+1) + img_bayer(m-1,n-1) + img_bayer(m+1,n-1))/4;
                    Green(m,n) = (img_bayer(m-1,n) + img_bayer(m+1,n) + img_bayer(m,n-1) + img_bayer(m,n+1))/4;
                    Blue(m,n) = img_bayer(m,n);
                elseif (rem(m,2)==0) && (rem(n,2)==0)  %Green 1
                    Red(m,n) = (img_bayer(m-1,n) + img_bayer(m+1,n))/2;
                    Green(m,n) = img_bayer(m,n);
                    Blue(m,n) = (img_bayer(m,n-1) + img_bayer(m,n+1))/2;
                elseif (rem(m,2)==1) && (rem(n,2)==1) %Green 2
                    Red(m,n) = (img_bayer(m,n-1) + img_bayer(m,n+1))/2;
                    Green(m,n) = img_bayer(m,n);
                    Blue(m,n) = (img_bayer(m-1,n) + img_bayer(m+1,n))/2;
                end
            end
        end
    end
    rgb = im2double(cat(3,Red,Green,Blue));
    
  %%% Convert from RGB full color to YCbCr %%%%%%%%
    mtable = [0.183 0.614 0.062; -0.101 -0.338 0.439; 0.439 -0.399 -0.040];
    y = ones(img_height,img_width);
    cb = ones(img_height,img_width);
    cr = ones(img_height,img_width);
    
    for m = 1:size(rgb,1)  %height
        for n = 1:size(rgb,2) %width    
              R = rgb(m,n,1);
              G = rgb(m,n,2);
              B = rgb(m,n,3);
              temp = mtimes(mtable,[R; G; B]);           
              y(m,n) = temp(1)+16/255;
              cb(m,n) = temp(2)+128/255;
              cr(m,n) = temp(3)+128/255;
        end
    end
    ycbcr = im2double(cat(3,y,cb,cr));
    
end