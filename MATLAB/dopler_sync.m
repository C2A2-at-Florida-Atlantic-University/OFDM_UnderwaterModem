clear; clc; close all; fclose all; format long;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% OFDM Parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
EQUALIZATION_METHOD = "ZF"; % "ZF", "MMSE", or "Averaged ZF"

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% OFDM Parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nfft = 1024;
nfft_zc = 4096;
BW = 312500;
cp_len = 1024;
M = 16;
ZP_density = 30;
gp_samples = 1024;
ofdm_symbols = 3;
Fc = 275000;
ZC_root = 13;
dopler_cp_offset = round(cp_len/16);
%dopler_cp_offset = 0;

% Gain Parameters
tx_scale = 10336;
extra_sync_gain = 4;
duc_ddc_loss_gain = 2;

% Channel parameters
snr_db = 150;
speed = -1; % In m/s

cfo = 0;
cpo = 0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fixed Values
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ZC_length = nfft_zc/2;          % Zadoff-Chu Sequence Length
sync_samples_early = 0;         % Number of samples to synchronize early
force_dopler_sync = 0;         % Force dopler synchronization
pilot_density = 0.5;            % Pilot to data ratio
DAC_FS = 10000000;              % Dac sample rate
nfft_p = 16*nfft;               % NFFT for plotting spectrum
speed_sound = 1500;             % Speed of sound underwater

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculated OFDM Parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Carrier Allocation
rep = 1/pilot_density;          % Data to pilot repetition
zp_carriers = round(nfft*ZP_density/100/2)*2; % Even Number of ZP carriers
zp_index = [1:zp_carriers/2,nfft/2,nfft/2+1,nfft-zp_carriers/2+1:nfft];
zp_carriers = zp_carriers + 2;  % Account for 2 ZP carriers around DC
pilot_index=[zp_carriers/2:rep:nfft/2-1,nfft/2+2:rep:nfft-zp_carriers/2];
if zp_index(end/2+2)-1 ~= pilot_index(end)
    pilot_index = [pilot_index zp_index(end/2+2)-1];
