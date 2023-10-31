clear; clc; close all; fclose all; format long;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Simulation settings
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% OFDM Parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nfft = 1024;
nfft_zc = 4096;
BW = 312500;
cp_len = 512;
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
snr_db = 15;
multipath = [0.5 0.5 0 0 1 0.2 0.54];
multipath = 1;
speed = -1.5; % In m/s
speed = 0;

cfo = 0;
cpo = 0;
cfo_dopler = 0;
cpo_dopler = 0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fixed Values
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ZC_length = nfft_zc/2;          % Zadoff-Chu Sequence Length
sync_samples_early = -20;         % Number of samples to synchronize early
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
ofdm_tx_signal_ser = [sync_tx_time.';gp;ofdm_tx_signal_ser]; % OFDM Frame

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
    (k))-(Fc-(nfft/2 - zp_carriers/2)*scs);
Fc_Dopler_Shift = (Fc * (1+speed/speed_sound))-Fc;
Upper_BW_Dopler_Shift = ((Fc+(nfft/2 - zp_carriers/2)*scs) * ...
    (1+speed/speed_sound))- (Fc+(nfft/2 - zp_carriers/2)*scs);
table(cp_used,Max_Freq_offset,scs)
table(Lower_BW_Dopler_Shift,Fc_Dopler_Shift,Upper_BW_Dopler_Shift)
ofdm_tx_signal_ch1 = filter(multipath,1,ofdm_tx_signal_ch);
ofdm_tx_signal_dopler = interp1(t_up,ofdm_tx_signal_ch1,t_up/k,'linear',0);

% One method to compensate for dopler if estimated k accurately:
%ofdm_tx_signal_dopler = resample(ofdm_tx_signal_dopler,round(DAC_FS/k),DAC_FS);
%ofdm_tx_signal_dopler = ofdm_tx_signal_dopler(1:length(ofdm_tx_signal_ch));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% IQ Mixer RX
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_ddc = ofdm_tx_signal_ch .* cos(2*pi*Fc*t_up);
q_ddc = ofdm_tx_signal_ch .* -sin(2*pi*Fc*t_up);
ddc_signal = complex(i_ddc,q_ddc);

i_ddc_dopler = ofdm_tx_signal_dopler .* cos(2*pi*Fc*t_up);
q_ddc_dopler = ofdm_tx_signal_dopler .* -sin(2*pi*Fc*t_up);
ddc_signal_dopler = complex(i_ddc_dopler,q_ddc_dopler);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DDC
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ddc_base_signal_real = decimate(real(ddc_signal),Interp_val,4096,'Fir');
ddc_base_signal_imag = decimate(imag(ddc_signal),Interp_val,4096,'FIR');
ddc_base_signal = complex(ddc_base_signal_real,ddc_base_signal_imag);
ddc_base_signal = duc_ddc_loss_gain * ddc_base_signal.';

ddc_dopler_real = decimate(real(ddc_signal_dopler),Interp_val,4096,'Fir');
ddc_dopler_imag = decimate(imag(ddc_signal_dopler),Interp_val,4096,'Fir');
ddc_dopler = complex(ddc_dopler_real,ddc_dopler_imag);
ddc_dopler = duc_ddc_loss_gain * ddc_dopler.';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Baseband channel impairments
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
t = 0:Ts:length(ddc_base_signal)*Ts-Ts;
ddc_base_signal = ddc_base_signal .* exp(-1i*2*pi*cfo*t).';
ddc_base_signal = ddc_base_signal * exp(-1i*cpo);

ddc_dopler = ddc_dopler .* exp(-1i*2*pi*cfo_dopler*t).';
ddc_dopler = ddc_dopler * exp(-1i*cpo);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Synchronization
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sync_coef = conj(fliplr(sync_tx_time)); % Matched Filter
sync_corr_filt = abs(filter(sync_coef,1,ddc_base_signal));
[val,ind] = max(sync_corr_filt);
ind = ind-sync_samples_early+gp_samples; % Remove GP from index
ofdm_rx_sync_signal = ddc_base_signal;
ofdm_rx_sync_signal([1:ind, ...
    ind+1+(nfft+cp_len+gp_samples)*ofdm_symbols:end]) = [];
