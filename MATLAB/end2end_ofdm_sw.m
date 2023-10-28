clear; clc; close all; fclose all; format long;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Simulation settings
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
EQUALIZER_METHOD = "ZF"; % "ZF", "MMSE", "ZF Averaged"
PLOT_TX_CARRIERS = false;
FIR_BASED_NOT_CIC = false;
LOOPBACK = false;
seed = 0;
seed_diff = 0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Generate Pilot Data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % Pilots for M = 2
rng(seed)
pilot_data_m2 = randsrc(16384*16,1,0:2-1);
file = fopen('../Xilinx/SW_Source/ofdm_v2/files/PilotDataM2.txt','wt');
%file = fopen('PilotDataM2.txt','w');
fprintf(file, "%d\n", pilot_data_m2);

% Pilots for M = 4
rng(seed)
pilot_data_m4 = randsrc(16384*16,1,0:4-1);
file = fopen('../Xilinx/SW_Source/ofdm_v2/files/PilotDataM4.txt','wt');
fprintf(file, "%d\n", pilot_data_m4);

% Pilots for M = 8
rng(seed)
pilot_data_m8 = randsrc(16384*16,1,0:8-1);
file = fopen('../Xilinx/SW_Source/ofdm_v2/files/PilotDataM8.txt','wt');
fprintf(file, "%d\n", pilot_data_m8);

% Pilots for M = 16
rng(seed)
pilot_data_m16 = randsrc(16384*16,1,0:16-1);
file = fopen('../Xilinx/SW_Source/ofdm_v2/files/PilotDataM16.txt','wt');
fprintf(file, "%d\n", pilot_data_m16);
fclose('all');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Generate Data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Generate random data for M = 2
rng(seed+seed_diff)
tx_data_m2 = randsrc(16384*16,1,0:2-1);
file = fopen('../Xilinx/SW_Source/ofdm_v2/files/TxModData2.txt','wt');
fprintf(file,"%d\n",tx_data_m2);

% Generate random data for M = 4
rng(seed+seed_diff)
tx_data_m4 = randsrc(16384*16,1,0:4-1);
file = fopen('../Xilinx/SW_Source/ofdm_v2/files/TxModData4.txt','wt');
fprintf(file,"%d\n",tx_data_m4);

% Generate random data for M = 8
rng(seed+seed_diff)
tx_data_m8 = randsrc(16384*16,1,0:8-1);
file = fopen('../Xilinx/SW_Source/ofdm_v2/files/TxModData8.txt','wt');
fprintf(file,"%d\n",tx_data_m8);

% Generate random data for M = 16
rng(seed+seed_diff)
tx_data_m16 = randsrc(16384*16,1,0:16-1);
file = fopen('../Xilinx/SW_Source/ofdm_v2/files/TxModData16.txt','wt');
fprintf(file,"%d\n",tx_data_m16);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% OFDM Parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Read OFDM Parameters from Info file from SW program
file = fopen('../Xilinx/SW_Source/ofdm_v2/files/OfdmInfo1.txt','r');
nfft = fscanf(file,"%d,",1);   % Size of FFT, number of subcarriers in OFDM
BW = fscanf(file,"%lf,",1); BW = BW*1000;% Bandwidth = complex FS
cp_len = fscanf(file, "%d,", 1);        % Cyclic Prefix length in samples
M = fscanf(file,"%d,", 1);              % Modulation Order
ZP_density = fscanf(file,"%d,", 1);     % Zero Padded Pilot Density
symbol_guard_ms = fscanf(file,"%d,",1); % Symbol guard band in ms
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
DAC_FS = 10000000;              % Dac sample rate
nfft_p = 16*nfft;               % NFFT for plotting spectrum
speed_sound = 1500;             % Speed of sound underwater
duc_ddc_loss_gain = 2;          % Loss of Matlab DUC
num_bits = 14;                  % Number of bits in a sample
cic_scale = 50;                 % Scaling of CIC

% Channel parameters
snr_db = 10;
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
sync_tx_zp = tx_scale*[zeros(1,(nfft_zc-ZC_length)/2),sync_tx,zeros(1, ...
    (nfft_zc-ZC_length)/2)]; % Add ZP and center ZC sequence in BW
sync_tx_time = ifft(ifftshift(sync_tx_zp),nfft_zc);

% Create coe file for ZC sequence Xilinx FIR Compiler
sync_coef = conj(fliplr(sync_tx_time));
sync_coef_i = real(sync_coef); sync_coef_q = imag(sync_coef);
max_val_i = max(sync_coef_i);max_val_q = max(sync_coef_q);
if (max_val_i < max_val_q)
    max_val = max_val_q;
else
    max_val = max_val_i;
end
scaled_sync_coef_i = int16(sync_coef_i ./ max_val .* 32767);
scaled_sync_coef_q = int16(sync_coef_q ./ max_val .* 32767);
filename = "../Xilinx/Vivado/modules/data/zc_"+string(nfft_zc)+"_nfft_" ...
    +ZC_length+"_ZC_"+string(ZC_root)+"_root_i.coe";
