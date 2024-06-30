clear; clc; close all; fclose all; format long;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Simulation settings 335328744369150
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Doppler Channel Interpolation method
    doppler_ch_interp_method = 'spline';
% Equalization Interpolation method
    interp_method = 'linear';
% Apply frequency offset compensation
    CFO_COMP = false;
% Use ideal values in frequency offset compensation
    CFO_IDEAL = false;
% Use ideal doppler shift factor in calculating resample ratio
    DOPPLER_IDEAL = true;
% Use TA estimate and compensation
    TA_COMP = false;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% OFDM Parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Fc = 250000;                % Center frequency of OFDM signal
M = 16;                     % Modulation Order
BW = 250000;                % Bandwidth = complex FS

snr_db = 1;                % AWGN in dB
multipath = [0.5,0.5,0,1,0,0.3];          % Multipath taps at baseband
%multipath = 1;
speed = 0;               % Speed of Tx or Rx in m/s
cfo = 30;                    % Carrier Frequency offset at baseband

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fixed Values
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nfft_zc = 4096;                       % NFFT for Zadoff-Chu sequence
cp = 256;                             % Cyclic prefix for data symbol
cp_offset = 0;                        % Offset of actual CP forced
zc_doppler_percent = 0.7;             % ZC samp to use for doppler estimate
zero_samples = 16384;                  % Number of zeros in between
ZC_root = 13;                         % Zadoff-Chu root index
ZC_length = nfft_zc/2;                % Zadoff-Chu Sequence Length
DAC_FS = 40000000;                    % Dac sample rate
nfft_p = 32*nfft_zc;                  % NFFT for plotting spectrum
speed_sound = 1500;                   % Speed of sound underwater
num_fir_taps = 4096;                  % Number of FIR taps for DUC/DDC
duc_ddc_loss_gain = 1.8;                % Loss of Matlab DUC
ZP_density = 30;            % Zero Padded Pilot Density
pilot_density = 0.5;                  % Pilot to data ratio

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculated OFDM Parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
scs = BW/nfft_zc;
Fs = BW; % Sample frequency (complex) = bandwidth
Interp_val = DAC_FS/Fs; % Interpolation value
Ts = 1/Fs; % Sampling period
Ts_up = 1/DAC_FS;
t = 0:Ts:4096*20*Ts-Ts;
F = (-nfft_p/2:nfft_p/2-1)/nfft_p*Fs; % Plotting baseband spectrum
F_up = (-nfft_p/2:nfft_p/2-1)/nfft_p*DAC_FS; % Plotting DUC spectrum
fir_taps = fir1(num_fir_taps,1/(DAC_FS/Fs));
fir_taps = fir_taps / sqrt(sum(fir_taps.^2));
filter_delay = floor(length(fir_taps)/2);
multipath = multipath/sum(multipath);
% Carrier Allocation
rep = 1/pilot_density;          % Data to pilot repetition
zp_carriers = floor(nfft_zc*ZP_density/100/2)*2; % Even Number of ZP carriers
zp_index = [1:zp_carriers/2,nfft_zc/2,nfft_zc/2+1,nfft_zc-zp_carriers/2+1:nfft_zc];
zp_carriers = zp_carriers + 2;  % Account for 2 ZP carriers around DC
pilot_index=[zp_carriers/2:rep:nfft_zc/2-1, ...
    nfft_zc/2+2:rep:nfft_zc-zp_carriers/2];
if zp_index(end/2+2)-1 ~= pilot_index(end)
    pilot_index = [pilot_index zp_index(end/2+2)-1];
end
index = find(pilot_index == nfft_zc/2-1);
if isempty(index)
    index = find(pilot_index == nfft/2-2);
    pilot_index = [pilot_index(1:index) nfft/2-1 pilot_index(index+1:end)];
