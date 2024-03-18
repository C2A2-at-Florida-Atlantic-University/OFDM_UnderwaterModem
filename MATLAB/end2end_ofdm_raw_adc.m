clear; clc; close all; fclose all; format long;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Simulation settings
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
EQUALIZER_METHOD = "ZF"; % "ZF", "MMSE", "ZF Averaged"
LOOPBACK = false;
DAC_ADC_SEL_DAC = false;
OSCILLOSCOPE = false;
seed = 0;
seed_diff = 0;
if (DAC_ADC_SEL_DAC)
    start_sample = 20498;
    start_sample = 20000; 
    start_sample = 20160;
else
    start_sample = 118915;
    start_sample = 118711;
    start_sample = 118582;
    start_sample = 118404;
    start_sample = 118000;
    start_sample = 192852;
    start_sample = 282420;
%     start_sample = 117500;
%     start_sample = 117000;
%     start_sample = 116000;
%     start_sample = 115000;
end
if (OSCILLOSCOPE)
    start_sample = 1866000; % For PA output
    start_sample = 4412650; % For DAC output
    start_sample = 4413250; % For ADC input
    start_sample = 4413250; % For ADC input atten 2
    start_sample = 4413450; % For ADC input atten 2 cleanup
    start_sample = 4417450; % For ADC input coax
    start_sample = 4413450; % For ADC input coax2
    start_sample = 4517450; % For waveform rx
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% OFDM Parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Read OFDM Parameters from Info file from SW program
%file = fopen('../Testing/Water_Testing/Tank/ADC_Capture/preset_0_test_0/OfdmInfo1.txt','r');
file = fopen('../Testing/Water_Testing/Tank/Full_Demod/preset_3_test_2/OfdmInfo1.txt','r');
nfft = fscanf(file,"%d,",1);   % Size of FFT, number of subcarriers in OFDM
BW = fscanf(file,"%lf,",1); BW = BW*1000;% Bandwidth = complex FS
cp_len = fscanf(file, "%d,", 1);        % Cyclic Prefix length in samples
M = fscanf(file,"%d,", 1);              % Modulation Order
ZP_density = fscanf(file,"%d,", 1);     % Zero Padded Pilot Density
symbol_guard_ms = fscanf(file,"%d,",1); % Symbol guard band in ms
symbol_guard_ms = 6;
frame_guard_ms = fscanf(file,"%d,",1);  % Frame guard band in ms
ofdm_symbols = fscanf(file,"%d,",1);    % Number of OFDM symbols in a Frame
Fc = fscanf(file,"%d,",1); Fc = Fc * 1000;% Center frequency of OFDM signal
tx_scale = fscanf(file,"%d,",1);        % Frequency domain digital gain
ifft_gain = fscanf(file,"%f,",1);       % Ifft scalar gain
extra_sync_gain = fscanf(file,"%f",1);  % Extra Sync Symbol gain
fclose('all');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fixed Values
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nfft_zc = 4096;                 % NFFT for Zadoff-Chu sequence
ZC_root = 13;                   % Zadoff-Chu root index
ZC_length = nfft_zc/2;          % Zadoff-Chu Sequence Length
doppler_cp_offset = round(cp_len/16); % Num of CP samples*2 to not use
sync_samples_early = 0;         % Number of samples to synchronize early
force_doppler_sync = 0;         % Force doppler synchronization
pilot_density = 0.5;            % Pilot to data ratio
if (DAC_ADC_SEL_DAC)
    DAC_FS = 10000000;          % DAC sample rate
else
    DAC_FS = 40000000;          % ADC sample rate
end
if (OSCILLOSCOPE)
    DAC_FS = 100000000;
end
nfft_p = 16*nfft;               % NFFT for plotting spectrum
speed_sound = 1500;             % Speed of sound underwater
duc_ddc_loss_gain = 2;          % Loss of Matlab DUC
num_bits = 14;                  % Number of bits in a sample
cic_scale = 50;                 % Scaling of CIC

% Channel parameters
snr_db = 14;
multipath = [0 0 0 0 0 0 0 0 0.5 0.5 0 0 1 0.2 0.54 0 0 0 0 0 0.6 ...
    0.1 0.2 0.1 0.4 0.1 0 0 0 0.1 0.05 0.02 0.2 0.2 0.1 0.1 0.1 0.05 0 ...
    0.1 0.2 0.1 0.4 0.1 0 0 0 0.1 0.05 0.02 0.2 0.2 0.1 0.1 0.1 0.05 0 ...
    0.1 0.2 0.1 0.4 0.1 0 0 0 0.1 0.05 0.02 0.2 0.2 0.1 0.1 0.1 0.05 0 ];
multipath = 2* rand(1,512) - 1;
multipath = 1;
multipath_decay_rate = 0.007;
speed = 1; % In m/s
speed = 0;

cfo = 0;
spo = 0;

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
cp_used = cp_len - 2*doppler_cp_offset;
Max_Freq_offset = 2*scs*(cp_used/nfft);
%multipath_weights = linspace(1, 0.0001, length(multipath));
multipath_weights = (1-multipath_decay_rate).^(0:length(multipath)-1);
multipath = multipath .* multipath_weights;
gp_samples = round(symbol_guard_ms / 1000 * BW);

