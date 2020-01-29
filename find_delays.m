read_from_file = 1; % 1 - read data from file; 0 - read file from the figure;
first_frame_of_the_exp = 2583; %947;
last_frame_of_the_exp = 12182; %9411;
duration_of_the_exp = 40; % sec
% video_fps of the Iphone is expected to be 240fps, however, it is
% calclulated to be around 212fps.
video_fps = (last_frame_of_the_exp - first_frame_of_the_exp + 1) / duration_of_the_exp;
eeg_sample_rate = 250; % Hz
visualize_flag = 1;

if read_from_file
    
    % read file
    y = uigetfile(); y = load(y); y = y.y;
    
    % define channel numbers
    time_ch = 1;
    eeg_ch = 2:9;
    groupid_ch = 12;
    tap_ch = 2; % 13 - in case if the accelerometer channel was used as the tapping channel;
    tap_ch_type = 'eeg'; % 'acc' - in case if the accelerometer channel was used as the tapping channel;
    arduino_ch = 17;
    
    % get data from the variable y
    time = y(time_ch, :);
    groupid = y(groupid_ch, :);
    tap = y(tap_ch, :);
    arduino = y(arduino_ch, :);
    
    % change scale for visualization purposes
    tap = tap / max(tap);
    
    % visualize initial data
    figure();
    plot(time, groupid)
    hold on
    plot(time, tap)
    plot(time, arduino)
    legend('groupid', 'tapping channel', 'arduino')
    
    % save initial variables
    groupid_init = groupid;
    tap_init = tap;
    arduino_init = arduino;
    % convert to time samples (detect time points when the groupid and arduino values were changing and when the tapping occurred)
    [groupid, tap, arduino] = convert_to_ts(groupid, tap, arduino, tap_ch_type);
    
    % tapping moments "acc" are detected automatically by finding
    % maximal peaks in the accelerometer data
    % however, it's possible to manually assign these moments by reviewing
    % the plot of the accelerometer data; in this case, the moment when the
    % accelerometer data deviates from the baseline is called the "tapping
    % moment"
    
    manually_assigned_tapping_moments_ms = readtable('manually_assigned_tapping_moments_ms.txt'); 
    manually_assigned_tapping_moments_ms = manually_assigned_tapping_moments_ms{:,:};
    manually_assigned_tapping_moments_ms = manually_assigned_tapping_moments_ms(1,:);
    tap = round(manually_assigned_tapping_moments_ms*eeg_sample_rate/1000);
    
    % get info about key frames from the text file
    frame_data = readtable('frame_data.txt'); frame_data = frame_data{:,:};
    image_app_frames = frame_data(1,:);
    tapping_frames = frame_data(2,:);
    
    % calculate reaction times from video 
    rt_video_frames = tapping_frames - image_app_frames;
    rt_video_ms = from_frames_to_ms(rt_video_frames, video_fps);
    
    % calculate reaction times from recorded data
    rt_recorded_ts = tap - arduino;
    rt_recorded_ms = from_ts_to_ms(rt_recorded_ts, eeg_sample_rate);

    % calculate delay of the paradigm presenter
    delay_ms = 1000*(groupid - tap)/eeg_sample_rate + rt_video_ms;
    
    if visualize_flag
        
        figure();
        % handles
        h = zeros(6,1);
        h(1) = plot(time, 2 * groupid_init);
        hold on
        h(2) = plot(time, 1.5 * tap_init);
        h(3) = plot(time, 1.2 * arduino_init);
        xlim([0, time(end)])
        ylim([-1, 2])
        for idx = 1:numel(groupid)
            h(4) = plot([groupid(idx), groupid(idx)]/eeg_sample_rate, [-1 2], 'LineStyle', '--', 'Color', 'b');
            h(5) = plot([tap(idx), tap(idx)]/eeg_sample_rate, [-1 2], 'LineStyle', '--', 'Color', 'g');
            h(6) = plot([arduino(idx), arduino(idx)]/eeg_sample_rate, [-1 2], 'LineStyle', '--', 'Color', 'r');
            % plot image appearance according to the video (acc -
            % reaction_time)
            %h(4) = plot([arduino(idx), arduino(idx)]/eeg_sample_rate, [-1 1], 'LineStyle', '--', 'Color', 'r');
        end
        
        legend(h, {'groupid'; 'tap-ch'; 'arduino'; 'groupid trigger'; 'tap-ch trigger'; 'arduino trigger'});              
        
    end
    
else
    
    file = uigetfile();
    f = openfig(file);
    %f = gcf;
    ax = get(f, 'children'); ax = get(ax, 'children');
    group_id = ax(2).YData; % group_id data
    acc_data = ax(1).YData; % accelerometer data
    
    figure();
    plot(group_id)
    hold on
    plot(acc_data)
    plot(tapping_channel)
    
end
