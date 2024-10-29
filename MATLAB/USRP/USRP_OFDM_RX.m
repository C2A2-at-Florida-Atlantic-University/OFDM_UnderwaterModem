clear; clc; close all; fclose('all');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Settings
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
address_tx = '192.168.10.13';
address_rx = '192.168.10.19';
platform = 'N200/N210/USRP2';

% Use USRP for collecting samples else use recorded USRP samples
USRP_MODE = "normal"; % Valid names: read, write, normal
% Name of sample file previously recorded by USRP
%usrp_record = "4096_NFFT_250000_BW_256_CP_64_M_30_ZP_300000_Fc_1_guard_4_symbols_wired.mat";
%usrp_record = "4096_NFFT_250000_BW_256_CP_64_M_30_ZP_300000_Fc_1_guard_4_symbols_tank.mat";
%usrp_record = "4096_NFFT_250000_BW_256_CP_64_M_30_ZP_300000_Fc_1_guard_16_symbols_wired.mat";
%usrp_record = "4096_NFFT_250000_BW_256_CP_64_M_30_ZP_300000_Fc_1_guard_16_symbols_tank.mat";
%usrp_record = "4096_NFFT_250000_BW_256_CP_16_M_90_ZP_100000_Fc_1_guard_16_symbols_wired.mat";
usrp_record = "4096_NFFT_250000_BW_256_CP_16_M_90_ZP_100000_Fc_1_guard_16_symbols_tank_1ft.mat";
%usrp_record = "4096_NFFT_250000_BW_256_CP_256_M_90_ZP_100000_Fc_1_guard_16_symbols_wired.mat";
%usrp_record = "4096_NFFT_250000_BW_256_CP_256_M_90_ZP_100000_Fc_1_guard_16_symbols_tank.mat";

%%%%% Generic Simulation Settings %%%%%
% Add expected scatter plot constellation points on plots
    PLOT_IDEAL = false;

%%%%% Demodulation settings %%%%%
% Perform Doppler Compensation
    DOPPLER_PROC = false;
% Perform CFO Estimation and Compensation 
    CFO_COMP = true;
% Slope CFO estimates from 1 symbol to the next
    CFO_EST_SLOPE = false;
% Channel Estimation Method: "LS" or "LS Averaged"
    CH_EST_METHOD = "LS";
% Channel Estimation Frequency Interpolation method
    interp_method = 'linear';
% Filter channel estimates across OFDM symbols aka Time-Domain Smoothing
    TEMPORAL_SMOOTHING = true;
% Enable frequency domain timing offset estimation and compensation
    TA_EST_COMP = true;
% Perform phase tracking and compensation
    PHASE_TRACKING_COMP = true;
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% OFDM Parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nfft = 4096;
BW = 250000;
cp_len = 256;
M = 4;
ZP_density = 30;
Fc = 300000;

% nfft = 4096;
% BW = 250000;
% cp_len = 256;
% M = 16;
% ZP_density = 90;
% Fc = 100000;

% nfft = 4096;
% BW = 250000;
% cp_len = 256;
% M = 256;
% ZP_density = 30;
% Fc = 300000;

symbol_guard_ms = 1;
frame_guard_ms = 10;
ofdm_symbols = 4;
tx_scale = 10386;
ifft_gain = 4.402506;
extra_sync_gain = 9.616123;