% figure(),stem((0:1/DAC_FS:length(multipath)/DAC_FS-1/DAC_FS)*1000, ...
%     multipath),xlabel('Time (ms)'),title('Multipath Delay Spread')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Generate Pilot Data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
rng(seed)
pilot_data = randsrc(pilot_carriers,ofdm_symbols,0:M-1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Generate Message Data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
rng(seed+seed_diff)
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
sync_tx_i = cos(pi*ZC_root*(1:ZC_length).* ...
    ((1:ZC_length)+1)/ZC_length);
sync_tx_q = -sin(pi*ZC_root*(1:ZC_length).* ...
    ((1:ZC_length)+1)/ZC_length);
sync_tx = complex(sync_tx_i,sync_tx_q);
sync_tx_zp = tx_scale*[zeros(1,(nfft_zc-ZC_length)/2),sync_tx,zeros(1, ...
    (nfft_zc-ZC_length)/2)]; % Add ZP and center ZC sequence in BW
sync_tx_time = ifft(ifftshift(sync_tx_zp),nfft_zc);

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
    ifft_sub_carriers(:,i) = ifft(ifftshift(carriers(:,i)),nfft)*ifft_gain;
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
full_scale = (2^(num_bits-1))^2 * (nfft+cp_len);
full_scale_zc = (2^(num_bits-1))^2 * nfft_zc;
sig_pow = sum(abs(ofdm_tx_signal_par1.^2));
sig_pow_dBFS = 10*log10(sig_pow/full_scale);
sig_peak = max(abs(ofdm_tx_signal_par1));
sig_peak_dBFS = 10*log10(sig_peak/(2^(num_bits-1)));
sig_pow = sum(abs((extra_sync_gain*ifft_gain*sync_tx_time).^2));
sig_pow_dBFS = [10*log10(sig_pow/full_scale_zc) sig_pow_dBFS];
sig_peak = max(abs((extra_sync_gain*ifft_gain*sync_tx_time)));
sig_peak_dBFS = [10*log10(sig_peak/(2^(num_bits-1))) sig_peak_dBFS];
sig_papr_dB = sig_peak_dBFS - sig_pow_dBFS

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GP Insertion2)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
gp = zeros(gp_samples,ofdm_symbols);       % Obtain GP
ofdm_tx_signal_par = vertcat(ofdm_tx_signal_par1,gp); % Copy GP

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Parallel to Serial
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ofdm_tx_signal_ser = reshape(ofdm_tx_signal_par,[(nfft+cp_len+ ...
    gp_samples)*ofdm_symbols, 1]);         % Parallel to Serial
gp = zeros(gp_samples,1);                  % Obtain GP
ofdm_tx_signal_ser = [extra_sync_gain*ifft_gain*sync_tx_time.'; ...
    zeros(cp_len,1);gp;ofdm_tx_signal_ser]; % OFDM Frame

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DUC
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fir_taps = fir1(1024,1/(DAC_FS/Fs));
fir_taps = fir_taps / sqrt(sum(fir_taps.^2));
filter_delay = floor(length(fir_taps)/2);
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
% White noise
snr = 10^(snr_db/10); % Convert SNR from dB to linear
ofdm_tx_signal_ch = awgn(ofdm_duc_signal_real,snr,'measured');
% Multipath
ofdm_tx_signal_ch1 = filter(multipath,1,ofdm_tx_signal_ch);
% doppler
k = (1+speed/speed_sound); % doppler shift factor
Lower_BW_doppler_Shift = ((Fc-(nfft/2 - zp_carriers/2)*scs) * ...
    (k))-(Fc-(nfft/2 - zp_carriers/2)*scs);
Fc_doppler_Shift = (Fc * (1+speed/speed_sound))-Fc;
Upper_BW_doppler_Shift = ((Fc+(nfft/2 - zp_carriers/2)*scs) * ...
    (1+speed/speed_sound))- (Fc+(nfft/2 - zp_carriers/2)*scs);
table(cp_used,Max_Freq_offset,scs)
table(Lower_BW_doppler_Shift,Fc_doppler_Shift,Upper_BW_doppler_Shift)
ofdm_tx_signal_doppler =interp1(t_up,ofdm_tx_signal_ch1,t_up/k,'linear',0);
% One method to compensate for doppler if estimated k accurately:
%ofdm_tx_signal_doppler = resample(ofdm_tx_signal_doppler, ...
    %round(DAC_FS/k),DAC_FS);
%ofdm_tx_signal_doppler = ofdm_tx_signal_doppler(1:length ...
%    (ofdm_tx_signal_ch));
% Sample phase offset
ofdm_tx_signal_doppler = ofdm_tx_signal_doppler .* exp(1i*spo);

ofdm_tx_signal_ch1 = ofdm_tx_signal_doppler;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Read DAC/ADC modem samples
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if (DAC_ADC_SEL_DAC)
    file = fopen('../Xilinx/SW_Source/ofdm_v2/files/RxDacRawSamples.txt','r');
    scale = 0.6;
    ofdm_modem_rx = fscanf(file,"%d\n");   
    figure(),plot(ofdm_modem_rx),xline(start_sample)
    ofdm_modem_rx = ofdm_modem_rx(start_sample:end);
