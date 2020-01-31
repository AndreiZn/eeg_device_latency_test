figure();
plot(time, 5*tap_init - 3.7, 'linewidth', 2.5)
hold on
plot(time, groupid_init, 'linewidth', 2.5);
xlabel('Time, s')
ylabel('Amplitude')
legend('EEG channel data', 'groupid')
set(gca, 'fontsize', 20)

figure();
plot(time, 5*tap_init - 3.7, 'linewidth', 2.5)
hold on
plot(time, groupid_init, 'linewidth', 2.5);
plot(time, 1.2*arduino_init, 'linewidth', 2.5)
xlabel('Time, s')
ylabel('Amplitude')
legend('EEG channel data', 'groupid', 'arduino')
set(gca, 'fontsize', 20)