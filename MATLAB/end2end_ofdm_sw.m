clear; clc; close all; fclose all; format long;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Simulation settings
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Preset = 916;
Test = 0;
% "ZF", "MMSE", "ZF Averaged", "LS", "Ideal"
% "Sym1Pilot" % Use entire 1st OFDM Symbol to estimate channel for all sym
% "SymAvg" % Average perfect channel estimates into 1 for all symbols
    EQUALIZER_METHOD = "ZF";
% Channel Estimation Interpolation Method
    interp_method = 'linear';
% Plot IFFT input and output (both MATLAB and from OFDM Modem SW)
    PLOT_TX_CARRIERS = false;
% Use FIR based DUC/DDC. Otherwise use CIC based
    FIR_BASED_NOT_CIC = true;
% Loop MATLAB IFFT output to FFT output to bypass channel
    LOOPBACK = false;
% Plot FFT input of OFDM Modem SW Data
    RXFFTSIM = true;
% Take OFDM Modem SW FFT input and Equalize in MATLAB instead of OFDM SW
    MAT_DEMOD = true;
% Enable CFO Correction on OFDM Modem SW captured data
    ADD_CFO_CORR = true;
% Enable CFO Correction on OFDM Matlab simulated data
    ADD_MAT_CFO_CORR = false;
% Use all raw OFDM SW files from desktop OFDM app else use from Modem lib
    DESKTOP_OFDM = false;
% Read and demod raw ADC samples from OFDM Modem SW
    RAW_SAMPLES = false;
% Perform doppler estimation + compensation on raw ADC Modem samples
    RAW_SAMPLE_DOPPLER = false;
% Compare Multipath channel with Channel Estimate
    COMP_EST = false;
% Plot MATLAB Channel Estimate else plot OFDM Modem Channel Estimate
    PLOT_MAT_CH_EST = true;
% Use Comb type pilot format else use alternating pilots
    PILOT_COMB_FORMAT = true;
% Assume all CFO is caused by doppler. Use CFO est to correct for doppler.
% If false, use CFO est to correct for CFO offset. Only for MATLAB sim
    DOPPLER_PROC = false;
% Perform estimation and correction for phase rotation from sym to sym
    PHASE_AVG = true;
% Filter multiple channel estimates instead of averaging
    FILTER_CH_EST = false;
% Perform power measurements
    POWER_MEASURE = false;
% Plot ideal QAM scatter points on top of RX constellations
    PLOT_IDEAL = false;
% Use Captured Modem UW-A Channel as multipath taps
    MODEM_MULTIPATH = false;

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
if (DESKTOP_OFDM)
    file = fopen('../Xilinx/SW_Source/ofdm_v2/files/OfdmInfo1.txt','r');
else
    filepath = '../Testing/Water_Testing/Tank/Full_Demod/preset_'+ ...
        string(Preset)+'_test_'+string(Test)+'/';
    file = fopen(sprintf('%sOfdmInfo1.txt',filepath),'r');
end
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
nfft_zc = 4096;                       % NFFT for Zadoff-Chu sequence
ZC_root = 13;                         % Zadoff-Chu root index
ZC_length = nfft_zc/2;                % Zadoff-Chu Sequence Length
doppler_cp_offset = round(cp_len/16); % Num of CP samples*2 to not use
sync_samples_early = 2;             % Num of samples to synchronize early
doppler_sync_samples_early = 1;       % samp to sync early for doppler
force_doppler_sync = 0;               % Force doppler synchronization
pilot_density = 0.5;                  % Pilot to data ratio
DAC_FS = 10000000;                    % Dac sample rate
ADC_FS = 40000000;                    % ADC sample rate
nfft_p = 32*nfft;                     % NFFT for plotting spectrum
speed_sound = 1500;                   % Speed of sound underwater
duc_ddc_loss_gain = 2;                % Loss of Matlab DUC
num_bits = 14;                        % Number of bits in a sample
cic_scale = 50;                       % Scaling of CIC
num_fir_taps = 4096;                  % Number of FIR taps for DUC/DDC
symbol_plot = ofdm_symbols;           % Set number of Symbols to plot

gp_samples = round(symbol_guard_ms / 1000 * BW);

% Channel parameters
snr_db = 30;                          % Signal-to-Noise ratio in dB
if MODEM_MULTIPATH
    filename = ...
    './Water_Channel/Preset_'+string(Preset)+'_Test_'+string(Test)+'.mat';
    load(filename);                       % Load Test Channel capture
    %multipath = ...                       % Model channel with FIR taps
    multipath = modem_water_ch(1:round((cp_len+gp_samples+nfft)/1));
else
    multipath = 1;
end
speed = 0.007;                            % Doppler In m/s
%speed = 0;

cfo = 0;                              % Carrier frequency offset
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
Interp_val_adc = ADC_FS/Fs; % Decimation value of Modem ADC
Ts = 1/Fs; % Sampling period
Ts_up = 1/DAC_FS;
F = (-nfft_p/2:nfft_p/2-1)/nfft_p*Fs; % Plotting baseband spectrum
F_up = (-nfft_p/2:nfft_p/2-1)/nfft_p*DAC_FS; % Plotting DUC spectrum
F_up_adc = (-nfft_p/2:nfft_p/2-1)/nfft_p*ADC_FS; % MODEM ADC frequency
cp_used = cp_len - 2*doppler_cp_offset;
Max_Freq_offset = 2*scs*(cp_used/nfft);
DAC_FS_sro = DAC_FS + DAC_FS*(sro*10e-6);

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
% TX Power Measurement
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if POWER_MEASURE
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

