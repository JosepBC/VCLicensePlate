teamplates = load_teamplates("../in_img/teamplates/level2/");

in_images = load_in_images("../in_img/tst/");

results = zeros(1, 7); %Number of correct matches, first element 0 matches, second element 1 match ...


%Process images
for key = keys(in_images)
    plate = char(key);
    n_elem_detected = process_image(in_images(plate), plate, teamplates);
    results(n_elem_detected + 1) = results(n_elem_detected + 1) + 1;
    %break;
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
    names = ls(in_images_root_path+"*.jpg");

    in_images = containers.Map();

    for n = 1 : height(names)
        elem = names(n, 1:6);
        in_images(elem) = imread(in_images_root_path+elem+".jpg");
    end
end

function teamplates = load_teamplates(teamplates_root_path)
    teamplate_names = ls(teamplates_root_path+"*.png");

    teamplates = containers.Map();

    for n = 1 : height(teamplate_names)
        elem = teamplate_names(n);
        teamplates(elem) = imread(teamplates_root_path+elem+".png");
        if size(teamplates(elem), 3) == 3
            teamplates(elem) = logical(rgb2gray(teamplates(elem)));
        end
    end

end


function n_elem_detected = process_image(src, ground_truth, teamplates)
    bw = green_filter(src);
    figure,imshow(bw);

    [n_elem_detected, gt] = check_plate(bw, ground_truth, teamplates);

end

function dst = green_filter(src_img)
    hsv_img = rgb2hsv(src_img);
    [h,s,v] = imsplit(hsv_img);
    dst = (172/360 < h & h < 250/360) & (80/255 < s & s < 255/255) & (60/255 < v & v < 255/255);
end

%IN:
%   - Full image
%   - String with the correct answer
%   - Teamplates
%OUT:
%   - Nelem sucesfully classified
%   - String with plate detected
function [n_elem_detected, detected_plate] = check_plate(bw_img, ground_truth, teamplates)
    n_elem_detected = 0;
    detected_plate = "";

    match_vals = containers.Map();
    match_x = containers.Map();

    part_teamplates_names = keys(teamplates);
    part_teamplates_imgs = values(teamplates);
    


    for n = 1 : length(teamplates)
        teamplate_name = part_teamplates_names{n};
        part_img = part_teamplates_imgs{n};

        [max_val, x_peak, y_peak] = correlate_element(bw_img, part_img);
        
        match_vals(teamplate_name) = max_val;
        match_x(teamplate_name) = x_peak;
    end
    
    correlations = get_6_max_correlations(match_vals);
    
    %Get the x_value for the correlations
    letters = keys(correlations);
    max_xs = values(match_x, letters);
    x_values = zeros(1, 6);

    for n = 1 : 6
        x_values(n) = max_xs{1,n}(1);
    end

    letters_x_map = containers.Map(letters, x_values);

    %Sort keys by x_value, this way we have the order of the matches to get
    %the score
    k = letters_x_map.keys;
    v = letters_x_map.values;

    [sorted_values, sort_idx] = sort(cell2mat(v));
    sorted_keys = k(sort_idx);

    for n = 1 : 6
        detected_plate = detected_plate + string(sorted_keys(n));
        if char(sorted_keys(n)) == ground_truth(n)
            n_elem_detected = n_elem_detected + 1;
        end
    end

    %detected_plate
    %n_elem_detected
    %ground_truth

end

function dst = get_6_max_correlations(correlations)
    k = correlations.keys;
    v = correlations.values;

    [sorted_values, sort_idx] = sort(cell2mat(v), 'descend');
    sorted_keys = k(sort_idx);

    dst = containers.Map();

    for n = 1 : 6
        best_name = char(sorted_keys(n));
        best_x_val = sorted_values(n);
        dst(best_name) = best_x_val;
    end

end

%IN:
%   - Full img
%   - One teamplate
%OUT:
%   - Max value correlation value
%   - X peak
function [max_val, x_peak, y_peak] = correlate_element(bw_img, teamplate)
    c = normxcorr2(teamplate, bw_img);
    max_val = max(c(:));
    [y_peak, x_peak] = find(c==max_val);
end
