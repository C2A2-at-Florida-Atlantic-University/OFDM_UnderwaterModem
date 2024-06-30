clear;clc;close all;fclose('all');format long;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Simulation settings
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Preset = 816;
Test = 0;

%%%%% Generic Simulation Settings %%%%%
% Use Preset/Test for config and modem analysis else MATLAB only analysis
    MODEM_ANALYSIS = true;
% Interpolation method of adding MATLAB simulated doppler channel
    doppler_ch_interp_method = 'spline';
% Add AWGN at baseband else add AWGN at passband
    BASEBAND_AWGN = true;
% Add SRO to channel
    SRO_CHANNEL = true;
% Add expected scatter plot constellation points on plots
    PLOT_IDEAL = false;
% Remove Doppler estimation and compensate with known value
    DOPPLER_IDEAL = true;
% Remove CFO Estimation and compensate with known value
    CFO_IDEAL = false;

%%%%% Demodulation settings %%%%%
% Perform Doppler Compensation
    DOPPLER_PROC = false;
% Perform CFO Estimation and Compensation 
    CFO_COMP = true;
% Slope CFO estimates from 1 symbol to the next
    CFO_EST_SLOPE = true;
% Channel Estimation Method: "LS" or "LS Averaged"
    CH_EST_METHOD = "LS Averaged";
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
if MODEM_ANALYSIS
    filepath = '../Testing/Water_Testing/Tank/Full_Demod/preset_'+ ...
        string(Preset)+'_test_'+string(Test)+'/';
    file = fopen(sprintf('%sOfdmInfo1.txt',filepath),'r');
    nfft = fscanf(file,"%d,",1);% Size of FFT,number of subcarriers in OFDM
    BW = fscanf(file,"%lf,",1); BW = BW*1000;% Bandwidth = complex FS
    cp_len = fscanf(file, "%d,", 1);        % Cyclic Prefix length in samp
    M = fscanf(file,"%d,", 1);              % Modulation Order
    ZP_density = fscanf(file,"%d,", 1);     % Zero Padded Pilot Density
    symbol_guard_ms = fscanf(file,"%d,",1); % Symbol guard band in ms
    frame_guard_ms = fscanf(file,"%d,",1);  % Frame guard band in ms
    ofdm_symbols = fscanf(file,"%d,",1);    % Num of OFDMsymbols in a Frame
    Fc = fscanf(file,"%d,",1); Fc = Fc * 1000;% Center frequency of OFDMsig
    tx_scale = fscanf(file,"%d,",1);        % Frequency domain digital gain
    ifft_gain = fscanf(file,"%f,",1);       % Ifft scalar gain
    extra_sync_gain = fscanf(file,"%f",1);  % Extra Sync Symbol gain
    fclose('all');
else
    nfft = 8196;
    BW = 100000;
    cp_len = 256;
    M = 16;
    ZP_density = 30;
    symbol_guard_ms = 6;
    frame_guard_ms = 0;
    ofdm_symbols = 4;
    Fc = 100000;
    tx_scale = 10386;
    ifft_gain = 4.402506;
    extra_sync_gain = 9.616123;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MATLAB simulated UW-A Channel settings
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
snr_db = 300;                    % Signal-to-Noise ratio in dB
multipath = 1;                  % Model channel with FIR taps
multipath = [0 0.1 0.9 0 0 0.5 0.5 0 0 0.2];
speed = 0;                      % Speed difference between TX/RX in m/s
cfo = -2;                        % Carrier Frequency Offset (HW impairment)
spo = pi/3;                        % Sample Phase Offset 
sro = 2;                       % Sample rate offset (in parts per million)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fixed Values
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nfft_zc = 4096;                       % NFFT for Zadoff-Chu sequence
ZC_root = 13;                         % Zadoff-Chu root index
ZC_length = nfft_zc/2;                % Zadoff-Chu Sequence Length
doppler_cp_offset = round(cp_len/16); % Num of CP samples*2 to not use
matlab_sync_samples_early = 50;      % Num of samples to synchronize early
pilot_density = 0.5;                  % Pilot to data ratio
DAC_FS = 40000000;                    % Dac sample rate
ADC_FS = 40000000;                    % ADC sample rate
nfft_p = 32*nfft;                     % NFFT for plotting spectrum
speed_sound = 1500;                   % Speed of sound underwater
duc_ddc_loss_gain = 2;                % Loss of Matlab DUC
num_bits = 14;                        % Number of bits in a sample
cic_scale = 50;                       % Scaling of CIC
num_fir_taps = 4096;                  % Number of FIR taps for DUC/DDC
symbol_plot = ofdm_symbols;           % Set number of Symbols to plot
gp_samples = round(symbol_guard_ms / 1000 * BW);

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
DAC_FS_sro = DAC_FS + DAC_FS*(-sro*10e-6);