file = fopen(filename,'w');
fprintf(file,"radix=10;\n");fprintf(file,"coefdata=\n");
fprintf(file,"%d,\n",scaled_sync_coef_i(1:end-1));
fprintf(file,"%d;",scaled_sync_coef_i(end));
fclose('all');
filename = "../Xilinx/Vivado/modules/data/zc_"+string(nfft_zc)+ ...
    "_nfft_"+ZC_length+"_ZC_"+string(ZC_root)+"_root_q.coe";
file = fopen(filename,'w');
fprintf(file,"radix=10;\n");fprintf(file,"coefdata=\n");
fprintf(file,"%d,\n",scaled_sync_coef_q(1:end-1));
fprintf(file,"%d;",scaled_sync_coef_q(end));
fclose('all');

% Reload coefficients for ZC sequence Xilinx FIR compiler
filename = "../Xilinx/SW_Source/ofdm_v2/files/zc_fir_coef_"+ ...
    string(nfft_zc)+"_nfft_"+ZC_length+"_ZC_"+string(ZC_root)+ ...
    "_root_i.txt";
file = fopen(filename,'w');
fprintf(file,"%d\n",scaled_sync_coef_i);
fclose('all');
filename = "../Xilinx/SW_Source/ofdm_v2/files/zc_fir_coef_"+ ...
    string(nfft_zc)+"_nfft_"+ZC_length+"_ZC_"+string(ZC_root)+ ...
    "_root_q.txt";
file = fopen(filename,'w');
fprintf(file,"%d\n",scaled_sync_coef_q);
fclose('all');

% ZC sequence time domain for SW
filename = "../Xilinx/SW_Source/ofdm_v2/files/zc_seq_time_"+ ...
    string(nfft_zc)+"_nfft_"+string(nfft_zc/2)+"_ZC_"+string(ZC_root)+ ...
    "_root.txt";
file = fopen(filename,'w');
fprintf(file,"%f, %f\n",[(real(sync_tx_time)); ...
    (imag(sync_tx_time))]);
fclose('all');

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

figure(),subplot(2,2,1),bar(1:ofdm_symbols+1,sig_pow_dBFS)
xlabel('OFDM Symbol'),ylabel('dBFS'),title('Average Power')
set(gca,'Ydir','reverse');subplot(2,2,2)
bar(1:ofdm_symbols+1,sig_peak_dBFS)
xlabel('OFDM Symbol'),ylabel('dBFS'),title('Peak Power')
set(gca,'Ydir','reverse');subplot(2,2,[3 4]),bar(1:ofdm_symbols+1, ...
    sig_papr_dB),xlabel('OFDM Symbols'),ylabel('dB'),title('PAPR')
sgtitle('TX Power')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GP Insertion2)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
gp = zeros(gp_samples,ofdm_symbols);       % Obtain GP
ofdm_tx_signal_par = vertcat(ofdm_tx_signal_par1,gp); % Copy GP

if (PLOT_TX_CARRIERS)
    ifft_mat = reshape(ofdm_tx_signal_par1,[1 (nfft+cp_len)*ofdm_symbols]);
    ifft_mat = [sync_tx_time*extra_sync_gain*ifft_gain ifft_mat];    
    % Read carrier allocation from SW: Ignore header:
    file = fopen('../Xilinx/SW_Source/ofdm_v2/files/TxFreqData1.txt','r');
    tmp = fscanf(file,"%d,",1);
    tmp = fscanf(file,"%d,",1);
    tmp = fscanf(file,"%d,",1);
    % Read Frequency domain carriers from SW file
    freq_data_ofdm = fscanf(file,"%f, %f", [2 nfft*ofdm_symbols]);
    freq_data_ofdm = complex(freq_data_ofdm(1,:),freq_data_ofdm(2,:));
    fclose('all');
    file=fopen('../Xilinx/SW_Source/ofdm_v2/files/TxIfftSamples1.txt','r');
    tmp = fscanf(file,"%d,",1);
    tmp = fscanf(file,"%d,",1);
    tmp = fscanf(file,"%d,",1);
    ifft_sw = fscanf(file,"%lf, %lf", [2 nfft_zc+ ...
        ((nfft+cp_len)*ofdm_symbols)]);
    fclose('all');
    ifft_sw = complex(ifft_sw(1,:),ifft_sw(2,:));
    ifft_sw = reshape(ifft_sw,[1 nfft_zc+(ofdm_symbols*(nfft+cp_len))]);
    freq_data_ofdm_1 = reshape(freq_data_ofdm,[nfft ofdm_symbols]);
    % Plotting
    p_plot = reshape(qam_mod_data*tx_scale,[1 ofdm_symbols*data_carriers]);
    p_plot_sw = reshape(freq_data_ofdm_1(data_index,:), ...
        [1 ofdm_symbols*data_carriers]);
    figure(),plot(real(p_plot),'LineWidth',2),hold on,plot(real( ...
        p_plot_sw)),title('Data Sub-Carriers')
    p_plot = reshape(reference_pilot*tx_scale, ...
        [1 ofdm_symbols*pilot_carriers]);
    p_plot_sw = reshape(freq_data_ofdm_1(pilot_index,:), ...
        [1 ofdm_symbols*pilot_carriers]);
    figure(),plot(real(p_plot),'LineWidth',2),hold on,plot(real( ...
        p_plot_sw)),title('Pilot Sub-Carriers')
    carriers_plot = reshape(carriers,[1 (ofdm_symbols)*nfft]);
    figure(),subplot(2,1,1),plot(real(carriers_plot),'LineWidth',2)
    hold on,plot(real(freq_data_ofdm)),legend('MATLAB','SW')
    title('Real'),subplot(2,1,2),plot(imag(carriers_plot), ...
        'LineWidth',2),hold on,plot(imag(freq_data_ofdm))
    title('Imaginary'),sgtitle('IFFT Input')
    figure(),subplot(2,1,1),plot(real(ifft_mat),'LineWidth',2),hold on
    plot(real(ifft_sw)),legend('MATLAB','SW'),title('Real')
    xlabel('Samples'),subplot(2,1,2),plot(imag(ifft_mat),'LineWidth',2)
    hold on,plot(imag(ifft_sw)),legend('MATLAB','SW'),title('Imaginary')
    xlabel('Samples'),sgtitle('IFFT Output')
    figure(),subplot(2,1,1),plot(real(ifft_mat)),xlabel('Samples')
    title('Real'),subplot(2,1,2),plot(imag(ifft_mat)),xlabel('Samples')
    title('Imaginary'),title('Ifft Output')
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Parallel to Serial
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ofdm_tx_signal_ser = reshape(ofdm_tx_signal_par,[(nfft+cp_len+ ...
    gp_samples)*ofdm_symbols, 1]);         % Parallel to Serial
