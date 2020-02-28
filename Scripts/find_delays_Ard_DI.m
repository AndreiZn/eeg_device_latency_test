%% defaults
visualize_data_flag = 0;

%% read and analyze data files
root_folder = uigetdir('./','Select a folder with data files...');
files = dir(root_folder);
config = files(strcmp({files.name}, 'config.txt'));
dirflag = ~[files.isdir] & ~strcmp({files.name},'..') & ~strcmp({files.name},'.') & ...
    ~strcmp({files.name},'.DS_Store') & ~strcmp({files.name},'config.txt');
files = files(dirflag);


% read the config file
setup_labels = cell(1,1);
fid = fopen(fullfile(config.folder, config.name));
setup_labels{1,1} = fgetl(fid);
i = 1;
while ischar(setup_labels{i,1})
    i = i + 1;
    setup_labels{i,1} = fgetl(fid);
end
trials_per_setting = str2num(setup_labels{1,1});
setup_labels = setup_labels(2:size(setup_labels,1)-1,1);
fclose(fid);
assert(numel(trials_per_setting) == size(setup_labels,1), 'the number of set-ups is not equal to the number of set-up labels')


% determine the maximal number of events among all data files
max_num_events = 0;
for filei=1:numel(files)
    %disp(filei)
    % read file
    file_struct = files(filei);
    filepath = fullfile(file_struct.folder, file_struct.name);
    y = load(filepath); y = y.y;
    
    if size(y,1) == 20
        groupid_ch = 12;
    elseif size(y,1) == 39
        groupid_ch = 36;
    else
        errordlg('Unrecognized case (only 20 and 39 channels are supported)')
    end
    
    num_events = round(numel(find(diff(y(groupid_ch,1000:end))))/2);
    if num_events > max_num_events
        max_num_events = num_events;
    end
end

% define the structure that will store delay data
delay_ms = NaN(numel(files), max_num_events);
delay_G_Ard_ms = NaN(numel(files), max_num_events);

for filei=1:numel(files)
    %disp(filei)
    % read file
    file_struct = files(filei);
    filepath = fullfile(file_struct.folder, file_struct.name);
    y = load(filepath); y = y.y;
    
    % define channel numbers
    if size(y,1) == 20
        time_ch = 1;
        eeg_ch = 2:9;
        groupid_ch = 12;
        acc_ch = 13:15; % accelerometer channels
        DI_ch = 17;
        arduino_ch = 19;
        CFG.event_length_s = 4; % events occur every 4 seconds
        CFG.image_appearance_time_s = 3; % sec
    elseif size(y,1) == 39
        time_ch = 1;
        eeg_ch = 2:33;
        groupid_ch = 36;
        DI_ch = 37;
        arduino_ch = 38;
        CFG.event_length_s = 0.9; % events occur every 4 seconds
        CFG.image_appearance_time_s = 0.4; % sec
    else
        errordlg('Unrecognized case (only 20 and 39 channels are supported)')
    end
    
    %calculte the number of the events from the groupid data
    groupid = y(groupid_ch, :);
    groupid_events = groupid(groupid >= 0);
    num_events = round(numel(find(diff(groupid_events)))/2);
    
    % get data from the variable y
    time = y(time_ch, :);
    groupid = y(groupid_ch, :);
    DI = y(DI_ch, :);
    arduino = y(arduino_ch, :);
    
    % calculate the sample rate of the EEG device
    eeg_sample_rate = 1/(time(2) - time(1));
    CFG.eeg_sample_rate = eeg_sample_rate;
    
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
    [groupid, ~, arduino, DI] = convert_to_ts(groupid, [], arduino, DI, [], CFG);
    
    
    
    assert(numel(groupid) == num_events, 'number of groupid triggers is not equal to the number of events')
    assert(numel(arduino) == num_events, 'number of arduino triggers is not equal to the number of events')
    assert(numel(DI) == num_events, 'number of DI triggers is not equal to the number of events')
    
    % calculate delay of the DI channel
    
    delay_ms(filei, 1:num_events) = 1000*(DI - arduino)/eeg_sample_rate;
    % calculate delay of the groupid channel
    delay_G_Ard_ms(filei, 1:num_events) = 1000*(groupid - arduino)/eeg_sample_rate;
    
    disp(numel(find(delay_ms(filei,:) < 0)))
    %keyboard
    
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

num_setups = size(setup_labels,1);
max_trials_per_setting = max(trials_per_setting);
num_files = size(delay_ms, 1);
num_events = size(delay_ms, 2);

resh_delay_ms = NaN(num_setups, max_trials_per_setting * num_events);

for exp_idx = 1:num_setups
    %file_idx = 1+(exp_idx-1)*trials_per_setting:exp_idx*trials_per_setting;
    file_idx = sum(trials_per_setting(1:exp_idx-1)) + 1 : sum(trials_per_setting(1:exp_idx));
    cur_delays = delay_ms(file_idx, :);
    total_num_trials = trials_per_setting(exp_idx) * num_events;
    resh_delay_ms(exp_idx, 1:total_num_trials) = reshape(cur_delays, total_num_trials, 1);
end

x = 1:num_setups;
y = nanmean(resh_delay_ms,2);
yneg = nanstd(resh_delay_ms, [], 2)/2;
ypos = yneg;
xneg = zeros(1,num_setups);
xpos = zeros(1,num_setups);
figure();
errorbar(x,y,yneg,ypos,xneg,xpos,'o')
xlim([0.5,num_setups+0.5])
xticks(1:num_setups)
xlabel('Set-up #')
ylabel('Digital input delay relative to arduino, ms')
%ylim([0, 1.1*max(resh_delay_ms(:))])
ylim([0, 900])
grid on


for i=1:num_setups
    text(x(i) + 0.1, y(i), setup_labels{i}, 'Interpreter', 'latex')
end
set(gca, 'fontsize', 14)

%% visualize delay_G_Ard_ms

resh_delay_G_Ard_ms = NaN(num_setups, max_trials_per_setting * num_events);

for exp_idx = 1:num_setups
    %file_idx = 1+(exp_idx-1)*trials_per_setting:exp_idx*trials_per_setting;
    file_idx = sum(trials_per_setting(1:exp_idx-1)) + 1 : sum(trials_per_setting(1:exp_idx));
    cur_delays = delay_G_Ard_ms(file_idx, :);
    total_num_trials = trials_per_setting(exp_idx) * num_events;
    resh_delay_G_Ard_ms(exp_idx, 1:total_num_trials) = reshape(cur_delays, total_num_trials, 1);
end

x = 1:num_setups;
y = nanmean(resh_delay_G_Ard_ms,2);
yneg = nanstd(resh_delay_G_Ard_ms, [], 2)/2;
ypos = yneg;
xneg = zeros(1,num_setups);
xpos = zeros(1,num_setups);
figure();
errorbar(x,y,yneg,ypos,xneg,xpos,'o')
xlim([0.5,num_setups+0.5])
xticks(1:num_setups)
xlabel('Set-up #')
ylabel('GroupID delay relative to arduino, ms')
ylim([0, 1.1*max(resh_delay_G_Ard_ms(:))])
%ylim([0, 900])
grid on

for i=1:num_setups
    text(x(i) + 0.1, y(i), setup_labels{i}, 'Interpreter', 'latex')
end
set(gca, 'fontsize', 14)