fir_taps = fir1(num_fir_taps,1/(DAC_FS/Fs));
fir_taps = fir_taps / sqrt(sum(fir_taps.^2));
filter_delay = floor(length(fir_taps)/2);

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
ofdm_tx_signal_ser = [sync_tx_time.'; ...
    zeros(cp_len,1);gp;ofdm_tx_signal_ser]; % OFDM Frame

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DUC
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
up_signal = upsample(ofdm_tx_signal_ser, Interp_val);
up_signal = [up_signal;zeros(filter_delay,1)];
ofdm_duc_signal = filter(fir_taps, 1, up_signal).'*7;
ofdm_duc_signal(1:filter_delay) = [];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% IQ Mixer TX
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Use oscillator at Fc for IQ mixer
t_up = 0:1/DAC_FS:length(ofdm_duc_signal)/DAC_FS-1/DAC_FS;
if SRO_CHANNEL
    t_up_sro = 0:1/DAC_FS_sro:length(ofdm_duc_signal)/DAC_FS_sro-1/...
        DAC_FS_sro;
    ofdm_duc_signal_i = real(ofdm_duc_signal) .* cos(2*pi*Fc*t_up_sro);
    ofdm_duc_signal_q = imag(ofdm_duc_signal) .* -sin(2*pi*Fc*t_up_sro);
else
    ofdm_duc_signal_i = real(ofdm_duc_signal) .* cos(2*pi*Fc*t_up);
    ofdm_duc_signal_q = imag(ofdm_duc_signal) .* -sin(2*pi*Fc*t_up);
end
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

% Doppler
k = (1+speed/speed_sound); % Doppler shift factor
ofdm_tx_signal_doppler =interp1(t_up,ofdm_tx_signal_ch,t_up/k, ...
    doppler_ch_interp_method,0);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% IQ Mixer RX
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% AWGN Channel
i_ddc = ofdm_tx_signal_ch .* cos(2*pi*Fc*t_up);
q_ddc = ofdm_tx_signal_ch .* -sin(2*pi*Fc*t_up);
ddc_signal = complex(i_ddc,q_ddc);

% MATLAB UW-A Simulated Channel
i_ddc_doppler = ofdm_tx_signal_doppler .* cos(2*pi*Fc*t_up);
q_ddc_doppler = ofdm_tx_signal_doppler .* -sin(2*pi*Fc*t_up);
ddc_signal_doppler = complex(i_ddc_doppler,q_ddc_doppler);

%%%%% Additional Channel Impairments %%%%%
% Apply Carrier Frequency Offset
ddc_signal_doppler = ddc_signal_doppler .* exp(1i*2*pi*cfo*t_up);
% Apply Sample Phase Offset
ddc_signal_doppler = ddc_signal_doppler .* exp(1i*spo);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DDC
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% AWGN Channel
ddc_stage2 = [ddc_signal zeros(1,filter_delay)];
ddc_stage2_out = filter(fir_taps,1,ddc_stage2);
ddc_stage2_out(1:filter_delay) = [];
ddc_base_signal = downsample(ddc_stage2_out,Interp_val)/7.2;

% MATLAB UW-A Simulated Channel
ddc_doppler_real = ...
    decimate(real(ddc_signal_doppler),Interp_val,4096,'Fir');
ddc_doppler_imag = ...
    decimate(imag(ddc_signal_doppler),Interp_val,4096,'Fir');
ddc_doppler = complex(ddc_doppler_real,ddc_doppler_imag);
ddc_doppler = duc_ddc_loss_gain * ddc_doppler.';

%%%%% Additional Channel Impairments %%%%%
% Multipath
ddc_doppler = filter(multipath,1,ddc_doppler);
% AWGN at baseband
if BASEBAND_AWGN
    ddc_doppler_pwr = mean(abs(ddc_doppler).^2);
    noise_pwr = ddc_doppler_pwr / snr;
    noise = sqrt(noise_pwr) .* randn(size(ddc_doppler));
    ddc_doppler = ddc_doppler + noise;
end

