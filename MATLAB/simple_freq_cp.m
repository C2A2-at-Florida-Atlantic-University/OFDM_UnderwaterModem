clear; clc; close all; fclose all; format long;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% OFDM Parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nfft = 512;
BW = 100000;
cp_carriers = 128;
M = 16;
pilot_density = 0.5;
ofdm_symbols = 3;
dopler_cp_offset = 0;
cp_len = 128;

snr_db = 15;
multipath = 1;
speed = -0.;
cfo = 0;
cpo = 0;
sync_offset = 0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculated OFDM Parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
rep = 1/pilot_density;
cp_index = 1:cp_carriers;
cp_index_end = nfft-cp_carriers+1:nfft;
pilot_index_cp = 1:rep:nfft;
if pilot_index_cp(end) ~= nfft
    pilot_index_cp = [pilot_index_cp nfft];
end
pilot_carriers_cp = length(pilot_index_cp);
data_index_cp = 1:nfft;
data_index_cp(pilot_index_cp) = [];
data_carriers_cp = length(data_index_cp);

pilot_index = 1:rep:nfft-cp_carriers;
if pilot_index(end) ~= nfft-cp_carriers
    pilot_index = [pilot_index nfft-cp_carriers];
end
pilot_carriers = length(pilot_index);
data_index = 1:nfft-cp_carriers;
data_index(pilot_index) = [];
data_carriers = length(data_index);
scs = BW/nfft;
Fs = BW;
Ts = 1/Fs;
T = 0:Ts:(nfft+cp_len)*ofdm_symbols*Ts-Ts;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Generate Pilot Data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
rng default
pilot_data = randsrc(pilot_carriers,ofdm_symbols,0:M-1);
pilot_data_cp = [pilot_data;pilot_data(1:cp_carriers/rep,:)];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Generate Message Data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
rng default
tx_data = randsrc(data_carriers,ofdm_symbols,0:M-1);
tx_data_cp = [tx_data;tx_data(1:cp_carriers/rep,:)];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% QAM Modulation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
qam_mod_data = qammod(tx_data,M);
qam_mod_data_cp = qammod(tx_data_cp,M);
reference_pilot = qammod(pilot_data,M);
reference_pilot_cp = qammod(pilot_data_cp,M);
zp_carrier = complex(0,0);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Carrier Allocation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
carriers = zeros(nfft,ofdm_symbols);
%carriers(pilot_index,:) = reference_pilot;
%carriers(data_index,:) = qam_mod_data;
carriers(pilot_index_cp,:) = reference_pilot_cp;
carriers(data_index_cp,:) = qam_mod_data_cp;
%cp_freq = carriers(1:cp_carriers,:);
%carriers(cp_index,:) = cp_freq;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% IFFT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Ifftshift to reorder carriers in correct order for IFFT
ifft_sub_carriers = zeros(nfft,ofdm_symbols);
for i = 1:ofdm_symbols % In loop so Ifftshift works per symbol
    ifft_sub_carriers(:,i) = ifft(ifftshift(carriers(:,i)),nfft);
end
cp_start = nfft-cp_len;
cp = ifft_sub_carriers(cp_start+1:end,:);
ifft_sub_carriers = vertcat(cp,ifft_sub_carriers);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Parallel to Serial
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ofdm_tx_signal_ser = reshape(ifft_sub_carriers,[(cp_len+nfft)*ofdm_symbols 1]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Channel
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
snr = 10^(snr_db/10);
ofdm_tx_signal_ch = awgn(ofdm_tx_signal_ser,snr,'measured');

k = (1+speed/1500);
ofdm_tx_signal_ch = filter(multipath,1,ofdm_tx_signal_ch);
ofdm_tx_signal_ch = interp1(T,ofdm_tx_signal_ch,T/k,'linear',0);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Serial to Parallel
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ofdm_rx_signal_par = reshape(ofdm_tx_signal_ch, [nfft+cp_len ofdm_symbols]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FFT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ofdm_rx_signal_par = [zeros(sync_offset,ofdm_symbols);
    ofdm_rx_signal_par(1:end-sync_offset,:)];
ofdm_rx_signal_par(1:cp_len,:) = [];
fft_signal = zeros(nfft,ofdm_symbols);
for i = 1:ofdm_symbols % Do FFTSHIFT per symbol
    fft_signal(:,i) = fftshift(fft(ofdm_rx_signal_par(:,i),nfft));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Channel Estimation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Get RX pilots
fft_signal_eq = fft_signal;
P_RX = fft_signal_eq(pilot_index_cp,:);
H = conj(P_RX) ./ conj(reference_pilot_cp);
H_interp = interp1(pilot_index_cp,H,1:nfft,'previous');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Channel Equalization
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Z_EQ_ZF = fft_signal_eq ./ conj(H_interp);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Frequency domain CP
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
freq_cp = Z_EQ_ZF(cp_index_end,:);
Z_EQ_ZF2 = Z_EQ_ZF;
fft_signal_cp = Z_EQ_ZF; cp_freq_domain = zeros(1,ofdm_symbols);
for i = 1:ofdm_symbols
    cp_begin =fft_signal_cp(pilot_index(1):pilot_index(1)+cp_carriers-1,i);
    cp_end = freq_cp(1:end,i);
    tmp = cp_begin .* conj(cp_end);
    tmp2 = mean(tmp);
    Z_EQ_ZF = Z_EQ_ZF ./ exp(1i*pi*angle(tmp2));
    %cp_freq_domain(i) = tan_val/2/pi;
end
%table(cp_freq_domain)
Z_EQ_ZF_CP = Z_EQ_ZF;

Z_EQ_ZF([cp_index_end,pilot_index],:) = [];
Z_EQ_ZF2([cp_index_end,pilot_index],:) = [];
fft_signal([cp_index_end,pilot_index],:) = [];
Z_EQ_ZF_CP(pilot_index_cp,:) = [];
figure(),subplot(2,2,1),scatter(real(Z_EQ_ZF),imag(Z_EQ_ZF),'.')
title('Data'),subplot(2,2,2),scatter(real(Z_EQ_ZF_CP), ...
    imag(Z_EQ_ZF_CP),'.'),title('Data + Data CP')
subplot(2,2,3),scatter(real(Z_EQ_ZF2),imag(Z_EQ_ZF2),'.')
title('Data no CP Processing'),subplot(2,2,4),scatter(real( ...
    fft_signal),imag(fft_signal),'.'),title('No Equalization')