else
    file = fopen('../Xilinx/SW_Source/ofdm_v2/files/RxAdcRawSamples.txt','r');
    %file = fopen('../Testing/Water_Testing/Tank/ADC_Capture/preset_0_test_0/RxAdcRawSamples.txt','r');
    file = fopen('../Testing/Water_Testing/Tank/Full_Demod/preset_3_test_2/RxAdcRawSamples.txt','r');
    scale = 0.03;
    ofdm_modem_rx = fscanf(file,"%d\n");
    figure(),plot(ofdm_modem_rx),xline(start_sample)
    ofdm_modem_rx = ofdm_modem_rx(start_sample:end);
end
if (OSCILLOSCOPE)
    file = fopen('tek0001CH1_pa_out.csv','r');
    file = fopen('tek0003CH1_dac_out.csv','r');
    file = fopen('tek0004CH2_adc_input.csv','r');
    file = fopen('tek0005CH2_adc_input_atten2.csv','r');
    file = fopen('tek0006CH2_adc_input_atten2_cleanup.csv','r');
    file = fopen('tek0007CH2_adc_input_coax.csv','r');
    file = fopen('tek0008CH2_adc_input_coax2.csv','r');
    file = fopen('waveformrx.csv','r');

    C = textscan(file, '%*f,%f', 'Delimiter', '\n');
    ofdm_modem_rx = C{1};
    scale = 10;
end
fclose(file);

ofdm_modem_rx = ofdm_modem_rx.'*scale;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% IQ Mixer RX
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_ddc = ofdm_tx_signal_ch .* cos(2*pi*Fc*t_up);
q_ddc = ofdm_tx_signal_ch .* -sin(2*pi*Fc*t_up);
ddc_signal = complex(i_ddc,q_ddc);

t_up2 = 0:1/DAC_FS:length(ofdm_modem_rx)/DAC_FS-1/DAC_FS;
i_ddc_modem = ofdm_modem_rx .*  cos(2*pi*Fc*t_up2);
q_ddc_modem = ofdm_modem_rx .* -sin(2*pi*Fc*t_up2);
ddc_signal_modem = complex(i_ddc_modem,q_ddc_modem);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DDC
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ddc_base_signal_real=decimate(real(ddc_signal),Interp_val,4096,'Fir');
ddc_base_signal_imag=decimate(imag(ddc_signal),Interp_val,4096,'FIR');
ddc_base_signal = complex(ddc_base_signal_real,ddc_base_signal_imag);
ddc_base_signal = duc_ddc_loss_gain * ddc_base_signal.';

fir_taps_4x = fir1(128,1/4);
fir_taps_4x = fir_taps_4x / sqrt(sum(fir_taps_4x.^2));
filter_delay_4x = floor(length(fir_taps_4x)/2);
fir_taps_40x = fir1(1024,1/40);
fir_taps_40x = fir_taps_40x / sqrt(sum(fir_taps_40x.^2));
filter_delay_40x = floor(length(fir_taps_40x)/2);
if (DAC_ADC_SEL_DAC)
    ddc_modem_in = [ddc_signal_modem zeros(1,filter_delay_40x)];
    ddc_modem_out = filter(fir_taps_40x,1,ddc_modem_in);
    ddc_modem_out(1:filter_delay_40x) = [];
    ddc_modem = downsample(ddc_modem_out,40);
else
    ddc_modem_stage1 = [ddc_signal_modem zeros(1,filter_delay_4x)];
    ddc_modem_stage1_out = filter(fir_taps_4x,1,ddc_modem_stage1);
    ddc_modem_stage1_out(1:filter_delay_4x) = [];
    ddc_modem_stage1_out = downsample(ddc_modem_stage1_out,4);
    ddc_modem_stage2 = [ddc_modem_stage1_out zeros(1,filter_delay_40x)];
    ddc_modem_stage2_out = filter(fir_taps_40x,1,ddc_modem_stage2);
    ddc_modem_stage2_out(1:filter_delay_40x) = [];
    ddc_modem = downsample(ddc_modem_stage2_out,40);
end
if (OSCILLOSCOPE)
    fir_taps = fir1(4096,1/Interp_val);
    fir_taps = fir_taps / sqrt(sum(fir_taps.^2));
    filter_delay = floor(length(fir_taps)/2);
    ddc_modem_in = [ddc_signal_modem zeros(1,filter_delay)];
    ddc_modem_out = filter(fir_taps,1,ddc_modem_in);
    ddc_modem_out(1:filter_delay) = [];
    ddc_modem = downsample(ddc_modem_out,Interp_val);
end

if (~OSCILLOSCOPE)
  ddc_modem = ddc_modem(1:(nfft+cp_len+gp_samples)*ofdm_symbols).';
  ddc_modem = [zeros(nfft_zc+cp_len+gp_samples,1);ddc_modem];
end

t = 0:Ts:length(ddc_base_signal)*Ts-Ts;