%%%%% Read DDC/syncronizer output or FFT Input from MODEM SW %%%%%
if MODEM_ANALYSIS
    file = fopen(sprintf('%sRxFftSamples1.txt',filepath),'r');
    fft_sw = fscanf(file,"%d, %d\n", [2 ofdm_symbols*(cp_len+nfft)]);
    fclose('all');
    fft_sw = complex(fft_sw(1,:),fft_sw(2,:));
    fft_sw = reshape(fft_sw, [nfft+cp_len ofdm_symbols]);
    gp = zeros(gp_samples,ofdm_symbols);   
    fft_sw = vertcat(fft_sw,gp);
    fft_sw = reshape(fft_sw, [(nfft+cp_len+length(gp))*ofdm_symbols 1]);
    fft_sw1 = fft_sw;
    fft_sw = [zeros(nfft_zc+cp_len+gp_samples,1);fft_sw];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Synchronization
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% AWGN Channel
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

% MATLAB UW-A Simulated Channel
sync_corr_doppler = abs(filter(sync_coef,1,ddc_doppler));
[val2,ind2] = max(sync_corr_doppler);
ind2 = ind2-matlab_sync_samples_early+gp_samples+cp_len;
ofdm_rx_sync_doppler = ddc_doppler;
ofdm_rx_sync_doppler([1:ind2, ...
    ind2+1+(nfft+cp_len+gp_samples)*ofdm_symbols:end]) = [];
if (length(ofdm_rx_sync_doppler) ~= (nfft+cp_len+gp_samples)*ofdm_symbols)
    tmp = zeros(1,(nfft+cp_len+gp_samples)*ofdm_symbols- ...
        length(ofdm_rx_sync_doppler)).';
    ofdm_rx_sync_doppler = [ofdm_rx_sync_doppler;tmp];
    warning('Deleted too much of MATLAB UW-A Simulated signal')
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
% AWGN Channel
ofdm_rx_signal_par=reshape(ofdm_rx_sync_signal, ...
    [nfft+cp_len+gp_samples ofdm_symbols]);

% MATLAB UW-A Simulated Channel or Modem Channel
if MODEM_ANALYSIS
    ofdm_rx_doppler_par = reshape(fft_sw1, [nfft+cp_len+gp_samples ...
        ofdm_symbols]);