filename = string(nfft)+'_NFFT_'+string(BW)+'_BW_'+string(cp_len)+'_CP_'...
    +string(M)+'_M_'+string(ZP_density)+'_ZP_'+string(Fc)+'_Fc_'+...
    string(symbol_guard_ms)+'_guard_'+string(ofdm_symbols)+...
    '_symbols_tank_1ft.mat';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fixed Values
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nfft_zc = 4096;                       % NFFT for Zadoff-Chu sequence
ZC_root = 13;                         % Zadoff-Chu root index
ZC_length = nfft_zc/2;                % Zadoff-Chu Sequence Length
doppler_cp_offset = round(cp_len/16); % Num of CP samples*2 to not use
matlab_sync_samples_early = 50;      % Num of samples to synchronize early
pilot_density = 0.5;                  % Pilot to data ratio
DAC_FS = 100000000;                   % Dac sample rate
ADC_FS = 40000000;                    % ADC sample rate
nfft_p = 32*nfft;                     % NFFT for plotting spectrum
speed_sound = 1500;                   % Speed of sound underwater
duc_ddc_loss_gain = 2;                % Loss of Matlab DUC
num_bits = 14;                        % Number of bits in a sample
cic_scale = 50;                       % Scaling of CIC
num_fir_taps = 4096;                  % Number of FIR taps for DUC/DDC
symbol_plot = ofdm_symbols;           % Set number of Symbols to plot
gp_samples = round(symbol_guard_ms / 1000 * BW);
frame_gp_samples = round(frame_guard_ms / 1000 * BW);
%LS_avg_win_size = ofdm_symbols;
LS_avg_win_size = 2;                  % Num of OFDM symbols to Avg LS Est

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculated OFDM Parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Carrier Allocation
rep = 1/pilot_density;          % Data to pilot repetition
zp_carriers = floor(nfft*ZP_density/100/2)*2; % Even Number of ZP carriers
zp_index = [1:zp_carriers/2,nfft/2,nfft/2+1,nfft-zp_carriers/2+1:nfft];
zp_carriers = zp_carriers + 2;  % Account for 2 ZP carriers around DC
pilot_index=[zp_carriers/2:rep:nfft/2-1,nfft/2+2:rep:nfft-zp_carriers/2];
if zp_index(end/2+2)-1 ~= pilot_index(end)
    pilot_index = [pilot_index zp_index(end/2+2)-1];
end
index = find(pilot_index == nfft/2-1);
if isempty(index)
    index = find(pilot_index == nfft/2-2);
    pilot_index = [pilot_index(1:index) nfft/2-1 pilot_index(index+1:end)];
end
pilot_carriers = length(pilot_index);
pilot_index = repmat(pilot_index.', [1 ofdm_symbols]);
pilot_index_orig = pilot_index;
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
Interp_val_adc = ADC_FS/Fs; % Decimation value of Modem ADC
Ts = 1/Fs; % Sampling period
Ts_up = 1/DAC_FS;
F = (-nfft_p/2:nfft_p/2-1)/nfft_p*Fs; % Plotting baseband spectrum
F_up = (-nfft_p/2:nfft_p/2-1)/nfft_p*DAC_FS; % Plotting DUC spectrum
F_up_adc = (-nfft_p/2:nfft_p/2-1)/nfft_p*ADC_FS; % MODEM ADC frequency
cp_used = cp_len - 2*doppler_cp_offset;
Max_Freq_offset = 2*scs*(cp_used/nfft);

fir_taps_5 = fir1(num_fir_taps,1/(DAC_FS/Fs));
fir_taps_5 = fir_taps_5 / sqrt(sum(fir_taps_5.^2));
filter_delay_5 = floor(length(fir_taps_5)/2);

fir_taps_2 = fir1(num_fir_taps,1/(DAC_FS/Fs));
fir_taps_2 = fir_taps_2 / sqrt(sum(fir_taps_2.^2));
filter_delay_2 = floor(length(fir_taps_2)/2);

fir_taps_4x=fir1(128,1/4);% Mimic 4x decimation with 128 TAP filter in FPGA
%fir_taps_4x = fir_taps_4x / sqrt(sum(fir_taps_4x.^2));
filter_delay_4x = floor(length(fir_taps_4x)/2);
fir_taps_rx = fir1(num_fir_taps,1/Interp_val);
%fir_taps_rx = fir_taps_rx / sqrt(sum(fir_taps_rx.^2));
filter_delay_rx = floor(length(fir_taps_rx)/2);

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
sync_tx_i = cos(pi*ZC_root*(1:ZC_length).*((1:ZC_length)+1)/ZC_length);
sync_tx_q = -sin(pi*ZC_root*(1:ZC_length).*((1:ZC_length)+1)/ZC_length);
sync_tx = complex(sync_tx_i,sync_tx_q);
sync_tx_zp = [zeros(1,(nfft_zc-ZC_length)/2),sync_tx,zeros(1, ...
    (nfft_zc-ZC_length)/2)]; % Add ZP and center ZC sequence in BW
sync_tx_time = ifft(ifftshift(ifft_gain*sync_tx_zp),nfft_zc);

sync_coef = conj(fliplr(sync_tx_time));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Carrier Allocation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FFT carriers of Data, Pilot and ZP carriers
carriers = zeros(nfft,ofdm_symbols);
for i=1:ofdm_symbols
    carriers(pilot_index_orig(:,i),i) = reference_pilot(:,i);
    carriers(data_index_orig(:,i),i) = qam_mod_data(:,i);
    carriers(zp_index(:,i),i) = zp_carrier;
end
tx_pilot_data = carriers;
tx_pilot_data(any(isnan(pilot_data_index),2),:) = [];
carriers = carriers * tx_scale;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% IFFT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Ifftshift to reorder carriers in correct order for IFFT
ifft_sub_carriers = zeros(nfft,ofdm_symbols);
for i = 1:ofdm_symbols % In loop so Ifftshift works per symbol
    ifft_sub_carriers(:,i) = ifft(ifftshift(carriers(:,i)),nfft)*ifft_gain;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CP Insertion
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cp_start = nfft-cp_len;
cp = ifft_sub_carriers(cp_start+1:end,:);            % Obtain CP
ofdm_tx_signal_par1 = vertcat(cp,ifft_sub_carriers);  % Copy CP

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GP Insertion2)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
gp = zeros(gp_samples,ofdm_symbols);       % Obtain GP
ofdm_tx_signal_par = vertcat(ofdm_tx_signal_par1,gp); % Copy GP