if (LOOPBACK)
    ddc_base_signal = ofdm_tx_signal_ser;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Synchronization
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sync_coef = conj(fliplr(sync_tx_time)); % Matched Filter
sync_corr_filt = abs(filter(sync_coef,1,ddc_base_signal));
[val,ind] = max(sync_corr_filt);
ind = ind-sync_samples_early+gp_samples+cp_len; % Remove GP from index
ofdm_rx_sync_signal = ddc_base_signal;
ofdm_rx_sync_signal([1:ind, ...
    ind+1+(nfft+cp_len+gp_samples)*ofdm_symbols:end]) = [];
if (length(ofdm_rx_sync_signal) ~= (nfft+cp_len+gp_samples)*ofdm_symbols)
    tmp = zeros(1,(nfft+cp_len+gp_samples)*ofdm_symbols- ...
        length(ofdm_rx_sync_signal)).';
    ofdm_rx_sync_signal = [ofdm_rx_sync_signal;tmp];
    warning('Deleted too much of signal')
end

sync_corr_modem = abs(filter(sync_coef,1,ddc_modem));
if (OSCILLOSCOPE)
    [val2,ind2] = max(sync_corr_modem);
    ind2 = ind2-sync_samples_early+gp_samples+force_doppler_sync+cp_len;
    ofdm_rx_sync_modem = ddc_modem;
    ofdm_rx_sync_modem([1:ind2, ...
        ind2+1+(nfft+cp_len+gp_samples)*ofdm_symbols:end]) = [];
    if (length(ofdm_rx_sync_modem) ~= (nfft+cp_len+gp_samples)*ofdm_symbols)
        tmp = zeros(1,(nfft+cp_len+gp_samples)*ofdm_symbols- ...
            length(ofdm_rx_sync_modem)).';
        ofdm_rx_sync_modem = [ofdm_rx_sync_modem;tmp];
        warning('Deleted too much of modem signal')
    end
    modem_sync_offset = (ind2-gp_samples)-(ind2-gp_samples);
    display(modem_sync_offset)
    sync_corr_modem = sync_corr_modem(ind2-nfft_zc-cp_len-gp_samples+1: ...
        ind2+(nfft+cp_len+gp_samples)*ofdm_symbols);
    ddc_modem = ddc_modem(ind2-nfft_zc-cp_len-gp_samples+1:ind2+ ...
        (nfft+cp_len+gp_samples)*ofdm_symbols);
    [val2,ind2] = max(sync_corr_modem);
    ind2 = ind2 + gp_samples + cp_len;
else
    ind2 = nfft_zc+cp_len+gp_samples;
    ofdm_rx_sync_modem = ddc_modem(ind2+1:end);
end

% Plot %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if (OSCILLOSCOPE)
    scale_sync = 50;
    scale_sync = 30;
else
    scale_sync = 1.8;
end
t_p = 0:Ts:length(ofdm_tx_signal_ser)*Ts-Ts;
vertical_lines = zeros(1,ofdm_symbols*3);
line_label = string.empty(0,length(vertical_lines));
vertical_lines_modem = zeros(1,ofdm_symbols*3);
for i=1:ofdm_symbols
    if (i == 1)
        %vertical_lines(i) = nfft_zc + gp_samples;
        vertical_lines = ind;
        vertical_lines_modem(i) = ind2;
        line_label(i) = "CP";
        vertical_lines(i+1) = vertical_lines(i) + cp_len;
        vertical_lines_modem(i+1) = vertical_lines_modem(i) + cp_len;
        line_label(i+1) = "Data";
        vertical_lines(i+2) = vertical_lines(i+1) + nfft;
        vertical_lines_modem(i+2) = vertical_lines_modem(i+1)+nfft;
        line_label(i+2) = "GP";
    else
        vertical_lines(3*i-2) = vertical_lines(3*i-3) + gp_samples;
        vertical_lines_modem(3*i-2) = vertical_lines_modem(3*i-3) + ...
            gp_samples;
        line_label(3*i-2) = "CP";
        vertical_lines(3*i-1) = vertical_lines(3*i-2) + cp_len;
        vertical_lines_modem(3*i-1)=vertical_lines_modem(3*i-2)+cp_len;
        line_label(3*i-1) = "Data";
        vertical_lines(3*i) = vertical_lines(3*i-1) + nfft;
        vertical_lines_modem(3*i) = vertical_lines_modem(3*i-1)+nfft;
        line_label(3*i) = "GP";
    end
end

vertical_lines = [nfft_zc vertical_lines];
line_label = ["Sync", line_label];
figure(),subplot(3,1,1),plot(t_p/1000,real(ofdm_tx_signal_ser), ...
    'LineWidth',2),hold on,plot(t_p/1000,scale_sync*real(ddc_modem))
for i = 1:length(vertical_lines)
    if i == 1
        xline(vertical_lines(i)*Ts/1000,'--r',line_label{i}, ...
            'LabelHorizontalAlignment','left')
    else
        xline(vertical_lines(i)*Ts/1000,'--r',line_label{i})
        xline(vertical_lines_modem(i-1)*Ts/1000,'--b',line_label{i}, ...
            'LabelVerticalAlignment','bottom');
    end