else
    ofdm_rx_doppler_par=reshape(ofdm_rx_sync_doppler, ...
        [nfft+cp_len+gp_samples ofdm_symbols]);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Doppler Processing
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if DOPPLER_PROC
    % Use ideal/actual doppler shift value instead of estimate
    if DOPPLER_IDEAL
        k_est = k;
    else
        k_est = k;
    end
    P = round(DAC_FS/k_est/Interp_val); Q = round(DAC_FS/Interp_val);
    if P*Q > 2^31
        re_scale = 2^31/(P*Q)
        P = floor(P*sqrt(re_scale));Q = floor(Q*sqrt(re_scale));
        warning('Re-Scalded down P/Q')
    else
        re_scale = 2^31/(P*Q)
        P = floor(P*sqrt(re_scale)); Q = floor(Q*sqrt(re_scale));
        warning('Re-Scaled up P/Q')
    end
    P_actual = DAC_FS/k/Interp_val; Q_actual = DAC_FS/Interp_val;
    ratio_actual = Q_actual/P_actual;
    P_est = P; Q_est = Q; ratio_est = Q/P;
    table(k,k_est)
    table(P_actual, Q_actual, ratio_actual)
    table(P_est, Q_est, ratio_est, k)

    if MODEM_ANALYSIS
        %%%%% DUC %%%%%
        up_signal_rx = upsample(fft_sw, Interp_val);
        up_signal_rx = [up_signal_rx;zeros(filter_delay,1)];
        ofdm_duc_signal_rx = filter(fir_taps,1,up_signal_rx).'*7;
        ofdm_duc_signal_rx(1:filter_delay) = [];

        %%%%% IQ Mixer TX %%%%%
        ofdm_duc_signal_rx_i=real(ofdm_duc_signal_rx).* cos(2*pi*Fc*t_up);
        ofdm_duc_signal_rx_q=imag(ofdm_duc_signal_rx).*-sin(2*pi*Fc*t_up);
        ofdm_duc_signal_rx_real =ofdm_duc_signal_rx_i+ofdm_duc_signal_rx_q;

        ofdm_tx_signal_doppler = ofdm_duc_signal_rx_real;
    end

    %%%%% IQ Mixer RX %%%%% 
    Fc_comp = Fc/k_est;
    i_ddc_doppler = ofdm_tx_signal_doppler .* cos(2*pi*Fc_comp*t_up);
    q_ddc_doppler = ofdm_tx_signal_doppler .*-sin(2*pi*Fc_comp*t_up);
    ddc_signal_doppler = complex(i_ddc_doppler,q_ddc_doppler);

    if ~MODEM_ANALYSIS
        %%%%% Additional Channel Impairments %%%%%
        % Apply Carrier Frequency Offset
        ddc_signal_doppler = ddc_signal_doppler .* exp(1i*2*pi*cfo*t_up);
        % Apply Sample Phase Offset
        ddc_signal_doppler = ddc_signal_doppler .* exp(1i*spo);
    end

    %%%%% DDC %%%%%
    ddc_doppler_real = ...
        decimate(real(ddc_signal_doppler),Interp_val,4096,'Fir');
    ddc_doppler_imag = ...
        decimate(imag(ddc_signal_doppler),Interp_val,4096,'Fir');
    ddc_doppler = complex(ddc_doppler_real,ddc_doppler_imag);
    ddc_doppler = duc_ddc_loss_gain * ddc_doppler.';

    if ~MODEM_ANALYSIS
        %%%%% Additional Channel Impairments %%%%%
        % Multipath
        ddc_doppler = filter(multipath,1,ddc_doppler);
        % AWGN at baseband
        if BASEBAND_AWGN
            ddc_doppler_pwr = mean(abs(ddc_doppler).^2);
            noise_pwr = ddc_doppler_pwr / snr;
            noise = sqrt(noise_pwr) .* randn(size(ddc_doppler));
            ddc_doppler = ddc_doppler + noise;
        end
    end
    
    %%%%% Resample %%%%%
    ddc_doppler_comp = resample(ddc_doppler,P,Q);
    if (length(ddc_doppler_comp) > length(ddc_doppler))
        ddc_doppler = ddc_doppler_comp(1:length(ddc_doppler));
        warning('Removing extra samples after baseband re-sampler')
    elseif (length(ddc_doppler_comp) < length(ddc_doppler))
        ddc_doppler = [ddc_doppler_comp.' zeros(1, ...
            length(ddc_doppler) - length(ddc_doppler_comp))].';
        warning('Adding extra zeros after baseband re-sampler')
    end

    if ~MODEM_ANALYSIS
        %%%%% Synchronization %%%%%
        sync_corr_doppler2 = abs(filter(sync_coef,1,ddc_doppler));
        [val3,ind3] = max(sync_corr_doppler2);
        ind3 = ind3-matlab_sync_samples_early+gp_samples+cp_len;
        ofdm_rx_sync_doppler2 = ddc_doppler;
        ofdm_rx_sync_doppler2([1:ind3, ...
            ind3+1+(nfft+cp_len+gp_samples)*ofdm_symbols:end]) = [];
        if (length(ofdm_rx_sync_doppler2)~=...
                (nfft+cp_len+gp_samples)*ofdm_symbols)
            tmp = zeros(1,(nfft+cp_len+gp_samples)*ofdm_symbols-...
                length(ofdm_rx_sync_doppler2)).';
            ofdm_rx_sync_doppler2 = [ofdm_rx_sync_doppler2;tmp];
            warning('Deleted too much of Doppler Resampled signal')
        end
        doppler2_sync_offset = (ind3-gp_samples)-(ind-gp_samples);
        display(doppler_sync_offset)

        %%%%% Serial to Parallel %%%%%
        ofdm_rx_doppler_par = reshape(ofdm_rx_sync_doppler2, ...
            [nfft+cp_len+gp_samples ofdm_symbols]);
    else
        fft_sw1_resamp = ddc_doppler;
        fft_sw1_resamp(1:nfft_zc+cp_len+gp_samples) = [];
        ofdm_rx_doppler_par = reshape(fft_sw1_resamp, ...
            [nfft+cp_len+gp_samples ofdm_symbols]);
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Remove Cyclic Prefix and Guard Period
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% AWGN Channel
ofdm_rx_signal_par(end-gp_samples+1:end,:) = []; % Remove GP
ofdm_cfo_signal = ofdm_rx_signal_par;
ofdm_cfo_signal(1:cp_len,:) = []; % Remove CP;

% UW-A Channel
ofdm_rx_doppler_par(end-gp_samples+1:end,:) = []; % Remove GP
ofdm_cfo_doppler2 = ofdm_rx_doppler_par;
ofdm_cfo_doppler2(1:cp_len,:) = []; % Remove CP

