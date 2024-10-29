clear; clc; close all; fclose('all');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Settings
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Add AWGN at baseband else add AWGN at passband
    BASEBAND_AWGN = true;
% Bypass DUC/DDC and add doppler channel at baseband
    BASEBAND_DOPPLER = true;
% Bypass DUC/DDC 
    BASEBAND_LOOPBACK = true;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% OTFS Parameters
%   MxN 2D transmit data grid representing the delay-Doppler domain
%   k is the delay axis index,   k = 0,1,...,M-1 and 
%   l is the Doppler axis index, l = 0,1,...,N-1
%   df is the subcarrier spacing in Hz
%   T is the duration of an OTFS sybsymbol in s including CP
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
M = 64;       % Similar to nfft in OFDM
cp_len = 0;
Mod_Order = 4;% QAM Modulation order
fc = 5e9;  % Center Frequency
%BW = 250000; % Set the Bandwidth and calculate the frequency bin spacing
%df = BW/M;

df = 15e3;    % Set frequency bin spacing and calculate bandwidth
BW = M*df;

% Set guard period in ms, then calculated guard period samples
% sub_symbol_guard_ms = 1;    % Guard period between OTFS sub-symbols
% padLen = round(sub_symbol_guard_ms / 1000 * BW);

% Set guard period in samples, then calculate guard period in ms
padLen = 10;
sub_symbol_guard_ms = padLen*1000/BW;

otfs_sub_symbols = 30; % Number of OTFS subsymbols per frame

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fixed Values
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
snr_db = 40;
DAC_FS = 100000000;                   % Dac sample rate
ADC_FS = 40000000;                    % ADC sample rate
nfft_p = 32*M;                        % NFFT for plotting spectrum
speed_sound = 1500;                   % Speed of sound underwater
num_fir_taps = 4096;                  % DUC/DDC FIR Filter taps

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculated OTFS Parameters 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Fs = BW;                            % Sampling frequency
Ts = 1/BW;                          % Sampling period
Interp_val = round(DAC_FS/Fs);             % Interpolation factor
DAC_FS = Interp_val * Fs;
Ts_up = 1/DAC_FS;                   % Sampling period at paddband
pilotBin=floor(otfs_sub_symbols/2)+1;% Populated bin in pilot OTFS symbol
Meff = M + padLen;                  % Number of samp per OTFS sub symbol
numSamps = Meff * otfs_sub_symbols; % Number of samp per OTFS symbol
t = Meff/BW;                        % symbol time (seconds)

