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
    bw = green_filter(src);
    dst = clean_img(bw);
    %rotated = scale_rotate(dst);
    dst = split_plate(dst);
    
end

function dst = green_filter(src_img)
    hsv_img = rgb2hsv(src_img);
    [h,s,v] = imsplit(hsv_img);
    dst = (s > 0.36) & (0.33 < h & h < 0.51 ) & (0.21 < v & v < 0.59);
end

function dst = clean_img(src)
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






%[row, col] = find(dst);
%min_row = min(row);
%min_col = min(col);

%max_row = max(row);
%max_col = max(col);




%rotation_angle = rad2deg(atan((max_row - min_row) / (max_col - min_col)))
%r = 45 - rotation_angle
%rotated = imrotate(dst, -r);
%figure, imshow(dst);
%hold on;
%plot(min_col, min_row, 'ro', 'MarkerSize', 3);
%plot(max_col, max_row, 'ro', 'MarkerSize', 30);

%figure, imshow(rotated);
end

function dst = split_plate(src)
    S = regionprops(src,'boundingbox','filledimage', 'Orientation');
    dst = cell(numel(S),1);
    for n = 1:numel(S)
        % get corresponding rectangular area
        bb = floor(S(n).BoundingBox);
        samp = src(bb(2):bb(2)+bb(4)-1,bb(1):bb(1)+bb(3)-1,:);
        % store this image
        dst{n} = samp;
    end

end

%IN:
%   - Array of the 6 elements of the plate
%   - String with the correct answer
%OUT:
%   - Nelem sucesfully classified
function dst = check_plate(plate_elements, ground_truth)

end

%IN:
%   - One plate letter/number
%OUT:
%   - Char with the most similar element
function dst = correlate_element(plate_element)

    t = imread('../in_img/teamplates/T.png');
    [rows, columns, numberOfColorChannels] = size(t);
    scondt = imresize(dst{1}, [rows, columns]);
    c = normxcorr2(t,scondt);
    %surf(c)
    %shading flat

    max(c(:))
    [ypeak,xpeak] = find(c==max(c(:)));
    yoffSet = ypeak-size(t,1);
    xoffSet = xpeak-size(t,2);
    imshow(scondt)
    drawrectangle(gca,'Position',[xoffSet,yoffSet,size(t,2),size(t,1)], ...
        'FaceAlpha',0);

    dst = 'T';
end


%IN:
%   - dst = Processed and splited image
%   - ground_truth = String with the plate, ex: WAQ123
function store_teamplates(dst, groun_truth)
    imwrite(dst{1}, "../in_img/teamplates/new/"+groun_truth(1)+".png");
    imwrite(dst{2}, "../in_img/teamplates/new/"+groun_truth(2)+".png");
    imwrite(dst{3}, "../in_img/teamplates/new/"+groun_truth(3)+".png");
    imwrite(dst{4}, "../in_img/teamplates/new/"+groun_truth(4)+".png");
    imwrite(dst{5}, "../in_img/teamplates/new/"+groun_truth(5)+".png");
    imwrite(dst{6}, "../in_img/teamplates/new/"+groun_truth(6)+".png");
end

function show_parts(dst)
    figure, imshow(dst{1});
    figure, imshow(dst{2});
    figure, imshow(dst{3});
    figure, imshow(dst{4});
    figure, imshow(dst{5});
    figure, imshow(dst{6});
end

