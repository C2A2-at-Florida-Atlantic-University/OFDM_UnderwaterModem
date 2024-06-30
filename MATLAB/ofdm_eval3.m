clear; clc; close all; fclose all; format long;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Simulation settings 335328744369150
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% "ZF", "MMSE", "ZF Averaged", "LS", "Ideal"
% "Sym1Pilot" % Use entire 1st OFDM Symbol to estimate channel for all sym
% "SymAvg" % Average perfect channel estimates into 1 for all symbols
    EQUALIZER_METHOD = "ZF Averaged";
% Channel Estimation Interpolation Method
    interp_method = 'linear';
% Doppler Channel Interpolation method
    doppler_ch_interp_method = 'spline';
% Doppler Compensation Interpolation method
    doppler_comp_interp_method = 'nearest';
% Loop MATLAB IFFT output to FFT output to bypass channel
    LOOPBACK = false;
% Use Comb type pilot format else use alternating pilots
    PILOT_COMB_FORMAT = true;
% Use CFO estimate to correct for CFO in time domain
    CFO_CORR = false;
% Frequency domain CP
    FREQ_CP = false;
% Assume all CFO is caused by doppler. Use CFO est to correct for doppler.
% If false, use CFO est to correct for CFO offset. Only for MATLAB sim
    DOPPLER_PROC = true;
% Use resampler for doppler compensation else use separate interp/decimate
    DOPPLER_RESAMPLER = true;
% Adjust sample rate to compensate for doppler either at base or passband
    DOPPLER_ADC = false;
% Perform 1d interpolation at baseband to compensate for doppler
    DOPPLER_ADC_BASEBAND = false;
% Use FIR Interp/decimate for doppler resampling else use CIC
    DOPPLER_FIR = false;
% Use CIC Interp/decimate for doppler resampling
    DOPPLER_CIC = false;
% Use actual k value for doppler compensation to remove estimation error
    DOPPER_K_ACTUAL = true;
% Perform doppler resampling at passband else baseband. Keep true for ADC
    DOPPLER_PASSBAND = false;
% Perform CFO est and comp after Doppler Compensation
    CFO_CORR_POST_DOPPLER = true;
% Perform estimation and correction for phase rotation from sym to sym
    PHASE_AVG = false;
% Filter multiple channel estimates instead of averaging
    FILTER_CH_EST = false;
% Perform power measurements
    POWER_MEASURE = false;
% Plot ideal QAM scatter points on top of RX constellations
    PLOT_IDEAL = false;
% Set pilots as QPSK instead of same modulation order as data
    QPSK_PILOTS = false;
% Add AWGN in baseband instead of passband
    BASEBAND_AWGN = true;
% Enable frequency domain timing offset estimation and compensation
    TA_EST_COMP = true;
% Enable frequency domain frequency offset estimation and compensation
    CFO_EST_COMP = false;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% OFDM Parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nfft = 4096;                % Size of FFT, number of subcarriers in OFDM
BW = 250000;                % Bandwidth = complex FS
cp_len = 1024;               % Cyclic Prefix length in samples
freq_cp = nfft/8;           % Number of CP pilot subcarriers
M = 16;                     % Modulation Order
ZP_density = 30;            % Zero Padded Pilot Density
symbol_guard_ms = 1;        % Symbol guard band in ms
frame_guard_ms = 1;         % Frame guard band in ms
ofdm_symbols = 5;          % Number of OFDM symbols in a Frame
Fc = 250000;                % Center frequency of OFDM signal

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fixed Values
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nfft_zc = 4096;                       % NFFT for Zadoff-Chu sequence
ZC_root = 13;                         % Zadoff-Chu root index
ZC_length = nfft_zc/2;                % Zadoff-Chu Sequence Length
doppler_cp_offset = round(cp_len/32); % Num of CP samples*2 to not use
sync_samples_early = 0;             % Num of samples to synchronize early
doppler_sync_samples_early = 0;       % samp to sync early for doppler
force_doppler_sync = 0;               % Force doppler synchronization
pilot_density = 0.5;                  % Pilot to data ratio
DAC_FS = 40000000;                    % Dac sample rate
nfft_p = 32*nfft;                     % NFFT for plotting spectrum
speed_sound = 1500;                   % Speed of sound underwater
duc_ddc_loss_gain = 2;                % Loss of Matlab DUC
num_bits = 14;                        % Number of bits in a sample
num_fir_taps = 4096;                  % Number of FIR taps for DUC/DDC
symbol_plot = 4;                      % Set number of Symbols to plot
ifft_gain = 30000;                     % IFFT gain on sub-carriers

gp_samples = round(symbol_guard_ms / 1000 * BW);

% Channel parameters
snr_db = 30;                          % Signal-to-Noise ratio in dB
multipath = [0 0 0.3 1 0 1 0.9 0.1 0 0 0 1];
%multipath = 1;
speed = 2;                            % Doppler In m/s
speed = 0;

cfo = 30;                              % Carrier frequency offset
spo = 0;                              % Sample phase offset
sro = 50;                       % Sample rate offset (in parts per million)
sro = 0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculated OFDM Parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Carrier Allocation
rep = 1/pilot_density;          % Data to pilot repetition
zp_carriers = floor(nfft*ZP_density/100/2)*2; % Even Number of ZP carriers
zp_index = [1:zp_carriers/2,nfft/2,nfft/2+1,nfft-zp_carriers/2+1:nfft];
zp_carriers = zp_carriers + 2;  % Account for 2 ZP carriers around DC
if FREQ_CP
    pilot_index=[zp_carriers/2:rep:nfft/2-1, ...
        nfft/2+2:rep:(nfft-zp_carriers/2-freq_cp+1), ...
        nfft-zp_carriers/2-freq_cp+2:nfft-zp_carriers/2];
else
    pilot_index=[zp_carriers/2:rep:nfft/2-1, ...
        nfft/2+2:rep:nfft-zp_carriers/2];
end
if zp_index(end/2+2)-1 ~= pilot_index(end)
    pilot_index = [pilot_index zp_index(end/2+2)-1];
end
index = find(pilot_index == nfft/2-1);
if isempty(index)
    index = find(pilot_index == nfft/2-2);
    pilot_index = [pilot_index(1:index) nfft/2-1 pilot_index(index+1:end)];
