%% defaults
eeg_sample_rate = 250; % Hz
visualize_data_flag = 0;

% define channel numbers
time_ch = 1;
eeg_ch = 2:9;
groupid_ch = 12;
acc_ch = 13:15; % accelerometer channels
DI_ch = 17;
arduino_ch = 19;

num_events = 10;

%% read and analyze data files
root_folder = uigetdir('./','Select a folder with data files...');

files = dir(root_folder);
dirflag = ~[files.isdir] & ~strcmp({files.name},'..') & ~strcmp({files.name},'.') & ~strcmp({files.name},'.DS_Store');
files = files(dirflag);

delay_ms = zeros(numel(files), num_events);

for filei=1:numel(files)
    % read file
    file_struct = files(filei);
    filepath = fullfile(file_struct.folder, file_struct.name);
    y = load(filepath); y = y.y;
    
    % get data from the variable y
    time = y(time_ch, :);
    groupid = y(groupid_ch, :);
    DI = y(DI_ch, :);
    arduino = y(arduino_ch, :);
    
    % change scale for visualization purposes
    arduino = arduino / max(arduino);
    DI = DI / max(DI);
    
    % visualize initial data
    if visualize_data_flag
        figure();
        plot(time, groupid)
        hold on
        plot(time, arduino)
        plot(time, DI)
        legend('groupid', 'arduino', 'DI')
    end
    
    % save initial variables
    groupid_init = groupid;
    arduino_init = arduino;
    DI_init = DI;

    % convert to time samples (detect time points when the groupid and arduino values were changing and when the tapping occurred)
    [groupid, ~, arduino, DI] = convert_to_ts(groupid, [], arduino, DI, []);
    
    assert(numel(groupid) == num_events, 'number of groupid triggers is not equal to the number of events')
    assert(numel(arduino) == num_events, 'number of arduino triggers is not equal to the number of events')
    assert(numel(DI) == num_events, 'number of DI triggers is not equal to the number of events')
    
    % calculate delay of the DI channel
    delay_ms(filei, :) = 1000*(DI - arduino)/eeg_sample_rate;
    
    %visualize data with triggers
    if visualize_data_flag
        figure();       
        % handles
        h = zeros(6,1);
        h(1) = plot(time, 1.2 * groupid_init);
        hold on
        h(2) = plot(time, 1.1 * arduino_init);
        h(3) = plot(time, DI_init);
        xlim([0, time(end)])
        ylim([-1, 2])
        for idx = 1:numel(groupid)
            h(4) = plot([groupid(idx), groupid(idx)]/eeg_sample_rate, [-1 2], 'LineStyle', '--', 'Color', 'b');
            h(5) = plot([arduino(idx), arduino(idx)]/eeg_sample_rate, [-1 2], 'LineStyle', '--', 'Color', 'r');
            h(6) = plot([DI(idx), DI(idx)]/eeg_sample_rate, [-1 2], 'LineStyle', '--', 'Color', 'k');
        end
        legend(h, {'groupid'; 'arduino'; 'DI'; 'groupid trigger'; 'arduino trigger'; 'DI trigger'});     
    end
    %keyboard
end

%% visualize delay_ms

trials_per_setting = 3; % each set-up was tested three times

num_files = size(delay_ms, 1);
num_events = size(delay_ms, 2);
num_setups = round(num_files / trials_per_setting); 

resh_delay_ms = zeros(num_setups, trials_per_setting * num_events);

for exp_idx = 1:num_setups
    
    file_idx = 1+(exp_idx-1)*trials_per_setting:exp_idx*trials_per_setting;
    cur_delays = delay_ms(file_idx, :);
    total_num_trials = trials_per_setting * num_events;
    resh_delay_ms(exp_idx, :) = reshape(cur_delays, total_num_trials, 1);
end

x = 1:num_setups;
y = mean(resh_delay_ms,2);
yneg = std(resh_delay_ms, [], 2)/2;
ypos = yneg;
xneg = zeros(1,num_setups);
xpos = zeros(1,num_setups);
figure();
errorbar(x,y,yneg,ypos,xneg,xpos,'o')
xlim([0.5,num_setups+0.5])
xticks(1:num_setups)
xlabel('Method #')
ylabel('Digital input delay, ms')
ylim([0, 1.1*max(resh_delay_ms(:))])
grid on
setup_labels = {'small operator window, lamp'; 'small operator window, no lamp'; ... 
                'small operator window, scope, lamp'; 'fullscreen operator window, no scope, no lamp'; ...
                'fullscreen operator window, busy laptop'; 'fullscreen operator window, external screen'};
for i=1:num_setups
    text(x(i) + 0.1, y(i), setup_labels{i})
end
set(gca, 'fontsize', 14)