end
legend('TX','UW-A Channel')
xlabel('Time (ms)'),title('In Phase'),subplot(3,1,2)
plot(t_p/1000,imag(ofdm_tx_signal_ser),'LineWidth',2),hold on
plot(t_p/1000,scale_sync*imag(ddc_modem))
for i = 1:length(vertical_lines)
    if i == 1
        xline(vertical_lines(i)*Ts/1000,'--r',line_label{i}, ...
            'LabelHorizontalAlignment','left')
    else
        xline(vertical_lines(i)*Ts/1000,'--r',line_label{i})
        xline(vertical_lines_modem(i-1)*Ts/1000,'--b',line_label{i}, ...
            'LabelVerticalAlignment','bottom');
    end
end
legend('TX','UW-A Channel'),xlabel('Time (ms)')
title('Quadrature'),subplot(3,1,3),plot(t_p/1000,sync_corr_filt),hold on
plot(t_p/1000,scale_sync*sync_corr_modem)
vertical_lines = [ind2-gp_samples-cp_len vertical_lines];
line_label = ["UW-A Sync", line_label];
xline(vertical_lines(2)*Ts/1000,'--b',line_label{2}, ...
    'LabelHorizontalAlignment','left')
xline(vertical_lines(1)*Ts/1000,'--r',line_label{1}, ...
    'LabelHorizontalAlignment','left','LabelVerticalAlignment','bottom')
legend('AWGN Channel','UW-A MAT Channel','AWGN Timing','UW-A MAT Timing')
xlabel('Time (ms)'),title('Synchronizer Correlator Output')
sgtitle('Baseband OFDM Signal')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Serial to Parallel
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ofdm_rx_signal_par=reshape(ofdm_rx_sync_signal, ...
    [nfft+cp_len+gp_samples ofdm_symbols]);
ddc_modem = reshape(ofdm_rx_sync_modem, ...
    [nfft+cp_len+gp_samples ofdm_symbols]);
%figure(),subplot(2,1,1),plot(real(ddc_modem)),

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CFO Estimation and Correction
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Remove GP
ofdm_rx_signal_par(end-gp_samples+1:end,:) = [];
% Remove GP
ddc_modem(end-gp_samples+1:end,:) = [];

% Plot spectrum
figure(),subplot(2,1,1),
plot(F/1000,10*log10(abs(fftshift(fft(reshape(ofdm_rx_signal_par, ...
    [1 (nfft+cp_len)*ofdm_symbols]),nfft_p)))))
title('MATLAB'),xlabel('kHz'),ylabel('dB'),subplot(2,1,2)
plot(F/1000,10*log10(abs(fftshift(fft(reshape(ddc_modem, ...
    [1 (nfft+cp_len)*ofdm_symbols]),nfft_p)))))
title('MODEM'),xlabel('kHz'),ylabel('dB'),sgtitle('DDC Output')

% Save and remove CP
cp_rm_signal = ofdm_rx_signal_par;
cp_rm_signal(1:cp_len,:) = []; % Remove CP

ofdm_cfo_signal = zeros(nfft,ofdm_symbols);
cfo_est_signal = zeros(1,ofdm_symbols);
for i = 1:ofdm_symbols
    cp_cfo_begin = ofdm_rx_signal_par(doppler_cp_offset+1:cp_len- ...
        doppler_cp_offset,i); % Obtain CP at beginning of symbol
    cp_cfo_end = ofdm_rx_signal_par(nfft+1+doppler_cp_offset: ...
        end-doppler_cp_offset,i); % Obtain CP at end of symbol
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
ofdm_cfo_signal = cp_rm_signal;
table(cfo_est_signal)

% Save and remove CP
cp_rm_modem = ddc_modem;
cp_rm_modem(1:cp_len,:) = [];

ofdm_cfo_modem = zeros(nfft,ofdm_symbols);
cfo_est = 0;
cfo_est_modem = zeros(1,ofdm_symbols);
for i = 1:ofdm_symbols
    cp_cfo_begin = ddc_modem(doppler_cp_offset+1:cp_len- ...
        doppler_cp_offset,i); % Obtain CP at beginning of symbol
    cp_cfo_end = ddc_modem(nfft+1+doppler_cp_offset: ...
        end-doppler_cp_offset,i); % Obtain CP at end of symbol
    %cp_cfo_begin = ofdm_rx_doppler_par(1:cp_len,i);
    %cp_cfo_end = ofdm_rx_doppler_par(nfft+1:end,i);
    tmp = cp_cfo_end.*conj(cp_cfo_begin); % Correlate
    sum_val = sum(tmp);
    tan_val = atan2(imag(sum_val),real(sum_val));
    normalized_cfo_est = 1*tan_val;
    cfo_est = normalized_cfo_est*scs;
    cfo_est_modem(i) = cfo_est/2/pi;
    ofdm_cfo_modem(:,i) = cp_rm_modem(:,i).*(cos(cfo_est*t(1:nfft)) ...
        +1i*sin(cfo_est*t(1:nfft)))';
