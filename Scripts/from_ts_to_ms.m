function [arr_ms] = from_ts_to_ms(arr, sample_rate)

arr_ms = round(1000*arr/sample_rate);