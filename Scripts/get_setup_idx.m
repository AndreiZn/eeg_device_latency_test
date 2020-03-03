function [idx] = get_setup_idx(filei, trials_per_setting)

for j=1:numel(trials_per_setting)
    if filei <= sum(trials_per_setting(1:j))
        idx = j;
        break;
    end
end