if (length(ofdm_rx_sync_signal) ~= (nfft+cp_len+gp_samples)*ofdm_symbols)
    tmp = zeros(1,(nfft+cp_len+gp_samples)*ofdm_symbols- ...
        length(ofdm_rx_sync_signal)).';
    ofdm_rx_sync_signal = [ofdm_rx_sync_signal;tmp];
    warning('Deleted too much of signal')
end

sync_corr_dopler = abs(filter(sync_coef,1,ddc_dopler));
[val2,ind2] = max(sync_corr_dopler);
ind2 = ind2-sync_samples_early+gp_samples+force_dopler_sync;
ofdm_rx_sync_dopler = ddc_dopler;
ofdm_rx_sync_dopler([1:ind2, ...
    ind2+1+(nfft+cp_len+gp_samples)*ofdm_symbols:end]) = [];
if (length(ofdm_rx_sync_dopler) ~= (nfft+cp_len+gp_samples)*ofdm_symbols)
    tmp = zeros(1,(nfft+cp_len+gp_samples)*ofdm_symbols- ...
        length(ofdm_rx_sync_dopler)).';
    ofdm_rx_sync_dopler = [ofdm_rx_sync_dopler;tmp];
    warning('Deleted too much of dopler signal')
end
doppler_sync_offset = (ind2-gp_samples)-(ind-gp_samples);
display(doppler_sync_offset)

% Plot %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
t_p = 0:Ts:length(ofdm_tx_signal_ser)*Ts-Ts;
vertical_lines = zeros(1,ofdm_symbols*3);
line_label = string.empty(0,length(vertical_lines));
vertical_lines_dopler = zeros(1,ofdm_symbols*3);
for i=1:ofdm_symbols
    if (i == 1)
        %vertical_lines(i) = nfft_zc + gp_samples;
        vertical_lines = ind;
        vertical_lines_dopler(i) = ind2;
        line_label(i) = "CP";
        vertical_lines(i+1) = vertical_lines(i) + cp_len;
        vertical_lines_dopler(i+1) = vertical_lines_dopler(i) + cp_len;
        line_label(i+1) = "Data";
        vertical_lines(i+2) = vertical_lines(i+1) + nfft;
        vertical_lines_dopler(i+2) = vertical_lines_dopler(i+1)+nfft;
        line_label(i+2) = "GP";
    else
        vertical_lines(3*i-2) = vertical_lines(3*i-3) + gp_samples;
        vertical_lines_dopler(3*i-2) = vertical_lines_dopler(3*i-3) + ...
            gp_samples;
        line_label(3*i-2) = "CP";
        vertical_lines(3*i-1) = vertical_lines(3*i-2) + cp_len;
        vertical_lines_dopler(3*i-1) = vertical_lines_dopler(3*i-2)+cp_len;
        line_label(3*i-1) = "Data";
        vertical_lines(3*i) = vertical_lines(3*i-1) + nfft;
        vertical_lines_dopler(3*i) = vertical_lines_dopler(3*i-1)+nfft;
        line_label(3*i) = "GP";
    end
end

vertical_lines = [nfft_zc vertical_lines];
line_label = ["Sync", line_label];
figure(),subplot(3,1,1),plot(t_p/1000,real(ofdm_tx_signal_ser), ...
    'LineWidth',2),hold on,plot(t_p/1000,real(ddc_base_signal))
plot(t_p/1000,real(ddc_dopler))
for i = 1:length(vertical_lines)
    if i == 1
        xline(vertical_lines(i)*Ts/1000,'--r',line_label{i}, ...
            'LabelHorizontalAlignment','left')
    else
        xline(vertical_lines(i)*Ts/1000,'--r',line_label{i})
        xline(vertical_lines_dopler(i-1)*Ts/1000,'--b',line_label{i}, ...
            'LabelVerticalAlignment','bottom');
    end
