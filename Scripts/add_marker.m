
%   This script adds a marker to the images in the lower right corner.
%You chose a folder, and the script changes the images in this folder, ...
%but the script creates folder with old pictures!
%date: 27.02.2020 
%time: 15:00

initial_path = '../';
%initial_path = '../';

%% input

input_dir = uigetdir(initial_path,'Select the folder with videos');
%input_dir = '../123';

% marker sizes are chosen empirically
marker_height = 60;
marker_length = 100;

marker_colour = 255;  %the brightness for each colour channel, it is identical
marker_colour_number = 3; %number of colour channels




%% preparation

save_dir = [input_dir '_old'];

if exist(save_dir) == 7 % if there is dir whith the path save_dir
    num = 1;
    save_dir = [input_dir '_old_' num2str(num)];
    while exist(save_dir) == 7
        num = num + 1;
        save_dir = [input_dir '_old_' num2str(num)];
    end 
end

mkdir(save_dir);  


%%
files = dir(input_dir);
files = files(3:end);


wait = waitbar(0,'Please wait...');
%% images processing
for i = 1:numel(files)  
    
    %input
    input_image_path = [files(i).folder filesep files(i).name];
    output_image_path = input_image_path;
    save_image_path = [save_dir filesep files(i).name];
    
    copyfile(input_image_path, save_image_path);
    
    %% making marker
    
    image  = imread(input_image_path);

    % marker parameters
%     marker_height = height;
%     marker_length = length;
%     marker_colour = 255;
%     marker_colour_number = 3;

    % creating marker
    marker = ones(marker_height, marker_length, marker_colour_number );
    marker = marker*marker_colour;


    % puting marker

    [im_h im_l] = size(image,1,2);
    im_m_x = im_h - marker_height + 1;
    im_m_y = im_l - marker_length + 1;

    image(im_m_x:im_h, im_m_y:im_l,:) = marker;



    % saving image
    
    imwrite(image,output_image_path);
    
    %%
     waitbar(i/numel(files) ,wait,'Please wait...');
end

close(wait);

