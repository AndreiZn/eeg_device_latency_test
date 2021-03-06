%% Split video into frames

video_folder = uigetdir('../', 'Select the folder with videos');
frames_output_folder = uigetdir('../', 'Select the output folder for frames');
vid_files = dir(video_folder);
dirflag = ~[vid_files.isdir] & ~strcmp({vid_files.name},'..') & ~strcmp({vid_files.name},'.') & ~strcmp({vid_files.name},'.DS_Store');
vid_files = vid_files(dirflag);
original_video_fps = 230;

f = waitbar(0,'Please wait...');
for vid_idx = 1:numel(vid_files)
    
    waitbar(vid_idx/numel(vid_files),f,'Please wait...');
    
    vid_file_name = vid_files(vid_idx).name;
    vid_name = [vid_files(vid_idx).folder, filesep, vid_file_name];
    videoObject = VideoReader(vid_name);
    n_frames = videoObject.NumFrames;
    f_2 = waitbar(0,'Please wait...');
    
    %fr_step = 100;
    starting_frames = 1201:2000; % frames displaying the start of the experiment
    fr_interval = 4 * original_video_fps;
    first_image_frames = 5980:6200;
    num_fr_per_event = numel(first_image_frames);
    num_events = 10;
    action_frames = zeros(num_events * num_fr_per_event, 1);
    for idx=1:num_events
        action_frames(1 + (idx-1)*num_fr_per_event: idx*num_fr_per_event) = first_image_frames + (idx-1)*fr_interval;
    end
    last_frames = 15400:18000;
    selected_frames = [starting_frames, action_frames', last_frames];
    %selected_frames = action_frames';
    
    for fr_idx = selected_frames %1:fr_step:n_frames
        
        waitbar(fr_idx/n_frames,f_2,'Please wait...');
        
        cur_frame = read(videoObject, fr_idx);
        output_folder = [frames_output_folder, filesep, vid_file_name(1:end-4), filesep];
        if ~exist(output_folder, 'dir')
            mkdir(output_folder)
        end
        imwrite(cur_frame, [output_folder, num2str(fr_idx, '%04d'), '.png']);
    end
    close(f_2);
end
close(f);

%% Make video from frames
root_folder = uigetdir('../', 'Select the folder with frames');
output_folder = uigetdir('../', 'Select the output folder for videos');
folders = dir(root_folder);
folders = folders(3:end);

f = waitbar(0,'Please wait...');
for folder_idx = 1:numel(folders)
    
    waitbar(folder_idx/numel(folders),f,'Please wait...');
    
    folder_cur = [root_folder, folders(folder_idx).name, filesep];
    im_files = dir(folder_cur);
    im_files = im_files(3:end);
    
    output_video_name = [output_folder, folders(folder_idx).name, '.avi'];
    video = VideoWriter(output_video_name); %create the video object
    video.FrameRate = 30;
    open(video); %open the file for writing
    for im_idx=1:2:numel(im_files) %where N is the number of images
        im = im_files(im_idx);
        im = [im.folder, filesep, im.name];
        I = imread(im); %read the next image
        writeVideo(video,I); %write the image to file
    end
    close(video); %close the file
end
close(f);

%% empty block
