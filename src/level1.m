img1 = imread('../in_img/vivotek/afternoon/WTG38N.png');
img2 = imread('../in_img/vivotek/afternoon/T67YVU.png');
img3 = imread('../in_img/vivotek/afternoon/V01KHQ.png');


teamplates = load_teamplates("../in_img/teamplates/");

in_images = load_in_images("../in_img/vivotek/afternoon/");

dst = process_image(img3);

function in_images = load_in_images(in_images_root_path)
    names = ls(in_images_root_path+"*.png");

    in_images = containers.Map();

    for n = 1 : height(names)
        elem = names(n, 1:6);
        in_images(elem) = imread(in_images_root_path+elem+".png");
    end
end


function teamplates = load_teamplates(teamplates_root_path)
    teamplate_names = ls(teamplates_root_path+"*.png");

    teamplates = containers.Map();

    for n = 1 : height(teamplate_names)
        elem = teamplate_names(n);
        teamplates(elem) = imread(teamplates_root_path+elem+".png");
    end

end




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