end
pilot_carriers = length(pilot_index);
data_index = 1:nfft_zc;
data_index([pilot_index,zp_index]) = [];
data_carriers = length(data_index);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Generate Pilot Data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
rng default
pilot_data = randsrc(pilot_carriers,1,0:M-1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Generate Message Data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
rng default
tx_data = randsrc(data_carriers,1,0:M-1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% QAM Modulation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
qam_mod_data = qammod(tx_data,M);
reference_pilot = qammod(pilot_data,M);
zp_carrier = complex(0,0);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Carrier Allocation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FFT carriers of Data, Pilot and ZP carriers
carriers = zeros(nfft_zc,1);
carriers(pilot_index) = reference_pilot;
carriers(data_index) = qam_mod_data;
carriers(zp_index) = zp_carrier;
tx_pilot_data = carriers;
ifft_data = ifft(ifftshift(carriers),nfft_zc).';
cp_data = ifft_data(nfft_zc-cp+1:nfft_zc);
ifft_data = [cp_data ifft_data];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Synchronization   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Create Zadoff-Chu sequence
% sync_tx = log2(M)/sqrt(2)*exp(-1i*pi*ZC_root*(1:ZC_length).* ...
%     ((1:ZC_length)+1)/ZC_length); % ZC sequence
sync_tx_i = cos(pi*ZC_root*(1:ZC_length).* ...
    ((1:ZC_length)+1)/ZC_length);
sync_tx_q = -sin(pi*ZC_root*(1:ZC_length).* ...
    ((1:ZC_length)+1)/ZC_length);
sync_tx = complex(sync_tx_i,sync_tx_q);
sync_tx_zp = [zeros(1,(nfft_zc-ZC_length)/2),sync_tx,zeros(1, ...
    (nfft_zc-ZC_length)/2)]; % Add ZP and center ZC sequence in BW
sync_tx_time = ifft(ifftshift(sync_tx_zp),nfft_zc);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DUC
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ifft_data = ifft_data * max(abs(sync_tx_time))/max(abs(ifft_data));
up_signal = upsample([sync_tx_time zeros(1,zero_samples) sync_tx_time ...
    zeros(1,nfft_zc) ifft_data zeros(1,nfft_zc)].', Interp_val);
up_signal = [up_signal;zeros(filter_delay,1)];
ofdm_duc_signal = filter(fir_taps, 1, up_signal).'*7;
ofdm_duc_signal(1:filter_delay) = [];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% IQ Mixer TX
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Use oscillator at Fc for IQ mixer
t_up = 0:1/DAC_FS:length(ofdm_duc_signal)/DAC_FS-1/DAC_FS;
ofdm_duc_signal_i = real(ofdm_duc_signal) .* cos(2*pi*Fc*t_up);
ofdm_duc_signal_q = imag(ofdm_duc_signal) .* -sin(2*pi*Fc*t_up);
ofdm_duc_signal_real = ofdm_duc_signal_i + ofdm_duc_signal_q;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Channel
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% No Channel
ofdm_tx_signal_ch = ofdm_duc_signal_real;

% AWGN
snr = 10^(snr_db/10); % Noise power
ofdm_duc_signal_real_pwr = mean(abs(ofdm_duc_signal_real).^2);
noise_pwr = ofdm_duc_signal_real_pwr/snr;
noise = sqrt(noise_pwr) .* randn(size(ofdm_duc_signal_real));
ofdm_tx_signal_ch1 = ofdm_duc_signal_real + noise;

% doppler
k = (1+speed/speed_sound); % doppler shift factor
ofdm_tx_signal_doppler = interp1(t_up,ofdm_tx_signal_ch1,t_up/k, ...
    doppler_ch_interp_method,0);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% IQ Mixer RX
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% No Channel
i_ddc = ofdm_tx_signal_ch .* cos(2*pi*Fc*t_up);
q_ddc = ofdm_tx_signal_ch .* -sin(2*pi*Fc*t_up);
ddc_signal = complex(i_ddc,q_ddc);

% Doppler Channel
i_ddc_doppler = ofdm_tx_signal_doppler .* cos(2*pi*Fc*t_up);
q_ddc_doppler = ofdm_tx_signal_doppler .* -sin(2*pi*Fc*t_up);
ddc_signal_doppler = complex(i_ddc_doppler,q_ddc_doppler);

% Apply Carrier Frequency Offset
ddc_signal_doppler = ddc_signal_doppler .* exp(1i*2*pi*cfo*t_up);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DDC
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% No Channel
ddc_stage2 = [ddc_signal zeros(1,filter_delay)];
ddc_stage2_out = filter(fir_taps,1,ddc_stage2);
ddc_stage2_out(1:filter_delay) = [];
ddc_base_signal = downsample(ddc_stage2_out,Interp_val)/7.2;

% Doppler Channel
ddc_doppler_real = ...
    decimate(real(ddc_signal_doppler),Interp_val,4096,'Fir');
ddc_doppler_imag = ...
    decimate(imag(ddc_signal_doppler),Interp_val,4096,'Fir');
ddc_doppler = complex(ddc_doppler_real,ddc_doppler_imag);
ddc_doppler = duc_ddc_loss_gain * ddc_doppler;

% Apply Multipath taps
ddc_doppler = filter(multipath,1,ddc_doppler);

sig_len = length(ddc_doppler);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Synchronization
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% No Channel
sync_coef = conj(fliplr(sync_tx_time)); % Matched Filter
sync_corr_filt = abs(filter(sync_coef,1,ddc_base_signal));
[sorted,indices] = sort(sync_corr_filt,'descend');
ind = sort(indices(1:2),'ascend');

% Doppler Channel
sync_corr_doppler = abs(filter(sync_coef,1,ddc_doppler));
[sorted2,indices2] = sort(sync_corr_doppler,'descend');
ind2 = sort(indices2(1:2),'ascend');
for i=1:10
    if ((ind2(1)<(ind(1)-1000))||(ind2(1)>ind(1)+1000))
        indices2(2) = [];
    elseif ((ind2(2)<(ind(2)-1000))||(ind2(2)>ind(2)+1000))
        indices2(2) = [];
    end
    ind2 = sort(indices2(1:2),'ascend');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Doppler estimation with ZC sequence correlation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sample_begin1 = ind2(1)-floor(nfft_zc*zc_doppler_percent-1);
sample_end1 = ind2(1);
sample_begin2 = ind2(2)-floor(nfft_zc*zc_doppler_percent-1);
sample_end2 = ind2(2);
zc_begin = ddc_doppler(sample_begin1:sample_end1);
zc_end = ddc_doppler(sample_begin2:sample_end2);
tmp = zc_end.*conj(zc_begin); % Correlate
sum_val = sum(tmp);
tan_val = atan2(imag(sum_val),real(sum_val));
normalized_corr_est = 1*tan_val;
corr_est_zc = normalized_corr_est*scs;
if CFO_IDEAL
    corr_est_zc = 2*pi*-cfo;
end
corr_est_doppler_zc = corr_est_zc/2/pi;
if CFO_COMP
    ddc_doppler = ddc_doppler.* ...
        (cos(corr_est_zc*t(1:sig_len))+1i*sin(corr_est_zc*t(1:sig_len)));
end
%k_est_corr = normalized_corr_est/Fc+1;
k_est_corr = corr_est_zc/Fc+1;

%k_est_corr = corr_est_doppler_zc/Fc+1;
cfo_corr_est = -corr_est_doppler_zc;
table(cfo,cfo_corr_est)
table(k,k_est_corr)
doppler_shift_at_Fc = Fc*(k-1);
doppler_shift_at_Fc_corr_est = Fc*(k_est_corr-1);
table(doppler_shift_at_Fc,doppler_shift_at_Fc_corr_est)

zc_corr = xcorr(zc_begin,zc_end);
[~,idx_zc] = max(abs(zc_corr));
phase_shift = angle(zc_corr(idx_zc));
estimated_f_offset = phase_shift / (2*pi*length(zc_begin)/Fs)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Take FFT of ZC sequence
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sample_begin1 = ind2(1)-nfft_zc+1;
sample_begin2 = ind2(2)-nfft_zc+1;
sample_begin3 = ind2(2)+nfft_zc+cp;
zc_freq0 = zeros(nfft_zc,3); zc_freq_eq = zeros(nfft_zc,3);
zc_freq0(:,1) = ddc_doppler(sample_begin1:sample_end1);
zc_freq0(:,2) = ddc_doppler(sample_begin2:sample_end2);
zc_freq0(:,3) = ddc_doppler(sample_begin3+cp_offset:sample_begin3+nfft_zc...
    -1+cp_offset);
for i=1:3
    zc_freq(:,i) = fftshift(fft(zc_freq0(:,i),nfft_zc));
end

% Equalize first ZC sequence
H_zp1 = conj(zc_freq(:,1)) ./ conj(sync_tx_zp).';
H_zp1(isinf(H_zp1)) = 0;
e_pa = 0;
for K=1:nfft_zc-2
    e_pa = e_pa + H_zp1(K) * H_zp1(K+2)';
end
TA_est = angle(e_pa)*nfft_zc/(2*pi*4)
TA_comp = exp(1j*2*pi*(1:nfft_zc)'.*TA_est/nfft_zc);
if TA_COMP
    H_zp1 = H_zp1 .* TA_comp;
end
zc_freq_eq(:,1) = zc_freq(:,1) ./ conj(H_zp1);
zc_freq_eq(isinf(zc_freq_eq)) = 0;
cfo_est_freq = -angle(mean(H_zp1))/pi*scs;
% figure(),plot(abs(H_zp1))
H_zp2 = conj(zc_freq(:,2)) ./ conj(sync_tx_zp).';
zc_freq_eq(:,2) = zc_freq(:,2) ./ conj(H_zp2);
H_zp2_zp1 = conj(zc_freq(:,2)) ./conj(zc_freq(:,1));
H_zp2(isinf(H_zp2)) = 0; H_zp2_zp1(isinf(H_zp2_zp1)) = 0;
e_pa2 = 0;
for K=1:nfft_zc-2
    e_pa2 = e_pa2 + H_zp2(K) * H_zp2(K+2)';
end
TA_est2 = angle(e_pa2)*nfft_zc/(2*pi*4)
TA_comp2 = exp(1j*2*pi*(1:nfft_zc)'.*TA_est2/nfft_zc);
if TA_COMP
    H_zp2 = H_zp2 .* TA_comp2;
    H_zp2_zp1 = H_zp2_zp1 .* TA_comp2;
end
cfo_est_freq2 = -angle(mean(H_zp2))/pi*scs;
cfo_est_freq3 = -angle(mean(H_zp2_zp1))/pi*scs;
table(cfo,cfo_est_freq,cfo_est_freq2/11,cfo_est_freq3)
figure(),subplot(2,2,1),scatter(real(zc_freq(:,1)),imag(zc_freq(:,1)),'.')
title('RX ZC'),subplot(2,2,2),scatter(real(zc_freq_eq(:,1)),...
    imag(zc_freq_eq(:,1)),'.'),title('RX ZC EQ'),subplot(2,2,3)
scatter(real(zc_freq(:,2)),imag(zc_freq(:,2)),'.'),title('RX ZC2')
subplot(2,2,4),scatter(real(zc_freq_eq(:,2)),imag(zc_freq_eq(:,2)),'.')
title('RX ZC2 EQ')

zc_freq_corr = zc_freq(:,1) .* conj(zc_freq(:,2));
%zc_freq_corr = zc_freq(:,1) .* conj(sync_tx_zp.');
zc_time_corr = ifft(ifftshift(zc_freq_corr,nfft_zc));
return
figure(),plot(real(zc_time_corr))

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Equalize data symbol
P_RX = zc_freq(pilot_index,3);
P_TX = reference_pilot;

% LS Channel Estimate
H = conj(P_RX) ./ conj(P_TX);
% Timing offset estimation
e_pa = 0;
for K=1:pilot_carriers-2
    e_pa = e_pa + H(K)*H(K+2)';
end
TA_est = angle(e_pa)*nfft_zc/(2*pi*4)
TA_comp = exp(1j*2*pi*(1:nfft_zc)'.*TA_est/nfft_zc);
TA_comp_H = TA_comp(pilot_index);
% H = H .* TA_comp_H;
% zc_freq(:,3) = zc_freq(:,3) .* TA_comp;
H_interp = interp1(pilot_index,H,1:nfft_zc,interp_method,"extrap");
zc_freq(:,3) = zc_freq(:,3) ./ conj(H_interp).';

figure(),subplot(2,2,2),scatter(real(zc_freq(:,1)),imag(zc_freq(:,2)),'.')
title('RX ZC Sequence 1'),subplot(2,2,3),scatter(real(zc_freq(:,2)), ...
    imag(zc_freq(:,2)),'.'),title('RX ZC Sequence 2'),subplot(2,2,1)
scatter(real(sync_tx_zp),imag(sync_tx_zp),'.'),title('TX ZC Sequence')
subplot(2,2,4),scatter(real(zc_freq(:,3)),imag(zc_freq(:,3)),'.')
title('Equalized Data Symbol'),sgtitle('Before Re-Sampling')

% Plot %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
t_p = 0:Ts:length(sync_corr_filt)*Ts-Ts;
line_label = ["Sync 1", "Sync 2"];
figure(),subplot(3,1,1),plot(t_p/1000,real(ddc_base_signal),'LineWidth',...
    2),hold on,plot(t_p/1000,real(ddc_doppler))
for i = 1:2
    xline(ind(i)*Ts/1000,'--b',line_label{i});
    xline(ind2(i)*Ts/1000,'--r',line_label{i},'LabelVerticalAlignment',...
        'bottom');
end
legend('No Channel','UW-A Channel','No Channel Sync','UW-A Channel Sync')
xlabel('Time (ms)'),title('Baseband In-Phase')
subplot(3,1,2),plot(t_p/1000,imag(ddc_base_signal),'LineWidth',2),hold on
plot(t_p/1000,imag(ddc_doppler))
for i = 1:2
    xline(ind(i)*Ts/1000,'--b',line_label{i});
    xline(ind2(i)*Ts/1000,'--r',line_label{i},'LabelVerticalAlignment',...
        'bottom');
end
legend('No Channel','UW-A Channel','No Channel Sync','UW-A Channel Sync')
xlabel('Time (ms)'),title('Baseband Quadrature')
subplot(3,1,3),plot(t_p/1000,sync_corr_filt,'LineWidth',2),hold on
plot(t_p/1000,sync_corr_doppler)
for i = 1:2
    xline(ind(i)*Ts/1000,'--b',line_label{i});
    xline(ind2(i)*Ts/1000,'--r',line_label{i},'LabelVerticalAlignment',...
        'bottom');
end
legend('No Channel','UW-A Channel','No Channel Sync','UW-A Channel Sync')
xlabel('Time (ms)'),title('Synchronizer Correlator Output Before Re-Samp')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Simple doppler estimation by correlator peak output difference
sync_peak_offset1 = ind(1)-ind2(1);
sync_peak_offset2 = ind(2)-ind2(2);
sync_peak_offset_diff = ind(2)-ind(1);
sync_peak_offset_diff_doppler = ind2(2)-ind2(1);
peak_diff_k_est = sync_peak_offset_diff_doppler/sync_peak_offset_diff;
speed_est = (peak_diff_k_est-1)*speed_sound;
table(sync_peak_offset1,sync_peak_offset2)
table(sync_peak_offset_diff,sync_peak_offset_diff_doppler)
table(speed,k,peak_diff_k_est,speed_est)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Resample
if DOPPLER_IDEAL
    P = DAC_FS/k/Interp_val; Q = DAC_FS/Interp_val;
    ratio_actual = Q/P;
    if P*Q >= 2^31
        re_scale = 2^31/(P*Q);
        P = floor(P*sqrt(re_scale));
        Q = floor(Q*sqrt(re_scale));
    end
    ratio_scaled = Q/P;
    table(ratio_actual,ratio_scaled)
    ddc_doppler_resamp = resample(ddc_doppler,P,Q);
    if length(ddc_doppler) > length(ddc_doppler_resamp)
        ddc_doppler_resamp = [ddc_doppler_resamp ...
            zeros(1,length(ddc_doppler)-length(ddc_doppler_resamp))];
    elseif length(ddc_doppler) < length(ddc_doppler_resamp)
        ddc_doppler_resamp = [ddc_doppler_resamp(length(ddc_doppler))];
    end
else
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Synchronize doppler Channel
sync_corr_doppler_resamp = abs(filter(sync_coef,1,ddc_doppler_resamp));
[~,indices3] = sort(sync_corr_doppler_resamp,'descend');
ind3 = sort(indices3(1:2),'ascend');
for i=1:10
    if ((ind3(1)<(ind(1)-1000))||(ind3(1)>ind(1)+1000))
        indices3(2) = [];
    elseif ((ind3(2)<(ind(2)-1000))||(ind3(2)>ind(2)+1000))
        indices3(2) = [];
    end
    ind3 = sort(indices3(1:2),'ascend');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Take FFT of ZC sequence
sample_begin11 = ind3(1)-nfft_zc+1;
sample_begin22 = ind3(2)-nfft_zc+1;
sample_begin33 = ind3(2)+nfft_zc+cp;
sample_end11 = ind3(1);
sample_end22 = ind3(2);
zc_freq = zeros(nfft_zc,2);
zc_freq(:,1) = ddc_doppler_resamp(sample_begin11:sample_end11);
zc_freq(:,2) = ddc_doppler_resamp(sample_begin22:sample_end22);
zc_freq(:,3) = ddc_doppler_resamp(sample_begin33+cp_offset:sample_begin33+nfft_zc-1+cp_offset);
for i=1:3
    zc_freq(:,i) = fftshift(fft(zc_freq(:,i),nfft_zc));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Equalize data symbol
P_RX = zc_freq(pilot_index,3);
P_TX = reference_pilot;

% LS Channel Estimate
H = conj(P_RX) ./ conj(P_TX);
% Timing offset estimation
e_pa = 0;
for K=1:pilot_carriers-2
    e_pa = e_pa + H(K)*H(K+2)';
end
TA_est = angle(e_pa)*nfft_zc/(2*pi*4)
TA_comp = exp(1j*2*pi*(1:nfft_zc)'.*TA_est/nfft_zc);
TA_comp_H = TA_comp(pilot_index);
% H = H .* TA_comp_H;
% zc_freq(:,3) = zc_freq(:,3) .* TA_comp;
H_interp = interp1(pilot_index,H,1:nfft_zc,interp_method,"extrap");
zc_freq(:,3) = zc_freq(:,3) ./ conj(H_interp).';

figure(),subplot(2,2,2),scatter(real(zc_freq(:,1)),imag(zc_freq(:,2)),'.')
title('RX ZC Sequence 1'),subplot(2,2,3),scatter(real(zc_freq(:,2)), ...
    imag(zc_freq(:,2)),'.'),title('RX ZC Sequence 2'),subplot(2,2,1)
scatter(real(sync_tx_zp),imag(sync_tx_zp),'.'),title('TX ZC Sequence')
subplot(2,2,4),scatter(real(zc_freq(:,3)),imag(zc_freq(:,3)),'.')
title('Equalized Data Symbol'),sgtitle('After Re-Sampling')

% Plot %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
t_p = 0:Ts:length(sync_corr_filt)*Ts-Ts;
line_label = ["Sync 1", "Sync 2"];
figure(),subplot(3,1,1),plot(t_p/1000,real(ddc_base_signal),'LineWidth',...
    2),hold on,plot(t_p/1000,real(ddc_doppler_resamp))
for i = 1:2
    xline(ind(i)*Ts/1000,'--b',line_label{i});
    xline(ind3(i)*Ts/1000,'--r',line_label{i},'LabelVerticalAlignment',...
        'bottom');
end
legend('No Channel','UW-A Channel','No Channel Sync','UW-A Channel Sync')
xlabel('Time (ms)'),title('Baseband In-Phase')
subplot(3,1,2),plot(t_p/1000,imag(ddc_base_signal),'LineWidth',2),hold on
plot(t_p/1000,imag(ddc_doppler_resamp))
for i = 1:2
    xline(ind(i)*Ts/1000,'--b',line_label{i});
    xline(ind3(i)*Ts/1000,'--r',line_label{i},'LabelVerticalAlignment',...
        'bottom');
end
legend('No Channel','UW-A Channel','No Channel Sync','UW-A Channel Sync')
xlabel('Time (ms)'),title('Baseband Quadrature')
subplot(3,1,3),plot(t_p/1000,sync_corr_filt,'LineWidth',2),hold on
plot(t_p/1000,sync_corr_doppler_resamp)
for i = 1:2
    xline(ind(i)*Ts/1000,'--b',line_label{i});
    xline(ind3(i)*Ts/1000,'--r',line_label{i},'LabelVerticalAlignment',...
        'bottom');
end
legend('No Channel','UW-A Channel','No Channel Sync','UW-A Channel Sync')
xlabel('Time (ms)'),title('Synchronizer Correlator Output')