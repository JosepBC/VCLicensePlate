teamplates = load_teamplates("../in_img/teamplates/level1/");

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

    plate_parts = split_plate(cleaned_img);

    [n_elem_detected, detected_plate] = check_plate(plate_parts, ground_truth, teamplates);

    if show_images
        img = imshowpair(src, cleaned_img, 'montage');
        dt = datetime("now", "Format", 'yyyy-MM-dd_HH.mm.sss');
        saveas(img, "../out_img/"+string(dt)+"_"+detected_plate+".png", "png");
    end

end

function dst = green_filter(src_img)
    hsv_img = rgb2hsv(src_img);
    [h,s,v] = imsplit(hsv_img);
    dst = (s > 129/360) & (84/255 < h & h < 130/255) & (53/255 < v & v < 150/255);
end

function dst = clean_img(src)
    dst = bwpropfilt(src,'Area',6); 
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