end
%ofdm_cfo_modem = cp_rm_modem;
table(cfo_est_modem)
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % doppler processing
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     k_est = (-mean(cfo_est_doppler)/Fc)+1;% Estimate doppler scaling factor
%     Fs_doppler_sample = DAC_FS/k;         % Resample rate
%     Fs_doppler_sample_est = DAC_FS/k_est; % Estimated resample rate
%     table(k,k_est,Fs_doppler_sample,Fs_doppler_sample_est)
% 
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     % Resample with doppler shift factor
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     P = round(DAC_FS/k/300);  Q = round(DAC_FS/300);
%     ofdm_tx_signal_doppler2 = resample(ofdm_tx_signal_doppler,P,Q);
%     if (length(ofdm_tx_signal_doppler2) > length(ofdm_tx_signal_ch))
%         ofdm_tx_signal_doppler2 = ofdm_tx_signal_doppler2(1:length( ...
%             ofdm_tx_signal_ch));
%     elseif (length(ofdm_tx_signal_doppler2) < length(ofdm_tx_signal_ch))
%         ofdm_tx_signal_doppler2 = [ofdm_tx_signal_doppler2 zeros(1, ...
%             length(ofdm_tx_signal_ch) - length(ofdm_tx_signal_doppler2))];
%     end
%     
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     % IQ Mixer RX
%     i_ddc_doppler2 = ofdm_tx_signal_doppler2 .* cos(2*pi*Fc*t_up);
%     q_ddc_doppler2 = ofdm_tx_signal_doppler2 .* -sin(2*pi*Fc*t_up);
%     ddc_signal_doppler2 = complex(i_ddc_doppler2,q_ddc_doppler2);
%     
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     % DDC
%     ddc_doppler_real2 = decimate(real(ddc_signal_doppler2), ...
%         Interp_val,4096,'Fir');
%     ddc_doppler_imag2 = decimate(imag(ddc_signal_doppler2), ...
%         Interp_val,4096,'Fir');
%     ddc_doppler2 = complex(ddc_doppler_real2,ddc_doppler_imag2);
%     ddc_doppler2 = duc_ddc_loss_gain * ddc_doppler2.';
% 
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     % Synchronization
%     sync_corr_doppler2 = abs(filter(sync_coef,1,ddc_doppler2));
%     [val3,ind3] = max(sync_corr_doppler2);
%     ind3 = ind3-sync_samples_early+gp_samples+force_doppler_sync+cp_len;
%     ofdm_rx_sync_doppler2 = ddc_doppler2;
%     ofdm_rx_sync_doppler2([1:ind3, ...
%         ind3+1+(nfft+cp_len+gp_samples)*ofdm_symbols:end]) = [];
%     if length(ofdm_rx_sync_doppler2)~=(nfft+cp_len+gp_samples)*ofdm_symbols
%         tmp = zeros(1,(nfft+cp_len+gp_samples)*ofdm_symbols- ...
%             length(ofdm_rx_sync_doppler2)).';
%         ofdm_rx_sync_doppler2 = [ofdm_rx_sync_doppler2;tmp];
%         warning('Deleted too much of UW-A signal 2')
%     end
%     doppler_sync_offset2 = (ind3-gp_samples)-(ind-gp_samples);
%     display(doppler_sync_offset2)
% 
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     % Serial to Parallel
%     ofdm_rx_doppler_par2=reshape(ofdm_rx_sync_doppler2, ...
%         [nfft+cp_len+gp_samples ofdm_symbols]);
% 
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     % CFO Estimation and Correction (OPTIONAL)
%     ofdm_rx_doppler_par2(end-gp_samples+1:end,:) = [];
%     
%     % Save and remove CP
%     cp_rm_doppler2 = ofdm_rx_doppler_par2;
%     cp_rm_doppler2(1:cp_len,:) = [];
%     
%     ofdm_cfo_doppler2 = zeros(nfft,ofdm_symbols);
%     cfo_est2 = 0;
%     cfo_est_doppler2 = zeros(1,ofdm_symbols);
%     for i = 1:ofdm_symbols
%         cp_cfo_begin = ofdm_rx_doppler_par2(doppler_cp_offset+1:cp_len- ...
%             doppler_cp_offset,i); % Obtain CP at beginning of symbol
%         cp_cfo_end = ofdm_rx_doppler_par2(nfft+1+doppler_cp_offset: ...
%             end-doppler_cp_offset,i); % Obtain CP at end of symbol
%         %cp_cfo_begin = ofdm_rx_doppler_par(1:cp_len,i);
%         %cp_cfo_end = ofdm_rx_doppler_par(nfft+1:end,i);
%         tmp = cp_cfo_end.*conj(cp_cfo_begin); % Correlate
%         sum_val = sum(tmp);
%         tan_val = atan2(imag(sum_val),real(sum_val));
%         normalized_cfo_est = 1*tan_val;
%         cfo_est = normalized_cfo_est*scs;
%         cfo_est_doppler2(i) = cfo_est/2/pi;
%         ofdm_cfo_doppler2(:,i) = cp_rm_doppler2(:,i).* ...
%             (cos(cfo_est*t(1:nfft))+1i*sin(cfo_est*t(1:nfft)))';
%     end
%     ofdm_cfo_doppler2 = cp_rm_doppler2; % Bypass optional CFO Correction
%     table(cfo_est_doppler2)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FFT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fft_signal = zeros(nfft,ofdm_symbols);
for i = 1:ofdm_symbols % Do FFTSHIFT per symbol
    fft_signal(:,i) = fftshift(fft(ofdm_cfo_signal(:,i),nfft));
end

