teamplates = load_teamplates("../in_img/teamplates/level1");

in_images = load_in_images("../in_img/vivotek/afternoon/");

results = zeros(1, 7); %Number of correct matches, first element 0 matches, second element 1 match ...

show_images = true; % Set to true to see each image and it's binarization

%Process images
for key = keys(in_images)
    plate = char(key);

    n_elem_detected = process_image(in_images(plate), plate, teamplates, show_images);
    results(n_elem_detected + 1) = results(n_elem_detected + 1) + 1;
end

%Print results
n_plates = sum(results);
n_ok = results(7);

%For all characters recognized use different print...
if n_ok == 1
    disp(sprintf("En %i imatge (%.2f%%) s'han reconegut tots els caracters de la matricula", n_ok, (n_ok / n_plates) * 100));
else
    disp(sprintf("En %i imatges (%.2f%%) s'han reconegut tots els caracters de la matricula", n_ok, (n_ok / n_plates) * 100));
end

%Other matches
for n = 6 : -1 : 1
    n_ok = results(n);
    if n_ok == 1
        disp(sprintf("En %i imatge (%.2f%%) s'han reconegut %i caracters de la matricula", n_ok, (n_ok / n_plates) * 100, n - 1));
    else
        disp(sprintf("En %i imatges (%.2f%%) s'han reconegut %i caracters de la matricula", n_ok, (n_ok / n_plates) * 100, n - 1));
    end
end




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


function n_elem_detected = process_image(src, ground_truth, teamplates, show_images)
    bw = green_filter(src);
    cleaned_img = clean_img(bw);
    %rotated = scale_rotate(dst);
    plate_parts = split_plate(cleaned_img);
    %show_parts(plate_parts);
    %store_teamplates(plate_parts, ground_truth);
    [n_elem_detected, detected_plate] = check_plate(plate_parts, ground_truth, teamplates);
    if show_images
        img = imshowpair(src, cleaned_img, 'montage');
        dt = datetime("now", "Format", 'yyyy-MM-dd_HH.mm.sss');
        saveas(img, "../out_img/"+string(dt)+"_"+detected_plate+".png", "png");
    end
    %dst = cleaned_img;
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
%   - Teamplates
%OUT:
%   - Nelem sucesfully classified
function [n_elem_detected, detected_plate] = check_plate(plate_elements, ground_truth, teamplates)
    n_elem_detected = 0;
    detected_plate = "";
    for n = 1 : height(plate_elements)
        detected_element = correlate_element(plate_elements{n}, teamplates);
        detected_plate = detected_plate + string(detected_element);
        if detected_element == ground_truth(n)
            n_elem_detected = n_elem_detected + 1;
        end
    end

end

%IN:
%   - One plate letter/number
%   - Teamplates
%OUT:
%   - Char with the most similar element
function dst = correlate_element(plate_element, teamplates)
    highest_match = 0;
    dst = '';

    for key = keys(teamplates)
        teamplate_name = char(key);
        teamplate_img = teamplates(teamplate_name);

        %Test image must be same size as teamplate
        [rows, cols, numberOfColorChannels] = size(teamplate_img);
        element = imresize(plate_element, [rows, cols]);

        %Get correlations
        c = normxcorr2(teamplate_img, element);
        current_max = max(c(:));
        if current_max > highest_match
            highest_match = current_max;
            dst = teamplate_name;
        end
    end
    %t = imread('../in_img/teamplates/T.png');
    %[rows, columns, numberOfColorChannels] = size(t);
    %scondt = imresize(dst{1}, [rows, columns]);
    %c = normxcorr2(t,scondt);
    %surf(c)
    %shading flat

    %
    %[ypeak,xpeak] = find(c==max(c(:)));
    %yoffSet = ypeak-size(t,1);
    %xoffSet = xpeak-size(t,2);
    %imshow(scondt)
    %drawrectangle(gca,'Position',[xoffSet,yoffSet,size(t,2),size(t,1)], ...
    %    'FaceAlpha',0);
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

