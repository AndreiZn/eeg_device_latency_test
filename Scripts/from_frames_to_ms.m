function arr_ms = from_frames_to_ms(arr, video_fps)

arr_ms = round(1000*arr/video_fps);