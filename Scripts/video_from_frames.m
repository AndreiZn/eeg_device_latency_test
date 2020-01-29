%% Split video into frames

video_folder = uigetdir('../', 'Select the folder with videos');
frames_output_folder = uigetdir('../', 'Select the output folder for frames');
vid_files = dir(video_folder);
dirflag = ~[vid_files.isdir] & ~strcmp({vid_files.name},'..') & ~strcmp({vid_files.name},'.') & ~strcmp({vid_files.name},'.DS_Store');
vid_files = vid_files(dirflag);

f = waitbar(0,'Please wait...');
for vid_idx = 1:numel(vid_files)
    
    waitbar(vid_idx/numel(vid_files),f,'Please wait...');
    
    vid_file_name = vid_files(vid_idx).name;
    vid_name = [vid_files(vid_idx).folder, filesep, vid_file_name];
    videoObject = VideoReader(vid_name);
    n_frames = videoObject.NumFrames;
    f_2 = waitbar(0,'Please wait...');
    for fr_idx = 1:n_frames
        
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