qam_mod_data = carriers/tx_scale;
qam_mod_data(any(isnan(rm_pilot_zp_index),2),:) = [];
reference_pilot = carriers/tx_scale;
reference_pilot(any(isnan(pilot_index_nan),2),:) = [];
tx_data = qamdemod(qam_mod_data,M);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Parallel to Serial
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ofdm_tx_signal_ser = reshape(ofdm_tx_signal_par,[(nfft+cp_len+ ...
    gp_samples)*ofdm_symbols, 1]);         % Parallel to Serial
gp = zeros(gp_samples,1);                  % Obtain GP
sync_tx_time = max(abs(ofdm_tx_signal_ser)) / max(abs(sync_tx_time)) * ...
    sync_tx_time; % Scale ZC sequence to data symbols
ofdm_duc_signal = [sync_tx_time.'; ...
    zeros(cp_len,1);gp;ofdm_tx_signal_ser]; % OFDM Frame
ofdm_duc_signal = ofdm_duc_signal.';
t = 0:1/BW/2:length(ofdm_duc_signal)/BW/2-1/BW/2;

% Frame GP
frame_gp = zeros(1,frame_gp_samples);

% figure(),subplot(2,1,1),plot(t*1000,real(ofdm_duc_signal))
% xlabel('Time (ms)'),title('In-Phase'),subplot(2,1,2)
% plot(t*1000,imag(ofdm_duc_signal)),xlabel('Time (ms)')
% title('Quadrature'),sgtitle('Baseband OFDM TX Signal')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DUC
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% up_signal = upsample(ofdm_tx_signal_ser, 5);
% up_signal = [up_signal;zeros(filter_delay_5,1)];
% ofdm_duc_signal = filter(fir_taps_5, 1, up_signal).'*7;
% ofdm_duc_signal(1:filter_delay_5) = [];
% 
% ddc_stage2 = [ofdm_duc_signal zeros(1,filter_delay_2)];
% ddc_stage2_out = filter(fir_taps_2,1,ddc_stage2);
% ddc_stage2_out(1:filter_delay_2) = [];
% ofdm_duc_signal = downsample(ddc_stage2_out,2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% USRP N210 TX/Rx
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Samples = length(ofdm_duc_signal)+length(frame_gp);
if USRP_MODE ~= "read"
    RadioRx = comm.SDRuReceiver(...
        'Platform',             platform, ...
        'IPAddress',            address_rx, ...  % Receiver's IP
        'CenterFrequency',      Fc, ...  % Matching the transmitter's freq
        'Gain',                 0, ...   % Adjust based on your setup
        'DecimationFactor',     Interp_val, ...
        'SamplesPerFrame',      Samples*2, ...
        'OutputDataType',       'double');
    release(RadioRx);
    RadioRxInfo = info(RadioRx);
    display(RadioRxInfo)
    
    disp('Starting RX')    
    [ofdm_rx_signal, ~, overflow] = step(RadioRx);
end

if USRP_MODE == "write"
    save(filename,'ofdm_rx_signal');
    disp('Wrote to file');
    return
end
if USRP_MODE == "read"
    load(usrp_record,'ofdm_rx_signal');
end

t_rx = 0:1/BW/2:length(ofdm_rx_signal)/BW/2-1/BW/2;
figure(),subplot(2,2,1),plot(real(ofdm_rx_signal)),xlabel('Samples')
title('In-Phase'),subplot(2,2,2),plot(imag(ofdm_rx_signal))
xlabel('Samples'),title('Quadrature'),subplot(2,2,3)
plot(t_rx*1000,real(ofdm_rx_signal)),xlabel('Time (ms)'),title('In-Phase')
subplot(2,2,4),plot(t_rx*1000,imag(ofdm_rx_signal)),xlabel('Time (ms)')
title('Quadrature'),sgtitle('Baseband OFDM RX Signal')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Synchronization
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ofdm_rx_signal = ofdm_rx_signal.';
sync_corr_filt = abs(filter(sync_coef,1,ofdm_rx_signal));
while (1)
    [val,ind0] = max(sync_corr_filt);
    if (ind0 > length(ofdm_rx_signal) - length(ofdm_duc_signal));
        sync_corr_filt(ind0) = complex(0);
    else
        break;
    end
end
sync_corr_filt = abs(filter(sync_coef,1,ofdm_rx_signal));
%ind = ind-sync_samples_early+gp_samples+cp_len; % Remove GP from index
ind = ind0+gp_samples+cp_len;
ofdm_rx_sync_signal = ofdm_rx_signal;
ofdm_rx_sync_signal([1:ind, ...
    ind+1+(nfft+cp_len+gp_samples)*ofdm_symbols:end]) = [];
if (length(ofdm_rx_sync_signal) ~= (nfft+cp_len+gp_samples)*ofdm_symbols)
    tmp = zeros(1,(nfft+cp_len+gp_samples)*ofdm_symbols- ...
        length(ofdm_rx_sync_signal));
    ofdm_rx_sync_signal = [ofdm_rx_sync_signal tmp];
    warning('Deleted too much of signal')
end

% Plot %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
t_p = 0:Ts:length(ofdm_rx_signal)*Ts-Ts;
vertical_lines = zeros(1,ofdm_symbols*3);
line_label = string.empty(0,length(vertical_lines));
for i=1:ofdm_symbols
    if (i == 1)
        %vertical_lines(i) = nfft_zc + gp_samples;
        vertical_lines = ind;
        line_label(i) = "CP";
        vertical_lines(i+1) = vertical_lines(i) + cp_len;
        line_label(i+1) = "Data";
        vertical_lines(i+2) = vertical_lines(i+1) + nfft;
        line_label(i+2) = "GP";
    else
        vertical_lines(3*i-2) = vertical_lines(3*i-3) + gp_samples;
            gp_samples;
        line_label(3*i-2) = "CP";
        vertical_lines(3*i-1) = vertical_lines(3*i-2) + cp_len;
        line_label(3*i-1) = "Data";
        vertical_lines(3*i) = vertical_lines(3*i-1) + nfft;
        line_label(3*i) = "GP";
    end
end

vertical_lines = [ind0 vertical_lines];
line_label = ["Sync", line_label];
figure(),subplot(3,1,1),plot(t_p/1000,real(ofdm_rx_signal))
for i = 1:length(vertical_lines)
    if i == 1
        xline(vertical_lines(i)*Ts/1000,'--b',line_label{i}, ...
            'LabelHorizontalAlignment','left')
    else
        xline(vertical_lines(i)*Ts/1000,'--b',line_label{i})
    end
end
xlabel('Time (ms)'),title('In Phase'),subplot(3,1,2)
plot(t_p/1000,imag(ofdm_rx_signal))
for i = 1:length(vertical_lines)
    if i == 1
        xline(vertical_lines(i)*Ts/1000,'--b',line_label{i}, ...
            'LabelHorizontalAlignment','left')
    else
        xline(vertical_lines(i)*Ts/1000,'--b',line_label{i})
    end
end
xlabel('Samples'),title('Quadrature'),subplot(3,1,3)
plot(t_p/1000,sync_corr_filt)
vertical_lines = [ind0 vertical_lines];
line_label = ["Sync", line_label];
xline(vertical_lines(2)*Ts/1000,'--b',line_label{2}, ...
    'LabelHorizontalAlignment','left')
xlabel('Time (ms)'),title('Synchronizer Correlator Output')
sgtitle('Baseband OFDM Signal Before Resampler')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Serial to Parallel
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ofdm_rx_signal_par=reshape(ofdm_rx_sync_signal, ...
    [nfft+cp_len+gp_samples ofdm_symbols]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Remove Cyclic Prefix and Guard Period
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ofdm_rx_signal_par(end-gp_samples+1:end,:) = []; % Remove GP
ofdm_cfo_signal = ofdm_rx_signal_par;
ofdm_cfo_signal(1:cp_len,:) = []; % Remove CP;

%%%%% CFO Estimation %%%%%
if CFO_COMP
    t = 0:Ts:length(ofdm_rx_sync_signal)*Ts-Ts;
    cfo_est = zeros(1,ofdm_symbols);
    cfo_est_doppler = zeros(1,ofdm_symbols);
    for i=1:ofdm_symbols
        cp_cfo_begin = ofdm_rx_signal_par(doppler_cp_offset+1:cp_len- ...
            doppler_cp_offset,i); % Obtain CP at beginning of symbol
        cp_cfo_end = ofdm_rx_signal_par(nfft+1+doppler_cp_offset: ...
            end-doppler_cp_offset,i); % Obtain CP at end of symbol
        tmp = cp_cfo_end .* conj(cp_cfo_begin); % Correlate
        sum_val = sum(tmp);
        tan_val = atan2(imag(sum_val),real(sum_val));
        normalized_cfo_est = 1*tan_val;
        cfo_est_val(i) = normalized_cfo_est*scs;
        cfo_est_doppler(i) = cfo_est_val(i)/2/pi;
    end

        %%%%% CFO Compensation %%%%%
    cfo_est_slope1 = ones(nfft,ofdm_symbols) .* cfo_est_val;
    cfo_est = zeros(nfft,ofdm_symbols);cfo_est_slope = cfo_est;
    cfo_est_val = [cfo_est_val (cfo_est_val(end)+(cfo_est_val(end)-...
        cfo_est_val(end-1)))];
    for i=1:ofdm_symbols
        if i == 1
            y1 = cfo_est_val(i) + 0.5*(cfo_est_val(i)-cfo_est_val(i+1));
        else
            y1 = y2;
        end
        y2 = cfo_est_val(i) - 0.5*(cfo_est_val(i)-cfo_est_val(i+1));
        slope = (y2-y1)/(nfft);
        cfo_est(:,i) = slope*(1:nfft)+(y1);
        if CFO_EST_SLOPE
            cfo_est_slope(:,i) = cfo_est(:,i);
        else
            cfo_est_slope(:,i) = cfo_est_slope1(:,i);
        end
        for K=1:nfft
            ofdm_cfo_signal(K,i)=ofdm_cfo_signal(K,i).*conj(cos(...
                cfo_est_slope(K,i)*t(K))+1i*sin(cfo_est_slope(K,i)*t(K)));
        end
    end

    %%%%% Plot CFO Estimates %%%%%
    cfo_comp = reshape(cfo_est_slope1, [1 nfft*ofdm_symbols]);
    cfo_est = reshape(cfo_est, [1 nfft*ofdm_symbols]);
    table(cfo_est_doppler)
    figure(),plot(cfo_est/2/pi),hold on,plot(cfo_comp/2/pi)
    xlabel('Samples'),ylabel('Frequency Offset (Hz)')
    title('Carrier Frequency Offset')
    for i=1:ofdm_symbols
        xline(nfft*i,'--k',['Symbol ',num2str(i)],...
            'LabelHorizontalAlignment','left','LabelVerticalAlignment',...
            'bottom')
    end
    legend('CFO Estimate Fitting','CFO Estimate')
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FFT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fft_signal = zeros(nfft,ofdm_symbols);
for i = 1:ofdm_symbols % Do FFTSHIFT per symbol
    fft_signal(:,i) = fftshift(fft(ofdm_cfo_signal(:,i),nfft));
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Channel Estimation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% UW-A Channel
fft_signal_eq = fft_signal;

%%%%% Extract pilot sub-carriers %%%%%
P_RX = fft_signal_eq(pilot_index(:,1),:);

%%%%% Get LS Channel Estimate %%%%%
H = conj(P_RX) ./ conj(reference_pilot);

%%%%% Timing Offset Estimation %%%%%
TA_est = zeros(1,ofdm_symbols);                 % Timing offset estimate
for i=1:ofdm_symbols
    phase_sum = 0; % Initialize the sum of phase differences
    for K = 1:pilot_carriers-2
        % Calculate the phase difference between pilot pairs
        phase_diff = angle(H(K,i) * conj(H(K+2,i)));
        % Accumulate the phase differences
        phase_sum = phase_sum + phase_diff;
    end
    % Average the phase differences
    avg_phase_diff = phase_sum / (pilot_carriers-2);
    % Unwrap the average phase difference
    avg_phase_diff_unwrapped = unwrap(avg_phase_diff);
    % Estimate the timing offset
    TA_est(i) = avg_phase_diff_unwrapped * nfft / (2 * pi * 4);
end
table(TA_est)

%%%%% Timing Offset Compensation %%%%%
if TA_EST_COMP
    TA_comp = exp(1j*2*pi*(1:nfft)' .* TA_est/nfft);
    TA_comp_H = TA_comp(pilot_index(:,1),:);
    TA_comp = exp(-1j*2*pi*(1:nfft)' .* TA_est/nfft);
    % Compensate LS estimate and data:
    H = H .* TA_comp_H;
    fft_signal_eq = fft_signal_eq .* TA_comp;
    %%%%% Plot %%%%%
    figure(),subplot(2,2,1),plot(real(TA_comp(:,1))),title('In-Phase')
    xlabel('Sub-Carrier Index'),subplot(2,2,2),plot(imag(TA_comp(:,1)))
    title('Quadrature'),xlabel('Sub-CarrierIndex'),subplot(2,2,3)
    plot(real(TA_comp_H(:,1))),title('In-Phase')
    xlabel('Pilot-Carrier Index'),subplot(2,2,4),plot(imag(TA_comp_H(:,1)))
    title('Quadrature'),xlabel('Pilot-Carrier Index')
    sgtitle('TA Compensation')
end

%%%%% Estimate and correct for phase offsets between symbols %%%%%
if PHASE_TRACKING_COMP
    phase_sym1 = H(:,1); % Initialize phase reference from 1st symbol
    phase_sym_rot = zeros(1,ofdm_symbols);
    for i=1:ofdm_symbols
        % Current phase of the symbol
        phase_sym_next = H(:,i);
        % Compute the phase difference
        phase_diff = angle(phase_sym1 ./ phase_sym_next);
        % Unwrap the phase differences
        phase_diff_unwrapped = unwrap(phase_diff);
        % Average the unwrapped phase differences using cmpx exponentials
        phase_sym_rot(i) = mean(phase_diff_unwrapped);
    end
    H = H .* exp(1i*phase_sym_rot);
    fft_signal_eq = fft_signal_eq .* exp(-1i*phase_sym_rot);
end

%%%%% Interpolate estimates at pilots to all sub-carriers %%%%%
H_interp_doppler = interp1(pilot_index(:,1), H, 1:nfft, interp_method, ...
    "extrap");

%%%%% Average all CH estimates in an OFDM frame
if CH_EST_METHOD == "LS Averaged"
    if TEMPORAL_SMOOTHING
        H_interp_doppler_filt = H_interp_doppler;
        if LS_avg_win_size ~= ofdm_symbols
            w_default = linspace(2,1,LS_avg_win_size);
            w_default = [w_default zeros(1,ofdm_symbols-LS_avg_win_size)];
        else
            w_default = linspace(2,1,ofdm_symbols);
        end
        w_flip = flip(w_default);
        w_flip(end) = [];
        for i=1:ofdm_symbols
            w = [w_flip(end-i+2:end) w_default(1:end-i+1)];
            w = w/sum(w);
            H_interp_doppler(:,i) = sum(H_interp_doppler_filt .* w, 2);
        end
    else
        H_interp_doppler = mean(H_interp_doppler,2);
        H_interp_doppler = repmat(H_interp_doppler, [1 ofdm_symbols]);
    end
end

%%%%% Get Ideal channel to compare with estimated channel %%%%%
H_ideal_doppler = conj(fft_signal_eq) ./ conj(carriers/tx_scale);
H_ideal_doppler(isinf(H_ideal_doppler)) = 0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Channel Estimate Plots
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot UW-A Channel response and estimates at pilots + data sub-carriers
for i=1:ofdm_symbols
    figure(),subplot(2,2,1),plot(1:nfft,real(H_ideal_doppler(:,i)),...
        'linewidth',2),hold on,plot(1:nfft,real(H_interp_doppler(:,i)))
    plot(pilot_index(:,i),real(H_ideal_doppler(pilot_index(:,i),i)),...
        'LineStyle','none','MarkerEdgeColor','#0072BD','Marker','*')
    legend('Ideal','LS','Pilots'),title('In-Phase')
    xlim([pilot_index(1),pilot_index(end)])
    subplot(2,2,3),plot(1:nfft,abs(H_ideal_doppler(:,i)),...
        'linewidth',2),hold on,plot(1:nfft,abs(H_interp_doppler(:,i)))
    plot(pilot_index(:,i),abs(H_ideal_doppler(pilot_index(:,i),i)),...
        'LineStyle','none','MarkerEdgeColor','#0072BD','Marker','*')
    legend('Ideal','LS','Pilots'),title('Magnitude')
    xlim([pilot_index(1),pilot_index(end)])
    subplot(2,2,2),plot(1:nfft,imag(H_ideal_doppler(:,i)),...
        'linewidth',2),hold on,plot(1:nfft,imag(H_interp_doppler(:,i)))
    plot(pilot_index(:,i),imag(H_ideal_doppler(pilot_index(:,i),i)),...
        'LineStyle','none','MarkerEdgeColor','#0072BD','Marker','*')
    legend('Ideal','LS','Pilots'),title('Quadrature')
    xlim([pilot_index(1),pilot_index(end)])
    subplot(2,2,4),plot(1:nfft,angle(H_ideal_doppler(:,i)),...
        'linewidth',2),hold on,plot(1:nfft,angle(H_interp_doppler(:,i)))
    plot(pilot_index(:,i),angle(H_ideal_doppler(pilot_index(:,i),i)),...
        'LineStyle','none','MarkerEdgeColor','#0072BD','Marker','*')
    legend('Ideal','LS','Pilots'),title('Angle')
    xlim([pilot_index(1),pilot_index(end)])
    sgtitle({'Channel Estimate Data + Pilot, Symbol ',num2str(i)})
end

%%%%% Plot MODEM Channel Estimate only at data sub-carriers %%%%%
for i=1:ofdm_symbols
    figure(),subplot(2,2,1),plot(data_index(:,i),real( ...
        H_ideal_doppler(data_index(:,i),i)),'linewidth',2),hold on
    plot(data_index(:,i),real(H_interp_doppler(data_index(:,i),i)))
    legend('Ideal','LS'),title('In-Phase')
    xlim([pilot_index(1),pilot_index(end)]),subplot(2,2,2)
    plot(data_index(:,i),imag( ...
        H_ideal_doppler(data_index(:,i),i)),'linewidth',2),hold on
    plot(data_index(:,i),imag(H_interp_doppler(data_index(:,i),i)))
    legend('Ideal','LS'),title('Quadrature')
    xlim([pilot_index(1),pilot_index(end)]),subplot(2,2,3)
    plot(data_index(:,i),abs( ...
        H_ideal_doppler(data_index(:,i),i)),'linewidth',2),hold on
    plot(data_index(:,i),abs(H_interp_doppler(data_index(:,i),i)))
    legend('Ideal','LS'),title('Magnitude')
    xlim([pilot_index(1),pilot_index(end)]),subplot(2,2,4)
    plot(data_index(:,i),imag( ...
        H_ideal_doppler(data_index(:,i),i)),'linewidth',2),hold on
    plot(data_index(:,i),imag(H_interp_doppler(data_index(:,i),i)))
    legend('Ideal','LS'),title('Angle')
    xlim([pilot_index(1),pilot_index(end)])
    sgtitle({'UW-A Channel Estimate Data Carriers, Symbol ',num2str(i)})
end

%%%%% Channel estimate quality measurements %%%%%
H_true = H_ideal_doppler(data_index(:,1));
H_actual = H_interp_doppler(data_index(:,1));

%%%%% Plot real channel (MATLAB or MODEM) for first 4 symbols %%%%%
figure()
for i = 1:symbol_plot
    subplot(2,2,1),plot(1:nfft,real(H_ideal_doppler(:,i)), ...
        'linewidth',2),hold on,xlim([pilot_index(1), ...
        pilot_index(end)]),subplot(2,2,2),plot(1:nfft,imag( ...
        H_ideal_doppler(:,i)),'linewidth',2),hold on
    xlim([pilot_index(1),pilot_index(end)])
    subplot(2,2,3),plot(1:nfft,abs(H_ideal_doppler(:,i)), ...
        'linewidth',2),hold on,xlim([pilot_index(1), ...
        pilot_index(end)]),subplot(2,2,4),plot(1:nfft,angle(...
        H_ideal_doppler(:,i)),'linewidth',2),hold on
    xlim([pilot_index(1),pilot_index(end)])
end
subplot(2,2,1),title('In-Phase'),xlabel('Sub-Carriers')
legend('Sym 0','Sym 1','Sym 2','Sym 3')
subplot(2,2,2),title('Quadrature'),xlabel('Sub-Carriers')
legend('Sym 0','Sym 1','Sym 2','Sym 3')
subplot(2,2,3),title('Magnitude'),xlabel('Sub-Carriers')
legend('Sym 0','Sym 1','Sym 2','Sym 3')
subplot(2,2,4),title('Phase'),xlabel('Sub-Carriers')
legend('Sym 0','Sym 1','Sym 2','Sym 3')
sgtitle('UW-A Actual Channel')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Channel Equalization
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Z_EQ_ZF = fft_signal_eq ./ conj(H_interp_doppler);
Z_EQ_ZF([pilot_index(:,1);zp_index(:,1)],:) = [];

%%%%% Scatter Plot %%%%%
lim = sqrt(2*M) + 1; y_lim = [-lim lim]; x_lim = [-lim lim];
ideal_scatter = qammod(0:M-1,M);

figure(),scatter(real(Z_EQ_ZF),imag(Z_EQ_ZF),'.'),grid on
if PLOT_IDEAL
    hold on,scatter(real(ideal_scatter),imag(ideal_scatter),300,'c','x',...
        'LineWidth',3)
end
title({'UW-A Channel','Equalized'}),ylim(y_lim),xlim(x_lim)

%%%%% Loop through each OFDM symbol, plot constellation %%%%%
symbol = 4;
figure()
for i=1:ofdm_symbols
    subplot(ofdm_symbols/2,ofdm_symbols/2,i),scatter(real(Z_EQ_ZF(:,i)),imag(Z_EQ_ZF(:,i)),'.')
    title(['UW-A Channel, Symbol ',num2str(i)])
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% QAM Demodulation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Demod
demod_data = qamdemod(Z_EQ_ZF,M);

% Symbol Error Rate
ser_data = symerr(tx_data,demod_data)/numel(tx_data);

% Get EVM measurements:
evm = comm.EVM(AveragingDimensions=[1 2],MaximumEVMOutputPort=1);
[data_evm,data_evm_pk] = evm(qam_mod_data,Z_EQ_ZF);

table(ser_data,data_evm,data_evm_pk)

%%%%% EVM Plots %%%%%
y_lim = [0 100]; y_ofdm = 1:ofdm_symbols; carriers_plot = zeros(1,nfft);
evm = comm.EVM(AveragingDimensions=1); y1=1:nfft;
evm_ofdm = evm(qam_mod_data,Z_EQ_ZF);
evm = comm.EVM(AveragingDimensions=2);
evm_carriers = evm(qam_mod_data,Z_EQ_ZF);
carriers_plot(data_index(:,1)) = evm_carriers;

figure(),subplot(2,1,1),bar(y1,carriers_plot)%,ax=gca;%ax.YLim=y_lim;
xlabel('Sub-Carriers'),ylabel('%')
title({'UW-A Channel','Averaged Across Sub-Carriers'}),subplot(2,1,2)
bar(y_ofdm,evm_ofdm)%,ax=gca;ax.YLim=y_lim;
xlabel('OFDM_Symbols')
ylabel('%'),title({'UW-A Channel','Averaged Across OFDM Symbols'})
sgtitle('EVM')