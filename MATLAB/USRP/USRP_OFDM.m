clear; clc; close all; fclose('all');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Settings
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
address_tx = '192.168.10.13';
address_rx = '192.168.10.19';
platform = 'N200/N210/USRP2';

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

figure(),subplot(2,1,1),plot(t*1000,real(ofdm_duc_signal))
xlabel('Time (ms)'),title('In-Phase'),subplot(2,1,2)
plot(t*1000,imag(ofdm_duc_signal)),xlabel('Time (ms)')
title('Quadrature'),sgtitle('Baseband OFDM TX Signal')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DUC
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% up_signal = upsample(ofdm_tx_signal_ser, 5);
% up_signal = [up_signal;zeros(filter_delay_5,1)];
% ofdm_duc_signal = filter(fir_taps_5, 1, up_signal).'*7;
% ofdm_duc_signal(1:filter_delay_5) = [];

% ddc_stage2 = [ofdm_duc_signal zeros(1,filter_delay_2)];
% ddc_stage2_out = filter(fir_taps_2,1,ddc_stage2);
% ddc_stage2_out(1:filter_delay_2) = [];
% ofdm_duc_signal = downsample(ddc_stage2_out,2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% USRP N210 TX/Rx
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
RadioTx = comm.SDRuTransmitter(...
    'Platform',             platform, ...
    'IPAddress',            address_tx, ...
    'CenterFrequency',      Fc, ...
    'Gain',                 0, ...
    'InterpolationFactor',  Interp_val);
normalized_signal = (ofdm_duc_signal / max(abs(ofdm_duc_signal))).';
normalized_signal = [normalized_signal;complex(frame_gp).'];
RadioTxInfo = info(RadioTx);
display(RadioTxInfo);
disp('Starting TX')
while(1)
    RadioTx(0.5*normalized_signal);
end