end
legend('TX','RX','RX Dopler')
xlabel('Time (ms)'),title('In Phase'),subplot(3,1,2)
plot(t_p/1000,imag(ofdm_tx_signal_ser),'LineWidth',2),hold on
plot(t_p/1000,imag(ddc_base_signal)),plot(t_p/1000,imag(ddc_dopler))
for i = 1:length(vertical_lines)
    if i == 1
        xline(vertical_lines(i)*Ts/1000,'--r',line_label{i}, ...
            'LabelHorizontalAlignment','left')
    else
        xline(vertical_lines(i)*Ts/1000,'--r',line_label{i})
        xline(vertical_lines_dopler(i-1)*Ts/1000,'--b',line_label{i}, ...
            'LabelVerticalAlignment','bottom');
    end
end
legend('TX','RX','RX Dopler'),xlabel('Time (ms)')
title('Quadrature'),subplot(3,1,3),plot(t_p/1000,sync_corr_filt),hold on
plot(t_p/1000,sync_corr_dopler)
vertical_lines = [ind2-gp_samples vertical_lines];
line_label = ["Dopler Sync", line_label];
xline(vertical_lines(2)*Ts/1000,'--b',line_label{2}, ...
    'LabelHorizontalAlignment','left')
xline(vertical_lines(1)*Ts/1000,'--r',line_label{1}, ...
    'LabelHorizontalAlignment','left','LabelVerticalAlignment','bottom')
legend('RX','RX Dopler','RX Timing','Dopler Timing'),xlabel('Time (ms)')
title('Synchronizer Correlator Output')
sgtitle('Baseband OFDM Signal')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Serial to Parallel
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ofdm_rx_signal_par=reshape(ofdm_rx_sync_signal, ...
    [nfft+cp_len+gp_samples ofdm_symbols]);