end
pilot_carriers = length(pilot_index);
if PILOT_COMB_FORMAT
    pilot_index = repmat(pilot_index.', [1 ofdm_symbols]);
    pilot_index_orig = pilot_index;
else
    pilot_index_orig = repmat(pilot_index.', [1 ofdm_symbols]);
    pilot_index = repmat(pilot_index.', [1 ofdm_symbols]);
    pilot_index(:,2:2:end) = pilot_index(:,2:2:end) + 1;
    pilot_index(end/2,2:2:end) = pilot_index(end/2,2:2:end) - 1;
    pilot_index(:,2:2:end)=cat(1,pilot_index(1:end/2,2:2:end), ...
        nfft/2+2*ones(1,length(2:2:ofdm_symbols)), ...
        pilot_index(end/2+1:end-1,2:2:end));
end
zp_index = repmat(zp_index.', [1 ofdm_symbols]);
data_index = 1:nfft;
data_index = repmat(data_index.', [1 ofdm_symbols]);
data_index_orig = data_index;
rm_pilot_zp_index = data_index; rm_pilot_zp_index_orig = data_index;
for i=1:ofdm_symbols
    rm_pilot_zp = sort([pilot_index(:,i);zp_index(:,i)]);
    rm_pilot_zp_index(rm_pilot_zp,i) = NaN;
    rm_pilot_zp_orig = sort([pilot_index_orig(:,i);zp_index(:,i)]);
    rm_pilot_zp_index_orig(rm_pilot_zp_orig,i) = NaN;
end
data_index_tmp = 1:nfft;
data_index_tmp2 = zeros(nfft-pilot_carriers-zp_carriers,ofdm_symbols);
data_index_tmp2_orig = zeros(nfft-pilot_carriers-zp_carriers,ofdm_symbols);
for i=1:ofdm_symbols
    data_index_tmp = data_index(:,i);
    data_index_tmp(any(isnan(rm_pilot_zp_index(:,i)),2)) = [];
    data_index_tmp2(:,i) = data_index_tmp;

    data_index_tmp_orig = data_index_orig(:,i);
    data_index_tmp_orig(any(isnan(rm_pilot_zp_index_orig(:,i)),2)) = [];
    data_index_tmp2_orig(:,i) = data_index_tmp_orig;
end
data_index = data_index_tmp2;
data_index_orig = data_index_tmp2_orig;
%data_index(any(isnan(rm_pilot_zp_index),2),:) = [];
data_carriers = length(data_index);
pilot_data_index = repmat((1:nfft).',[1 ofdm_symbols]);
pilot_index_nan = repmat((1:nfft).',[1 ofdm_symbols]);
for i=1:ofdm_symbols
    pilot_data_index(zp_index(:,i),i) = NaN;
    pilot_index_nan(sort([zp_index(:,i);data_index(:,i)]),i) = NaN;
end

% Other Parameters
scs = BW/nfft;
num_data_bits = length(data_index)*ofdm_symbols;
Fs = BW; % Sample frequency (complex) = bandwidth
Interp_val = DAC_FS/Fs; % Interpolation value
Ts = 1/Fs; % Sampling period
Ts_up = 1/DAC_FS;
F = (-nfft_p/2:nfft_p/2-1)/nfft_p*Fs; % Plotting baseband spectrum
F_up = (-nfft_p/2:nfft_p/2-1)/nfft_p*DAC_FS; % Plotting DUC spectrum
cp_used = cp_len - 2*doppler_cp_offset;
Max_Freq_offset = 2*scs*(cp_used/nfft);
DAC_FS_sro = DAC_FS + DAC_FS*(sro*10e-6);
Symbol_Time = 1/BW*(nfft+cp_len);

fir_taps = fir1(num_fir_taps,1/(DAC_FS/Fs));
fir_taps = fir_taps / sqrt(sum(fir_taps.^2));
filter_delay = floor(length(fir_taps)/2);

fir_taps_4x=fir1(128,1/4);% Mimic 4x decimation with 128 TAP filter in FPGA
%fir_taps_4x = fir_taps_4x / sqrt(sum(fir_taps_4x.^2));
filter_delay_4x = floor(length(fir_taps_4x)/2);
fir_taps_rx = fir1(num_fir_taps,1/Interp_val);
%fir_taps_rx = fir_taps_rx / sqrt(sum(fir_taps_rx.^2));
filter_delay_rx = floor(length(fir_taps_rx)/2);

figure(),subplot(2,1,1),stem((0:1/DAC_FS:length(multipath)/ ...
    DAC_FS-1/DAC_FS)*1000,abs(multipath)),title('Magnitude'),subplot(2,1,2)
stem((0:1/DAC_FS:length(multipath)/DAC_FS-1/DAC_FS)*1000,angle(multipath))
xlabel('Time (ms)'),title('Angle'),sgtitle('Multipath Delay Spread')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Generate Pilot Data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
rng default
if QPSK_PILOTS
    pilot_data = randsrc(pilot_carriers,ofdm_symbols,0:3);
else
    pilot_data = randsrc(pilot_carriers,ofdm_symbols,0:M-1);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Generate Message Data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
rng default
tx_data = randsrc(data_carriers,ofdm_symbols,0:M-1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% QAM Modulation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
qam_mod_data = qammod(tx_data,M) * ifft_gain;
if QPSK_PILOTS
    reference_pilot = qammod(pilot_data,4) * ifft_gain;
else
    reference_pilot = qammod(pilot_data,M) * ifft_gain;
end
zp_carrier = complex(0,0);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Synchronization   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Create Zadoff-Chu sequence
sync_tx = log2(M)/sqrt(2)*exp(-1i*pi*ZC_root*(1:ZC_length).* ...
    ((1:ZC_length)+1)/ZC_length); % ZC sequence
sync_tx_i = cos(pi*ZC_root*(1:ZC_length).* ...
    ((1:ZC_length)+1)/ZC_length);
sync_tx_q = -sin(pi*ZC_root*(1:ZC_length).* ...
    ((1:ZC_length)+1)/ZC_length);
sync_tx = complex(sync_tx_i,sync_tx_q);
sync_tx_zp = [zeros(1,(nfft_zc-ZC_length)/2),sync_tx,zeros(1, ...
    (nfft_zc-ZC_length)/2)]; % Add ZP and center ZC sequence in BW
sync_tx_time = ifft(ifftshift(ifft_gain*sync_tx_zp),nfft_zc);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Carrier Allocation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FFT carriers of Data, Pilot and ZP carriers
carriers = zeros(nfft,ofdm_symbols);
for i=1:ofdm_symbols
    carriers(pilot_index_orig(:,i),i) = reference_pilot(:,i);
    carriers(data_index_orig(:,i),i) = qam_mod_data(:,i);
    carriers(zp_index(:,i),i) = zp_carrier;
    if FREQ_CP
        carriers(pilot_index(end,i)-freq_cp+1:pilot_index(end,i)) = ...
            carriers(pilot_index(1,i):pilot_index(1,i)+freq_cp-1);
    end
end
tx_pilot_data = carriers;
tx_pilot_data(any(isnan(pilot_data_index),2),:) = [];

figure(),scatter(real(reference_pilot(:,1)),imag(reference_pilot(:,i)),'.')
hold on,scatter(real(qam_mod_data(:,1)),imag(qam_mod_data(:,1)),'.')
sgtitle('TX Constellation'),legend('Pilot','Data Symbols')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% IFFT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Ifftshift to reorder carriers in correct order for IFFT
ifft_sub_carriers = zeros(nfft,ofdm_symbols);
for i = 1:ofdm_symbols % In loop so Ifftshift works per symbol
    ifft_sub_carriers(:,i) = ifft(ifftshift(carriers(:,i)),nfft);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CP Insertion
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cp_start = nfft-cp_len;
cp = ifft_sub_carriers(cp_start+1:end,:);            % Obtain CP
ofdm_tx_signal_par1 = vertcat(cp,ifft_sub_carriers);  % Copy CP

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TX Power Measurement
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if POWER_MEASURE
    full_scale = (2^(num_bits-1))^2 * (nfft+cp_len);
    full_scale_zc = (2^(num_bits-1))^2 * nfft_zc;
    sig_pow = sum(abs(ofdm_tx_signal_par1.^2));
    sig_pow_dBFS = 10*log10(sig_pow/full_scale);
    sig_peak = max(abs(ofdm_tx_signal_par1));
    sig_peak_dBFS = 10*log10(sig_peak/(2^(num_bits-1)));
    sig_pow1 = sum(abs((sync_tx_time).^2));
    sig_pow_dBFS = [10*log10(sig_pow1/full_scale_zc) sig_pow_dBFS];
    sig_peak = max(abs((sync_tx_time)));
    sig_peak_dBFS = [10*log10(sig_peak/(2^(num_bits-1))) sig_peak_dBFS];
    sig_papr_dB = sig_peak_dBFS - sig_pow_dBFS;
    
    figure(),subplot(2,2,1),bar(1:ofdm_symbols+1,sig_pow_dBFS)
    xlabel('OFDM Symbol'),ylabel('dBFS'),title('Average Power')
    set(gca,'Ydir','reverse');subplot(2,2,2)
    bar(1:ofdm_symbols+1,sig_peak_dBFS)
    xlabel('OFDM Symbol'),ylabel('dBFS'),title('Peak Power')
    set(gca,'Ydir','reverse');subplot(2,2,[3 4]),bar(1:ofdm_symbols+1, ...
        sig_papr_dB),xlabel('OFDM Symbols'),ylabel('dB'),title('PAPR')
    sgtitle('TX Power')
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GP Insertion2)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
gp = zeros(gp_samples,ofdm_symbols);       % Obtain GP
ofdm_tx_signal_par = vertcat(ofdm_tx_signal_par1,gp); % Copy GP

if ~PILOT_COMB_FORMAT
    for i=1:ofdm_symbols
        qam_mod_data(:,i) = carriers(data_index(:,i),i);
        reference_pilot(:,i) = carriers(pilot_index(:,i),i);
    end
else
    qam_mod_data = carriers;
    qam_mod_data(any(isnan(rm_pilot_zp_index),2),:) = [];
    reference_pilot = carriers;
    reference_pilot(any(isnan(pilot_index_nan),2),:) = [];
end
tx_data = qamdemod(qam_mod_data/ifft_gain,M);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Parallel to Serial
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ofdm_tx_signal_ser = reshape(ofdm_tx_signal_par,[(nfft+cp_len+ ...
    gp_samples)*ofdm_symbols, 1]);         % Parallel to Serial
gp = zeros(gp_samples,1);                  % Obtain GP
ofdm_tx_signal_ser = [sync_tx_time.'; ...
    zeros(cp_len,1);gp;ofdm_tx_signal_ser]; % OFDM Frame

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DUC
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%      [kdk,fir_taps] = interp(ofdm_tx_signal_ser,Interp_val,10,1);
%     filter_delay = floor(length(fir_taps)/2);
%     ofdm_tx_signal_zp = [zeros(filter_delay,1);ofdm_tx_signal_ser; ...
%         zeros(filter_delay,1)];
%     ofdm_duc_signal = interp(ofdm_tx_signal_zp,Interp_val,10,1);
%     ofdm_duc_signal = ofdm_duc_signal(filter_delay*Interp_val+1:end- ...
%         filter_delay*Interp_val);
%     ofdm_duc_signal = ofdm_duc_signal.';
up_signal = upsample(ofdm_tx_signal_ser, Interp_val);
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
% AWGN Channel method 1
snr = 10^(snr_db/10); % Noise power
if ~BASEBAND_AWGN
    ofdm_tx_signal_ch_pwr = mean(abs(ofdm_duc_signal_real).^2);
    noise_pwr = ofdm_tx_signal_ch_pwr / snr;
    noise = sqrt(noise_pwr) .* randn(size(ofdm_duc_signal_real));
    ofdm_tx_signal_ch = ofdm_duc_signal_real + noise;
else
    ofdm_tx_signal_ch = ofdm_duc_signal_real;
end

% Multipath
%ofdm_tx_signal_ch1 = filter(multipath,1,ofdm_tx_signal_ch);
ofdm_tx_signal_ch1 = ofdm_tx_signal_ch;

% doppler
k = (1+speed/speed_sound); % doppler shift factor
Lower_BW_doppler_Shift = ((Fc-(nfft/2 - zp_carriers/2)*scs) * ...
    (k))-(Fc-(nfft/2 - zp_carriers/2)*scs);
Fc_doppler_Shift = (Fc * (1+speed/speed_sound))-Fc;
Upper_BW_doppler_Shift = ((Fc+(nfft/2 - zp_carriers/2)*scs) * ...
    (1+speed/speed_sound))- (Fc+(nfft/2 - zp_carriers/2)*scs);
table(cp_used,Max_Freq_offset,scs)
table(Lower_BW_doppler_Shift,Fc_doppler_Shift,Upper_BW_doppler_Shift)
%ofdm_tx_signal_doppler =interp1(t_up,ofdm_tx_signal_ch1,t_up/k,'linear',0);
ofdm_tx_signal_doppler =interp1(t_up,ofdm_tx_signal_ch1,t_up/k, ...
    doppler_ch_interp_method,0);
% One method to compensate for doppler
%ofdm_tx_signal_doppler = interp1(t_up/k,ofdm_tx_signal_doppler,t_up,'spline',0);
% One method to compensate for doppler if estimated k accurately:
%ofdm_tx_signal_doppler = resample(ofdm_tx_signal_doppler, ...
    %round(DAC_FS/k),DAC_FS);
%ofdm_tx_signal_doppler = ofdm_tx_signal_doppler(1:length ...
%    (ofdm_tx_signal_ch));

% Sample phase offset
ofdm_tx_signal_doppler = ofdm_tx_signal_doppler * exp(1j*spo);

% Carrier Frequency Offset
%ofdm_tx_signal_doppler = ofdm_tx_signal_doppler .* exp(1i*2*pi*t_up*cfo);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% IQ Mixer RX
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% AWGN Channel
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
    % MATLAB decimate
%    ddc_base_signal_real=decimate(real(ddc_signal),Interp_val,4096,'Fir');
%    ddc_base_signal_imag=decimate(imag(ddc_signal),Interp_val,4096,'FIR');
%     ddc_base_signal = complex(ddc_base_signal_real,ddc_base_signal_imag);
%     ddc_base_signal = duc_ddc_loss_gain * ddc_base_signal.';
    % Model FPGA implementation of DDC
%     ddc_stage1 = [ddc_signal zeros(1,filter_delay_4x)];
%     ddc_stage1_out = filter(fir_taps_4x,1,ddc_stage1);
%     ddc_stage1_out(1:filter_delay_4x) = [];
%     ddc_stage1_out = downsample(ddc_stage1_out,4);
ddc_stage2 = [ddc_signal zeros(1,filter_delay)];
ddc_stage2_out = filter(fir_taps,1,ddc_stage2);
ddc_stage2_out(1:filter_delay) = [];
ddc_base_signal = downsample(ddc_stage2_out,Interp_val)/7.2;

ddc_doppler_real = ...
    decimate(real(ddc_signal_doppler),Interp_val,4096,'Fir');
ddc_doppler_imag = ...
    decimate(imag(ddc_signal_doppler),Interp_val,4096,'Fir');
ddc_doppler = complex(ddc_doppler_real,ddc_doppler_imag);
ddc_doppler = duc_ddc_loss_gain * ddc_doppler.';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Bypass DUC/DDC for MATLAB AWGN Channel
if (LOOPBACK)
    ddc_base_signal = ofdm_tx_signal_ser/1.91;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Synchronization
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sync_coef = conj(fliplr(sync_tx_time)); % Matched Filter
sync_corr_filt = abs(filter(sync_coef,1,ddc_base_signal));
[val,ind] = max(sync_corr_filt);
%ind = ind-sync_samples_early+gp_samples+cp_len; % Remove GP from index
ind = ind+gp_samples+cp_len;
ofdm_rx_sync_signal = ddc_base_signal;
ofdm_rx_sync_signal([1:ind, ...
    ind+1+(nfft+cp_len+gp_samples)*ofdm_symbols:end]) = [];
if (length(ofdm_rx_sync_signal) ~= (nfft+cp_len+gp_samples)*ofdm_symbols)
    tmp = zeros(1,(nfft+cp_len+gp_samples)*ofdm_symbols- ...
        length(ofdm_rx_sync_signal));
    ofdm_rx_sync_signal = [ofdm_rx_sync_signal tmp];
    warning('Deleted too much of signal')
end

sync_corr_doppler = abs(filter(sync_coef,1,ddc_doppler));
[val2,ind2] = max(sync_corr_doppler);
ind2 = ind2-sync_samples_early+gp_samples+force_doppler_sync+cp_len;
ofdm_rx_sync_doppler = ddc_doppler;
ofdm_rx_sync_doppler([1:ind2, ...
    ind2+1+(nfft+cp_len+gp_samples)*ofdm_symbols:end]) = [];
if (length(ofdm_rx_sync_doppler) ~= (nfft+cp_len+gp_samples)*ofdm_symbols)
    tmp = zeros(1,(nfft+cp_len+gp_samples)*ofdm_symbols- ...
        length(ofdm_rx_sync_doppler)).';
    ofdm_rx_sync_doppler = [ofdm_rx_sync_doppler;tmp];
    warning('Deleted too much of doppler signal')
end
doppler_sync_offset = (ind2-gp_samples)-(ind-gp_samples);
display(doppler_sync_offset)

% Plot %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
t_p = 0:Ts:length(ofdm_tx_signal_ser)*Ts-Ts;
vertical_lines = zeros(1,ofdm_symbols*3);
line_label = string.empty(0,length(vertical_lines));
vertical_lines_doppler = zeros(1,ofdm_symbols*3);
for i=1:ofdm_symbols
    if (i == 1)
        %vertical_lines(i) = nfft_zc + gp_samples;
        vertical_lines = ind;
        vertical_lines_doppler(i) = ind2;
        line_label(i) = "CP";
        vertical_lines(i+1) = vertical_lines(i) + cp_len;
        vertical_lines_doppler(i+1) = vertical_lines_doppler(i) + cp_len;
        line_label(i+1) = "Data";
        vertical_lines(i+2) = vertical_lines(i+1) + nfft;
        vertical_lines_doppler(i+2) = vertical_lines_doppler(i+1)+nfft;
        line_label(i+2) = "GP";
    else
        vertical_lines(3*i-2) = vertical_lines(3*i-3) + gp_samples;
        vertical_lines_doppler(3*i-2) = vertical_lines_doppler(3*i-3) + ...
            gp_samples;
        line_label(3*i-2) = "CP";
        vertical_lines(3*i-1) = vertical_lines(3*i-2) + cp_len;
        vertical_lines_doppler(3*i-1)=vertical_lines_doppler(3*i-2)+cp_len;
        line_label(3*i-1) = "Data";
        vertical_lines(3*i) = vertical_lines(3*i-1) + nfft;
        vertical_lines_doppler(3*i) = vertical_lines_doppler(3*i-1)+nfft;
        line_label(3*i) = "GP";
    end
end

vertical_lines = [nfft_zc vertical_lines];
line_label = ["Sync", line_label];
figure(),subplot(3,1,1),plot(t_p/1000,real(ofdm_tx_signal_ser), ...
    'LineWidth',2),hold on,plot(t_p/1000,real(ddc_doppler))
for i = 1:length(vertical_lines)
    if i == 1
        xline(vertical_lines(i)*Ts/1000,'--b',line_label{i}, ...
            'LabelHorizontalAlignment','left')
    else
        xline(vertical_lines(i)*Ts/1000,'--b',line_label{i})
        xline(vertical_lines_doppler(i-1)*Ts/1000,'--r',line_label{i}, ...
            'LabelVerticalAlignment','bottom');
    end
end
legend('Ideal Channel','MATLAB UW-A Channel',...
    'Ideal Timing','','MATLAB UW-A Timing')
xlabel('Time (ms)'),title('In Phase'),subplot(3,1,2)
plot(t_p/1000,imag(ofdm_tx_signal_ser),'LineWidth',2),hold on
plot(t_p/1000,imag(ddc_doppler))
for i = 1:length(vertical_lines)
    if i == 1
        xline(vertical_lines(i)*Ts/1000,'--b',line_label{i}, ...
            'LabelHorizontalAlignment','left')
    else
        xline(vertical_lines(i)*Ts/1000,'--b',line_label{i})
        xline(vertical_lines_doppler(i-1)*Ts/1000,'--r',line_label{i}, ...
            'LabelVerticalAlignment','bottom');
    end
end
legend('Ideal Channel','MATLAB UW-A Channel',...
    'Ideal Timing','','MATLAB UW-A Timing')
xlabel('Samples'),title('Quadrature'),subplot(3,1,3)
plot(t_p/1000,sync_corr_filt),hold on,plot(t_p/1000,sync_corr_doppler)
vertical_lines = [ind2-gp_samples-cp_len vertical_lines];
line_label = ["UW-A Sync", line_label];
xline(vertical_lines(2)*Ts/1000,'--b',line_label{2}, ...
    'LabelHorizontalAlignment','left')
xline(vertical_lines(1)*Ts/1000,'--r',line_label{1}, ...
    'LabelHorizontalAlignment','left','LabelVerticalAlignment','bottom')
legend('Ideal','MATLAB UW-A Channel','Ideal Timing','MATLAB UW-A Timing')
xlabel('Time (ms)'),title('Synchronizer Correlator Output')
sgtitle('Baseband OFDM Signal Before Resampler')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Serial to Parallel
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Add multipath at baseband (too many taps at passband)
ofdm_rx_sync_doppler = filter(multipath,1,ofdm_rx_sync_doppler);

% Plot spectrum of FFT input
figure(),plot(F/1000,10*log10(abs(fftshift(fft(ofdm_rx_sync_doppler,...
    nfft_p))))),xlabel('kHz'),ylabel('dB')
title('MATLAB Sim FFT Input Spectrum Before Doppler Compensation')

% Serial to parrallel
ofdm_rx_signal_par=reshape(ofdm_rx_sync_signal, ...
    [nfft+cp_len+gp_samples ofdm_symbols]);
ofdm_rx_doppler_par=reshape(ofdm_rx_sync_doppler, ...
    [nfft+cp_len+gp_samples ofdm_symbols]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% RX Power Measure
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if POWER_MEASURE
    sig_pow_rx = sum(abs(ofdm_rx_doppler_par.^2));
    ofdm_rx_doppler_par = ...
        ofdm_rx_doppler_par.*sqrt(sig_pow./sig_pow_rx);
    sig_pow_rx1 = sum(abs(ofdm_rx_doppler_par.^2));

    y1 = 1:ofdm_symbols;
    figure(),b = bar(y1,[10*log10(sig_pow/full_scale);...
        10*log10(sig_pow_rx1/full_scale)],'LineWidth',0.5);
    xtips1 = b(1).XEndPoints;ytips1 = b(1).YEndPoints;
    labels1 = string(b(1).YData);text(xtips1,ytips1,labels1,...
        'HorizontalAlignment','center','VerticalAlignment','bottom')
    xtips2 = b(2).XEndPoints;ytips2 = b(2).YEndPoints;
    labels2 = string(b(2).YData);text(xtips2,ytips2,labels2,...
        'HorizontalAlignment','center','VerticalAlignment','bottom')
    legend('TX','RX'),xlabel('OFDM Symbols'),title('Power'),ylabel('dBFS')
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CFO Estimation and Correction
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% AWGN Channel
ofdm_rx_signal_par(end-gp_samples+1:end,:) = []; % Remove GP
ofdm_cfo_signal = ofdm_rx_signal_par; 
ofdm_cfo_signal(1:cp_len,:) = [];                % Remove CP

% Add white noise at baseband
if BASEBAND_AWGN
    ofdm_cfo_signal_pwr = mean(abs(ofdm_cfo_signal).^2);
    noise_pwr = ofdm_cfo_signal_pwr / snr;
    noise = sqrt(noise_pwr) .* randn(size(ofdm_cfo_signal));
    ofdm_cfo_signal = ofdm_cfo_signal + noise;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MATLAB Doppler channel
ofdm_rx_doppler_par_gp = ofdm_rx_doppler_par;
ofdm_rx_doppler_par(end-gp_samples+1:end,:) = []; % Remove GP

% Add white noise at baseband
if BASEBAND_AWGN
    ofdm_rx_doppler_par_pwr = mean(abs(ofdm_rx_doppler_par).^2);
    noise_pwr = ofdm_rx_doppler_par_pwr / snr;
    noise = sqrt(noise_pwr) .* randn(size(ofdm_rx_doppler_par));
    ofdm_rx_doppler_par = ofdm_rx_doppler_par + noise;
end

cp_rm_doppler = ofdm_rx_doppler_par;              % Save and remove CP
cp_rm_doppler(1:cp_len,:) = [];                   % Remove CP


t = 0:Ts:length(ddc_base_signal)*Ts-Ts;

ofdm_cfo_doppler = zeros(nfft,ofdm_symbols);
cfo_est = 0;
cfo_est_doppler = zeros(1,ofdm_symbols);
for i = 1:ofdm_symbols
    cp_cfo_begin = ofdm_rx_doppler_par(doppler_cp_offset+1:cp_len- ...
        doppler_cp_offset,i); % Obtain CP at beginning of symbol
    cp_cfo_end = ofdm_rx_doppler_par(nfft+1+doppler_cp_offset: ...
        end-doppler_cp_offset,i); % Obtain CP at end of symbol
    tmp = cp_cfo_end.*conj(cp_cfo_begin); % Correlate
    sum_val = sum(tmp);
    tan_val = atan2(imag(sum_val),real(sum_val));
    normalized_cfo_est = 1*tan_val;
    cfo_est = normalized_cfo_est*scs;
    cfo_est_doppler(i) = cfo_est/2/pi;
    ofdm_cfo_doppler(:,i) = cp_rm_doppler(:,i).*(cos(cfo_est*t(1:nfft)) ...
        +1i*sin(cfo_est*t(1:nfft)))';
end
if ~CFO_CORR || DOPPLER_PROC
    ofdm_cfo_doppler = cp_rm_doppler;
end
table(cfo_est_doppler)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% doppler processing
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if DOPPLER_PROC
    k_est = (-mean(cfo_est_doppler)/Fc)+1;% Estimate doppler scaling factor
    k_est = (cfo_est_doppler(1)/Fc)+1;
    Fs_doppler_sample = DAC_FS/k;         % Resample rate
    Fs_doppler_sample_est = DAC_FS/k_est; % Estimated resample rate
    Fc_doppler_shift_Hz = Fs_doppler_sample - DAC_FS;
    Fc_doppler_shift_Hz_est = Fs_doppler_sample_est - DAC_FS;
    base_doppler_shift_Hz = BW/k - BW;
    base_doppler_shift_Hz_est = BW/k_est - BW;
    k_Delta = k/k_est - 1;% Doppler Delta
    Fs_doppler_diff = Fs_doppler_sample - Fs_doppler_sample_est;
    table(k,k_est,Fs_doppler_sample,Fs_doppler_sample_est)
    table(k_Delta, Fs_doppler_diff)
    table(Fc_doppler_shift_Hz,Fc_doppler_shift_Hz_est)
    table(base_doppler_shift_Hz,base_doppler_shift_Hz_est)

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Resample with doppler shift factor
    P = round(DAC_FS/k_est/Interp_val);  Q = round(DAC_FS/Interp_val);
    if DOPPLER_RESAMPLER
        if P*Q >= 2^31
            re_scale = 2^31/(P*Q)
            P = floor(P*sqrt(re_scale)); Q = floor(Q*sqrt(re_scale));
            warning('Re-Scaled down P/Q')
        else
            re_scale = 2^31/(P*Q)
            P = floor(P*sqrt(re_scale)); Q = floor(Q*sqrt(re_scale));
            warning('Re-Scaled up P/Q')
        end
        P_est = P; Q_est = Q; ratio_est = Q/P;
        P_actual = DAC_FS/k/Interp_val; Q_actual = DAC_FS/Interp_val;
        ratio_actual=Q_actual/P_actual;
        table(P_actual,Q_actual,ratio_actual)
        table(P_est,Q_est,ratio_est)
        if DOPPER_K_ACTUAL
            if P_actual*Q_actual >= 2^31
                re_scale = 2^31/(P_actual*Q_actual);
                P = floor(P_actual*sqrt(re_scale));
                Q = floor(Q_actual*sqrt(re_scale));
            end
            P_actual_scaled = P; Q_actual_scaled = Q;
            ratio_actual_scaled = Q/P;
            table(P_actual_scaled,Q_actual_scaled,ratio_actual_scaled)
        end
        if DOPPLER_PASSBAND
            ofdm_tx_signal_doppler2 = resample(ofdm_tx_signal_doppler,P,Q);
            Fc_comp = Fc;
        else
            ofdm_tx_signal_doppler2 = ofdm_tx_signal_doppler;
            Fc_comp = Fc/k;
        end
    else
        if DOPPLER_FIR
            num_fir_taps_doppler = 512;
            fir_taps_P_doppler = fir1(num_fir_taps_doppler,1/P);
            fir_taps_P_doppler = fir_taps_P_doppler / sqrt(sum(...
                fir_taps_P_doppler.^2));
            filter_delay_P_doppler = floor(length(fir_taps_P_doppler)/2);
            up_doppler = upsample(tmp,P);
            up_doppler = [up_doppler,zeros(1,filter_delay_P_doppler)];
            up_duc_doppler = filter(fir_taps_P_doppler, 1, up_doppler);
            clear up_doppler;
            up_duc_doppler(1:filter_delay) = [];

            fir_taps_Q_doppler = fir1(num_fir_taps_doppler,1/Q);
            fir_taps_Q_doppler = fir_taps_Q_doppler / sqrt(sum( ...
                fir_taps_Q_doppler.^2));
            filter_delay_Q_doppler = floor(length(fir_taps_Q_doppler)/2);
            down_ddc_doppler = [up_duc_doppler zeros(1,filter_delay)];
            clear up_duc_doppler;
            down_ddc_doppler_filt = filter(fir_taps_Q_doppler, 1, ...
                down_ddc_doppler);
            clear down_ddc_doppler;
            down_ddc_doppler_filt(1:filter_delay_Q_doppler) = [];
            ofdm_tx_signal_doppler2 = downsample(down_ddc_doppler_filt, ...
                Q);
            clear down_ddc_doppler_filt;
%         elseif DOPPLER_CIC
%             % Read Captured Xilinx CIC Filter impulse Response:
%             file = fopen('../Xilinx/Vivado/modules/sim/cic_duc_test_out.txt','r');
%             cic_impulse = fscanf(file,"%d, %d\n",[2 79]);
%             cic_impulse = complex(cic_impulse(1,:),cic_impulse(2,:));
%             cic_impulse = cic_impulse / sum(cic_impulse); % Normalize
%             up_doppler = upsample(tmp,P);
%             up_doppler_cic = filter(cic_impulse,1,up_doppler);
% 
%             
        end
    end
    if DOPPLER_ADC
        ADC_FS_compensated = DAC_FS/k; Delta_Fs = ADC_FS_compensated...
            -DAC_FS;
        ADC_FS_compensated_est = DAC_FS/k_est;
        Delta_Fs_est = ADC_FS_compensated_est - DAC_FS;
        table(ADC_FS_compensated,ADC_FS_compensated_est, ...
            Delta_Fs, Delta_Fs_est)
        if ~DOPPLER_ADC_BASEBAND
            ofdm_tx_signal_doppler2 = interp1(t_up/k, ...
                ofdm_tx_signal_doppler,t_up, ...
                doppler_comp_interp_method,0);
            %ofdm_tx_signal_doppler2 = ofdm_tx_signal_doppler;
            % IQ Mixer RX
            i_ddc_doppler2=ofdm_tx_signal_doppler2.*cos(2*pi*Fc*t_up);
            q_ddc_doppler2=ofdm_tx_signal_doppler2.*-sin(2*pi*Fc*t_up);
            ddc_signal_doppler2=complex(i_ddc_doppler2,q_ddc_doppler2);
        else
            ofdm_tx_signal_doppler2 = ofdm_tx_signal_doppler;
            % IQ Mixer RX
            Fc_doppler = Fc/k;
            i_ddc_doppler2 = ofdm_tx_signal_doppler2 .* ...
                cos(2*pi*Fc_doppler*t_up);
            q_ddc_doppler2 = ofdm_tx_signal_doppler2 .* ...
                -sin(2*pi*Fc_doppler*t_up);
            ddc_signal_doppler2=complex(i_ddc_doppler2,q_ddc_doppler2);
%             ddc_signal_doppler2 = interp1(t_up/k,...
%             ddc_signal_doppler2,t_up,doppler_comp_interp_method,0);
        end
    else        
        if (length(ofdm_tx_signal_doppler2) > ...
                length(ofdm_tx_signal_doppler))
            ofdm_tx_signal_doppler2=...
                ofdm_tx_signal_doppler2(1:length(ofdm_tx_signal_doppler));
            warning('Removing extra samples after re-sampler')
        elseif (length(ofdm_tx_signal_doppler2) < ...
                length(ofdm_tx_signal_doppler))
            ofdm_tx_signal_doppler2 = [ofdm_tx_signal_doppler2 zeros(1, ...
                length(ofdm_tx_signal_doppler2) - ...
                length(ofdm_tx_signal_doppler2))];
            warning('Adding extra zeros after re-sampler')
        end
        % IQ Mixer RX
        i_ddc_doppler2 =ofdm_tx_signal_doppler2 .* cos(2*pi*Fc_comp*t_up);
        q_ddc_doppler2 =ofdm_tx_signal_doppler2 .* -sin(2*pi*Fc_comp*t_up);
        ddc_signal_doppler2 = complex(i_ddc_doppler2,q_ddc_doppler2);
    end
    % DDC
    ddc_doppler_real2 = decimate(real(ddc_signal_doppler2), ...
        Interp_val, 4096, 'Fir');
    ddc_doppler_imag2 = decimate(imag(ddc_signal_doppler2), ...
        Interp_val, 4096, 'Fir');
    ddc_doppler2 = complex(ddc_doppler_real2,ddc_doppler_imag2);
    ddc_doppler2 = 1.8*duc_ddc_loss_gain * ddc_doppler2.';
    % Add white noise at baseband
    if BASEBAND_AWGN
        ddc_doppler2_pwr = mean(abs(ddc_doppler2).^2);
        noise_pwr = ddc_doppler2_pwr / snr;
        noise = sqrt(noise_pwr) .* randn(size(ddc_doppler2));
        ddc_doppler2 = ddc_doppler2 + noise;
    end
    if DOPPLER_ADC_BASEBAND
        BW_compensated = BW/k;
        t_base = 0:1/BW:length(ddc_doppler2)/BW-1/BW;
        t_base_comp = 0:1/BW_compensated:length(ddc_doppler2) ...
            /BW_compensated-1/BW_compensated;
        ddc_doppler2 =interp1(t_base/k,ddc_doppler2,t_base, ...
            doppler_comp_interp_method,0);
    end
    if ~DOPPLER_PASSBAND
        if DOPPLER_CIC
            % Read Captured Xilinx CIC Filter impulse Response
%             file = fopen(...
%                 'Xilinx/Vivado/modules/sim/cic_duc_test_out.txt','r');
%             cic_impulse = fscanf(file, '%d, %d\n',[2 79]);
            cic_impulse = [1:40 39:-1:1];
            cic_impulse = complex(cic_impulse,cic_impulse);
            cic_impulse = cic_impulse/sum(cic_impulse); % Normalize
            up_doppler_cic = upsample(ddc_doppler2,P);
            up_doppler_cic = filter(cic_impulse,1,up_doppler_cic);
            %down_doppler_cic = filter(cic_impulse,1,up_doppler_cic);
            ddc_doppler2_comp = downsample(up_doppler_cic,Q);
        elseif DOPPLER_FIR
            num_fir_taps_doppler = P*4;
            fir_taps_P_doppler = fir1(num_fir_taps_doppler,1/(2*P));
            fir_taps_P_doppler = fir_taps_P_doppler / sqrt(sum(...
                fir_taps_P_doppler.^2));
            filter_delay_P_doppler = floor(length(fir_taps_P_doppler)/2);
            up_doppler = upsample(ddc_doppler2,P);
            up_doppler = [up_doppler;zeros(filter_delay_P_doppler,1)];
            up_duc_doppler = filter(fir_taps_P_doppler, 1, up_doppler);
            clear up_doppler;
            up_duc_doppler(1:filter_delay) = [];
            ddc_doppler2_comp = downsample(up_duc_doppler,Q);
            clear up_duc_doppler;
        else
            ddc_doppler2_comp = resample(ddc_doppler2,P,Q);
        end
        if (length(ddc_doppler2_comp) > length(ddc_doppler2))
            ddc_doppler2 = ddc_doppler2_comp(1:length(ddc_doppler2));
            warning('Removing extra samples after baseband re-sampler')
        elseif (length(ddc_doppler2_comp) < length(ddc_doppler2))
            ddc_doppler2 = [ddc_doppler2_comp.' zeros(1, ...
                length(ddc_doppler2) - length(ddc_doppler2_comp))].';
            warning('Adding extra zeros after baseband re-sampler')
        end
    end
    % Synchronization
    sync_corr_doppler2 = abs(filter(sync_coef,1,ddc_doppler2));
    [val3,ind3] = max(sync_corr_doppler2);
    ind3 = ind3-doppler_sync_samples_early...
        + gp_samples+force_doppler_sync+cp_len;
    ofdm_rx_sync_doppler2 = ddc_doppler2;
    ofdm_rx_sync_doppler2([1:ind3, ...
        ind3+1+(nfft+cp_len+gp_samples)*ofdm_symbols:end]) = [];
    if length(ofdm_rx_sync_doppler2) ~= ...
            (nfft+cp_len+gp_samples)*ofdm_symbols
        tmp = zeros(1,(nfft+cp_len+gp_samples)*ofdm_symbols- ...
            length(ofdm_rx_sync_doppler2)).';
        ofdm_rx_sync_doppler2 = [ofdm_rx_sync_doppler2;tmp];
        warning('Deleted too much of UW-A signal 2')
    end
    doppler_sync_offset2 = (ind3-gp_samples) - (ind-gp_samples);

    vertical_lines(1) = [];
    vertical_lines_doppler2 = zeros(1,ofdm_symbols*3);
    line_label(1) = [];
    for i=1:ofdm_symbols
        if i==1
            vertical_lines_doppler2(i) = ind3;
            vertical_lines_doppler2(i+1) = ...
                vertical_lines_doppler2(i) + cp_len;
            vertical_lines_doppler2(i+2) = ...
                vertical_lines_doppler2(i+1)+nfft;
        else
            vertical_lines_doppler2(3*i-2) = ...
                vertical_lines_doppler2(3*i-3)+gp_samples;
            vertical_lines_doppler2(3*i-1) = ...
                vertical_lines_doppler2(3*i-2)+cp_len;
            vertical_lines_doppler2(3*i) = ...
                vertical_lines_doppler(3*i-1)+nfft;
        end
    end

    % Plot synchronization timing after resampling
    figure(),subplot(3,1,1),plot(t_p/1000,real(ofdm_tx_signal_ser),...
        'LineWidth',2),hold on,plot(t_p/1000,real(ddc_doppler2))
    for i=1:length(vertical_lines)
        if i==1
            xline(vertical_lines(i)*Ts/1000,'--b',line_label{i}, ...
                'LabelHorizontalAlignment','left')
        else
            xline(vertical_lines(i)*Ts/1000,'--b',line_label{i})
            xline(vertical_lines_doppler2(i-1)*Ts/1000,'--r',...
                line_label{i},'LabelVerticalAlignment','bottom');
        end
    end
    legend('Ideal','MATLAB UW-A Channel','Ideal Timing','',...
        'MATLAB UW-A Timing'),xlabel('Time (ms)'),title('In Phase')
    subplot(3,1,2)
    plot(t_p/1000,imag(ofdm_tx_signal_ser),'LineWidth',2),hold on
    plot(t_p/1000,imag(ddc_doppler2))
    for i = 1:length(vertical_lines)
        if i == 1
            xline(vertical_lines(i)*Ts/1000,'--b',line_label{i}, ...
                'LabelHorizontalAlignment','left')
        else
            xline(vertical_lines(i)*Ts/1000,'--b',line_label{i})
            xline(vertical_lines_doppler2(i-1)*Ts/1000,'--r', ...
                line_label{i},'LabelVerticalAlignment','bottom');
        end
    end
    legend('Ideal','MATLAB UW-A Channel','Ideal Timing', '', ...
        'MATLAB UW-A Timing')
    xlabel('Time (ms)'),title('Quadrature'),subplot(3,1,3)
    plot(t_p/1000,sync_corr_filt),hold on
    plot(t_p/1000,sync_corr_doppler2)
    vertical_lines = [ind3-gp_samples-cp_len vertical_lines];
    line_label = ["UW-A Sync", line_label];
    xline(vertical_lines(2)*Ts/1000,'--b',line_label{2}, ...
        'LabelHorizontalAlignment','left')
    xline(vertical_lines(1)*Ts/1000,'--r',line_label{1}, ...
        'LabelHorizontalAlignment','Left','LabelVerticalAlignment', ...
        'bottom')
    legend('Ideal','MATLAB UW-A Channel','Ideal Timning', ...
        'MATLAB UW-A Timing')
    title('Synchronizer Correlator Output')
    sgtitle('Baseband OFDM Signal After Doppler Compensation')

    % Serial to Parallel
    ofdm_rx_doppler_par2 = reshape(ofdm_rx_sync_doppler2, ...
        [nfft+cp_len+gp_samples ofdm_symbols]);
    ofdm_rx_doppler_par2(end-gp_samples+1:end,:) = []; % Remove GP

    % Save and remove CP
    cp_rm_doppler2 = ofdm_rx_doppler_par2;
    cp_rm_doppler2(1:cp_len,:) = [];

    ofdm_cfo_doppler2 = zeros(nfft,ofdm_symbols);
    cfo_est2 = 0;
    cfo_est_doppler2 = zeros(1,ofdm_symbols);
    for i = 1:ofdm_symbols
        cp_cfo_begin = ofdm_rx_doppler_par2(doppler_cp_offset+1:...
            cp_len-doppler_cp_offset,i);
        cp_cfo_end = ofdm_rx_doppler_par2(nfft+1+doppler_cp_offset: ...
            end-doppler_cp_offset,i);
        tmp = cp_cfo_end .* conj(cp_cfo_begin);
        sum_val = sum(tmp);
        tan_val = atan2(imag(sum_val), real(sum_val));
        normalized_cfo_est = 1*tan_val;
        cfo_est= normalized_cfo_est*scs;
        cfo_est_doppler2(i) = cfo_est/2/pi;
        ofdm_cfo_doppler2(:,i) = cp_rm_doppler2(:,i) .* ...
            (cos(cfo_est*t(1:nfft)) + 1i*sin(cfo_est*t(1:nfft)))';
    end
    table(cfo_est_doppler2)
    if ~CFO_CORR_POST_DOPPLER
        ofdm_cfo_doppler2 = cp_rm_doppler2;
    end
else
    ofdm_cfo_doppler2 = ofdm_cfo_doppler;
end

% Plot
% Plot spectrum of FFT input
figure(),plot(F/1000,10*log10(abs(fftshift(fft(ofdm_cfo_doppler2,...
    nfft_p))))),xlabel('kHz'),ylabel('dB')
title('MATLAB Sim FFT Input Spectrum After Doppler Compensation')
%ofdm_cfo_doppler2 = reshape(ofdm_cfo_doppler2, [nfft,ofdm_symbols]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FFT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fft_signal = zeros(nfft,ofdm_symbols);
for i = 1:ofdm_symbols % Do FFTSHIFT per symbol
    fft_signal(:,i) = fftshift(fft(ofdm_cfo_signal(:,i),nfft));
end

fft_doppler2 = zeros(nfft,ofdm_symbols);
for i = 1:ofdm_symbols
    fft_doppler2(:,i) = fftshift(fft(ofdm_cfo_doppler2(:,i),nfft));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Channel Estimation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initialize AWGN Channel data
fft_signal_eq = fft_signal;
P_RX = fft_signal_eq;

% Initialize MATLAB UW-A sim channel data
fft_doppler_eq2 = fft_doppler2;
% for i=1:ofdm_symbols
%     for K=1:nfft
%         fft_doppler_eq2(K,i) = fft_doppler_eq2(K,i) * ...
%             exp(-1j*2*pi*cfo*(K-1)/nfft);
%     end
% end
%fft_doppler_eq2 = fft_doppler_eq2 .* exp(-1j*2*pi*cfo*(0:nfft-1).');
P_RX_dopler = fft_doppler_eq2;

% Get RX pilots depending on the pilot format
if ~PILOT_COMB_FORMAT
    P_RX = zeros(pilot_carriers,ofdm_symbols);
    P_RX_dopler = zeros(pilot_carriers,ofdm_symbols);
    for i=1:ofdm_symbols
        P_RX_tmp = fft_signal_eq(:,i);
        P_RX_tmp(any(isnan(pilot_index_nan(:,i)),2),:) = [];
        P_RX(:,i) = P_RX_tmp;
        P_RX_tmp = fft_doppler2(:,i);
        P_RX_tmp(any(isnan(pilot_index_nan(:,i)),2),:) = [];
        P_RX_dopler(:,i) = P_RX_tmp;  
    end
else
    P_RX(any(isnan(pilot_index_nan),2),:) = [];
    P_RX_dopler(any(isnan(pilot_index_nan),2),:) = [];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Expanded Channel Estimation
% P_RX_re = real(P_RX);           P_RX_im = -imag(P_RX);
% P_re = real(reference_pilot);   P_im = -imag(reference_pilot);
% H = (P_RX_re.*P_re + P_RX_im.*P_im) ./ (P_re.^2 + P_im.^2) + ...
%     1i*(P_RX_im.*P_re - P_RX_re.*P_im) ./ (P_re.^2 + P_im.^2);

%%%%% SNR estimate %%%%%
rx_pilots = P_RX; tx_pilots = reference_pilot;

rx_pilot_power = mean(abs(rx_pilots).^2);
tx_pilot_power = mean(abs(tx_pilots).^2);

norm_rx_pilots = rx_pilots .* sqrt(tx_pilot_power ./ rx_pilot_power);

noise_est = norm_rx_pilots - tx_pilots;
noise_est_power = mean(abs(noise_est).^2);

SNR_estimate = tx_pilot_power ./ noise_est_power;
SNR_estimate_db = 10*log10(mean(SNR_estimate))

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Matlab Doppler Channel Estimation:
%%%%% SNR Estimate %%%%%
rx_pilots = P_RX_dopler;
rx_pilot_power = mean(abs(rx_pilots).^2);
norm_rx_pilots = rx_pilots .* sqrt(tx_pilot_power./rx_pilot_power);
noise_est = norm_rx_pilots - tx_pilots;
noise_est_power = mean(abs(noise_est).^2);
SNR_estimate_doppler = tx_pilot_power ./ noise_est_power;
SNR_estimate_db_doppler = 10*log10(mean(SNR_estimate_doppler))

%%%%% Get LS Channel estimate %%%%%
H = conj(P_RX_dopler) ./ conj(reference_pilot);
%%%%% Timing offset estimation %%%%%
e_pa = zeros(1,ofdm_symbols);               % Phase shift estimate
TA_est = zeros(1,ofdm_symbols);             % Timing offset estimate
for i=1:ofdm_symbols
    for K=1:pilot_carriers-2
        e_pa(i) = e_pa(i) + H(K,i) * H(K+2,i)';
    end
    TA_est(i) = angle(e_pa(i))*nfft/(2*pi*4);
end
TA_comp = exp(1j*2*pi*(1:nfft)'.*TA_est/nfft);
if ~PILOT_COMB_FORMAT
    TA_comp_H = zeros(pilot_carriers,ofdm_symbols);
    for i=1:ofdm_symbols
        TA_comp_tmp = TA_comp(:,i);
        TA_comp_tmp(any(isnan(pilot_index_nan(:,i)),2),:) = [];
        TA_comp_H(:,i) = TA_comp_tmp;
    end
else
    TA_comp_H = TA_comp;
    TA_comp_H(any(isnan(pilot_index_nan),2),:) = [];
end
TA_comp = exp(-1j*2*pi*(1:nfft)'.*TA_est/nfft);

figure(),subplot(2,2,1),plot(real(TA_comp(:,1))),title('In-Phase')
xlabel('Sub-Carrier Index'),subplot(2,2,2),plot(imag(TA_comp(:,1)))
title('Quadrature'),xlabel('Sub-Carrier Index'),subplot(2,2,3)
plot(real(TA_comp_H(:,1))),title('In-Phase'),xlabel('Pilot-Carrier Index')
subplot(2,2,4),plot(imag(TA_comp_H(:,1))),title('Quadrature')
xlabel('Pilot-Carrier Index'),sgtitle('TA Compensation')

%%%%% Timing offset correction %%%%%
if TA_EST_COMP
    H = H .* TA_comp_H;
    fft_doppler_eq2 = fft_doppler_eq2 .* TA_comp;
end
table(TA_est)

%%%%% Frequency offset estimation %%%%%
%e_cfo = H(:,2).*conj(H(:,1));

%e_cfo_theta = angle(H(:,2).*conj(H(:,1)));
e_cfo_theta = angle(sum(H(:,2).*conj(H(:,1))));
e_cfo = e_cfo_theta / (2*pi*scs);
e_cfo = e_cfo_theta;

e_cfo_rep = repmat(e_cfo, [1 ofdm_symbols]);
% e_cfo_interp=interp1(pilot_index(:,1),e_cfo,1:nfft,interp_method,'extrap');
% e_cfo_interp_rep = repmat(e_cfo_interp.', [1 ofdm_symbols]);

% e_cfo_rep = exp(1j*e_cfo_rep.*(1:ofdm_symbols));
% e_cfo_interp_rep = exp(1j*e_cfo_interp_rep.*(1:ofdm_symbols));
%e_cfo_rep = exp(-1j*ones(nfft,1)*e_cfo_rep.*(0:ofdm_symbols-1));
e_cfo_rep = exp(-1j*ones(1,ofdm_symbols).*(0:nfft-1)'.*(0:nfft-1)'*2*pi*cfo);
e_cfo_rep = exp(-1j*2*pi*cfo*(0:nfft-1)'/nfft);
e_cfo_rep = repmat(e_cfo_rep, [1 ofdm_symbols]);
e_cfo_interp_rep = e_cfo_rep;
if ~PILOT_COMB_FORMAT
    e_cfo_rep = zeros(pilot_carriers,ofdm_symbols);
    for i=1:ofdm_symbols
        e_cfo_rep_tmp=e_cfo_interp_rep(:,i);
        e_cfo_rep_tmp(any(isnan(pilot_index_nan(:,i)),2),:) = [];
        e_cfo_rep(:,i) = e_cfo_rep_tmp;
    end
else
    e_cfo_rep(any(isnan(pilot_index_nan),2),:) = [];
end

figure()
for i=1:4
    x_lim = [pilot_index(1),pilot_index(end,1)];
    subplot(2,2,1),plot(real(e_cfo_interp_rep(:,i))),title('In-Phase')
    xlim(x_lim),xlabel('Sub-Carrier Index'),hold on,subplot(2,2,2)
    plot(imag(e_cfo_interp_rep(:,i))),title('Quadrature')
    xlabel('Sub-Carrier Index'),xlim(x_lim),hold on,subplot(2,2,3)
    plot(abs(e_cfo_interp_rep(:,i))),title('Magnitude')
    xlim(x_lim),xlabel('Sub-Carrier Index'),hold on,subplot(2,2,4)
    plot(angle(e_cfo_interp_rep(:,i))),title('Phase'),xlim(x_lim)
    xlabel('Sub-Carrier Index'),hold on
end
subplot(2,2,1),legend('Symbol 0','Symbol 1','Symbol 2','Symbol 3')
sgtitle('CFO Compensation')

%%%% Frequency offset compensation %%%%%
if CFO_EST_COMP
    H = H .* (e_cfo_rep);
    fft_doppler_eq2 = fft_doppler_eq2 .* (e_cfo_interp_rep);
end
%%%%% Estimate and correct for phase offsets between symbols %%%%%
if PHASE_AVG
    phase_sym_rot = zeros(1,ofdm_symbols);
    phase_sym1 = H(:,1);
    for i = 1:ofdm_symbols
        phase_sym_next = H(:,i);
        %phase_sym_rot(i) = mean(angle(phase_sym1./phase_sym_next));
        phase_sym_rot(i) = angle(mean(phase_sym1)/mean(phase_sym_next));
    end
    H = H .* exp(1i*phase_sym_rot);
    fft_doppler_eq2 = fft_doppler_eq2 .* exp(-1i*phase_sym_rot);
end

%%%%% Get Ideal Channel to compare with estimated channel %%%%%
fft_doppler_eq2_tmp = fft_doppler_eq2;
fft_doppler_eq2_tmp(zp_index,:) = [];
H_ideal2 = conj(fft_doppler_eq2_tmp) ./ ...
    conj(tx_pilot_data);
%%%%% Use entire sym1 as pilots, rest of syms are data %%%%%
if (EQUALIZER_METHOD == "Sym1Pilot" || EQUALIZER_METHOD== "SymAvg")
    H_sym2 = H_ideal2(:,1);
    H_sym2 = repmat(H_sym2, [1 ofdm_symbols]);
    H_interp_doppler2_sym1 = interp1([pilot_index,data_index], ...
        H_sym2,1:nfft,interp_method,"extrap");
end  
%%%%% Interpolate Ideal channel to all NFFT sub-carriers %%%%%
H_interp_doppler2_ideal = zeros(nfft,ofdm_symbols);
for i=1:ofdm_symbols
    tmp_pilot_data_index = pilot_data_index(:,i);
    tmp_pilot_data_index(any(isnan(pilot_data_index),2),:) = [];
    H_interp_doppler2_ideal(:,i) = interp1(tmp_pilot_data_index,...
        H_ideal2(:,i),1:nfft,interp_method,"extrap");
end  
%%%%% Doppler Estimation %%%%%
R0=1/(2*ofdm_symbols)*sum(sum(abs(H).^2));
R1=1/ofdm_symbols*sum(conj(H(:,1).*H(:,2)));
fd = 1/(2*pi*Symbol_Time)*sqrt((1-abs(R1)/R0)/0.223)
%%%%% Interpolate estimates at pilots to all sub-carriers %%%%%
H_interp_doppler2_orig = zeros(nfft,ofdm_symbols);
for i=1:ofdm_symbols
    H_interp_doppler2_orig(:,i)=interp1(pilot_index(:,i),H(:,i),...
        1:nfft,interp_method,"extrap");
end 
%%%%% For Alternating pilots, interpolate next sym pilots %%%%%
if (~PILOT_COMB_FORMAT && EQUALIZER_METHOD ~= "ZF AVERAGED")
    H_interp_doppler2 = H_interp_doppler2_orig;
    for i=1:ofdm_symbols
        if i<ofdm_symbols
            H_interp_doppler2(:,i) = ...
                mean(H_interp_doppler2(:,i:i+1),2);
        else
            H_interp_doppler2(:,i) = ...
                mean(H_interp_doppler2(:,i-1:i),2);
        end
    end
else
    H_interp_doppler2 = H_interp_doppler2_orig;
end
%%%%% Average all CH estimates in an OFDM frame %%%%%
if EQUALIZER_METHOD == "ZF Averaged"
    if FILTER_CH_EST
        H_interp_doppler2_filt = H_interp_doppler2;
        w_default = linspace(2,1,ofdm_symbols);
        w_flip = flip(w_default);
        w_flip(end) = [];
        for i=1:ofdm_symbols
            w = [w_flip(end-i+2:end) w_default(1:end-i+1)];
            w = w/sum(w);
            H_interp_doppler2(:,i)=sum(H_interp_doppler2_filt.*w,2);
        end
    else
        H_interp_doppler2 = mean(H_interp_doppler2,2);
        H_interp_doppler2 = ...
            repmat(H_interp_doppler2, [1 ofdm_symbols]);
    end
end  

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot MATLAB simulated channel response and estimate
for i = 1:symbol_plot
    figure(),subplot(2,2,1),plot(1:nfft,real( ...
        H_interp_doppler2_ideal(:,i)), ...
        'linewidth',2),hold on,plot(1:nfft,real( ...
        H_interp_doppler2(:,i))),title('In-Phase'),xlim([ ...
        pilot_index(1),pilot_index(end)]),legend('Ideal','LS')
    subplot(2,2,3),plot(1:nfft,abs(H_interp_doppler2_ideal( ...
        :,i)),'linewidth',2),hold on,plot(1:nfft,abs( ...
        H_interp_doppler2(:,i))),title('Magnitude'),xlim([ ...
        pilot_index(1),pilot_index(end)]),legend('Ideal','LS')
    subplot(2,2,2),plot(1:nfft,imag(H_interp_doppler2_ideal(:,i))...
        ,'linewidth',2),hold on,plot(1:nfft,imag( ...
        H_interp_doppler2(:,i))),title('Quadrature')
    xlim([pilot_index(1),pilot_index(end)]),legend('Ideal','LS')
    subplot(2,2,4),plot(1:nfft,angle(H_interp_doppler2_ideal...
        (:,i)),'linewidth',2),hold on,plot(1:nfft,angle( ...
        H_interp_doppler2(:,i))),title('Phase')
    xlim([pilot_index(1),pilot_index(end)]),legend('Ideal','LS')

    sgtitle({'Matlab Channel Estimate, Symbol ',num2str(i)})
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Channel estimate quality measurements
% Get normalized mean square error(NMSE) of channel estimate for doppler CH
if ~PILOT_COMB_FORMAT
    H_true = zeros(data_carriers,ofdm_symbols);
    H_doppler = zeros(data_carriers,ofdm_symbols);
    for i=1:ofdm_symbols
        H_true_tmp = H_interp_doppler2_ideal(:,i);
        H_true_tmp(any(isnan(rm_pilot_zp_index(:,i)),2),:) = [];
        H_true(:,i) = H_true_tmp;
        H_doppler_tmp = H_interp_doppler2(:,i);
        H_doppler_tmp(any(isnan(rm_pilot_zp_index(:,i)),2),:) = [];
        H_doppler(:,i) = H_doppler_tmp;
    end
else
    H_true = H_interp_doppler2_ideal;
    H_true(any(isnan(rm_pilot_zp_index),2),:) = [];
    H_doppler = H_interp_doppler2;
    H_doppler(any(isnan(rm_pilot_zp_index),2),:) = [];
end
H_true_sc = H_interp_doppler2_ideal;
%H_true_sc(zp_index,:) = [];
H_doppler_sc = H_interp_doppler2;
%H_doppler_sc(zp_index,:) = [];

squared_errors = zeros(data_carriers,ofdm_symbols);
sum_squared_errors = zeros(1,ofdm_symbols);
sum_squared_magnitudes_true = zeros(1,ofdm_symbols);
NMSE_doppler = zeros(1,ofdm_symbols);
for i=1:ofdm_symbols
    squared_errors(:,i) = abs(H_true(:,i) - H_doppler(:,i)).^2;
    sum_squared_errors(i) = sum(squared_errors(:,i));
    sum_squared_magnitudes_true(i) = sum(abs(H_true(:,i)).^2);
    NMSE_doppler(i)=sum_squared_errors(i) / sum_squared_magnitudes_true(i);
end
NMSE_doppler_sc = abs(H_true_sc - H_doppler_sc).^2 ./ abs(H_true_sc.^2);
NMSE_doppler_sc2 = abs(H_true_sc - H_doppler_sc).^2;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot channel estimate NMSE vs OFDM symbol
y1 = 1:ofdm_symbols;
figure(),b = bar(y1,NMSE_doppler,'LineWidth',0.5);
xtips1 = b(1).XEndPoints;ytips1 = b(1).YEndPoints;
labels1 = string(b(1).YData);text(xtips1,ytips1,labels1,...
    'HorizontalAlignment','center','VerticalAlignment','bottom')
legend('MATLAB Sim')
xlabel('OFDM Symbols'),title('Channel Estimate Error per Symbol')
ylabel('Normalized Mean Squared Error (NMSE)')

% Plot channel estimate NMSE vs sub-carrier
y1 = 1:nfft; y1([zp_index(:,1);pilot_index(:,1)]) = [];
NMSE_doppler_sc_plot = NMSE_doppler_sc(:,1);
NMSE_doppler_sc_plot([zp_index(:,1);pilot_index(:,1)]) = [];
figure(),bar(y1,NMSE_doppler_sc_plot.');
legend('MATLAB Sim'),xlabel('Data Sub-Carriers')
title('Channel Estimate Error per Sub-Carrier for Symbol 1')
ylabel('Normalized Mean Squared Error (NMSE)')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot real channel (MATLAB or MODEM) for first 4 symbols
figure()
for i = 1:symbol_plot
    subplot(2,2,1),plot(1:nfft,real(H_interp_doppler2_ideal...
        (:,i)),'linewidth',2),hold on,xlim([pilot_index(1),...
        pilot_index(end)]),subplot(2,2,2),plot(1:nfft,imag(...
        H_interp_doppler2_ideal(:,i)),'linewidth',2),hold on
    xlim([pilot_index(1),pilot_index(end)]),subplot(2,2,3)
    plot(1:nfft,abs(H_interp_doppler2_ideal(:,i)), ...
        'linewidth',2),hold on,xlim([pilot_index(1), ...
        pilot_index(end)]),subplot(2,2,4),plot(1:nfft,angle(...
        H_interp_doppler2_ideal(:,i)),'linewidth',2),hold on
    xlim([pilot_index(1),pilot_index(end)])
end

x_lim = [-1.5 1.5];
x_lim2 = [0.4 1.8];
x_lim3 = [-4 4];

subplot(2,2,1),title('In-Phase'),xlabel('Sub-Carriers')
legend('Sym 0','Sym 1','Sym 2','Sym 3'),%ylim(x_lim)
subplot(2,2,2),title('Quadrature'),xlabel('Sub-Carriers')
legend('Sym 0','Sym 1','Sym 2','Sym 3'),%ylim(x_lim)
subplot(2,2,3),title('Magnitude'),xlabel('Sub-Carriers')
legend('Sym 0','Sym 1','Sym 2','Sym 3'),%ylim(x_lim2)
subplot(2,2,4),title('Phase'),xlabel('Sub-Carriers'),%ylim(x_lim3)
legend('Sym 0','Sym 1','Sym 2','Sym 3'),sgtitle('MATLAB Actual Channel')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% For proof only. With ideal channel, equalization should be perfect
if (EQUALIZER_METHOD == "Ideal")
    H_interp_doppler2 = H_interp_doppler2_ideal;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Channel Equalization
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Expand Equalization 
% H_ZF_re = real(H_interp); H_ZF_im = -imag(H_interp);
% fft_re = real(fft_signal_eq); fft_im = imag(fft_signal_eq);
% Z_EQ_ZF=(fft_re.*H_ZF_re + fft_im.*H_ZF_im)./ ...
%     (H_ZF_re.^2+ H_ZF_im.^2) ...
%     +1i*(fft_im.*H_ZF_re - fft_re.*H_ZF_im)./ ...
%     (H_ZF_re.^2 + H_ZF_im.^2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Equalize MATLAB Sim channel
MMSE_weights_doppler = ...
    conj(H_interp_doppler2) ./(abs(H_interp_doppler2).^2+NMSE_doppler_sc2);
MMSE_weights_doppler = NMSE_doppler_sc2 ./ (NMSE_doppler_sc2 + 1);

Z_EQ_ZF_doppler2 = fft_doppler_eq2 ./ conj(H_interp_doppler2);

%%%%% SNR Estimate %%%%%
P_RX_doppler = Z_EQ_ZF_doppler2;
if ~PILOT_COMB_FORMAT
    P_RX_doppler = zeros(pilot_carriers,ofdm_symbols);
    for i=1:ofdm_symbols
        P_RX_tmp = Z_EQ_ZF_doppler2(:,i);
        P_RX_tmp(any(isnan(pilot_index_nan(:,i)),2),:) = [];
        P_RX_doppler(:,i) = P_RX_tmp;
    end
else
    P_RX_doppler(any(isnan(pilot_index_nan),2),:) = [];
end
rx_pilots = P_RX_doppler;
rx_pilot_power = mean(abs(rx_pilots).^2);
norm_rx_pilots = rx_pilots .* sqrt(tx_pilot_power./rx_pilot_power);
noise_est = norm_rx_pilots - tx_pilots;
noise_est_power = mean(abs(noise_est).^2);
SNR_estimate_doppler = tx_pilot_power ./ noise_est_power;
SNR_estimate_db_doppler = 10*log10(mean(SNR_estimate_doppler))

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Only keep data sub-carriers
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~PILOT_COMB_FORMAT
    % Initialize data variables
    Z_EQ_ZF2 = zeros(data_carriers,ofdm_symbols);
    fft_signal_eq_2 = zeros(data_carriers,ofdm_symbols);
    fft_doppler_eq2_2 = zeros(data_carriers,ofdm_symbols);
    Z_EQ_ZF_doppler2_2 = zeros(data_carriers,ofdm_symbols);
    % Remove pilot and ZP sub-carriers
    Z_EQ_ZF = fft_signal*2.01/ifft_gain;
    for i=1:ofdm_symbols
        Z_EQ_ZF_tmp = Z_EQ_ZF(:,i);
        Z_EQ_ZF_tmp(any(isnan(rm_pilot_zp_index(:,i)),2),:) = [];
        Z_EQ_ZF2(:,i) = Z_EQ_ZF_tmp;

        fft_signal_eq_tmp = fft_signal_eq(:,i);
        fft_signal_eq_tmp(any(isnan(rm_pilot_zp_index(:,i)),2),:) = [];
        fft_signal_eq_2(:,i) = fft_signal_eq_tmp;

        fft_doppler_eq2_tmp = fft_doppler_eq2(:,i);
        fft_doppler_eq2_tmp(any(isnan(rm_pilot_zp_index(:,i)),2),:) = [];
        fft_doppler_eq2_2(:,i) = fft_doppler_eq2_tmp;

        Z_EQ_ZF_doppler2_tmp = Z_EQ_ZF_doppler2(:,i);
        Z_EQ_ZF_doppler2_tmp(any(isnan(rm_pilot_zp_index(:,i)),2),:) = [];
        Z_EQ_ZF_doppler2_2(:,i) = Z_EQ_ZF_doppler2_tmp;          
    end
    Z_EQ_ZF = Z_EQ_ZF2;
    fft_signal_eq = fft_signal_eq_2;
    fft_doppler_eq2 = fft_doppler_eq2_2;
    Z_EQ_ZF_doppler2 = Z_EQ_ZF_doppler2_2/ifft_gain;

else
    Z_EQ_ZF = fft_signal*2.01/ifft_gain;
    Z_EQ_ZF(any(isnan(rm_pilot_zp_index),2),:) = [];
    fft_signal_eq(any(isnan(rm_pilot_zp_index),2),:) = [];
    fft_doppler_eq2(any(isnan(rm_pilot_zp_index),2),:) = [];
    Z_EQ_ZF_doppler2(any(isnan(rm_pilot_zp_index),2),:) = [];
    Z_EQ_ZF_doppler2 = Z_EQ_ZF_doppler2/ifft_gain;
end

% Scatter Plot %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
lim = sqrt(2*M) + 1; y_lim = [-lim lim]; x_lim = [-lim lim];
ideal_scatter = qammod(0:M-1,M);
figure(),subplot(2,1,1),scatter(real(Z_EQ_ZF),imag(Z_EQ_ZF),'.'),grid on
if PLOT_IDEAL
    hold on,scatter(real(ideal_scatter),imag(ideal_scatter),300,'c','x',...
        'LineWidth',3)
end
title({[num2str(snr_db),'dB AWGN Channel'],'No Equalization'}),ylim(y_lim)
xlim(x_lim),subplot(2,1,2),scatter(real(Z_EQ_ZF_doppler2),imag( ...
    Z_EQ_ZF_doppler2),'.'),grid on
if PLOT_IDEAL
    hold on,scatter(real(ideal_scatter),imag(ideal_scatter),300,'c','x',...
        'LineWidth',3)
end
title({'MATLAB Sim UW-A Channel','Doppler Correction with Equalization'})
ylim(y_lim),xlim(x_lim)
sgtitle('Equalizer Output')

% Loop through each OFDM MODEM symbol and plot the constellation
for i=1:symbol_plot
    figure(),scatter(real(Z_EQ_ZF_doppler2(:,i)),...
        imag(Z_EQ_ZF_doppler2(:,i)),'.'),grid on
    title(['Modem Sim Channel, Symbol ',num2str(i)])
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% QAM Demodulation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Demod
demod_data = qamdemod(Z_EQ_ZF,M);
demod_doppler2 = qamdemod(Z_EQ_ZF_doppler2,M);

ser_data = symerr(tx_data, demod_data)/numel(tx_data);
ser_doppler2 = symerr(tx_data, demod_doppler2)/numel(tx_data);

% Get EVM measurements
evm = comm.EVM(AveragingDimensions=[1 2],MaximumEVMOutputPort=1);
[data_evm,data_evm_pk] = evm(qam_mod_data/ifft_gain,Z_EQ_ZF);
[doppler_evm2,doppler_evm_pk2]=evm(qam_mod_data/ifft_gain,Z_EQ_ZF_doppler2);

table(NMSE_doppler)

Equalization =["AWGN Channel";"UW-A Channel"];
SER = [ser_data;ser_doppler2];
AverageEVM = [data_evm;doppler_evm2];
PeakEVM = [data_evm_pk;doppler_evm_pk2];
table(Equalization,SER,AverageEVM,PeakEVM)

y_lim = [0 100]; y_ofdm = 1:ofdm_symbols; y1 = 1:nfft; y_lim2 = [0 200];
carriers_plot = zeros(1,nfft); carriers_plot_doppler2 = zeros(1,nfft);
carriers_plot_sw = zeros(1,nfft);
evm = comm.EVM(AveragingDimensions=1);
evm_ofdm = evm(qam_mod_data/ifft_gain,Z_EQ_ZF);
evm_ofdm_doppler2 = evm(qam_mod_data/ifft_gain,Z_EQ_ZF_doppler2);
evm = comm.EVM(AveragingDimensions=2);
evm_carriers = evm(qam_mod_data/ifft_gain,Z_EQ_ZF);
carriers_plot(data_index(:,1)) = evm_carriers;
evm_carriers_doppler2 = evm(qam_mod_data/ifft_gain,Z_EQ_ZF_doppler2);
carriers_plot_doppler2(data_index(:,1)) = evm_carriers_doppler2;

figure(),subplot(2,2,1),bar(y1,carriers_plot),ax=gca;ax.YLim=y_lim;
xlabel('Sub-Carriers'),ylabel('%')
title({'AWGN Channel', 'Averaged Across Sub-Carriers'}),subplot(2,2,2)
bar(y1,carriers_plot_doppler2),ax=gca;ax.YLim=y_lim;xlabel('Sub-Carriers')
ylabel('%')
title({'MATLAB Sim UW-A Channel','Averaged Across Sub-Carriers'})
subplot(2,2,3)
bar(y_ofdm,evm_ofdm),ax=gca;ax.YLim=y_lim;xlabel('OFDM Symbols')
ylabel('%'),title({'AWGN Channel','Averaged Across OFDM Symbols'})
subplot(2,2,4),bar(y_ofdm,evm_ofdm_doppler2)
ax=gca;ax.YLim=y_lim;xlabel('OFDM Symbols'),ylabel('%')
title({'MATLAB Sim UW-A Channel','Averaged Across OFDM Symbols'})
sgtitle('EVM')