if (PLOT_TX_CARRIERS)
    ifft_mat = reshape(ofdm_tx_signal_par1,[1 (nfft+cp_len)*ofdm_symbols]);
    ifft_mat = [sync_tx_time*extra_sync_gain*ifft_gain zeros(1,cp_len)...
        ifft_mat];    
    % Read carrier allocation from SW: Ignore header:
    if (DESKTOP_OFDM)
        file = ...
            fopen('../Xilinx/SW_Source/ofdm_v2/files/TxFreqData1.txt','r');
    else
        file = fopen(sprintf('%sTxFreqData1.txt',filepath),'r');
    end
    tmp = fscanf(file,"%d,",1);
    tmp = fscanf(file,"%d,",1);
    tmp = fscanf(file,"%d,",1);
    % Read Frequency domain carriers from SW file
    freq_data_ofdm = fscanf(file,"%f, %f", [2 nfft*ofdm_symbols]);
    freq_data_ofdm = complex(freq_data_ofdm(1,:),freq_data_ofdm(2,:));
    fclose('all');
    if (DESKTOP_OFDM)
        file=...
         fopen('../Xilinx/SW_Source/ofdm_v2/files/TxIfftSamples1.txt','r');
    else
        file = fopen(sprintf('%sTxIfftSamples1.txt',filepath),'r');
    end
    tmp = fscanf(file,"%d,",1);
    tmp = fscanf(file,"%d,",1);
    tmp = fscanf(file,"%d,",1);
    ifft_sw = fscanf(file,"%lf, %lf", [2 nfft_zc+cp_len+ ...
        ((nfft+cp_len)*ofdm_symbols)]);
    fclose('all');
    ifft_sw = complex(ifft_sw(1,:),ifft_sw(2,:));
    ifft_sw = reshape(ifft_sw, ...
        [1 nfft_zc+cp_len+(ofdm_symbols*(nfft+cp_len))]);
    freq_data_ofdm_1 = reshape(freq_data_ofdm,[nfft ofdm_symbols]);
    % Plotting
    p_plot = reshape(qam_mod_data*tx_scale,[1 ofdm_symbols*data_carriers]);
    freq_data_ofdm_1_tmp = freq_data_ofdm_1;
    %freq_data_ofdm_1_tmp(any(isnan(rm_pilot_zp_index),2),:) = [];
    freq_data_ofdm_1_tmp = freq_data_ofdm_1_tmp(data_index);
    p_plot_sw = reshape(freq_data_ofdm_1_tmp, ...
        [1 ofdm_symbols*data_carriers]);
    figure(),plot(real(p_plot),'LineWidth',2),hold on,plot(real( ...
        p_plot_sw)),title('Data Sub-Carriers')
    p_plot = reshape(reference_pilot*tx_scale, ...
        [1 ofdm_symbols*pilot_carriers]);
    freq_data_ofdm_1_tmp = freq_data_ofdm_1;
    %freq_data_ofdm_1_tmp(any(isnan(pilot_index_nan),2),:) = [];
    freq_data_ofdm_1_tmp = freq_data_ofdm_1_tmp(pilot_index);
    p_plot_sw = reshape(freq_data_ofdm_1_tmp, ...
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
    ifft_sw = ifft_sw(nfft_zc+cp_len+1:end);
    ifft_sw = reshape(ifft_sw,[nfft+cp_len ofdm_symbols]);
    ifft_sw = vertcat(ifft_sw,gp);
    ofdm_tx_signal_par = ifft_sw;
    figure(),subplot(2,1,1),plot(real(reshape(qam_mod_data,[1 ...
        ofdm_symbols*data_carriers])),'LineWidth',2),hold on
    plot(real(reshape(carriers(data_index)/tx_scale, [1 ofdm_symbols*...
        data_carriers]))),subplot(2,1,2),plot(imag(reshape(qam_mod_data,...
        [1 ofdm_symbols*data_carriers])),'LineWidth',2),hold on
    plot(imag(reshape(...
    carriers(data_index)/tx_scale, [1 ofdm_symbols*data_carriers])))
end



if ~PILOT_COMB_FORMAT
    for i=1:ofdm_symbols
        qam_mod_data(:,i) = carriers(data_index(:,i),i)/tx_scale;
        reference_pilot(:,i) = carriers(pilot_index(:,i),i)/tx_scale;
    end
else
    qam_mod_data = carriers/tx_scale;
    qam_mod_data(any(isnan(rm_pilot_zp_index),2),:) = [];
    reference_pilot = carriers/tx_scale;
    reference_pilot(any(isnan(pilot_index_nan),2),:) = [];
end
tx_data = qamdemod(qam_mod_data,M);

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
if (FIR_BASED_NOT_CIC)
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Channel
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% AWGN Channel
snr = 10^(snr_db/10); % Noise power
ofdm_tx_signal_ch = awgn(ofdm_duc_signal_real,snr,'measured');

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
ofdm_tx_signal_doppler =interp1(t_up,ofdm_tx_signal_ch1,t_up/k,'linear',0);
% One method to compensate for doppler if estimated k accurately:
%ofdm_tx_signal_doppler = resample(ofdm_tx_signal_doppler, ...
    %round(DAC_FS/k),DAC_FS);
%ofdm_tx_signal_doppler = ofdm_tx_signal_doppler(1:length ...
%    (ofdm_tx_signal_ch));

% Sample phase offset
ofdm_tx_signal_doppler = ofdm_tx_signal_doppler .* exp(1i*spo);

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
if (FIR_BASED_NOT_CIC)
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
else
    % Model Xilinx CIC Filter as DUC
    ddc_base_signal = filter(cic_impulse,1,ddc_signal).'*duc_ddc_loss_gain;
    ddc_base_signal = downsample(ddc_base_signal,Interp_val);

    ddc_doppler = filter(cic_impulse,1,ddc_signal_doppler).'* ...
        duc_ddc_loss_gain;
    ddc_doppler = downsample(ddc_doppler,Interp_val);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DDC on MODEM ADC samples
if RAW_SAMPLES
    file = fopen(sprintf('%sRxAdcRawSamples.txt',filepath),'r');
    ofdm_rx_modem = fscanf(file,"%d").';
    fclose('all');

    figure(),plot(F_up_adc/1000,10*log10(abs(fftshift(fft( ...
        ofdm_rx_modem,nfft_p))))),xlabel('kHz')
    t_up2 = 0:1/ADC_FS:length(ofdm_rx_modem)/ADC_FS-1/ADC_FS;

    % IQ Mixer RX
    i_modem = ofdm_rx_modem .* cos(2*pi*Fc*t_up2);
    q_modem = ofdm_rx_modem .* -sin(2*pi*Fc*t_up2);
    ddc_signal_modem = complex(i_modem,q_modem);

%     ddc_modem_real = ...
%         decimate(real(ddc_signal_modem),Interp_val*4,4096,'Fir');
%     ddc_modem_imag = ...
%         decimate(imag(ddc_signal_modem),Interp_val*4,4096,'Fir');
%     ddc_modem = complex(ddc_modem_real,ddc_modem_imag);
%     ddc_modem = ddc_modem.' * duc_ddc_loss_gain;
    % DDC model of FPGA implementation:
    ddc_modem_stage1 = [ddc_signal_modem zeros(1,filter_delay_4x)];
    ddc_modem_stage1_out = filter(fir_taps_4x,1,ddc_modem_stage1);
    ddc_modem_stage1_out(1:filter_delay_4x) = [];
    ddc_modem_stage1_out = downsample(ddc_modem_stage1_out,4);
    ddc_modem_stage2 = [ddc_modem_stage1_out zeros(1,filter_delay_rx)];
    ddc_modem_stage2_out = filter(fir_taps_rx,1,ddc_modem_stage2);
    ddc_modem_stage2_out(1:filter_delay_rx) = [];
    ddc_modem = downsample(ddc_modem_stage2_out,Interp_val);
    ddc_modem(1:cp_len+gp_samples-25) = [];

    figure(),plot(F/1000,10*log10(abs(fftshift(fft(ddc_modem,nfft_p)))))
    xlabel('kHz'),ylabel('dB'),title('ADC Captured Samples Spectrum')

    figure(),subplot(2,1,1),plot(3*real(ddc_doppler),'LineWidth',2),hold on
    plot(-real([zeros(1,nfft_zc+cp_len+gp_samples) ddc_modem]))
    title('In-Phase'),subplot(2,1,2)
    plot(3*imag(ddc_doppler),'LineWidth',2),hold on
    plot(-imag([zeros(1,nfft_zc+cp_len+gp_samples) ddc_modem]))
    title('Quadrature'),legend('MATLAB','MODEM')
    sgtitle('MATLAB vs MODEM ADC Sample Capture DDC Output')
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Bypass DUC/DDC for MATLAB AWGN Channel
if (LOOPBACK)
    ddc_base_signal = ofdm_tx_signal_ser/1.91;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Read DDC/syncronizer output or FFT Input from MODEM SW
if (DESKTOP_OFDM)
    file =fopen('../Xilinx/SW_Source/ofdm_v2/files/RxFftSamples1.txt','r');
else
    file = fopen(sprintf('%sRxFftSamples1.txt',filepath),'r');
end
fft_sw = fscanf(file,"%d, %d\n", [2 ofdm_symbols*(cp_len+nfft)]);
fclose('all');
fft_sw = complex(fft_sw(1,:),fft_sw(2,:));
if RAW_SAMPLES
    ddc_modem = reshape(ddc_modem(1:(nfft+cp_len+gp_samples)*...
        ofdm_symbols), [nfft+cp_len+gp_samples ofdm_symbols]);
    ddc_modem(end-gp_samples+1:end,:) = [];
    fft_sw = reshape(ddc_modem,[1 ofdm_symbols*(nfft+cp_len)]);
    fft_sw_plot = fft_sw;
end
fft_sw_plot = fft_sw;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot FFT input time domain
if (DESKTOP_OFDM)
    scale = 1;
else
    scale = 5;
end
figure(),subplot(2,1,1),plot(real(reshape(ofdm_tx_signal_par1,[1 ...
    ofdm_symbols*(cp_len+nfft)])),'LineWidth',2),hold on
plot(real(fft_sw*scale)),title('Real'),legend('MATLAB','SW'),subplot(2,1,2)
plot(imag(reshape(ofdm_tx_signal_par1,[1 ofdm_symbols*(cp_len+nfft)])),...
    'LineWidth',2),hold on,plot(imag(fft_sw*scale)),legend('MATLAB','SW')
title('Imaginary'),sgtitle('FFT Input')
if (DESKTOP_OFDM)
    scale = 1; % Full Demod path
else
    scale = 3; % Internal loopback
end
fft_sw1 = fft_sw*scale;
fft_sw = reshape(fft_sw, [nfft+cp_len ofdm_symbols]);
gp = zeros(gp_samples,ofdm_symbols);   
fft_sw = vertcat(fft_sw,gp);
fft_sw = reshape(fft_sw, [(nfft+cp_len+length(gp))*ofdm_symbols 1]);
fft_sw = [zeros(nfft_zc+cp_len+gp_samples,1);fft_sw];
fft_sw = scale*fft_sw;

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
plot(t_p/1000,real(fft_sw))
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
legend('Ideal','MATLAB UW-A Channel','Modem UW-A Channel',...
    'Ideal Timing','','MATLAB UW-A Timing')
xlabel('Time (ms)'),title('In Phase'),subplot(3,1,2)
plot(t_p/1000,imag(ofdm_tx_signal_ser),'LineWidth',2),hold on
plot(t_p/1000,imag(ddc_doppler)),plot(t_p/1000,imag(fft_sw))
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
legend('Ideal','MATLAB UW-A Channel','Modem UW-A doppler',...
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
% Plot spectrum of FFT input
ofdm_rx_sync_doppler = filter(multipath,1,ofdm_rx_sync_doppler);
if PLOT_MAT_CH_EST
    figure(),plot(F/1000,10*log10(abs(fftshift(fft(ofdm_rx_sync_doppler,...
        nfft_p))))),xlabel('kHz'),ylabel('dB')
    title('MATLAB Sim FFT Input Spectrum')
else
    figure(),plot(F/1000,10*log10(abs(fftshift(fft(fft_sw_plot,nfft_p)))))
    xlabel('kHz'),ylabel('dB'),title('Modem FFT Input Spectrum')
end

ofdm_rx_signal_par=reshape(ofdm_rx_sync_signal, ...
    [nfft+cp_len+gp_samples ofdm_symbols]);
ofdm_rx_sync_doppler = filter(multipath,1,ofdm_rx_sync_doppler);
ofdm_rx_doppler_par=reshape(ofdm_rx_sync_doppler, ...
    [nfft+cp_len+gp_samples ofdm_symbols]);
ofdm_rx_modem_par=reshape(fft_sw1,[nfft+cp_len ofdm_symbols]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CFO Estimation and Correction
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% AWGN Channel
ofdm_rx_signal_par(end-gp_samples+1:end,:) = []; % Remove GP
ofdm_cfo_signal = ofdm_rx_signal_par; 
ofdm_cfo_signal(1:cp_len,:) = [];                % Remove CP

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MATLAB Doppler channel
ofdm_rx_doppler_par(end-gp_samples+1:end,:) = []; % Remove GP
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
if DOPPLER_PROC || ~ADD_MAT_CFO_CORR
    ofdm_cfo_doppler = cp_rm_doppler;
end
table(cfo_est_doppler)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MODEM Channel data
cp_rm_modem = ofdm_rx_modem_par;
cp_rm_modem(1:cp_len,:) = [];

ofdm_cfo_modem = zeros(nfft,ofdm_symbols);
cfo_est = 0;
cfo_est_modem = zeros(1,ofdm_symbols);
for i = 1: ofdm_symbols
    cp_cfo_begin = ofdm_rx_modem_par(doppler_cp_offset+1:cp_len- ...
        doppler_cp_offset,i); % Obtain CP at beginning of symbol
    cp_cfo_end = ofdm_rx_modem_par(nfft+1+doppler_cp_offset: ...
        end-doppler_cp_offset,i); % Obtain CP at end of symbol
    tmp = cp_cfo_end.*conj(cp_cfo_begin); % Correlate
    sum_val = sum(tmp);
    tan_val = atan2(imag(sum_val),real(sum_val));
    normalized_cfo_est = 1*tan_val;
    cfo_est = normalized_cfo_est*scs;
    cfo_est_modem(i) = cfo_est/2/pi;
    ofdm_cfo_modem(:,i) = cp_rm_modem(:,i).*(cos(cfo_est*t(1:nfft)) ...
        +1i*sin(cfo_est*t(1:nfft)))';
end
if (~ADD_CFO_CORR)
    ofdm_cfo_modem = cp_rm_modem;
end
table(cfo_est_modem)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% doppler processing
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if DOPPLER_PROC
    k_est = (-mean(cfo_est_doppler)/Fc)+1;% Estimate doppler scaling factor
    Fs_doppler_sample = DAC_FS/k;         % Resample rate
    Fs_doppler_sample_est = DAC_FS/k_est; % Estimated resample rate
    table(k,k_est,Fs_doppler_sample,Fs_doppler_sample_est)

    if RAW_SAMPLES
        k_est_modem = (-mean(cfo_est_modem)/Fc)+1;
        Fs_modem_sample = ADC_FS/k;
        Fs_modem_sample_est = ADC_FS/k_est;
        table(k,k_est_modem,Fs_modem_sample,Fs_modem_sample_est)
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Resample with doppler shift factor
    P = round(DAC_FS/k/300);  Q = round(DAC_FS/300);
    P = round(DAC_FS/k);  Q = round(DAC_FS);
    if P*Q >= 2^31
        re_scale = 2^31/(P*Q);
        P = floor(P*sqrt(re_scale)); Q = floor(Q*sqrt(re_scale));
    end
    ofdm_tx_signal_doppler2 = resample(ofdm_tx_signal_doppler,P,Q);
    if (length(ofdm_tx_signal_doppler2) > length(ofdm_tx_signal_ch))
        ofdm_tx_signal_doppler2 = ofdm_tx_signal_doppler2(1:length( ...
            ofdm_tx_signal_ch));
    elseif (length(ofdm_tx_signal_doppler2) < length(ofdm_tx_signal_ch))
        ofdm_tx_signal_doppler2 = [ofdm_tx_signal_doppler2 zeros(1, ...
            length(ofdm_tx_signal_ch) - length(ofdm_tx_signal_doppler2))];
    end

    if RAW_SAMPLES
        P_modem = round(ADC_FS/k/300); Q_modem = round(ADC_FS/300);
        ofdm_rx_signal_modem2 = resample(ofdm_rx_modem,P_modem,Q_modem);
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % IQ Mixer RX
    i_ddc_doppler2 = ofdm_tx_signal_doppler2 .* cos(2*pi*Fc*t_up);
    q_ddc_doppler2 = ofdm_tx_signal_doppler2 .* -sin(2*pi*Fc*t_up);
    ddc_signal_doppler2 = complex(i_ddc_doppler2,q_ddc_doppler2);

    if RAW_SAMPLES
        i_modem2 = ofdm_rx_signal_modem2 .* cos(2*pi*Fc*t_up2);
        q_modem2 = ofdm_rx_signal_modem2 .* -sin(2*pi*Fc*t_up2);
        ddc_signal_modem2 = complex(i_modem2,q_modem2);
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % DDC
    ddc_doppler_real2 = decimate(real(ddc_signal_doppler2), ...
        Interp_val,4096,'Fir');
    ddc_doppler_imag2 = decimate(imag(ddc_signal_doppler2), ...
        Interp_val,4096,'Fir');
    ddc_doppler2 = complex(ddc_doppler_real2,ddc_doppler_imag2);
    ddc_doppler2 = duc_ddc_loss_gain * ddc_doppler2.';

    if RAW_SAMPLES
        ddc_modem_stage12 = [ddc_signal_modem2 zeros(1,filter_delay_4x)];
        ddc_modem_stage1_out2 = filter(fir_taps_4x,1,ddc_modem_stage12);
        ddc_modem_stage1_out2(1:filter_delay_4x) = [];
        ddc_modem_stage1_out2 = downsample(ddc_modem_stage1_out2,4);
        ddc_modem_stage22=[ddc_modem_stage1_out2 zeros(1,filter_delay_rx)];
        ddc_modem_stage2_out2 = filter(fir_taps_rx,1,ddc_modem_stage22);
        ddc_modem_stage2_out2(1:filter_delay_rx) = [];
        ddc_modem2 = downsample(ddc_modem_stage2_out2,Interp_val);
        ddc_modem2(1:cp_len+gp_samples-25) = [];   
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Synchronization
    sync_corr_doppler2 = abs(filter(sync_coef,1,ddc_doppler2));
    [val3,ind3] = max(sync_corr_doppler2);
    ind3 = ind3-doppler_sync_samples_early...
        +gp_samples+force_doppler_sync+cp_len;
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
    %display(doppler_sync_offset2)

    vertical_lines(1) = [];
    vertical_lines_doppler2 = zeros(1,ofdm_symbols*3);
    line_label(1) = [];
    for i=1:ofdm_symbols
        if i==1
            vertical_lines_doppler2(i) = ind3;
            vertical_lines_doppler2(i+1)=vertical_lines_doppler2(i)+cp_len;
            vertical_lines_doppler2(i+2)=vertical_lines_doppler2(i+1)+nfft;
        else
            vertical_lines_doppler2(3*i-2) = ...
                vertical_lines_doppler2(3*i-3)+gp_samples;
            vertical_lines_doppler2(3*i-1) = ...
                vertical_lines_doppler2(3*i-2)+cp_len;
            vertical_lines_doppler2(3*i) = ...
                vertical_lines_doppler(3*i-1)+nfft;
        end
    end

    % Plot syncronization timing after resampling
    figure(),subplot(3,1,1),plot(t_p/1000,real(ofdm_tx_signal_ser),...
        'LineWidth',2),hold on,plot(t_p/1000,real(ddc_doppler2))
    for i=1:length(vertical_lines)
        if i==1
            xline(vertical_lines(i)*Ts/1000,'--b',line_label{i}, ...
                'LabelHorizontalAlignment','left')
        else
            xline(vertical_lines(i)*Ts/1000,'--b',line_label{i})
            xline(vertical_lines_doppler2(i-1)*Ts/1000,'--r', ...
                line_label{i},'LabelVerticalAlignment','bottom');
        end
    end
    legend('Ideal','MATLAB UW-A Channel','Ideal Timing',...
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
            xline(vertical_lines_doppler2(i-1)*Ts/1000,'--r',...
                line_label{i},'LabelVerticalAlignment','bottom');
        end
    end
    legend('Ideal','MATLAB UW-A Channel','Ideal Timing',...
        'MATLAB UW-A Timing')
    xlabel('Time (ms)'),title('Quadrature'),subplot(3,1,3)
    plot(t_p/1000,sync_corr_filt),hold on,plot(t_p/1000,sync_corr_doppler2)
    vertical_lines = [ind3-gp_samples-cp_len vertical_lines];
    line_label = ["UW-A Sync", line_label];
    xline(vertical_lines(2)*Ts/1000,'--b',line_label{2}, ...
        'LabelHorizontalAlignment','left')
    xline(vertical_lines(1)*Ts/1000,'--r',line_label{1}, ...
        'LabelHorizontalAlignment','Left','LabelVerticalAlignment',...
        'bottom')
    legend('Ideal','MATLAB UW-A Channel','Ideal Timing',...
        'MATLAB UW-A Timing')
    title('Synchronizer Correlator Output')
    sgtitle('Baseband OFDM Signal After Re-Sampler')
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Plot Modem ADC samples after DDC compared to MATLAB
    if RAW_SAMPLES
    ddc_modem2((nfft+cp_len+gp_samples)*ofdm_symbols+1:end) = [];
    figure(),subplot(2,1,1),plot(real(ofdm_rx_sync_doppler2),'LineWidth',2)
    hold on,plot(real(ddc_modem2)),title('In-Phase'),subplot(2,1,2)
    plot(imag(ofdm_rx_sync_doppler2),'LineWidth',2),plot(real(ddc_modem2))
    title('Quadrature'),legend('MATLAB','MODEM')
    sgtitle('MATLAB vs MODEM ADC Capture DDC Output')
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Add multipath at baseband (too many taps to model at pass band)
    ofdm_rx_sync_doppler2 = filter(multipath,1,ofdm_rx_sync_doppler2);

    % Serial to Parallel
    ofdm_rx_doppler_par2=reshape(ofdm_rx_sync_doppler2, ...
        [nfft+cp_len+gp_samples ofdm_symbols]);

    if RAW_SAMPLES
        ofdm_rx_modem_par2 = reshape(ddc_modem2,[nfft+cp_len+gp_samples ...
            ofdm_symbols]);
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Residual CFO Estimation and Correction (OPTIONAL)
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
    %ofdm_cfo_doppler2 = cp_rm_doppler2; % Bypass optional CFO Correction
    table(cfo_est_doppler2)

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Residual CFO estimation on doppler corrected MODEM ADC samples
    if RAW_SAMPLES
        ofdm_rx_modem_par2(end-gp_samples+1:end,:) = [];
        cp_rm_modem2 = ofdm_rx_modem_par2;
        cp_rm_modem2(1:cp_len,:) = [];
        ofdm_cfo_modem2 = zeros(nfft,ofdm_symbols);
        cfo_est_modem2 = zeros(1,ofdm_symbols);
        for i=1:ofdm_symbols
            cp_cfo_begin=ofdm_rx_modem_par2(doppler_cp_offset+1:cp_len-...
                doppler_cp_offset,i);
            cp_cfo_end = ofdm_rx_modem_par2(nfft+1+doppler_cp_offset: ...
                end-doppler_cp_offset,i);
            tmp = cp_cfo_end.*conj(cp_cfo_begin);
            sum_val = sum(tmp);
            tan_val = atan2(imag(sum_val),real(sum_val));
            normalized_cfo_est = 1*tan_val;
            cfo_est = normalized_cfo_est*scs;
            cfo_est_modem2(i) = cfo_est/2/pi;
            ofdm_cfo_modem2(:,i) = cp_rm_modem2(:,i).* ...
                (cos(cfo_est*t(1:nfft))+1i*sin(cfo_est*t(1:nfft)))';
        end
        ofdm_cfo_modem2 = cp_rm_modem2;
        table(cfo_est_modem2)
    end
    if RAW_SAMPLE_DOPPLER
        ofdm_cfo_modem = ofdm_cfo_modem2;
    end
else
    ofdm_cfo_doppler2 = ofdm_cfo_doppler;
end


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

fft_modem = zeros(nfft,ofdm_symbols);
for i = 1:ofdm_symbols
    fft_modem(:,i) = fftshift(fft(ofdm_cfo_modem(:,i),nfft));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Channel Estimation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initialize AWGN Channel data
fft_signal_eq = fft_signal;
P_RX = fft_signal_eq;

% Initialize MATLAB UW-A sim channel data
fft_doppler_eq2 = fft_doppler2;
P_RX_dopler = fft_doppler_eq2;

% Initialize Modem actual UW-A sim channel data
fft_modem_eq = fft_modem;
P_RX_modem = fft_modem_eq;

% Get RX pilots depending on the pilot format
if ~PILOT_COMB_FORMAT
    P_RX = zeros(pilot_carriers,ofdm_symbols);
    P_RX_dopler = zeros(pilot_carriers,ofdm_symbols);
    P_RX_modem = zeros(pilot_carriers,ofdm_symbols);
    for i=1:ofdm_symbols
        P_RX_tmp = fft_signal_eq(:,i);
        P_RX_tmp(any(isnan(pilot_index_nan(:,i)),2),:) = [];
        P_RX(:,i) = P_RX_tmp;
        P_RX_tmp = fft_doppler2(:,i);
        P_RX_tmp(any(isnan(pilot_index_nan(:,i)),2),:) = [];
        P_RX_dopler(:,i) = P_RX_tmp;        
        P_RX_tmp = fft_modem(:,i);
        P_RX_tmp(any(isnan(pilot_index_nan(:,i)),2),:) = [];
        P_RX_modem(:,i) = P_RX_tmp;
    end
else
    P_RX(any(isnan(pilot_index_nan),2),:) = [];
    P_RX_dopler(any(isnan(pilot_index_nan),2),:) = [];
    P_RX_modem(any(isnan(pilot_index_nan),2),:) = [];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Expanded Channel Estimation
% P_RX_re = real(P_RX);           P_RX_im = -imag(P_RX);
% P_re = real(reference_pilot);   P_im = -imag(reference_pilot);
% H = (P_RX_re.*P_re + P_RX_im.*P_im) ./ (P_re.^2 + P_im.^2) + ...
%     1i*(P_RX_im.*P_re - P_RX_re.*P_im) ./ (P_re.^2 + P_im.^2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Matlab Doppler Channel Estimation:
%%%%% Get LS Channel estimate %%%%%
H = conj(P_RX_dopler) ./ conj(reference_pilot);
%%%%% Estimate and correct for phase offsets between symbols %%%%%
% k_index = (0:nfft-1).'*1/scs;
% for i = 1:ofdm_symbols
%     phi_k_doppler = exp(2j*pi*k*k_index);
%     fft_doppler_eq2(:,i)= fft_doppler_eq2(:,i) .* phi_k_doppler;
%     phi_k_doppler(any(isnan(pilot_index_nan(:,i)),2)) = [];
%     H(:,i) = H(:,i) .* phi_k_doppler;
% end
if PHASE_AVG
    phase_sym_rot = zeros(1,ofdm_symbols);
    phase_sym1 = H(:,1);
    for i = 1:ofdm_symbols
        phase_sym_next = H(:,i);
        phase_sym_rot(i) = mean(angle(phase_sym1./phase_sym_next));
    end
    H = H .* exp(1i*phase_sym_rot);
    fft_doppler_eq2 = fft_doppler_eq2 .* exp(-1i*phase_sym_rot);
end
% if PHASE_AVG
%     phase_sym_rot = zeros(1,ofdm_symbols);
%     phase_sym1 = mean(angle(H(:,1)));
%     for i = 1:ofdm_symbols
%         phase_sym_next = mean(angle(H(:,i)));
%         phase_sym_rot(i) = phase_sym1./phase_sym_next;
%     end
%     H = H.*exp(1i*phase_sym_rot);
%     fft_doppler_eq2 = fft_doppler_eq2 .* exp(-1i*phase_sym_rot);
% end
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MODEM Channel Estimation:
%%%%% Get LS Channel estimate %%%%%
H = conj(P_RX_modem) ./ conj(reference_pilot);
%%%%% Estimate and correct for phase offsets between symbols %%%%%
if PHASE_AVG
    phase_sym_rot = zeros(1,ofdm_symbols);
    phase_sym1 = H(:,1);
    for i = 1:ofdm_symbols
        phase_sym_next = H(:,i);
        phase_sym_rot(i) = mean(angle(phase_sym1./phase_sym_next));
    end
    H = H.*exp(1i*phase_sym_rot);
    fft_modem_eq = fft_modem_eq .* exp(-1i*phase_sym_rot);
%     phase_sym_rot = zeros(1,ofdm_symbols);
%     phase_sym1 = angle(H(:,1));
%     for i = 1:ofdm_symbols
%         phase_sym_next = angle(H(:,i));
%         phase_sym_rot(i) = mean(phase_sym1./phase_sym_next);
%     end
%     H = H.*exp(1i*phase_sym_rot);
%     fft_modem_eq = fft_modem_eq .* exp(-1i*phase_sym_rot);
end
% if PHASE_AVG
%     phase_sym_rot = zeros(1,ofdm_symbols);
%     phase_sym1 = mean(angle(H(:,1)));
%     for i = 1:ofdm_symbols
%         phase_sym_next = mean(angle(H(:,i)));
%         phase_sym_rot(i) = phase_sym1./phase_sym_next;
%     end
%     H = H.*exp(1i*phase_sym_rot);
%     fft_modem_eq = fft_modem_eq .* exp(-1i*phase_sym_rot);
% end
%%%%% Interpolate estimates at pilots to all sub-carriers %%%%%
H_interp_modem_orig = zeros(nfft,ofdm_symbols);
for i=1:ofdm_symbols
    H_interp_modem_orig(:,i) = interp1(pilot_index(:,i),H(:,i), ...
        1:nfft,interp_method,"extrap");
end
%%%%% For Alternating pilots, interpolate next sym pilots %%%%%
if (~PILOT_COMB_FORMAT && EQUALIZER_METHOD ~= "ZF Averaged")
    H_interp_modem = H_interp_modem_orig;
    for i=1:ofdm_symbols
        if i<ofdm_symbols
            H_interp_modem(:,i) = ...
                mean(H_interp_modem_orig(:,i:i+1),2);
        else
            H_interp_modem(:,i) = ...
                mean(H_interp_modem_orig(:,i-1:i),2);
        end
    end
else
    H_interp_modem = H_interp_modem_orig;
end
%%%%% Average all CH estimates in an OFDM frame %%%%%
if EQUALIZER_METHOD == "ZF Averaged"
    if FILTER_CH_EST
        H_interp_modem_filt = H_interp_modem;
        w_default = linspace(2,1,ofdm_symbols);
        w_flip = flip(w_default);
        w_flip(end) = [];
        for i=1:ofdm_symbols
            w = [w_flip(end-i+2:end) w_default(1:end-i+1)];
            w = w/sum(w);
            H_interp_modem(:,i)=sum(H_interp_modem_filt.*w,2);
        end
    else
        H_interp_modem = mean(H_interp_modem,2);
        H_interp_modem = ...
            repmat(H_interp_modem, [1 ofdm_symbols]);
    end
end
%%%%% Get Ideal Channel to compare with estimated channel %%%%%
fft_modem_eq_tmp = fft_modem_eq;
fft_modem_eq_tmp(zp_index,:) = [];
H_ideal3 = conj(fft_modem_eq_tmp) ./ ...
    conj(tx_pilot_data);
%%%%% Use entire sym1 as pilots, rest of syms are data %%%%%
if (EQUALIZER_METHOD == "Sym1Pilot" || EQUALIZER_METHOD== "SymAvg")
    if (EQUALIZER_METHOD == "SymAvg")
        H_sym1 = mean(H_ideal3,2);
    else
        H_sym1 = H_ideal3(:,1);
    end
    H_sym1 = repmat(H_sym1, [1 ofdm_symbols]);
    H_interp_modem_sym1=interp1([pilot_index,data_index], ...
        H_sym1,1:nfft,interp_method,"extrap");
end
if (EQUALIZER_METHOD == "Sym1Pilot" || EQUALIZER_METHOD== "SymAvg")
    H_interp = H_interp_sym1;
    H_interp_doppler2 = H_interp_doppler2_sym1;
    H_interp_modem = H_interp_modem_sym1;
end
%%%%% Interpolate Ideal channel to all NFFT sub-carriers %%%%%
H_interp_modem_ideal = zeros(nfft,ofdm_symbols);
for i=1:ofdm_symbols
    tmp_pilot_data_index = pilot_data_index(:,i);
    tmp_pilot_data_index(any(isnan(pilot_data_index),2),:) = [];
    H_interp_modem_ideal(:,i) = interp1(tmp_pilot_data_index, ...
        H_ideal3(:,i),1:nfft,interp_method,"extrap");
end
%%%%% Get time domain taps of Modem channel %%%%%
modem_ch = zeros(nfft,ofdm_symbols);
for i = 1:ofdm_symbols
    modem_ch(:,i) = ifft(ifftshift(H_interp_modem_ideal(:,i)),nfft);
end
modem_ch_ser = reshape(modem_ch, [1 ofdm_symbols*nfft]);
modem_water_ch = modem_ch_ser;
% up_ch = upsample(modem_ch_ser, Interp_val);
% up_ch = [up_ch zeros(1,filter_delay)];
% modem_duc_ch = filter(fir_taps,1,up_ch);
% modem_duc_ch(1:filter_delay) = [];
% t_up_ch = 0:1/DAC_FS:length(modem_duc_ch)/DAC_FS-1/DAC_FS;
% modem_water_ch_i = real(modem_duc_ch) .* cos(2*pi*Fc*t_up_ch);
% modem_water_ch_q = real(modem_duc_ch) .* -sin(2*pi*Fc*t_up_ch);
% modem_water_ch = modem_water_ch_i + modem_water_ch_q;
figure(),subplot(2,1,1),plot(abs(modem_water_ch)),title('Magnitude')
subplot(2,1,2),plot(angle(modem_water_ch)),title('Phase'),xlabel('Samples')
sgtitle('Modem Captured Channel Taps at Baseband')
filename = ...
    './Water_Channel/Preset_'+string(Preset)+'_Test_'+string(Test)+'.mat';
save(filename,'modem_water_ch');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot MATLAB simulated channel response and estimate
if (PLOT_MAT_CH_EST)
    for i = 1:ofdm_symbols
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
% Plot full MODEM channel response and estimate at pilots + data
else
    for i = 1:ofdm_symbols
        figure(),subplot(2,2,1),plot(1:nfft,real( ...
            H_interp_modem_ideal(:,i)),'linewidth',2),hold on
        plot(1:nfft,real(H_interp_modem_orig(:,i)))
        plot(pilot_index(:,i),real(H_interp_modem_ideal(...
            pilot_index(:,i),i)),'LineStyle','none',...
            'MarkerEdgeColor','#0072BD','Marker','*')                
        if ~PILOT_COMB_FORMAT
            plot(1:nfft,real(H_interp_modem(:,i)))
            legend('Ideal','LS','Pilots','LS Alternating')
        else
            legend('Ideal','LS','Pilots')
        end
        title('In-Phase')
        xlim([pilot_index(1),pilot_index(end)])
        subplot(2,2,3),plot(1:nfft,abs(H_interp_modem_ideal( ...
            :,i)),'Linewidth',2),hold on,plot(1:nfft,abs( ...
            H_interp_modem_orig(:,i))),plot(pilot_index(:,i), ...
            abs(H_interp_modem_ideal(pilot_index(:,i),i)), ...
            'LineStyle','none','MarkerEdgeColor','#0072BD', ...
            'Marker','*')
        if ~PILOT_COMB_FORMAT
            plot(1:nfft,abs(H_interp_modem(:,i)))
            legend('Ideal','LS','Pilots','LS Alternating')
        else
            legend('Ideal','LS','Pilots')
        end
        title('Magnitude'),xlim([ ...
            pilot_index(1,1),pilot_index(end,1)])
        subplot(2,2,2),plot(1:nfft,imag(H_interp_modem_ideal(:,i)), ...
            'linewidth',2),hold on,plot(1:nfft,imag( ...
            H_interp_modem_orig(:,i)))
        plot(pilot_index(:,i),imag(H_interp_modem_ideal(...
            pilot_index(:,i),i)),'LineStyle','none',...
            'MarkerEdgeColor','#0072BD','Marker','*')             
        if ~PILOT_COMB_FORMAT
            plot(1:nfft,imag(H_interp_modem(:,i)))
            legend('Ideal','LS','Pilots','LS Alternating')
        else
            legend('Ideal','LS','Pilots')
        end               
        title('Quadrature'),xlim([ ...
            pilot_index(1,1),pilot_index(end,1)])
        subplot(2,2,4),plot(1:nfft,angle(...
            H_interp_modem_ideal(:,i)),'linewidth',2),hold on
        plot(1:nfft,angle(H_interp_modem_orig(:,i)))
        plot(pilot_index(:,i),angle(H_interp_modem_ideal( ...
            pilot_index(:,i),i)),'LineStyle','none',...
            'MarkerEdgeColor','#0072BD','Marker','*')
        if ~PILOT_COMB_FORMAT
            plot(1:nfft,angle(H_interp_modem(:,i)))
            legend('Ideal','LS','Pilots','LS Alternating')
        else
            legend('Ideal','LS','Pilots')
        end
        title('Phase')

        sgtitle({'Modem Channel Estimate Data+Pilot, Symbol ',num2str(i)})
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Plot MODEM Channel Estimate only at data sub-carriers
    for i = 1:ofdm_symbols
        figure(),subplot(2,1,1),plot(data_index(:,i),real( ...
            H_interp_modem_ideal(data_index(:,i),i)),'linewidth',2)
        hold on
        plot(data_index(:,i), ...
            real(H_interp_modem_orig(data_index(:,i),i)))
        if ~PILOT_COMB_FORMAT
            plot(data_index(:,i), ...
                real(H_interp_modem(data_index(:,i),i)))
            legend('Ideal','LS','LS Format 2')
        else
            legend('Ideal','LS')
        end             
        title('In-Phase')
        xlim([pilot_index(1),pilot_index(end)])
        subplot(2,1,2),plot(data_index(:,i), ...
            imag(H_interp_modem_ideal(data_index(:,i),i)), ...
            'linewidth',2),hold on,plot(data_index(:,i) ...
            ,imag(H_interp_modem_orig(data_index(:,i),i)))                 
        if ~PILOT_COMB_FORMAT
            plot(data_index(:,i), ...
                imag(H_interp_modem(data_index(:,i),i)))
            legend('Ideal','LS','LS Format 2')
        else
            legend('Ideal','LS')
        end
        title('Quadrature'),xlim([ ...
            pilot_index(1),pilot_index(end)])
        sgtitle({'Modem Channel Estimate Data, Symbol ',num2str(i)})
    end       
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
% Get NMSE of channel estimate for MODEM UW-A Channel
if ~PILOT_COMB_FORMAT
    H_true_modem = zeros(data_carriers,ofdm_symbols);
    H_modem = zeros(data_carriers,ofdm_symbols);
    for i=1:ofdm_symbols
        H_true_modem_tmp = H_interp_modem_ideal(:,i);
        H_true_modem_tmp(any(isnan(rm_pilot_zp_index(:,i)),2),:) = [];
        H_true_modem(:,i) = H_true_modem_tmp;
        H_modem_tmp = H_interp_modem(:,i);
        H_modem_tmp(any(isnan(rm_pilot_zp_index(:,i)),2),:) = [];
        H_modem(:,i) = H_modem_tmp;
    end
else
    H_true_modem = H_interp_modem_ideal;
    H_true_modem(any(isnan(rm_pilot_zp_index),2),:) = [];
    H_modem = H_interp_modem;
    H_modem(any(isnan(rm_pilot_zp_index),2),:) = [];
end
H_true_modem_sc = H_interp_modem_ideal;
%H_true_modem_sc(zp_index,:) = [];
H_modem_sc = H_interp_modem;
%H_modem_sc(zp_index,:) = [];

squared_errors_modem = zeros(data_carriers,ofdm_symbols);
sum_squared_errors_modem = zeros(1,ofdm_symbols);
sum_squared_magnitudes_true_modem = zeros(1,ofdm_symbols);
NMSE_modem = zeros(1,ofdm_symbols);
for i=1:ofdm_symbols
    squared_errors_modem(:,i) = abs(H_true_modem(:,i)-H_modem(:,i)).^2;
    sum_squared_errors_modem(i) = sum(squared_errors_modem(:,i));
    sum_squared_magnitudes_true_modem(i) = sum(abs(H_true_modem(:,i)).^2);
    NMSE_modem(i) = ...
        sum_squared_errors_modem(i) / sum_squared_magnitudes_true_modem(i);
end
NMSE_modem_sc =abs(H_true_modem_sc-H_modem_sc).^2./abs(H_true_modem_sc.^2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot channel estimate NMSE vs OFDM symbol
y1 = 1:ofdm_symbols;
figure(),b = bar(y1,[NMSE_doppler;NMSE_modem],'LineWidth',0.5);
xtips1 = b(1).XEndPoints;ytips1 = b(1).YEndPoints;
labels1 = string(b(1).YData);text(xtips1,ytips1,labels1,...
    'HorizontalAlignment','center','VerticalAlignment','bottom')
xtips2 = b(2).XEndPoints;ytips2 = b(2).YEndPoints;
labels2 = string(b(2).YData);text(xtips2,ytips2,labels2,...
    'HorizontalAlignment','center','VerticalAlignment','bottom')
legend('MATLAB Sim','Modem')
xlabel('OFDM Symbols'),title('Channel Estimate Error per Symbol')
ylabel('Normalized Mean Squared Error (NMSE)')

% Plot channel estimate NMSE vs sub-carrier
y1 = 1:nfft; y1([zp_index(:,1);pilot_index(:,1)]) = [];
NMSE_doppler_sc_plot = NMSE_doppler_sc(:,1);
NMSE_doppler_sc_plot([zp_index(:,1);pilot_index(:,1)]) = [];
NMSE_modem_sc_plot = NMSE_modem_sc(:,1);
NMSE_modem_sc_plot([zp_index(:,1);pilot_index(:,1)]) = [];
figure(),bar(y1,[NMSE_doppler_sc_plot NMSE_modem_sc_plot].');
legend('MATLAB Sim','Modem'),xlabel('Data Sub-Carriers')
title('Channel Estimate Error per Sub-Carrier for Symbol 1')
ylabel('Normalized Mean Squared Error (NMSE)')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot real channel (MATLAB or MODEM) for first 4 symbols
figure()
for i = 1:symbol_plot
    if PLOT_MAT_CH_EST
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
    else
        subplot(2,2,1),plot(1:nfft,real(H_interp_modem_ideal(:,i)), ...
            'linewidth',2),hold on,xlim([pilot_index(1), ...
            pilot_index(end)]),subplot(2,2,2),plot(1:nfft,imag( ...
            H_interp_modem_ideal(:,i)),'linewidth',2),hold on
        xlim([pilot_index(1),pilot_index(end)])
        subplot(2,2,3),plot(1:nfft,abs(H_interp_modem_ideal(:,i)), ...
            'linewidth',2),hold on,xlim([pilot_index(1), ...
            pilot_index(end)]),subplot(2,2,4),plot(1:nfft,angle(...
            H_interp_modem_ideal(:,i)),'linewidth',2),hold on
        xlim([pilot_index(1),pilot_index(end)])
    end
end
subplot(2,2,1),title('In-Phase'),xlabel('Sub-Carriers')
legend('Sym 0','Sym 1','Sym 2','Sym 3')
subplot(2,2,2),title('Quadrature'),xlabel('Sub-Carriers')
legend('Sym 0','Sym 1','Sym 2','Sym 3')
subplot(2,2,3),title('Magnitude'),xlabel('Sub-Carriers')
legend('Sym 0','Sym 1','Sym 2','Sym 3')
subplot(2,2,4),title('Phase'),xlabel('Sub-Carriers')
legend('Sym 0','Sym 1','Sym 2','Sym 3')
if PLOT_MAT_CH_EST
    sgtitle('MATLAB Actual Channel')
else
    sgtitle('Modem Actual Channel')
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% For proof only. With ideal channel, equalization should be perfect
if (EQUALIZER_METHOD == "Ideal")
    H_interp_doppler2 = H_interp_doppler2_ideal;
    H_interp_modem = H_interp_modem_ideal;
end

if (COMP_EST)
    multipath_freq = fftshift(fft(multipath,nfft));
    figure(),subplot(2,1,1),plot(real(multipath_freq),'LineWidth',2)
    hold on,plot(real(H_interp(:,1))),title('Real'),legend('Channel', ...
        'Channel Est'),subplot(2,1,2),plot(imag(multipath_freq), ...
        'LineWidth',2),hold on,plot(imag(H_interp(:,1))),title('Imaginary')
    legend('Channel','Channel Est'),sgtitle('Channel Estimate')
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
%Z_EQ_ZF_doppler2 = fft_doppler_eq2 .*conj(H_interp_doppler2) ./ ...
%    (conj(H_interp_doppler2).^2 + NMSE_doppler_sc2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Equalized Modem UW-A Data
Z_EQ_ZF_modem = fft_modem_eq ./ conj(H_interp_modem);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot Equalized data
if (DESKTOP_OFDM)
    file =fopen('../Xilinx/SW_Source/ofdm_v2/files/RxFreqDataEQ1.txt','r');
else
    file = fopen(sprintf('%sRxFreqDataEQ1.txt',filepath),'r');
end
tmp = fscanf(file,"%d,\n",1);
tmp = fscanf(file,"%d,\n",1);
tmp = fscanf(file,"%d,\n",1);
EQ_sw_raw = fscanf(file,"%f, %f", [2 nfft*ofdm_symbols]);
fclose('all');
EQ_sw_raw = complex(EQ_sw_raw(1,:),EQ_sw_raw(2,:));
EQ_sw = reshape(EQ_sw_raw,[nfft ofdm_symbols]);
EQ_sw_pilots = EQ_sw;
%EQ_sw_pilots(any(isnan(pilot_index_nan),2),:) = [];
EQ_sw_pilots = EQ_sw_pilots(pilot_index);
%EQ_sw(any(isnan(rm_pilot_zp_index),2),:) = []; % Remove ZP and Pilot
EQ_sw = EQ_sw(data_index);
EQ_sw_tmp2 = zeros(pilot_carriers,ofdm_symbols);
EQ_sw_pilots = reshape(EQ_sw_pilots,[1 ofdm_symbols*pilot_carriers]);
EQ_sw_raw = reshape(EQ_sw, [1 ofdm_symbols*data_carriers]);
Z_EQ_ZF1 = fft_signal;
Z_EQ_ZF_pilot = Z_EQ_ZF1;
%Z_EQ_ZF_pilot(any(isnan(pilot_index_nan),2),:) = [];
Z_EQ_ZF_pilot = Z_EQ_ZF_pilot(pilot_index);
Z_EQ_ZF_pilot = reshape(Z_EQ_ZF_pilot, [1 ofdm_symbols*pilot_carriers]);
%Z_EQ_ZF1(any(isnan(rm_pilot_zp_index),2),:) = [];
Z_EQ_ZF1  = Z_EQ_ZF1(data_index);
Z_EQ_ZF1 = reshape(Z_EQ_ZF1, [1 ofdm_symbols*data_carriers]);
% figure(),subplot(2,1,1),plot(real(Z_EQ_ZF1),'LineWidth',2),hold on
% plot(real(EQ_sw_raw)),title('Real'),legend('MATLAB','SW'),subplot(2,1,2)
% plot(imag(Z_EQ_ZF1),'LineWidth',2),hold on,plot(imag(EQ_sw_raw))
% title('Imag'),legend('MATLAB','SW'),sgtitle('Equalizer Output')
% figure(),subplot(2,1,1),plot(real(Z_EQ_ZF_pilot),'LineWidth',2),hold on
% plot(real(EQ_sw_pilots)),title('Real'),legend('MATLAG','SW'),subplot(2,1,2)
% plot(imag(Z_EQ_ZF_pilot),'LineWidth',2),hold on,plot(imag(EQ_sw_pilots))
% title('Imaginary'),legend('MATLAG','SW'),sgtitle('EQ Pilots')

if (MAT_DEMOD)
    EQ_sw = Z_EQ_ZF_modem;
    if ~PILOT_COMB_FORMAT
        EQ_sw = zeros(data_carriers,ofdm_symbols);
        for i=1:ofdm_symbols
            EQ_sw_tmp = Z_EQ_ZF_modem(:,i);
            EQ_sw_tmp(any(isnan(rm_pilot_zp_index(:,i)),2),:) = [];
            EQ_sw(:,i) = EQ_sw_tmp;
        end
    else
        EQ_sw(any(isnan(rm_pilot_zp_index),2),:) = [];
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Only keep data sub-carriers
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~PILOT_COMB_FORMAT
    % Initialize data variables
    Z_EQ_ZF2 = zeros(data_carriers,ofdm_symbols);
    fft_signal_eq_2 = zeros(data_carriers,ofdm_symbols);
    fft_doppler_eq2_2 = zeros(data_carriers,ofdm_symbols);
    Z_EQ_ZF_doppler2_2 = zeros(data_carriers,ofdm_symbols);
    fft_modem_eq2 = zeros(data_carriers,ofdm_symbols);
    Z_EQ_ZF_modem2 = zeros(data_carriers,ofdm_symbols);
    % Remove pilot and ZP sub-carriers
    Z_EQ_ZF = fft_signal/tx_scale/2.3;
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

        fft_modem_eq_tmp = fft_modem_eq(:,i);
        fft_modem_eq_tmp(any(isnan(rm_pilot_zp_index(:,i)),2),:) = [];
        fft_modem_eq2(:,i) = fft_modem_eq_tmp;  

        Z_EQ_ZF_modem2_tmp = Z_EQ_ZF_modem(:,i);
        Z_EQ_ZF_modem2_tmp(any(isnan(rm_pilot_zp_index(:,i)),2),:) = [];
        Z_EQ_ZF_modem2(:,i) = Z_EQ_ZF_modem2_tmp;          
    end
    Z_EQ_ZF = Z_EQ_ZF2;
    fft_signal_eq = fft_signal_eq_2;
    fft_doppler_eq2 = fft_doppler_eq2_2;
    Z_EQ_ZF_doppler2 = Z_EQ_ZF_doppler2_2;
    fft_modem_eq = fft_modem_eq2;
    Z_EQ_ZF_modem = Z_EQ_ZF_modem2;

else
    Z_EQ_ZF = fft_signal/tx_scale/2.3;
    Z_EQ_ZF(any(isnan(rm_pilot_zp_index),2),:) = [];
    fft_signal_eq(any(isnan(rm_pilot_zp_index),2),:) = [];
    fft_doppler_eq2(any(isnan(rm_pilot_zp_index),2),:) = [];
    Z_EQ_ZF_doppler2(any(isnan(rm_pilot_zp_index),2),:) = [];
    fft_modem_eq(any(isnan(rm_pilot_zp_index),2),:) = [];
    Z_EQ_ZF_modem(any(isnan(rm_pilot_zp_index),2),:) = [];
end

% Scatter Plot %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
lim = sqrt(2*M) + 1; y_lim = [-lim lim]; x_lim = [-lim lim];
ideal_scatter = qammod(0:M-1,M);
figure(),subplot(2,2,1),scatter(real(Z_EQ_ZF),imag(Z_EQ_ZF),'.'),grid on
if PLOT_IDEAL
    hold on,scatter(real(ideal_scatter),imag(ideal_scatter),300,'c','x',...
        'LineWidth',3)
end
title({[num2str(snr_db),'dB AWGN Channel'],'No Equalization'}),ylim(y_lim)
xlim(x_lim),subplot(2,2,2),scatter(real(Z_EQ_ZF_doppler2),imag( ...
    Z_EQ_ZF_doppler2),'.'),grid on
if PLOT_IDEAL
    hold on,scatter(real(ideal_scatter),imag(ideal_scatter),300,'c','x',...
        'LineWidth',3)
end
title({'MATLAB Sim UW-A Channel','Doppler Correction with Equalization'})
ylim(y_lim),xlim(x_lim),subplot(2,2,3),scatter(real(Z_EQ_ZF_modem),...
    imag(Z_EQ_ZF_modem),'.'),grid on
if PLOT_IDEAL
    hold on,scatter(real(ideal_scatter),imag(ideal_scatter),300,'c','x',...
        'LineWidth',3)
end
title({'Modem UW-A Channel','FFT Input Capture Decoded in MATLAB'})
xlim(x_lim),ylim(y_lim),subplot(2,2,4),scatter(real(EQ_sw),imag(EQ_sw),'.')
if PLOT_IDEAL
    hold on,scatter(real(ideal_scatter),imag(ideal_scatter),300,'c','x',...
        'LineWidth',3)
end
ylim(y_lim),xlim(x_lim),grid on
title({'MODEM UW-A Channel','SW with Equalization'})
sgtitle('Equalizer Output')

% Loop through each OFDM MODEM symbol and plot the constellation
symbol = 4;
if PLOT_MAT_CH_EST
    for i=1:symbol
        figure(),scatter(real(Z_EQ_ZF_doppler2(:,i)),...
            imag(Z_EQ_ZF_doppler2(:,i)),'.')
        title(['Modem Sim Channel, Symbol ',num2str(i)])
    end
else
    for i=1:symbol
        figure(),scatter(real(EQ_sw(:,i)),imag(EQ_sw(:,i)),'.')
        title(['Modem UW-A Channel, Symbol ',num2str(i)])
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% QAM Demodulation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Demod
demod_data = qamdemod(Z_EQ_ZF,M);
demod_doppler2 = qamdemod(Z_EQ_ZF_doppler2,M);

if (DESKTOP_OFDM)
    filename = "../Xilinx/SW_Source/ofdm_v2/files/RxDemodData"+M+".txt";
    file = fopen(filename,'r');
else
    filename2 = sprintf('%sRxDemodData%d.txt',filepath,M);
    file = fopen(filename2,'r');
end
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

table(NMSE_doppler)
table(NMSE_modem)

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
carriers_plot(data_index(:,1)) = evm_carriers;
evm_carriers_doppler2 = evm(qam_mod_data,Z_EQ_ZF_doppler2);
carriers_plot_doppler2(data_index(:,1)) = evm_carriers_doppler2;
evm_carriers_sw = evm(qam_mod_data,EQ_sw);
carriers_plot_sw(data_index(:,1)) = evm_carriers_sw;

figure(),subplot(2,3,1),bar(y1,carriers_plot),ax=gca;ax.YLim=y_lim;
xlabel('Sub-Carriers'),ylabel('%')
title({'AWGN Channel', 'Averaged Across Sub-Carriers'}),subplot(2,3,2)
bar(y1,carriers_plot_doppler2),ax=gca;ax.YLim=y_lim;xlabel('Sub-Carriers')
ylabel('%')
title({'MATLAB Sim UW-A Channel','Averaged Across Sub-Carriers'})
subplot(2,3,4)
bar(y_ofdm,evm_ofdm),ax=gca;ax.YLim=y_lim;xlabel('OFDM Symbols')
ylabel('%'),title({'AWGN Channel','Averaged Across OFDM Symbols'})
subplot(2,3,5),bar(y_ofdm,evm_ofdm_doppler2)
ax=gca;ax.YLim=y_lim;xlabel('OFDM Symbols'),ylabel('%')
title({'MATLAB Sim UW-A Channel','Averaged Across OFDM Symbols'})
subplot(2,3,3)
bar(y1,carriers_plot_sw),ax=gca;ax.YLim=y_lim2;xlabel('Sub-Carriers')
ylabel('%'),title({'Modem UW-A Channel','Averaged Across Sub-Carriers'})
subplot(2,3,6),bar(y_ofdm,evm_sw),ax=gca;ax.YLim=y_lim2;
xlabel('OFDM Symbols'),ylabel('%')
title({'Modem UW-A Channel','Averaged Across OFDM Symbols'})
sgtitle('EVM')