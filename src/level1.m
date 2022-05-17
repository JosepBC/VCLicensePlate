img1 = imread('../in_img/vivotek/afternoon/WTG38N.png');
img2 = imread('../in_img/vivotek/afternoon/T67YVU.png');
img3 = imread('../in_img/vivotek/afternoon/V01KHQ.png');

dst1 = green_filter(img1);
figure, imshow(dst1);

function dst = green_filter(src_img)
    %min_green = [70, 20, 60];  %this is hsl  
    %max_green = [160, 200, 255]; %this is hsl

    min_green = [70, 20, 68];
    max_green = [160, 200, 100]; 

    hsv_img = rgb2hsv(src_img);
    dst = in_range(hsv_img, min_green, max_green);
end


function dst = in_range(src_img, low_values, high_values)
    dst = src_img(:,:,1) > low_values(1) & src_img(:,:,2) > low_values(2) & src_img(:,:,3) > low_values(3) & src_img(:,:,1) < high_values(1) & src_img(:,:,2) < high_values(2) & src_img(:,:,3) < high_values(3);

end