end
pilot_carriers = length(pilot_index);
data_index = 1:nfft;
data_index([zp_index,pilot_index]) = [];
data_carriers = length(data_index);
% Other Parameters
scs = BW/nfft;
num_data_bits = length(data_index)*ofdm_symbols;
Fs = BW; % Sample frequency (complex) = bandwidth
Interp_val = DAC_FS/Fs; % Interpolation value
Ts = 1/Fs; % Sampling period
Ts_up = 1/DAC_FS;
F = (-nfft_p/2:nfft_p/2-1)/nfft_p*Fs; % Plotting baseband spectrum
F_up = (-nfft_p/2:nfft_p/2-1)/nfft_p*DAC_FS; % Plotting DUC spectrum
cp_used = cp_len - 2*dopler_cp_offset;
Max_Freq_offset = 2*scs*(cp_used/nfft);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Generate Pilot Data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
rng default
pilot_data = randsrc(pilot_carriers,ofdm_symbols,0:M-1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Generate Message Data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
rng default
tx_data = randsrc(data_carriers,ofdm_symbols,0:M-1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% QAM Modulation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
qam_mod_data = qammod(tx_data,M);
reference_pilot = qammod(pilot_data,M);
zp_carrier = complex(0,0);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Synchronization
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Create Zadoff-Chu sequence
sync_tx = log2(M)/sqrt(2)*exp(-1i*pi*ZC_root*(1:ZC_length).* ...
    ((1:ZC_length)+1)/ZC_length); % ZC sequence
sync_tx_zp = tx_scale*[zeros(1,(nfft_zc-ZC_length)/2),sync_tx,zeros(1, ...
    (nfft_zc-ZC_length)/2)]; % Add ZP and center ZC sequence in BW
sync_tx_time = ifft(ifftshift(sync_tx_zp),nfft_zc) * extra_sync_gain;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Carrier Allocation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FFT carriers of Data, Pilot and ZP carriers
carriers = zeros(nfft,ofdm_symbols);
carriers(pilot_index,:) = reference_pilot;
carriers(data_index,:) = qam_mod_data;
carriers(zp_index,:) = zp_carrier;
carriers = carriers * tx_scale;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% IFFT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Ifftshift to reorder carriers in correct order for IFFT
ifft_sub_carriers = zeros(nfft,ofdm_symbols);
for i = 1:ofdm_symbols % In loop so Ifftshift works per symbol
    ifft_sub_carriers(:,i) = ifft(ifftshift(carriers(:,i)),nfft);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CP and GP Insertion
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cp_start = nfft-cp_len;
cp = ifft_sub_carriers(cp_start+1:end,:);            % Obtain CP
ofdm_tx_signal_par = vertcat(cp,ifft_sub_carriers);  % Copy CP
gp = zeros(gp_samples,ofdm_symbols);       % Obtain GP
ofdm_tx_signal_par = vertcat(ofdm_tx_signal_par,gp); % Copy GP

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Parallel to Serial
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ofdm_tx_signal_ser = reshape(ofdm_tx_signal_par,[(nfft+cp_len+ ...
    gp_samples)*ofdm_symbols, 1]);         % Parallel to Serial
gp = zeros(gp_samples,1);                  % Obtain GP
%ofdm_tx_signal_ser = [sync_tx_time.';gp;ofdm_tx_signal_ser]; % OFDM Frame
ofdm_tx_signal_ser = [sync_tx_time.';sync_tx_time(1:cp_len).' ...
    ;gp;ofdm_tx_signal_ser]; % OFDM Frame

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DUC
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[kdk,fir_taps] = interp(ofdm_tx_signal_ser,Interp_val,10,1);
filter_delay = floor(length(fir_taps)/2);
ofdm_tx_signal_zp = [zeros(filter_delay,1);ofdm_tx_signal_ser; ...
    zeros(filter_delay,1)];
ofdm_duc_signal = interp(ofdm_tx_signal_zp,Interp_val,10,1);
ofdm_duc_signal = ofdm_duc_signal(filter_delay*Interp_val+1:end- ...
    filter_delay*Interp_val);
ofdm_duc_signal = ofdm_duc_signal.';

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

snr = 10^(snr_db/10); % Convert SNR from dB to linear
ofdm_tx_signal_ch = awgn(ofdm_duc_signal_real,snr,'measured');
k = (1+speed/speed_sound); % Dopler shift factor
Lower_BW_Dopler_Shift = ((Fc-(nfft/2 - zp_carriers/2)*scs) * ...
    (1+speed/speed_sound))-(Fc-(nfft/2 - zp_carriers/2)*scs);
Fc_Dopler_Shift = (Fc * (1+speed/speed_sound))-Fc;
Upper_BW_Dopler_Shift = ((Fc+(nfft/2 - zp_carriers/2)*scs) * ...
    (1+speed/speed_sound))- (Fc+(nfft/2 - zp_carriers/2)*scs);
table(cp_used,Max_Freq_offset,scs)
table(Lower_BW_Dopler_Shift,Fc_Dopler_Shift,Upper_BW_Dopler_Shift)
ofdm_tx_signal_dopler = interp1(t_up,ofdm_tx_signal_ch,t_up/k,'linear',0);

% One method to compensate for dopler if estimated k accurately:
%ofdm_tx_signal_dopler = resample(ofdm_tx_signal_dopler,round(DAC_FS/k),DAC_FS);
%ofdm_tx_signal_dopler = ofdm_tx_signal_dopler(1:length(ofdm_tx_signal_ch));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% IQ Mixer RX
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_ddc_dopler = ofdm_tx_signal_dopler .* cos(2*pi*Fc*t_up);
q_ddc_dopler = ofdm_tx_signal_dopler .* -sin(2*pi*Fc*t_up);
ddc_signal_dopler = complex(i_ddc_dopler,q_ddc_dopler);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DDC
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ddc_dopler_real = decimate(real(ddc_signal_dopler),Interp_val,4096,'Fir');
ddc_dopler_imag = decimate(imag(ddc_signal_dopler),Interp_val,4096,'Fir');
ddc_dopler = complex(ddc_dopler_real,ddc_dopler_imag);
ddc_dopler = duc_ddc_loss_gain * ddc_dopler.';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Baseband channel impairments
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
t = 0:Ts:length(ddc_dopler)*Ts-Ts;
ddc_dopler = ddc_dopler .* exp(-1i*2*pi*cfo*t).';
ddc_dopler = ddc_dopler * exp(-1i*cpo);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Synchronization
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sync_coef = conj(fliplr(sync_tx_time)); % Matched Filter
sync_corr_dopler = abs(filter(sync_coef,1,ddc_dopler));
[val2,ind2] = max(sync_corr_dopler);
ind2 = ind2-sync_samples_early+gp_samples+force_dopler_sync;

% Correlate with CP of synchronization symbol
ofdm_rx_sync_dopler = ddc_dopler;
cp_sync_begin = ofdm_rx_sync_dopler(dopler_cp_offset+1:cp_len ...
    -dopler_cp_offset);
cp_sync_end = ofdm_rx_sync_dopler(nfft_zc+1+dopler_cp_offset: ...
    nfft_zc+cp_len-dopler_cp_offset);
conj_val = conj(cp_sync_begin);
tmp = complex(real(cp_sync_end.*conj_val),imag(cp_sync_end.*conj_val));
sum_val = sum(tmp);
tan_val = angle(sum_val);
normalized_cfo_est = 1*tan_val;
cfo_est = normalized_cfo_est*scs;
sync_cfo_est = cfo_est/2/pi;
table(sync_cfo_est)

% Remove Synchronization symbol
ofdm_rx_sync_dopler([1:(ind2 + cp_len), ...
    ind2+cp_len+1+(nfft+cp_len+gp_samples)*ofdm_symbols:end]) = [];
if (length(ofdm_rx_sync_dopler) ~= (nfft+cp_len+gp_samples)*ofdm_symbols)
    tmp = zeros(1,(nfft+cp_len+gp_samples)*ofdm_symbols- ...
        length(ofdm_rx_sync_dopler)).';
    ofdm_rx_sync_dopler = [ofdm_rx_sync_dopler;tmp];
    warning('Deleted too much of dopler signal')
end

t_p = 0:Ts:length(ofdm_tx_signal_ser)*Ts-Ts;
vertical_lines_dopler = zeros(1,ofdm_symbols*3);
line_label = string.empty(0,length(vertical_lines_dopler));
for i=1:ofdm_symbols
    if (i == 1)
        vertical_lines_dopler(i) = ind2 + cp_len;
        line_label(i) = "CP";
        vertical_lines_dopler(i+1) = vertical_lines_dopler(i) + cp_len;
        line_label(i+1) = "Data";
        vertical_lines_dopler(i+2) = vertical_lines_dopler(i+1)+nfft;
        line_label(i+2) = "GP";
    else
        vertical_lines_dopler(3*i-2) = vertical_lines_dopler(3*i-3) + ...
            gp_samples;
        line_label(3*i-2) = "CP";
        vertical_lines_dopler(3*i-1) = vertical_lines_dopler(3*i-2)+cp_len;
        line_label(3*i-1) = "Data";
        vertical_lines_dopler(3*i) = vertical_lines_dopler(3*i-1)+nfft;
        line_label(3*i) = "GP";
    end
end
vertical_lines_dopler = [length(sync_tx_time) length(sync_tx_time)+ ... 
    cp_len vertical_lines_dopler];
line_label = ["Sync" "Sync CP" line_label];

figure(),subplot(3,1,1),plot(t_p/1000,real(ofdm_tx_signal_ser), ...
    'LineWidth',2),hold on,plot(t_p/1000,real(ddc_dopler))
for i = 1:length(vertical_lines_dopler)
    if (i < 3)
        xline(vertical_lines_dopler(i)*Ts/1000,'--b',line_label{i}, ...
            'LabelVerticalAlignment','bottom', ...
            'LabelHorizontalAlignment','left');
    else
        xline(vertical_lines_dopler(i)*Ts/1000,'--b',line_label{i}, ...
            'LabelVerticalAlignment','bottom');
    end
end
legend('TX','RX')
xlabel('Time (ms)'),title('In Phase'),subplot(3,1,2)
plot(t_p/1000,imag(ofdm_tx_signal_ser),'LineWidth',2),hold on
plot(t_p/1000,imag(ddc_dopler))
for i = 1:length(vertical_lines_dopler)
    if (i < 3)
        xline(vertical_lines_dopler(i)*Ts/1000,'--b',line_label{i}, ...
            'LabelVerticalAlignment','bottom', ...
            'LabelHorizontalAlignment','left');
    else
        xline(vertical_lines_dopler(i)*Ts/1000,'--b',line_label{i}, ...
            'LabelVerticalAlignment','bottom');
    end
end
legend('TX','RX'),xlabel('Time (ms)')
title('Quadrature'),subplot(3,1,3),plot(t_p/1000,sync_corr_dopler)
% xline(vertical_lines(1)*Ts/1000,'--r',line_label{1}, ...
%     'LabelHorizontalAlignment','left','LabelVerticalAlignment','bottom')
xlabel('Time (ms)'),title('Synchronizer Correlator Output')
sgtitle('Baseband OFDM Signal')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Serial to Parallel
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ofdm_rx_dopler_par=reshape(ofdm_rx_sync_dopler, ...
    [nfft+cp_len+gp_samples ofdm_symbols]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CFO Estimation and Correction
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Remove GP
ofdm_rx_dopler_par(end-gp_samples+1:end,:) = [];

% Save and remove CP
cp_rm_dopler = ofdm_rx_dopler_par;
cp_rm_dopler(1:cp_len,:) = [];

ofdm_cfo_dopler = zeros(nfft,ofdm_symbols);
cfo_est = 0;
cfo_est_dopler = zeros(1,ofdm_symbols);
for i = 1:ofdm_symbols
    cp_cfo_begin = ofdm_rx_dopler_par(dopler_cp_offset+1:cp_len- ...
        dopler_cp_offset,i); % Obtain CP at beginning of symbol
    cp_cfo_end = ofdm_rx_dopler_par(nfft+1+dopler_cp_offset: ...
        end-dopler_cp_offset,i); % Obtain CP at end of symbol
    %cp_cfo_begin = ofdm_rx_dopler_par(1:cp_len,i);
    %cp_cfo_end = ofdm_rx_dopler_par(nfft+1:end,i);
    tmp = cp_cfo_end.*conj(cp_cfo_begin); % Correlate
    sum_val = sum(tmp);
    tan_val = atan2(imag(sum_val),real(sum_val));
    normalized_cfo_est = 1*tan_val;
    cfo_est = normalized_cfo_est*scs;
    cfo_est_dopler(i) = cfo_est/2/pi;
    ofdm_cfo_dopler(:,i) = cp_rm_dopler(:,i).*(cos(cfo_est*t(1:nfft)) ...
        +1i*sin(cfo_est*t(1:nfft)))';
end
%ofdm_cfo_dopler = cp_rm_dopler;
table(cfo_est_dopler)