fft_modem2 = zeros(nfft,ofdm_symbols);
for i = 1:ofdm_symbols
    fft_modem2(:,i) = fftshift(fft(ofdm_cfo_modem(:,i),nfft));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Channel Estimation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Get RX pilots
fft_signal_eq = fft_signal;
P_RX = fft_signal_eq(pilot_index,:);

fft_modem_eq2 = fft_modem2;
P_RX_modem = fft_modem_eq2(pilot_index,:);
switch EQUALIZER_METHOD
    case "ZF"
        % P_RX_re = real(P_RX);           P_RX_im = -imag(P_RX);
        % P_re = real(reference_pilot);   P_im = -imag(reference_pilot);
        % H = (P_RX_re.*P_re + P_RX_im.*P_im) ./ (P_re.^2 + P_im.^2) + ...
        %     1i*(P_RX_im.*P_re - P_RX_re.*P_im) ./ (P_re.^2 + P_im.^2);
        H = conj(P_RX) ./ conj(reference_pilot);
        H_interp = interp1(pilot_index,H,1:nfft,'previous');
    
%         file = fopen( ...
%             '../Xilinx/SW_Source/ofdm_v2/files/ChannelEstimate1.txt','r');
%         %H_sw = fscanf(file,"%lf, %lf", [2 ofdm_symbols*pilot_carriers]);
%         P_sw = fscanf(file,"%lf, %lf, %lf, %lf", ...
%             [4, ofdm_symbols*pilot_carriers]);
%         fclose('all');
%         P_tx_sw = complex(P_sw(1,:),P_sw(2,:));
%         P_rx_sw = complex(P_sw(3,:),P_sw(4,:));
%         H_sw = conj(P_rx_sw) ./ conj(P_tx_sw);
%         H1 = reshape(H, [1 ofdm_symbols*pilot_carriers]);
%         figure(),subplot(2,1,1),plot(real(H1),'LineWidth',2),hold on
%         plot(real(H_sw)),title('Real'),legend('MATLAB','SW')
%         subplot(2,1,2),plot(imag(H1),'LineWidth',2),hold on
%         plot(imag(H_sw)),title('Imaginary'),legend('MATLAB','SW')
%         sgtitle('Channel')

        H = conj(P_RX_modem) ./ conj(reference_pilot);
        H_interp_modem2 = interp1(pilot_index,H,1:nfft,'previous');
    case "MMSE"
        H = P_RX ./ reference_pilot;
        H_MMSE = conj(H) ./ (conj(H).*H + 1/snr);
        H_interp = interp1(pilot_index,H_MMSE,1:nfft,'previous');

        H = P_RX_modem ./ (reference_pilot);
        H_MMSE_modem2 = conj(H) ./ (conj(H).*H + 1/snr);
        H_interp_modem2 = interp1(pilot_index,H_MMSE_modem2,1:nfft, ...
            'previous');
    case "ZF Averaged"
        H = conj(P_RX) ./ conj(reference_pilot);
        H = mean(H,2);
        H_interp = interp1(pilot_index,H,1:nfft,'previous');
        H_interp = repmat(H_interp, [ofdm_symbols 1]).';

        H = conj(P_RX_modem) ./ conj(reference_pilot);
        H = mean(H,2);
        H_interp_modem2 = interp1(pilot_index,H,1:nfft,'previous');
        H_interp_modem2 = repmat(H_interp_modem2,[ofdm_symbols 1]).';
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Channel Equalization
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
switch EQUALIZER_METHOD
    case "ZF"
        % H_ZF_re = real(H_interp); H_ZF_im = -imag(H_interp);
        % fft_re = real(fft_signal_eq); fft_im = imag(fft_signal_eq);
        % Z_EQ_ZF=(fft_re.*H_ZF_re + fft_im.*H_ZF_im)./ ...
        %     (H_ZF_re.^2+ H_ZF_im.^2) ...
        %     +1i*(fft_im.*H_ZF_re - fft_re.*H_ZF_im)./ ...
        %     (H_ZF_re.^2 + H_ZF_im.^2);
        Z_EQ_ZF = fft_signal_eq ./ conj(H_interp);

        Z_EQ_ZF_modem2 = fft_modem_eq2 ./ conj(H_interp_modem2);
    case "MMSE"
        Z_EQ_ZF = fft_signal_eq .* H_interp;           % MMSE

        Z_EQ_ZF_modem2 = fft_modem_eq2 .* H_interp_modem2;
    case "ZF Averaged"
        Z_EQ_ZF = fft_signal_eq ./ conj(H_interp);

        Z_EQ_ZF_modem2 = fft_modem_eq2 ./ conj(H_interp_modem2);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Phase 2 Equalization
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% P_RX = Z_EQ_ZF_doppler2(pilot_index,:);
% H = conj(P_RX) .* (reference_pilot(:,:));
% H_interp = angle(mean(H));
% Z_EQ_ZF_doppler2 = Z_EQ_ZF_doppler2 .* exp(1i*H_interp);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Synchronization error correction
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Z_EQ_ZF = Z_EQ_ZF * exp(1i*pi*(sync_offset_estimate/cp_len));

