img1 = imread('../in_img/vivotek/afternoon/WTG38N.png');
img2 = imread('../in_img/vivotek/afternoon/T67YVU.png');
img3 = imread('../in_img/vivotek/afternoon/V01KHQ.png');

dst = process_image(img3);
[row, col] = find(dst);
min_row = min(row);
min_col = min(col);

max_row = max(row);
max_col = max(col);




rotation_angle = rad2deg(atan((max_row - min_row) / (max_col - min_col)))
dst = imrotate(dst, -45 + rotation_angle);
figure, imshow(dst);
hold on;
plot(min_col, min_row, 'ro', 'MarkerSize', 3);
plot(max_col, max_row, 'ro', 'MarkerSize', 30);
%dst = process_image(img2);
%figure, imshow(dst);

%dst = process_image(img3);
%figure, imshow(dst);



function dst = process_image(src)
    dst = green_filter(src);
    dst = filter_img(dst);
    %dst = scale_rotate(dst);
    
end

function dst = green_filter(src_img)
    hsv_img = rgb2hsv(src_img);
    [h,s,v] = imsplit(hsv_img);
    dst = (s > 0.36) & (0.33 < h & h < 0.51 ) & (0.21 < v & v < 0.59);
end

function dst = filter_img(src)
    dst = bwpropfilt(src,'Area',6); 
end

function dst = scale_rotate(src)
    [row, col] = find(src);
    min_row = min(row);
    min_col = min(col);
    
    max_row = max(row);
    max_col = max(col);

    hold on;
    plot(min_row, min_col, 'ro', 'MarkerSize', 3);
    rotation_angle = rad2deg(atan((max_row - min_row) / (max_col - min_col)));
    rotation_angle
    dst = imrotate(src, 45 - rotation_angle);
end