% DUC FIR Filter Taps
fir_taps = fir1(num_fir_taps,1/(DAC_FS/Fs));
fir_taps = fir_taps / sqrt(sum(fir_taps.^2));
filter_delay = floor(length(fir_taps)/2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Generate Pilot Data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
rng default
%pilot_data = randsrc(M,otfs_sub_symbols,0:Mod_Order-1);
pilot_data = zeros(M,otfs_sub_symbols);
pilot_data(1,pilotBin) = exp(1i*pi/4);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Generate Message Data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
rng default
tx_data = randsrc(M,otfs_sub_symbols,0:Mod_Order-1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% QAM Modulation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
qam_mod_data = qammod(tx_data,Mod_Order);
reference_pilot = pilot_data;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Synchronization   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Carrier Allocation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Inverse Zak transform
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
otfs_data_signal = ifft(qam_mod_data.').' / M;
otfs_pilot_signal = ifft(reference_pilot.').' / M;

% Normalize
otfs_data_signal2 = otfs_data_signal;
otfs_pilot_signal2 = otfs_pilot_signal;
%otfs_data_signal = otfs_data_signal ./ max(abs(otfs_data_signal));
%otfs_pilot_signal = otfs_pilot_signal ./ max(abs(otfs_pilot_signal));

figure(),subplot(2,1,1),plot(real(otfs_data_signal(:,1))),xlabel('Samples')
title('In-Phase'),subplot(2,1,2),plot(imag(otfs_data_signal(:,1)))
xlabel('Samples'),title('Quadrature'),sgtitle('Baseband OTFS Signal Sym 1')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CP Insertion
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cp_start = M-cp_len+1;
otfs_data_signal_cp = [otfs_data_signal(cp_start:end,:); otfs_data_signal];
otfs_pilot_signal_cp=[otfs_pilot_signal(cp_start:end,:);otfs_pilot_signal];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GP Insertion2)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
otfs_data_signal_gp =[otfs_data_signal_cp; zeros(padLen, ...
    otfs_sub_symbols)];
otfs_pilot_signal_gp=[otfs_pilot_signal_cp;zeros(padLen, ...
    otfs_sub_symbols)];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Parallel to Serial
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
otfs_data_signal_ser = otfs_data_signal_gp(:);
otfs_pilot_signal_ser = otfs_pilot_signal_gp(:);

figure(),subplot(2,1,1),plot(real(otfs_data_signal_ser)),xlabel('Samples')
title('In-Phase'),subplot(2,1,2),plot(imag(otfs_data_signal_ser))
xlabel('Samples'),title('Quadrature'),sgtitle('Baseband OTFS Signal')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DUC
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
up_signal = upsample(otfs_data_signal_ser, Interp_val);
up_signal = [up_signal;zeros(filter_delay,1)];
otfs_duc_signal = filter(fir_taps, 1, up_signal).';
otfs_duc_signal(1:filter_delay) = [];

up_pilot_signal = upsample(otfs_pilot_signal_ser, Interp_val);
up_pilot_signal = [up_pilot_signal;zeros(filter_delay,1)];
otfs_duc_pilot = filter(fir_taps, 1, up_pilot_signal).';
otfs_duc_pilot(1:filter_delay) = [];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% IQ Mixer TX
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
t_up = 0:1/DAC_FS:length(otfs_duc_signal)/DAC_FS-1/DAC_FS;
otfs_duc_signal_i = real(otfs_duc_signal) .* cos(2*pi*fc*t_up);
otfs_duc_signal_q = imag(otfs_duc_signal) .*-sin(2*pi*fc*t_up);
otfs_duc_signal_real = otfs_duc_signal_i + otfs_duc_signal_q;

otfs_duc_pilot_i = real(otfs_duc_pilot) .* cos(2*pi*fc*t_up);
otfs_duc_pilot_q = imag(otfs_duc_pilot) .* cos(2*pi*fc*t_up);
otfs_duc_pilot_real = otfs_duc_signal_i + otfs_duc_signal_q;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Channel
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
snr = 10^(snr_db/10);
if ~BASEBAND_AWGN
    otfs_tx_signal_ch_pwr = mean(abs(otfs_duc_signal_real).^2);
    noise_pwr = otfs_tx_signal_ch_pwr / snr;
    noise = sqrt(noise_pwr) .* randn(size(otfs_duc_signal_real));
    otfs_signal_ch = otfs_duc_signal_real + noise;

    otfs_tx_pilot_ch_pwr = mean(abs(otfs_duc_pilot_real).^2);
    noise_pwr = otfs_tx_pilot_ch_pwr / snr;
    noise = sqrt(noise_pwr) .* randn(size(otfs_duc_pilot_real));
    otfs_pilot_ch = otfs_duc_pilot_real + noise;
else
    otfs_signal_ch = otfs_duc_signal_real;
    otfs_pilot_ch = otfs_duc_pilot_real;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% IQ Mixer RX
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_ddc = otfs_signal_ch .* cos(2*pi*fc*t_up);
q_ddc = otfs_signal_ch .*-sin(2*pi*fc*t_up);
ddc_signal = complex(i_ddc,q_ddc);

i_ddc_pilot = otfs_signal_ch .* cos(2*pi*fc*t_up);
q_ddc_pilot = otfs_signal_ch .*-sin(2*pi*fc*t_up);
ddc_pilot = complex(i_ddc_pilot,q_ddc_pilot);

%%%%% Additional Channel Impairments %%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DDC
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ddc_signal1 = [ddc_signal zeros(1,filter_delay)];
ddc_signal2 = filter(fir_taps, 1, ddc_signal1);
ddc_signal2(1:filter_delay) = [];
otfs_data_ddc_ser = downsample(ddc_signal2, Interp_val) * 2;

ddc_pilot1 = [ddc_pilot zeros(1,filter_delay)];
ddc_pilot2 = filter(fir_taps, 1, ddc_pilot1);
ddc_pilot2(1:filter_delay) = [];
otfs_pilot_ddc_ser = downsample(ddc_pilot2,Interp_val) * 2;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Baseband Channel
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Configure paths
chanParams.pathDelays   = [0  5   8  ]; % num of samp that path is delayed
chanParams.pathGains    = [1  0.7 0.5]; % complex path gain
chanParams.pathDopplers = [0 -3   5  ]; % Doppler ind as a mult of fsamp/MN

% Calculate the actual Doppler frequencies from the Doppler indices
chanParams.pathDopplerFreqs = chanParams.pathDopplers * ...
    1/(otfs_sub_symbols*t); % Hz

% Send the baseband OTFS pilot and data symbol through the doppler channel
base_doppler_pilot = dopplerChannel(otfs_pilot_signal_ser,BW,chanParams);
base_doppler_data  = dopplerChannel(otfs_data_signal_ser, BW,chanParams);

if BASEBAND_DOPPLER
    otfs_pilot_signal_ser = base_doppler_pilot(1:numSamps);
    otfs_data_signal_ser  = base_doppler_data(1:numSamps);
    for k = 1:length(chanParams.pathDelays)
        fprintf('Scatterer %d\n',k);
        fprintf('\tDelay = %5.2f us\n',1e6*chanParams.pathDelays(k)/ ...
            (Meff*df));
        fprintf('\tRelative Doppler shift = %5.0f Hz (%5.0f km/h)\n', ...
            chanParams.pathDopplerFreqs(k), (physconst('LightSpeed')*...
            chanParams.pathDopplerFreqs(k)/fc)*(3600/1000));
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Serial to Parallel on Pilot
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if BASEBAND_LOOPBACK
    if BASEBAND_AWGN
        ddc_doppler_pwr = mean(abs(otfs_data_signal_ser).^2);
        noise_pwr = ddc_doppler_pwr / snr;
        noise = sqrt(noise_pwr) .* randn(size(otfs_data_signal_ser));
        otfs_data_signal_ser = otfs_data_signal_ser + noise;
    end
    otfs_rx_signal_gp = reshape(otfs_data_signal_ser, [M+cp_len+ ...
        padLen otfs_sub_symbols]);
    otfs_rx_pilot_gp = reshape(otfs_pilot_signal_ser, [M+cp_len+padLen ...
        otfs_sub_symbols]);
else
    otfs_data_signal_ser = otfs_data_ddc_ser.';
    otfs_rx_signal_gp = reshape(otfs_data_ddc_ser.', [M+cp_len+padLen ...
        otfs_sub_symbols]);
    otfs_rx_pilot_gp = reshape(otfs_pilot_ddc_ser.', [M+cp_len+padLen ...
        otfs_sub_symbols]);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GP Removal on Pilot
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
otfs_rx_pilot_cp = otfs_rx_pilot_gp(1:cp_len+M,:);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CP Removal on Pilot
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
otfs_rx_pilot = otfs_rx_pilot_cp(cp_len+1:end,:);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Inverse ZAK transform on Pilot
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%otfs_rx_pilot = otfs_rx_pilot .*  max(abs(otfs_pilot_signal2));
qam_pilot_demod = fft(otfs_rx_pilot.').' * M;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Channel Estimate
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Es = mean(abs(qammod(0:Mod_Order-1,Mod_Order).^2));
n0 = Es/(10^(snr_db/10));
pilot_locations = numel(reference_pilot);

Ydd = qam_pilot_demod;
Pdd = reference_pilot;
Hdd = Ydd * conj(Pdd(1, pilotBin)) / (abs(Pdd(1,pilotBin))^2 + n0);
%Hofdm = conj(Hofdm) .* Ydd ./ (abs(Hofdm).^2 + n0);

[lp,vp] = find(abs(Hdd) >= 0.05);
chanEst.pathGains = diag(Hdd(lp,vp));
chanEst.pathDelays = lp-1;
chanEst.pathDopplers = vp-pilotBin;

G = getG(M,otfs_sub_symbols,chanEst,padLen,'ZP');
% Hdd = 0;
% for i=1:pilot_locations
%     Hdd = Hdd + Ydd * conj(Pdd(i)) / (abs(Pdd(i))^2 + n0);
% end
% Hdd = Hdd / pilot_locations;

xa = 0:1:otfs_sub_symbols-1;
ya = 0:1:M-1;
figure(),mesh(xa,ya,abs(Hdd))
title('Delay-Doppler Channel Response H_{dd} from Channel Sounding')
xlabel('Normalized Doppler');
ylabel('Normalized Delay');
zlabel('Magnitude');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Channel Equalization
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
y_otfs =((G'*G)+n0*eye(Meff*otfs_sub_symbols)) \ (G'*otfs_data_signal_ser);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GP Removal
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
otfs_rx_signal_cp = reshape(y_otfs, [M + padLen, otfs_sub_symbols]);
otfs_rx_signal_cp = otfs_rx_signal_cp(1:M,:);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CP Removal
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
otfs_rx_signal = otfs_rx_signal_cp(cp_len+1:end,:);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Inverse ZAK transform
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
qam_data_demod = fft(otfs_rx_signal.').' * M;

figure(),scatter(real(qam_data_demod),imag(qam_data_demod),'.')
title('Demodulated OTFS')

figure(),subplot(2,1,1),plot(real(otfs_data_signal2(:,1)),'LineWidth',2)
hold on,plot(real(otfs_rx_signal(:,1))),title('In-Phase'),xlabel('Samples')
legend('TX','RX'),subplot(2,1,2),plot(imag(otfs_data_signal2(:,1)),...
    'LineWidth',2),hold on
plot(imag(otfs_rx_signal(:,1))),title('Quadrature'),xlabel('Samples')
legend('TX','RX'),sgtitle('Baseband OTFS Signal, Symbol 1')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% QAM Demodulation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%demod_data = qamdemod(qam_data_demod,Mod_Order);
demod_data = qamdemod(qam_data_demod,Mod_Order);

% Symbol Error Rate
ser_data = symerr(tx_data,demod_data)/numel(tx_data);

% Get EVM measurements
evm = comm.EVM(AveragingDimensions=[1 2],MaximumEVMOutputPort=1);
[data_evm,data_evm_pk] = evm(qam_mod_data, qam_data_demod);

table(ser_data,data_evm,data_evm_pk)

%%%%% EVM Plots %%%%%
y_lim = [0 100]; y_otfs = 1:otfs_sub_symbols;
evm = comm.EVM(AveragingDimensions=1); y1=1:M;
evm_otfs = evm(qam_mod_data, qam_data_demod);
evm = comm.EVM(AveragingDimensions=2);
evm_doppler = evm(qam_mod_data, qam_data_demod);

figure(),subplot(2,1,1),bar(y1,evm_doppler)
xlabel('Delay'),ylabel('%'),title('Averaged Across Delay Axis')
subplot(2,1,2),bar(y_otfs,evm_otfs),xlabel('Doppler'),ylabel('%')
title('Averaged Across Doppler Axis'),sgtitle('EVM')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function y = dopplerChannel(x,fs,chanParams)
    % Form an output vector y comprising paths of x with different
    % delays, Dopplers, and complex gains
    numPaths = length(chanParams.pathDelays);
    maxPathDelay = max(chanParams.pathDelays);
    txOutSize = length(x);
    
    y = zeros(txOutSize+maxPathDelay,1);
    
    for k = 1:numPaths
        pathOut = zeros(txOutSize+maxPathDelay,1);

        % Doppler
        pathShift = frequencyOffset(x,fs,chanParams.pathDopplerFreqs(k));
    
        % Delay and gain
        pathOut(1+chanParams.pathDelays(k):chanParams.pathDelays(k)+txOutSize) = ...
            pathShift * chanParams.pathGains(k);
            
        y = y + pathOut;
    end
end
function G = getG(M,N,chanParams,padLen,padType)
    % Form time domain channel matrix from detected DD paths
    if strcmp(padType,'ZP') || strcmp(padType,'CP')
        Meff = M + padLen;  % account for subsymbol pad length in forming channel
        lmax = padLen;      % max delay
    else
        Meff = M;
        lmax = max(chanParams.pathDelays);  % max delay
    end
    MN = Meff*N;
    P = length(chanParams.pathDelays);  % number of paths
    if (P > 11)
        P = 11;
    end
    
    % Form an array of channel responses for each path
    g = zeros(lmax+1,MN);
    for p = 1:P
        gp = chanParams.pathGains(p);
        lp = chanParams.pathDelays(p);
        vp = chanParams.pathDopplers(p); 

        % For each DD path, compute the channel response.
        % Each path is a complex sinusoid at the Doppler frequency (kp)
        % shifted by a delay (lp) and scaled by the path gain (gp)
        g(lp+1,:) = g(lp+1,:) + gp*exp(1i*2*pi/MN * vp*((0:MN-1)-lp));
    end    

    % Form the MN-by-MN channel matrix G
    G = zeros(MN,MN);
    % Each DD path is a diagonal in G offset by its path delay l
    for l = unique(chanParams.pathDelays).'
        if (l > 10)
            break
        end
        l
        G = G + diag(g(l+1,l+1:end),-l);
    end
end