ofdm_rx_dopler_par=reshape(ofdm_rx_sync_dopler, ...
    [nfft+cp_len+gp_samples ofdm_symbols]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CFO Estimation and Correction
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Remove GP
ofdm_rx_signal_par(end-gp_samples+1:end,:) = [];

% Save and remove CP
cp_rm_signal = ofdm_rx_signal_par;
cp_rm_signal(1:cp_len,:) = []; % Remove CP

ofdm_cfo_signal = zeros(nfft,ofdm_symbols);
cfo_est_signal = zeros(1,ofdm_symbols);
for i = 1:ofdm_symbols
    cp_cfo_begin = ofdm_rx_signal_par(dopler_cp_offset+1:cp_len- ...
        dopler_cp_offset,i); % Obtain CP at beginning of symbol
    cp_cfo_end = ofdm_rx_signal_par(nfft+1+dopler_cp_offset: ...
        end-dopler_cp_offset,i); % Obtain CP at end of symbol
    %cp_cfo_begin = ofdm_rx_signal_par(1:cp_len,i);
    %cp_cfo_end = ofdm_rx_signal_par(nfft+1:end,i);
    %tmp = cp_cfo_end.*conj(cp_cfo_begin); % Correlate
    conj_val = conj(cp_cfo_begin);
    tmp = complex(real(cp_cfo_end.*conj_val),imag(cp_cfo_end.*conj_val));
    sum_val = sum(tmp);
    %tan_val = atan2(imag(sum_val),real(sum_val));
    tan_val = angle(sum_val);
    normalized_cfo_est = 1*tan_val;
    cfo_est = normalized_cfo_est*scs;
    cfo_est_signal(i) = cfo_est/2/pi;
    ofdm_cfo_signal(:,i) = cp_rm_signal(:,i).*(cos(cfo_est*t(1:nfft)) ...
        +1i*sin(cfo_est*t(1:nfft)))';
end
%ofdm_cfo_signal = cp_rm_signal;
table(cfo_est_signal)

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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Dopler processing
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    k_est = (-mean(cfo_est_dopler)/Fc)+1; % Estimate dopler scaling factor
    Fs_dopler_sample = DAC_FS/k;          % Resample rate
    Fs_dopler_sample_est = DAC_FS/k_est;  % Estimated resample rate
    table(k,k_est,Fs_dopler_sample,Fs_dopler_sample_est)

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Resample with dopler shift factor
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    P = round(DAC_FS/k/300);  Q = round(DAC_FS/300);
    ofdm_tx_signal_dopler2 = resample(ofdm_tx_signal_dopler,P,Q);
    if (length(ofdm_tx_signal_dopler2) > length(ofdm_tx_signal_ch))
        ofdm_tx_signal_dopler2 = ofdm_tx_signal_dopler2(1:length( ...
            ofdm_tx_signal_ch));
    elseif (length(ofdm_tx_signal_dopler2) < length(ofdm_tx_signal_ch))
        ofdm_tx_signal_dopler2 = [ofdm_tx_signal_dopler2 zeros(1, ...
            length(ofdm_tx_signal_ch) - length(ofdm_tx_signal_dopler2))];
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % IQ Mixer RX
    i_ddc_dopler2 = ofdm_tx_signal_dopler2 .* cos(2*pi*Fc*t_up);
    q_ddc_dopler2 = ofdm_tx_signal_dopler2 .* -sin(2*pi*Fc*t_up);
    ddc_signal_dopler2 = complex(i_ddc_dopler2,q_ddc_dopler2);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % DDC
    ddc_dopler_real2 = decimate(real(ddc_signal_dopler2),Interp_val,4096,'Fir');
    ddc_dopler_imag2 = decimate(imag(ddc_signal_dopler2),Interp_val,4096,'Fir');
    ddc_dopler2 = complex(ddc_dopler_real2,ddc_dopler_imag2);
    ddc_dopler2 = duc_ddc_loss_gain * ddc_dopler2.';

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Synchronization
    sync_corr_dopler2 = abs(filter(sync_coef,1,ddc_dopler2));
    [val3,ind3] = max(sync_corr_dopler2);
    ind3 = ind3-sync_samples_early+gp_samples+force_dopler_sync;
    ofdm_rx_sync_dopler2 = ddc_dopler2;
    ofdm_rx_sync_dopler2([1:ind3, ...
        ind3+1+(nfft+cp_len+gp_samples)*ofdm_symbols:end]) = [];
    if(length(ofdm_rx_sync_dopler2)~=(nfft+cp_len+gp_samples)*ofdm_symbols)
        tmp = zeros(1,(nfft+cp_len+gp_samples)*ofdm_symbols- ...
            length(ofdm_rx_sync_dopler2)).';
        ofdm_rx_sync_dopler2 = [ofdm_rx_sync_dopler2;tmp];
        warning('Deleted too much of dopler signal 2')
    end
    doppler_sync_offset2 = (ind3-gp_samples)-(ind-gp_samples);
    display(doppler_sync_offset2)

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Serial to Parallel
    ofdm_rx_dopler_par2=reshape(ofdm_rx_sync_dopler2, ...
        [nfft+cp_len+gp_samples ofdm_symbols]);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % CFO Estimation and Correction
    ofdm_rx_dopler_par2(end-gp_samples+1:end,:) = [];
    
    % Save and remove CP
    cp_rm_dopler2 = ofdm_rx_dopler_par2;
    cp_rm_dopler2(1:cp_len,:) = [];
    
    ofdm_cfo_dopler2 = zeros(nfft,ofdm_symbols);
    cfo_est2 = 0;
    cfo_est_dopler2 = zeros(1,ofdm_symbols);
    for i = 1:ofdm_symbols
        cp_cfo_begin = ofdm_rx_dopler_par2(dopler_cp_offset+1:cp_len- ...
            dopler_cp_offset,i); % Obtain CP at beginning of symbol
        cp_cfo_end = ofdm_rx_dopler_par2(nfft+1+dopler_cp_offset: ...
            end-dopler_cp_offset,i); % Obtain CP at end of symbol
        %cp_cfo_begin = ofdm_rx_dopler_par(1:cp_len,i);
        %cp_cfo_end = ofdm_rx_dopler_par(nfft+1:end,i);
        tmp = cp_cfo_end.*conj(cp_cfo_begin); % Correlate
        sum_val = sum(tmp);
        tan_val = atan2(imag(sum_val),real(sum_val));
        normalized_cfo_est = 1*tan_val;
        cfo_est = normalized_cfo_est*scs;
        cfo_est_dopler2(i) = cfo_est/2/pi;
        ofdm_cfo_dopler2(:,i) = cp_rm_dopler2(:,i).* ...
            (cos(cfo_est*t(1:nfft))+1i*sin(cfo_est*t(1:nfft)))';
    end
    ofdm_cfo_dopler2 = cp_rm_dopler2;
    table(cfo_est_dopler2)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FFT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fft_signal = zeros(nfft,ofdm_symbols);
for i = 1:ofdm_symbols % Do FFTSHIFT per symbol
    fft_signal(:,i) = fftshift(fft(ofdm_cfo_signal(:,i),nfft));
end

fft_dopler = zeros(nfft,ofdm_symbols);
for i = 1:ofdm_symbols
    fft_dopler(:,i) = fftshift(fft(ofdm_cfo_dopler(:,i),nfft));
end

fft_dopler_no_cfo = zeros(nfft,ofdm_symbols);
for i = 1:ofdm_symbols
    fft_dopler_no_cfo(:,i) = fftshift(fft(cp_rm_dopler(:,i),nfft));
end

fft_dopler2 = zeros(nfft,ofdm_symbols);
for i = 1:ofdm_symbols
    fft_dopler2(:,i) = fftshift(fft(ofdm_cfo_dopler2(:,i),nfft));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Channel Estimation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Get RX pilots
fft_signal_eq = fft_signal;
P_RX = fft_signal_eq(pilot_index,:);
% P_RX_re = real(P_RX);           P_RX_im = -imag(P_RX);
% P_re = real(reference_pilot);   P_im = -imag(reference_pilot);
% H = (P_RX_re.*P_re + P_RX_im.*P_im) ./ (P_re.^2 + P_im.^2) + ...
%     1i*(P_RX_im.*P_re - P_RX_re.*P_im) ./ (P_re.^2 + P_im.^2);
H = conj(P_RX) ./ conj(reference_pilot);
H_interp = interp1(pilot_index,H,1:nfft,'previous');
% H = P_RX ./ reference_pilot;
% H_MMSE = conj(H) ./ (abs(H).^2 + 1/snr);
% H_interp_MMSE = interp1(pilot_index,H_MMSE,1:nfft,'previous');

fft_dopler_eq = fft_dopler;
P_RX = fft_dopler_eq(pilot_index,:);
% H = conj(P_RX) ./ conj(reference_pilot);
% H_interp_dopler = interp1(pilot_index,H,1:nfft,'previous');
H = P_RX ./ (reference_pilot);
H_MMSE_dopler = conj(H) ./ (abs(H).^2 + 1/snr);
H_interp_MMSE_dopler=interp1(pilot_index,H_MMSE_dopler,1:nfft,'previous');

fft_dopler_eq_no_cfo = fft_dopler_no_cfo;
P_RX = fft_dopler_eq_no_cfo(pilot_index,:);
% H = conj(P_RX) ./ conj(reference_pilot);
% H_interp_dopler = interp1(pilot_index,H,1:nfft,'previous');
H = P_RX ./ (reference_pilot);
H_MMSE_dopler_no_cfo = conj(H) ./ (abs(H).^2 + 1/snr);
H_interp_MMSE_dopler_no_cfo=interp1(pilot_index,H_MMSE_dopler_no_cfo, ...
    1:nfft,'previous');

fft_dopler_eq2 = fft_dopler2;
P_RX = fft_dopler_eq2(pilot_index,:);
% H = conj(P_RX) ./ conj(reference_pilot);
% H_interp_dopler2 = interp1(pilot_index,H,1:nfft,'previous');
H = P_RX ./ (reference_pilot);
H_MMSE_dopler2 = conj(H) ./ (abs(H).^2 + 1/snr);
H_interp_MMSE_dopler2=interp1(pilot_index,H_MMSE_dopler2,1:nfft, ...
    'previous');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Channel Equalization
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% H_ZF_re = real(H_interp); H_ZF_im = -imag(H_interp);
% fft_re = real(fft_signal_eq); fft_im = imag(fft_signal_eq);
% Z_EQ_ZF =(fft_re.*H_ZF_re + fft_im.*H_ZF_im)./(H_ZF_re.^2 + H_ZF_im.^2) ...
%     +1i*(fft_im.*H_ZF_re - fft_re.*H_ZF_im)./(H_ZF_re.^2 + H_ZF_im.^2);
Z_EQ_ZF = fft_signal_eq ./ conj(H_interp);
% Z_EQ_ZF = fft_signal_eq .* H_interp_MMSE;           % MMSE
% P_RX = Z_EQ_ZF(pilot_index,:);
% H = angle(P_RX ./ conj(reference_pilot));
% H_phase = -mean(H);
% Z_EQ_ZF = Z_EQ_ZF .* (exp(-1i*H_phase));

% Z_EQ_ZF_dopler = fft_dopler_eq ./ conj(H_interp_dopler); % ZF
Z_EQ_ZF_dopler = fft_dopler_eq .* H_interp_MMSE_dopler;         % MMSE
% P_RX = Z_EQ_ZF_dopler(pilot_index,:);
% P_RX = mean(P_RX);
%Z_EQ_ZF_dopler = Z_EQ_ZF_dopler ./ imag(P_RX);
fft_dopler_eq([pilot_index,zp_index],:) = [];
Z_EQ_ZF_dopler([pilot_index,zp_index],:) = [];

% Z_EQ_ZF_dopler = fft_dopler_eq ./ conj(H_interp_dopler); % ZF
Z_EQ_ZF_dopler_no_cfo =fft_dopler_eq_no_cfo .* H_interp_MMSE_dopler_no_cfo;
% P_RX = Z_EQ_ZF_dopler(pilot_index,:);
% P_RX = mean(P_RX);
%Z_EQ_ZF_dopler = Z_EQ_ZF_dopler ./ imag(P_RX);
fft_dopler_eq_no_cfo([pilot_index,zp_index],:) = [];
Z_EQ_ZF_dopler_no_cfo([pilot_index,zp_index],:) = [];

% Z_EQ_ZF_dopler2 = fft_dopler_eq2 ./ conj(H_interp_dopler2); % ZF
Z_EQ_ZF_dopler2 = fft_dopler_eq2 .* H_interp_MMSE_dopler2;         % MMSE
% P_RX = Z_EQ_ZF_dopler(pilot_index,:);
% P_RX = mean(P_RX);
%Z_EQ_ZF_dopler = Z_EQ_ZF_dopler ./ imag(P_RX);
fft_dopler_eq2([pilot_index,zp_index],:) = [];
Z_EQ_ZF_dopler2([pilot_index,zp_index],:) = [];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Synchronization error correction
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Z_EQ_ZF = Z_EQ_ZF * exp(1i*pi*(sync_offset_estimate/cp_len));
Z_EQ_ZF([pilot_index,zp_index],:) = [];
fft_signal_eq([pilot_index,zp_index],:) = [];
%Z_EQ_ZF_dopler = Z_EQ_ZF_dopler * exp(1i*pi*(sync_offset_estimate/cp_len));
%Z_EQ_ZF_dopler_no_cfo = Z_EQ_ZF_dopler_no_cfo * ...
%    exp(1i*pi*(sync_offset_estimate/cp_len));
%Z_EQ_ZF_dopler2=Z_EQ_ZF_dopler2 * exp(1i*pi*(sync_offset_estimate/cp_len));

% Plot %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
lim = sqrt(2*M) + 1; y_lim = [-lim lim]; x_lim = [-lim lim];
figure(),subplot(2,3,4),scatter(real(Z_EQ_ZF),imag(Z_EQ_ZF),'.')
title('AWGN Channel Equalized + CFO'),ylim(y_lim),xlim(x_lim)
subplot(2,3,5),plot(real(Z_EQ_ZF_dopler),imag(Z_EQ_ZF_dopler),'.')
title('Dopler Channel Equalized + CFO'),ylim(y_lim),xlim(x_lim),subplot(2,3,1)
scatter(real(fft_signal/tx_scale),imag(fft_signal/tx_scale),'.')
ylim(y_lim),xlim(x_lim),title('AWGN Channel No Equalization + CFO')
subplot(2,3,2),scatter(real(fft_dopler/tx_scale),imag(fft_dopler/ ...
    tx_scale),'.'),ylim(y_lim),xlim(x_lim)
title('Dopler Channel No Equalization + CFO'),subplot(2,3,3)
scatter(real(Z_EQ_ZF_dopler2),imag(Z_EQ_ZF_dopler2),'.'),ylim(y_lim)
xlim(x_lim),title('Dopler Channel Resampled + Equalized + CFO')
subplot(2,3,6),scatter(real(Z_EQ_ZF_dopler_no_cfo),imag( ...
    Z_EQ_ZF_dopler_no_cfo),'.'),ylim(y_lim),xlim(x_lim)
title('Dopler Channel Equalized No CFO')
sgtitle('Equalizer Output')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% QAM Demodulation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Demod
demod_data = qamdemod(Z_EQ_ZF,M);
demod_dopler = qamdemod(Z_EQ_ZF_dopler,M);
demod_dopler2 = qamdemod(Z_EQ_ZF_dopler2,M);

ser_data = symerr(tx_data, demod_data)/numel(tx_data);
ser_dopler = symerr(tx_data, demod_dopler)/numel(tx_data);
ser_dopler2 = symerr(tx_data, demod_dopler2)/numel(tx_data);

% Get EVM measurements
evm = comm.EVM(AveragingDimensions=[1 2],MaximumEVMOutputPort=1);
[data_evm,data_evm_pk] = evm(qam_mod_data,Z_EQ_ZF);
[dopler_evm,dopler_evm_pk] = evm(qam_mod_data,Z_EQ_ZF_dopler);
[dopler_evm2,dopler_evm_pk2] = evm(qam_mod_data,Z_EQ_ZF_dopler2);

Equalization =["AWGN Channel";"Dopler Channel";"Dopler Channel Resampled"];
SER = [ser_data;ser_dopler;ser_dopler2];
AverageEVM = [data_evm;dopler_evm;dopler_evm2];
PeakEVM = [data_evm_pk;dopler_evm_pk;dopler_evm_pk2];
table(Equalization,SER,AverageEVM,PeakEVM)

y_lim = [0 100]; y_ofdm = 1:ofdm_symbols; y1 = 1:nfft;
carriers_plot = zeros(1,nfft); carriers_plot_dopler = zeros(1,nfft);
carriers_plot_dopler2 = zeros(1,nfft);
evm = comm.EVM(AveragingDimensions=1);
evm_ofdm = evm(qam_mod_data,Z_EQ_ZF);
evm_ofdm_dopler = evm(qam_mod_data,Z_EQ_ZF_dopler);
evm_ofdm_dopler2 = evm(qam_mod_data,Z_EQ_ZF_dopler2);
evm = comm.EVM(AveragingDimensions=2);
evm_carriers = evm(qam_mod_data,Z_EQ_ZF);
carriers_plot(data_index) = evm_carriers;
evm_carriers_dopler = evm(qam_mod_data,Z_EQ_ZF_dopler);
carriers_plot_dopler(data_index) = evm_carriers_dopler;
evm_carriers_dopler2 = evm(qam_mod_data,Z_EQ_ZF_dopler2);
carriers_plot_dopler2(data_index) = evm_carriers_dopler2;

figure(),subplot(2,3,1),bar(y1,carriers_plot),ax=gca;ax.YLim=y_lim;
xlabel('Sub-Carriers'),ylabel('%'),title(['AWGN Channel Averaged ' ...
    'Across Sub-Carriers']),subplot(2,3,2),bar(y1,carriers_plot_dopler)
ax=gca;ax.YLim=y_lim;xlabel('Sub-Carriers'),ylabel('%')
title('Dopler Channel Averaged Across Sub-Carriers'),subplot(2,3,3)
bar(y1,carriers_plot_dopler2),ax=gca;ax.YLim=y_lim;xlabel('Sub-Carriers')
ylabel('%'),title(['Dopler Channel Resampled Averaged ' ...
    'Across Sub-Carriers']),subplot(2,3,4)
bar(y_ofdm,evm_ofdm),ax=gca;ax.YLim=y_lim;xlabel('OFDM Symbols')
ylabel('%'),title('AWGN Channel Averaged Across OFDM Symbols')
subplot(2,3,5),bar(y_ofdm,evm_ofdm_dopler),ax=gca;ax.YLim=y_lim;
xlabel('OFDM Symbols'),ylabel('%'),title(['Dopler Channel Averaged ' ...
    'Across OFDM Symbols']),subplot(2,3,6),bar(y_ofdm,evm_ofdm_dopler2)
ax=gca;ax.YLim=y_lim;xlabel('OFDM Symbols'),ylabel('%')
title('Dopler Channel Resampled Averaged Across OFDM Symbols')
sgtitle('EVM')