gp = zeros(gp_samples,1);                  % Obtain GP
ofdm_tx_signal_ser = [extra_sync_gain*ifft_gain*sync_tx_time.'; ...
    gp;ofdm_tx_signal_ser]; % OFDM Frame

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DUC
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if (FIR_BASED_NOT_CIC)
    [kdk,fir_taps] = interp(ofdm_tx_signal_ser,Interp_val,10,1);
    filter_delay = floor(length(fir_taps)/2);
    ofdm_tx_signal_zp = [zeros(filter_delay,1);ofdm_tx_signal_ser; ...
        zeros(filter_delay,1)];
    ofdm_duc_signal = interp(ofdm_tx_signal_zp,Interp_val,10,1);
    ofdm_duc_signal = ofdm_duc_signal(filter_delay*Interp_val+1:end- ...
        filter_delay*Interp_val);
    ofdm_duc_signal = ofdm_duc_signal.';
else
    % Read Captured Xilinx CIC Filter impulse Response:
    file = fopen('../Xilinx/Vivado/modules/sim/cic_duc_test_out.txt','r');
    cic_impulse = fscanf(file,"%d, %d\n",[2 79]);
    cic_impulse = complex(cic_impulse(1,:),cic_impulse(2,:));
    cic_impulse = cic_impulse / sum(cic_impulse); % Normalize
    % Model Xilinx CIC Filter as DUC
    ofdm_tx_signal_up = upsample(ofdm_tx_signal_ser,Interp_val);
    ofdm_duc_signal_cic = filter(cic_impulse,1,ofdm_tx_signal_up);
    ofdm_duc_signal = ofdm_duc_signal_cic.'*cic_scale;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% IQ Mixer TX
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Use oscillator at Fc for IQ mixer
t_up = 0:1/DAC_FS:length(ofdm_duc_signal)/DAC_FS-1/DAC_FS;
ofdm_duc_signal_i = real(ofdm_duc_signal) .* cos(2*pi*Fc*t_up);
ofdm_duc_signal_q = imag(ofdm_duc_signal) .* -sin(2*pi*Fc*t_up);
ofdm_duc_signal_real = ofdm_duc_signal_i + ofdm_duc_signal_q;

% figure(),subplot(2,1,1),plot(ofdm_duc_signal_real),xlabel('Samples')
% subplot(2,1,2),plot(t_up*1000,ofdm_duc_signal_real),xlabel('Time (ms)')
% sgtitle('OFDM TX Signal')

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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% IQ Mixer RX
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_ddc = ofdm_tx_signal_ch .* cos(2*pi*Fc*t_up);
q_ddc = ofdm_tx_signal_ch .* -sin(2*pi*Fc*t_up);
ddc_signal = complex(i_ddc,q_ddc);