%Z_EQ_ZF_doppler2=Z_EQ_ZF_doppler2*exp(1i*pi* ...
%    (sync_offset_estimate/cp_len));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Only keep data sub-carriers
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Z_EQ_ZF([pilot_index,zp_index],:) = [];
fft_signal_eq([pilot_index,zp_index],:) = [];

fft_modem_eq2([pilot_index,zp_index],:) = [];
Z_EQ_ZF_modem2([pilot_index,zp_index],:) = [];

% Plot %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
lim = sqrt(2*M) + 1; y_lim = [-lim lim]; x_lim = [-lim lim];
figure(),subplot(2,2,1),scatter(real(Z_EQ_ZF),imag(Z_EQ_ZF),'.'),grid on
title({'AWGN Channel', 'CFO Correction with Equalization'}),ylim(y_lim)
xlim(x_lim),subplot(2,2,2),scatter(real(Z_EQ_ZF_modem2),imag( ...
    Z_EQ_ZF_modem2),'.'),grid on,title({'MATLAB Channel', ...
    'Doppler Correction with Equalization'}),ylim(y_lim),xlim(x_lim)
subplot(2,2,3),scatter(real(fft_signal_eq/tx_scale/ifft_gain), ...
    imag(fft_signal_eq/tx_scale/ifft_gain),'.'),grid on
title({'AWGN Channel','CFO Correction without Equalization'}),ylim(y_lim)
xlim(x_lim),subplot(2,2,4),scatter(real(Z_EQ_ZF_modem2),imag(Z_EQ_ZF_modem2),'.')
ylim(y_lim),xlim(x_lim),grid on
title({'UW-A Channel','SW with Equalization'})
sgtitle('Equalizer Output')

symbol = 4;
for i=1:ofdm_symbols
    figure(),scatter(real(Z_EQ_ZF_modem2(:,i)),imag(Z_EQ_ZF_modem2(:,i)),'.')
    title(['SW Symbol ',num2str(i)]),grid on
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% QAM Demodulation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Demod
demod_data = qamdemod(Z_EQ_ZF,M);
demod_modem2 = qamdemod(Z_EQ_ZF_modem2,M);

ser_data = symerr(tx_data, demod_data)/numel(tx_data);
ser_sw = symerr(tx_data, demod_modem2)/numel(tx_data);

% Get EVM measurements
evm = comm.EVM(AveragingDimensions=[1 2],MaximumEVMOutputPort=1);
[data_evm,data_evm_pk] = evm(qam_mod_data,Z_EQ_ZF);
[data_evm_sw,data_evm_pk_sw] = evm(qam_mod_data,Z_EQ_ZF_modem2);

Equalization =["AWGN Channel";"UW-A Channel"];
SER = [ser_data;ser_sw];
AverageEVM = [data_evm;data_evm_sw];
PeakEVM = [data_evm_pk;data_evm_pk_sw];
table(Equalization,SER,AverageEVM,PeakEVM)

y_lim = [0 40]; y_ofdm = 1:ofdm_symbols; y1 = 1:nfft; y_lim2 = [0 40];
carriers_plot = zeros(1,nfft); carriers_plot_doppler2 = zeros(1,nfft);
carriers_plot_sw = zeros(1,nfft);
evm = comm.EVM(AveragingDimensions=1);
evm_ofdm = evm(qam_mod_data,Z_EQ_ZF);
evm_sw = evm(qam_mod_data,Z_EQ_ZF_modem2);
evm = comm.EVM(AveragingDimensions=2);
evm_carriers = evm(qam_mod_data,Z_EQ_ZF);
carriers_plot(data_index) = evm_carriers;
evm_carriers_sw = evm(qam_mod_data,Z_EQ_ZF_modem2);
carriers_plot_sw(data_index) = evm_carriers_sw;

figure(),subplot(2,2,1),bar(y1,carriers_plot),ax=gca;ax.YLim=y_lim;
xlabel('Sub-Carriers'),ylabel('%')
title({'AWGN Channel', 'Averaged Across Sub-Carriers'}),subplot(2,2,2)
bar(y_ofdm,evm_ofdm),ax=gca;ax.YLim=y_lim;xlabel('OFDM Symbols')
ylabel('%'),title({'AWGN Channel','Averaged Across OFDM Symbols'})
subplot(2,2,3)
bar(y1,carriers_plot_sw),ax=gca;ax.YLim=y_lim2;xlabel('Sub-Carriers')
ylabel('%'),title({'SW','Averaged Across Sub-Carriers'}),subplot(2,3,4)
bar(y_ofdm,evm_sw),ax=gca;ax.YLim=y_lim2;xlabel('OFDM Symbols'),ylabel('%')
title({'SW','Averaged Across OFDM Symbols'})
sgtitle('EVM')

for i=1:ofdm_symbols
    evm_symbols = zeros(1,nfft);
    evm_symbols_data = evm(qam_mod_data(:,i),Z_EQ_ZF_modem2(:,i));
    evm_symbols(data_index) = evm_symbols_data;
    figure(),bar(y1,evm_symbols),ax=gca;%ax.YLim=y_lim;
    xlabel('Sub-Carriers'),ylabel('%'),
    title({'EVM Averaged Across Sub-Carriers Symbol ',num2str(i)})
end