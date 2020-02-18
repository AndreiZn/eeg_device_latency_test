function [first_trig] = find_first_trig(s, event_length_s, sample_rate)

event_length_tp = event_length_s * sample_rate;
eps = 20; % time_samples - possible error of event length

change_tp = find(diff([0,s]));
all_trig_moments = find(s(change_tp) == 1);

fl = 1;
i = 1;
while fl
    
    first_trig = change_tp(all_trig_moments(i));
    end_of_first_trig = change_tp(all_trig_moments(i)+1);
    
    if abs(end_of_first_trig - first_trig - event_length_tp) < eps
        fl = 0;
    end
    
    i = i + 1;
    
end