i_ddc_doppler = ofdm_tx_signal_doppler .* cos(2*pi*Fc*t_up);
q_ddc_doppler = ofdm_tx_signal_doppler .* -sin(2*pi*Fc*t_up);
ddc_signal_doppler = complex(i_ddc_doppler,q_ddc_doppler);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DDC
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if (FIR_BASED_NOT_CIC)
    ddc_base_signal_real=decimate(real(ddc_signal),Interp_val,4096,'Fir');
    ddc_base_signal_imag=decimate(imag(ddc_signal),Interp_val,4096,'FIR');
    ddc_base_signal = complex(ddc_base_signal_real,ddc_base_signal_imag);
    ddc_base_signal = duc_ddc_loss_gain * ddc_base_signal.';
    
    ddc_doppler_real = ...
        decimate(real(ddc_signal_doppler),Interp_val,4096,'Fir');
    ddc_doppler_imag = ...
        decimate(imag(ddc_signal_doppler),Interp_val,4096,'Fir');
    ddc_doppler = complex(ddc_doppler_real,ddc_doppler_imag);
    ddc_doppler = duc_ddc_loss_gain * ddc_doppler.';
else
    % Model Xilinx CIC Filter as DUC
    ddc_base_signal = filter(cic_impulse,1,ddc_signal).'*duc_ddc_loss_gain;
    ddc_base_signal = downsample(ddc_base_signal,Interp_val);

    ddc_doppler = filter(cic_impulse,1,ddc_signal_doppler).'* ...
        duc_ddc_loss_gain;
    ddc_doppler = downsample(ddc_doppler,Interp_val);
end

t = 0:Ts:length(ddc_base_signal)*Ts-Ts;

if (LOOPBACK)
    ddc_base_signal = ofdm_tx_signal_ser;
end

% figure(),subplot(2,2,1),plot(F/1000,abs(10*log10(fftshift(fft( ...
%     ddc_doppler,nfft_p))))),title('Magnitude UW-A Channel')
% xlabel('F (kHz)'),subplot(2,2,2),plot(F/1000,angle(10*log10(fftshift(fft...
%     (ddc_doppler,nfft_p))))),title('Phase UW-A Channel'),xlabel('F (kHz)')
% subplot(2,2,3),plot(F/1000,abs(10*log10(fftshift(fft(multipath, ...
%     nfft_p))))),title('Magnitude Multipath Channel'),xlabel('F (kHz)')
% subplot(2,2,4),plot(F/1000,angle(10*log10(fftshift(fft(multipath, ...
%     nfft_p))))),title('Phase Multipath Channel'),xlabel('F (kHz)')
file = fopen('../Xilinx/SW_Source/ofdm_v2/files/RxFftSamples1.txt','r');
fft_sw = fscanf(file,"%d, %d\n", [2 ofdm_symbols*nfft]);
fclose('all');
fft_sw = complex(fft_sw(1,:),fft_sw(2,:));
figure(),plot(F/1000,10*log10(abs(fftshift(fft(fft_sw,nfft_p)))))
xlabel('kHz'),ylabel('dB'),title('FFT Input Spectrum')

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

sync_corr_doppler = abs(filter(sync_coef,1,ddc_doppler));
[val2,ind2] = max(sync_corr_doppler);
ind2 = ind2-sync_samples_early+gp_samples+force_doppler_sync;
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
    'LineWidth',2),hold on,plot(t_p/1000,real(ddc_base_signal))
plot(t_p/1000,real(ddc_doppler))
for i = 1:length(vertical_lines)
    if i == 1
        xline(vertical_lines(i)*Ts/1000,'--r',line_label{i}, ...
            'LabelHorizontalAlignment','left')
    else
        xline(vertical_lines(i)*Ts/1000,'--r',line_label{i})
        xline(vertical_lines_doppler(i-1)*Ts/1000,'--b',line_label{i}, ...
            'LabelVerticalAlignment','bottom');
    end
end
legend('TX','AWGN Channel','UW-A Channel')
xlabel('Time (ms)'),title('In Phase'),subplot(3,1,2)
plot(t_p/1000,imag(ofdm_tx_signal_ser),'LineWidth',2),hold on
plot(t_p/1000,imag(ddc_base_signal)),plot(t_p/1000,imag(ddc_doppler))
for i = 1:length(vertical_lines)
    if i == 1
        xline(vertical_lines(i)*Ts/1000,'--r',line_label{i}, ...
            'LabelHorizontalAlignment','left')
    else
        xline(vertical_lines(i)*Ts/1000,'--r',line_label{i})
        xline(vertical_lines_doppler(i-1)*Ts/1000,'--b',line_label{i}, ...
            'LabelVerticalAlignment','bottom');
    end
end
legend('TX','AWGN Channel','UW-A doppler'),xlabel('Time (ms)')
title('Quadrature'),subplot(3,1,3),plot(t_p/1000,sync_corr_filt),hold on
plot(t_p/1000,sync_corr_doppler)
vertical_lines = [ind2-gp_samples vertical_lines];
line_label = ["UW-A Sync", line_label];
xline(vertical_lines(2)*Ts/1000,'--b',line_label{2}, ...
    'LabelHorizontalAlignment','left')
