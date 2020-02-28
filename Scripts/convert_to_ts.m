function [G, TP, ARD, DI] = convert_to_ts(gid, acc, ard, di, tap_ch_type, CFG)

%% groupid processing
first_gid = find(gid >= 1,1);
gid(1:first_gid-1) = 0;
try
last_gid = find(gid >= 1); last_gid = last_gid(end);
catch
    keyboard
end
gid(last_gid+1:end) = 0;

gid_idx = find(diff([gid,0]));
G = gid_idx(1:2:end);

sample_rate = CFG.eeg_sample_rate;
event_length_s = CFG.event_length_s;
image_appearance_time_s = CFG.image_appearance_time_s;
freq_of_tapping = 1/event_length_s; % Hz
% we will check windows of w_size width and find there a maximum peak -
% at each channel; the peak occurs at the moments when there was tapping;
w_size = round(sample_rate/freq_of_tapping); % time-points

%% accelerometer data processing
if ~isempty(tap_ch_type)
    % we will check windows of w_size width and find there a maximum peak -
    % at each channel; the peak occurs at the moments when there was tapping;
    w_size = sample_rate/freq_of_tapping; % time-points
    w_num = 1;
    
    num_t_samples = size(acc,2);
    tapping_channel = zeros(1,num_t_samples);
    
    for t_idx = 1:w_size:num_t_samples-w_size
        s_cur = acc(1, t_idx:t_idx+w_size-1);
        if strcmp(tap_ch_type, 'acc')
            [~, max_idx] = max(s_cur);
            abs_max_idx = max_idx + w_size*(w_num-1);
            tapping_channel(abs_max_idx) = -1;
        else
            [~, min_idx] = min(s_cur);
            abs_min_idx = min_idx + w_size*(w_num-1);
            tapping_channel(abs_min_idx) = -1;
        end
        w_num = w_num + 1;
    end
    
    last_gid = G(end);
    tapping_channel(1, 1:first_gid - w_size) = 0;
    tapping_channel(1, last_gid+1:end) = 0;
    TP = find(tapping_channel);
else
    TP = [];
end
%% arduino data

%ard(1:first_gid-w_size) = 0;

try
    ard_first = find_first_trig(ard, image_appearance_time_s, sample_rate);
catch
    keyboard
end
ard_step = w_size;
ard_range = 40; % time points

ARD = zeros(1,numel(G));
ARD(1) = ard_first;

for i=2:numel(G)
    new_point_estimate = NaN(i-1,1);
    for j=1:i-1
        prev_point = ARD(j);
        num_steps = i - j;
        new_point_estimate(j,1) = ARD(j) + num_steps*ard_step;
    end
    ard_cur = round(nanmean(new_point_estimate));
    ard_cur_range = ard_cur - ard_range:min(ard_cur + ard_range, numel(ard));
    ard_trig = ard_cur_range(find(diff(ard(ard_cur_range)),1));
    if ~isempty(ard_trig)
        ARD(i) = ard_cur_range(find(diff(ard(ard_cur_range)),1));
    else
        ARD(i) = ard_cur;
    end
end

%% DI data

% check that the DI data is not changing before the first event (use grouid
% to identify the first event approximately)
% w_left = 1*sample_rate; % 1sec in time-points
%
% if ~isempty(find(diff(di(1:first_gid-w_left)),1))
%     di(1:first_gid-w_left) = 0;
% end
%
% di = find(diff([di,0]));
% DI = di(1:2:end);

di_first = find_first_trig(di, image_appearance_time_s, sample_rate);
di_step = w_size;
di_range = 40; % time points

DI = zeros(1,numel(G));
DI(1) = di_first;

for i=2:numel(G)
    di_cur = di_first + (i-1)*di_step;
    di_cur_range = di_cur - di_range:di_cur + di_range;
    try
        DI(i) = di_cur_range(find(diff([di(di_cur_range),0]),1));
    catch
        keyboard
    end
end