%%%%% CFO Estimation %%%%%
if CFO_COMP
    t = 0:Ts:length(ddc_base_signal)*Ts-Ts;
    cfo_est = zeros(1,ofdm_symbols);
    cfo_est_doppler = zeros(1,ofdm_symbols);
    for i=1:ofdm_symbols
        cp_cfo_begin = ofdm_rx_doppler_par(doppler_cp_offset+1:cp_len- ...
            doppler_cp_offset,i); % Obtain CP at beginning of symbol
        cp_cfo_end = ofdm_rx_doppler_par(nfft+1+doppler_cp_offset: ...
            end-doppler_cp_offset,i); % Obtain CP at end of symbol
        tmp = cp_cfo_end .* conj(cp_cfo_begin); % Correlate
        sum_val = sum(tmp);
        tan_val = atan2(imag(sum_val),real(sum_val));
        normalized_cfo_est = 1*tan_val;
        cfo_est_val(i) = normalized_cfo_est*scs;
        if CFO_IDEAL
            cfo_est_val(i) = cfo*2*pi;
        end
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
            ofdm_cfo_doppler2(K,i)=ofdm_cfo_doppler2(K,i).*conj(cos(...
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
% AWGN Channel
fft_signal = zeros(nfft,ofdm_symbols);
for i = 1:ofdm_symbols % Do FFTSHIFT per symbol
    fft_signal(:,i) = fftshift(fft(ofdm_cfo_signal(:,i),nfft));
end

% UW-A Channel
fft_doppler2 = zeros(nfft,ofdm_symbols);
for i = 1:ofdm_symbols
    fft_doppler2(:,i) = fftshift(fft(ofdm_cfo_doppler2(:,i),nfft));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Channel Estimation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% UW-A Channel
fft_doppler_eq2 = fft_doppler2;

%%%%% Extract pilot sub-carriers %%%%%
P_RX_doppler = fft_doppler_eq2(pilot_index(:,1),:);

%%%%% Get LS Channel Estimate %%%%%
H = conj(P_RX_doppler) ./ conj(reference_pilot);

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
    fft_doppler_eq2 = fft_doppler_eq2 .* TA_comp;
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
    fft_doppler_eq2 = fft_doppler_eq2 .* exp(-1i*phase_sym_rot);
end

%%%%% Interpolate estimates at pilots to all sub-carriers %%%%%
H_interp_doppler = interp1(pilot_index(:,1), H, 1:nfft, interp_method, ...
    "extrap");

%%%%% Average all CH estimates in an OFDM frame
if CH_EST_METHOD == "LS Averaged"
    if TEMPORAL_SMOOTHING
        H_interp_doppler_filt = H_interp_doppler;
        w_default = linspace(2,1,ofdm_symbols);
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
H_ideal_doppler = conj(fft_doppler_eq2) ./ conj(carriers/tx_scale);
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
% AWGN Channel
fft_signal_awgn = fft_signal;
fft_signal_awgn([pilot_index(:,1);zp_index(:,1)],:) = [];

% UW-A Channel
Z_EQ_ZF = fft_doppler_eq2 ./ conj(H_interp_doppler);
Z_EQ_ZF([pilot_index(:,1);zp_index(:,1)],:) = [];

%%%%% Scatter Plot %%%%%
lim = sqrt(2*M) + 1; y_lim = [-lim lim]; x_lim = [-lim lim];
ideal_scatter = qammod(0:M-1,M);
figure(),scatter(real(fft_signal_awgn),imag(fft_signal_awgn),'.'),grid on
if PLOT_IDEAL
    hold on,scatter(real(ideal_scatter),imag(ideal_scatter),300,'c','x',...
        'LineWidth',3)
end
title({[num2str(snr_db),'dB AWGN Channel'],'No Equalization'}),ylim(y_lim)
xlim(x_lim),figure(),scatter(real(Z_EQ_ZF),imag(Z_EQ_ZF),'.'),grid on
if PLOT_IDEAL
    hold on,scatter(real(ideal_scatter),imag(ideal_scatter),300,'c','x',...
        'LineWidth',3)
end
title({'UW-A Channel','Equalized'}),ylim(y_lim),xlim(x_lim)

%%%%% Loop through each OFDM symbol, plot constellation %%%%%
symbol = 4;
for i=1:symbol
    figure(),scatter(real(Z_EQ_ZF(:,i)),imag(Z_EQ_ZF(:,i)),'.')
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

figure(),subplot(2,1,1),bar(y1,carriers_plot),ax=gca;ax.YLim=y_lim;
xlabel('Sub-Carriers'),ylabel('%')
title({'UW-A Channel','Averaged Across Sub-Carriers'}),subplot(2,1,2)
bar(y_ofdm,evm_ofdm),ax=gca;ax.YLim=y_lim;xlabel('OFDM_Symbols')
ylabel('%'),title({'UW-A Channel','Averaged Across OFDM Symbols'})
sgtitle('EVM')