xline(vertical_lines(1)*Ts/1000,'--r',line_label{1}, ...
    'LabelHorizontalAlignment','left','LabelVerticalAlignment','bottom')
legend('AWGN Channel','UW-A Channel','AWGN Timing','UW-A Timing')
xlabel('Time (ms)'),title('Synchronizer Correlator Output')
sgtitle('Baseband OFDM Signal')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Serial to Parallel
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ofdm_rx_signal_par=reshape(ofdm_rx_sync_signal, ...
    [nfft+cp_len+gp_samples ofdm_symbols]);
ofdm_rx_doppler_par=reshape(ofdm_rx_sync_doppler, ...
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

% Remove GP
ofdm_rx_doppler_par(end-gp_samples+1:end,:) = [];

% Save and remove CP
cp_rm_doppler = ofdm_rx_doppler_par;
cp_rm_doppler(1:cp_len,:) = [];

ofdm_cfo_doppler = zeros(nfft,ofdm_symbols);
cfo_est = 0;
cfo_est_doppler = zeros(1,ofdm_symbols);
for i = 1:ofdm_symbols
    cp_cfo_begin = ofdm_rx_doppler_par(doppler_cp_offset+1:cp_len- ...
        doppler_cp_offset,i); % Obtain CP at beginning of symbol
    cp_cfo_end = ofdm_rx_doppler_par(nfft+1+doppler_cp_offset: ...
        end-doppler_cp_offset,i); % Obtain CP at end of symbol
    %cp_cfo_begin = ofdm_rx_doppler_par(1:cp_len,i);
    %cp_cfo_end = ofdm_rx_doppler_par(nfft+1:end,i);
    tmp = cp_cfo_end.*conj(cp_cfo_begin); % Correlate
    sum_val = sum(tmp);
    tan_val = atan2(imag(sum_val),real(sum_val));
    normalized_cfo_est = 1*tan_val;
    cfo_est = normalized_cfo_est*scs;
    cfo_est_doppler(i) = cfo_est/2/pi;
    ofdm_cfo_doppler(:,i) = cp_rm_doppler(:,i).*(cos(cfo_est*t(1:nfft)) ...
        +1i*sin(cfo_est*t(1:nfft)))';
end
%ofdm_cfo_doppler = cp_rm_doppler;
table(cfo_est_doppler)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% doppler processing
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    k_est = (-mean(cfo_est_doppler)/Fc)+1;% Estimate doppler scaling factor
    Fs_doppler_sample = DAC_FS/k;         % Resample rate
    Fs_doppler_sample_est = DAC_FS/k_est; % Estimated resample rate
    table(k,k_est,Fs_doppler_sample,Fs_doppler_sample_est)

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Resample with doppler shift factor
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    P = round(DAC_FS/k/300);  Q = round(DAC_FS/300);
    ofdm_tx_signal_doppler2 = resample(ofdm_tx_signal_doppler,P,Q);
    if (length(ofdm_tx_signal_doppler2) > length(ofdm_tx_signal_ch))
        ofdm_tx_signal_doppler2 = ofdm_tx_signal_doppler2(1:length( ...
            ofdm_tx_signal_ch));
    elseif (length(ofdm_tx_signal_doppler2) < length(ofdm_tx_signal_ch))
        ofdm_tx_signal_doppler2 = [ofdm_tx_signal_doppler2 zeros(1, ...
            length(ofdm_tx_signal_ch) - length(ofdm_tx_signal_doppler2))];
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % IQ Mixer RX
    i_ddc_doppler2 = ofdm_tx_signal_doppler2 .* cos(2*pi*Fc*t_up);
    q_ddc_doppler2 = ofdm_tx_signal_doppler2 .* -sin(2*pi*Fc*t_up);
    ddc_signal_doppler2 = complex(i_ddc_doppler2,q_ddc_doppler2);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % DDC
    ddc_doppler_real2 = decimate(real(ddc_signal_doppler2), ...
        Interp_val,4096,'Fir');
    ddc_doppler_imag2 = decimate(imag(ddc_signal_doppler2), ...
        Interp_val,4096,'Fir');
    ddc_doppler2 = complex(ddc_doppler_real2,ddc_doppler_imag2);
    ddc_doppler2 = duc_ddc_loss_gain * ddc_doppler2.';

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Synchronization
    sync_corr_doppler2 = abs(filter(sync_coef,1,ddc_doppler2));
    [val3,ind3] = max(sync_corr_doppler2);
    ind3 = ind3-sync_samples_early+gp_samples+force_doppler_sync;
    ofdm_rx_sync_doppler2 = ddc_doppler2;
    ofdm_rx_sync_doppler2([1:ind3, ...
        ind3+1+(nfft+cp_len+gp_samples)*ofdm_symbols:end]) = [];
    if length(ofdm_rx_sync_doppler2)~=(nfft+cp_len+gp_samples)*ofdm_symbols
        tmp = zeros(1,(nfft+cp_len+gp_samples)*ofdm_symbols- ...
            length(ofdm_rx_sync_doppler2)).';
        ofdm_rx_sync_doppler2 = [ofdm_rx_sync_doppler2;tmp];
        warning('Deleted too much of UW-A signal 2')
    end
    doppler_sync_offset2 = (ind3-gp_samples)-(ind-gp_samples);
    display(doppler_sync_offset2)

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Serial to Parallel
    ofdm_rx_doppler_par2=reshape(ofdm_rx_sync_doppler2, ...
        [nfft+cp_len+gp_samples ofdm_symbols]);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % CFO Estimation and Correction (OPTIONAL)
    ofdm_rx_doppler_par2(end-gp_samples+1:end,:) = [];
    
    % Save and remove CP
    cp_rm_doppler2 = ofdm_rx_doppler_par2;
    cp_rm_doppler2(1:cp_len,:) = [];
    
    ofdm_cfo_doppler2 = zeros(nfft,ofdm_symbols);
    cfo_est2 = 0;
    cfo_est_doppler2 = zeros(1,ofdm_symbols);
    for i = 1:ofdm_symbols
        cp_cfo_begin = ofdm_rx_doppler_par2(doppler_cp_offset+1:cp_len- ...
            doppler_cp_offset,i); % Obtain CP at beginning of symbol
        cp_cfo_end = ofdm_rx_doppler_par2(nfft+1+doppler_cp_offset: ...
            end-doppler_cp_offset,i); % Obtain CP at end of symbol
        %cp_cfo_begin = ofdm_rx_doppler_par(1:cp_len,i);
        %cp_cfo_end = ofdm_rx_doppler_par(nfft+1:end,i);
        tmp = cp_cfo_end.*conj(cp_cfo_begin); % Correlate
        sum_val = sum(tmp);
        tan_val = atan2(imag(sum_val),real(sum_val));
        normalized_cfo_est = 1*tan_val;
        cfo_est = normalized_cfo_est*scs;
        cfo_est_doppler2(i) = cfo_est/2/pi;
        ofdm_cfo_doppler2(:,i) = cp_rm_doppler2(:,i).* ...
            (cos(cfo_est*t(1:nfft))+1i*sin(cfo_est*t(1:nfft)))';
    end
    ofdm_cfo_doppler2 = cp_rm_doppler2; % Bypass optional CFO Correction
    table(cfo_est_doppler2)

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

% file = fopen('../Xilinx/SW_Source/ofdm_v2/files/RxFftSamples1.txt','r');
% fft_sw = fscanf(file,"%d, %d\n", [2 ofdm_symbols*(cp_len+nfft)]);
% fclose('all');
% fft_sw = complex(fft_sw(1,:),fft_sw(2,:));
% ofdm_cfo_signal1 = reshape(ofdm_cfo_signal, [1 nfft*ofdm_symbols]);
% ofdm_cfo_signal1 = reshape(ofdm_rx_signal_par, [1 (nfft+cp_len)*ofdm_symbols]);
% figure(),subplot(2,1,1),plot(real(ofdm_cfo_signal1),'LineWidth',2),hold on
% plot(real(fft_sw)),title('Real'),legend('MATLAB','SW'),subplot(2,1,2)
% plot(imag(ofdm_cfo_signal1),'LineWidth',2),hold on,plot(imag(fft_sw))
% title('Imag'),sgtitle('FFT Input'),legend('MATLAB','SW')
% file = fopen('../Xilinx/SW_Source/ofdm_v2/files/RxFreqData1.txt','r');
% tmp = fscanf(file,"%d,",1);
% tmp = fscanf(file,"%d,",1);
% tmp = fscanf(file,"%d,",1);
% Fft_data_sw = fscanf(file,"%f, %f", [2 nfft*ofdm_symbols]);
% Fft_data_sw = complex(Fft_data_sw(1,:),Fft_data_sw(2,:));
% fclose('all');
% fft_signal1 = reshape(fft_signal,[1 ofdm_symbols*nfft]);
% figure(),subplot(2,1,1),plot(real(fft_signal1),'LineWidth',2),hold on
% plot(real(Fft_data_sw)),title('Real'),legend('MATLAB','SW'),subplot(2,1,2)
% plot(imag(fft_signal1),'LineWidth',2),hold on,plot(imag(Fft_data_sw))
% title('Imag'),sgtitle('FFT Output'),legend('MATLAB','SW')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Channel Estimation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Get RX pilots
fft_signal_eq = fft_signal;
P_RX = fft_signal_eq(pilot_index,:);

fft_doppler_eq2 = fft_doppler2;
P_RX_dopler = fft_doppler_eq2(pilot_index,:);  
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


        H = conj(P_RX_dopler) ./ conj(reference_pilot);
        H_interp_doppler2 = interp1(pilot_index,H,1:nfft,'previous');
    case "MMSE"
        H = P_RX ./ reference_pilot;
        H_MMSE = conj(H) ./ (conj(H).*H + 1/snr);
        H_interp = interp1(pilot_index,H_MMSE,1:nfft,'previous');

        H = P_RX_dopler ./ (reference_pilot);
        H_MMSE_doppler2 = conj(H) ./ (conj(H).*H + 1/snr);
        H_interp_doppler2=interp1(pilot_index,H_MMSE_doppler2,1:nfft, ...
            'previous');        
    case "ZF Averaged"
        H = conj(P_RX) ./ conj(reference_pilot);
        H = mean(H,2);
        H_interp = interp1(pilot_index,H,1:nfft,'previous');
        H_interp = repmat(H_interp, [ofdm_symbols 1]).';

        H = conj(P_RX_dopler) ./ conj(reference_pilot);
        H = mean(H,2);
        H_interp_doppler2 = interp1(pilot_index,H,1:nfft,'previous');
        H_interp_doppler2 = repmat(H_interp_doppler2, [ofdm_symbols 1]).';
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

        Z_EQ_ZF_doppler2 = fft_doppler_eq2 ./ conj(H_interp_doppler2);
    case "MMSE"
        Z_EQ_ZF = fft_signal_eq .* H_interp;           % MMSE

        Z_EQ_ZF_doppler2 = fft_doppler_eq2 .* H_interp_doppler2;
    case "ZF Averaged"
        Z_EQ_ZF = fft_signal_eq ./ conj(H_interp);

        Z_EQ_ZF_doppler2 = fft_doppler_eq2 ./ conj(H_interp_doppler2);
end

file = fopen('../Xilinx/SW_Source/ofdm_v2/files/RxFreqDataEQ1.txt','r');
tmp = fscanf(file,"%d,\n",1);
tmp = fscanf(file,"%d,\n",1);
tmp = fscanf(file,"%d,\n",1);
EQ_sw_raw = fscanf(file,"%f, %f", [2 nfft*ofdm_symbols]);
fclose('all');
EQ_sw_raw = complex(EQ_sw_raw(1,:),EQ_sw_raw(2,:));
EQ_sw = reshape(EQ_sw_raw,[nfft ofdm_symbols]);
EQ_sw_pilots = EQ_sw(pilot_index,:);
EQ_sw([zp_index,pilot_index],:) = []; % Remove ZP and Pilot carriers
EQ_sw_pilots = reshape(EQ_sw_pilots,[1 ofdm_symbols*pilot_carriers]);
EQ_sw_raw = reshape(EQ_sw, [1 ofdm_symbols*data_carriers]);
Z_EQ_ZF1 = Z_EQ_ZF;
Z_EQ_ZF_pilot = Z_EQ_ZF1(pilot_index,:);
Z_EQ_ZF_pilot = reshape(Z_EQ_ZF_pilot, [1 ofdm_symbols*pilot_carriers]);
Z_EQ_ZF1([pilot_index,zp_index],:) = [];
Z_EQ_ZF1 = reshape(Z_EQ_ZF1, [1 ofdm_symbols*data_carriers]);
figure(),subplot(2,1,1),plot(real(Z_EQ_ZF1),'LineWidth',2),hold on
plot(real(EQ_sw_raw)),title('Real'),legend('MATLAB','SW'),subplot(2,1,2)
plot(imag(Z_EQ_ZF1),'LineWidth',2),hold on,plot(imag(EQ_sw_raw))
title('Imag'),legend('MATLAB','SW'),sgtitle('Equalizer Output')
figure(),subplot(2,1,1),plot(real(Z_EQ_ZF_pilot),'LineWidth',2),hold on
plot(real(EQ_sw_pilots)),title('Real'),legend('MATLAG','SW'),subplot(2,1,2)
plot(imag(Z_EQ_ZF_pilot),'LineWidth',2),hold on,plot(imag(EQ_sw_pilots))
title('Imaginary'),legend('MATLAG','SW'),sgtitle('EQ Pilots')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Phase 2 Equalization
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
P_RX = Z_EQ_ZF_doppler2(pilot_index,:);
H = conj(P_RX) .* (reference_pilot(:,:));
H_interp = angle(mean(H));
Z_EQ_ZF_doppler2 = Z_EQ_ZF_doppler2 .* exp(1i*H_interp);


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

fft_doppler_eq2([pilot_index,zp_index],:) = [];
Z_EQ_ZF_doppler2([pilot_index,zp_index],:) = [];

% Plot %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
lim = sqrt(2*M) + 1; y_lim = [-lim lim]; x_lim = [-lim lim];
figure(),subplot(2,2,1),scatter(real(Z_EQ_ZF),imag(Z_EQ_ZF),'.')
title({'AWGN Channel', 'CFO Correction with Equalization'}),ylim(y_lim)
xlim(x_lim),subplot(2,2,2),scatter(real(Z_EQ_ZF_doppler2),imag( ...
    Z_EQ_ZF_doppler2),'.'),title({'UW-A Channel', ...
    'Doppler Correction with Equalization'}),ylim(y_lim),xlim(x_lim)
subplot(2,2,3),scatter(real(fft_signal_eq/tx_scale/ifft_gain), ...
    imag(fft_signal_eq/tx_scale/ifft_gain),'.')
title({'AWGN Channel','CFO Correction without Equalization'}),ylim(y_lim)
xlim(x_lim),subplot(2,2,4),scatter(real(EQ_sw),imag(EQ_sw),'.')
ylim(y_lim),xlim(x_lim)
title({'UW-A Channel','SW with Equalization'})
sgtitle('Equalizer Output')

symbol = 1;
figure(),scatter(real(EQ_sw(:,symbol)),imag(EQ_sw(:,symbol)),'.')
title('SW')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% QAM Demodulation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Demod
demod_data = qamdemod(Z_EQ_ZF,M);
demod_doppler2 = qamdemod(Z_EQ_ZF_doppler2,M);

filename = "../Xilinx/SW_Source/ofdm_v2/files/RxDemodData"+M+".txt";
file = fopen(filename,'r');
tmp = fscanf(file,"%d",1);
tmp = fscanf(file,"%d",1);
tmp = fscanf(file,"%d",1);
data_char_rx = fscanf(file,"%d",data_carriers*ofdm_symbols);
fclose('all');
data_char_rx = reshape(data_char_rx, [data_carriers ofdm_symbols]);

demod_sw = qamdemod(EQ_sw,M);

ser_data = symerr(tx_data, demod_data)/numel(tx_data);
ser_doppler2 = symerr(tx_data, demod_doppler2)/numel(tx_data);
ser_sw = symerr(tx_data, demod_sw)/numel(tx_data);
%ser_sw = symerr(tx_data, data_char_rx)/numel(tx_data);

% Get EVM measurements
evm = comm.EVM(AveragingDimensions=[1 2],MaximumEVMOutputPort=1);
[data_evm,data_evm_pk] = evm(qam_mod_data,Z_EQ_ZF);
[doppler_evm2,doppler_evm_pk2] = evm(qam_mod_data,Z_EQ_ZF_doppler2);
[data_evm_sw,data_evm_pk_sw] = evm(qam_mod_data,EQ_sw);

Equalization =["AWGN Channel";"UW-A Channel";"SW"];
SER = [ser_data;ser_doppler2;ser_sw];
AverageEVM = [data_evm;doppler_evm2;data_evm_sw];
PeakEVM = [data_evm_pk;doppler_evm_pk2;data_evm_pk_sw];
table(Equalization,SER,AverageEVM,PeakEVM)

y_lim = [0 100]; y_ofdm = 1:ofdm_symbols; y1 = 1:nfft; y_lim2 = [0 200];
carriers_plot = zeros(1,nfft); carriers_plot_doppler2 = zeros(1,nfft);
carriers_plot_sw = zeros(1,nfft);
evm = comm.EVM(AveragingDimensions=1);
evm_ofdm = evm(qam_mod_data,Z_EQ_ZF);
evm_sw = evm(qam_mod_data,EQ_sw);
evm_ofdm_doppler2 = evm(qam_mod_data,Z_EQ_ZF_doppler2);
evm = comm.EVM(AveragingDimensions=2);
evm_carriers = evm(qam_mod_data,Z_EQ_ZF);
carriers_plot(data_index) = evm_carriers;
evm_carriers_doppler2 = evm(qam_mod_data,Z_EQ_ZF_doppler2);
carriers_plot_doppler2(data_index) = evm_carriers_doppler2;
evm_carriers_sw = evm(qam_mod_data,EQ_sw);
carriers_plot_sw(data_index) = evm_carriers_sw;

figure(),subplot(2,3,1),bar(y1,carriers_plot),ax=gca;ax.YLim=y_lim;
xlabel('Sub-Carriers'),ylabel('%')
title({'AWGN Channel', 'Averaged Across Sub-Carriers'}),subplot(2,3,2)
bar(y1,carriers_plot_doppler2),ax=gca;ax.YLim=y_lim;xlabel('Sub-Carriers')
ylabel('%'),title({'UW-A Channel','Averaged Across Sub-Carriers'})
subplot(2,3,4)
bar(y_ofdm,evm_ofdm),ax=gca;ax.YLim=y_lim;xlabel('OFDM Symbols')
ylabel('%'),title({'AWGN Channel','Averaged Across OFDM Symbols'})
subplot(2,3,5),bar(y_ofdm,evm_ofdm_doppler2)
ax=gca;ax.YLim=y_lim;xlabel('OFDM Symbols'),ylabel('%')
title({'UW-A Channel','Averaged Across OFDM Symbols'}),subplot(2,3,3)
bar(y1,carriers_plot_sw),ax=gca;ax.YLim=y_lim2;xlabel('Sub-Carriers')
ylabel('%'),title({'SW','Averaged Across Sub-Carriers'}),subplot(2,3,6)
bar(y_ofdm,evm_sw),ax=gca;ax.YLim=y_lim2;xlabel('OFDM Symbols'),ylabel('%')
title({'SW','Averaged Across OFDM Symbols'})
sgtitle('EVM')