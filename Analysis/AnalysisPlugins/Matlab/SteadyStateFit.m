function [Synx,Freq,ROCOF] = SteadyStateFit ( ...
	SignalParams, ...
	DelayCorr, ...
	MagCorr, ...
	~, ...
	~, ...
	SampleRate, ...
	Samples ...
)

%******DEBUGGING******(alternativly: use PmuFitSave.m)********************
% name = fullfile(getenv('USERPROFILE'),'Documents','PMUCAL','Output','Saved4PFit.mat');
% if exist(name,'file')
%     A = open(name);
%     P = A.P;
%     clear A;
% else
%     P = struct('SignalParams', {}, 'DelayCorr', {}, 'MagCorr', {}, 'F0', {}, 'AnalysisCycles', {}, 'SampleRate', {}, 'Samples', {});
% end
% 
% n = length(P)+1;
% P(n).SignalParams = SignalParams;
% P(n).DelayCorr = DelayCorr;
% P(n).MagCorr = MagCorr;
% P(n).F0 = F0;
% P(n).AnalysisCycles = AnalysisCycles;
% P(n).SampleRate = SampleRate;
% P(n).Samples = Samples;
% 
% save(name,'P')
%*********************DEBUGGING*****************************************
% ARG: 2022/02/15:  Added support for Fourier series type signals

if SignalParams(4,1) >= 0       % check the delimiter is negative
    % This is a sum of sinewaves signal
    [~,F,~,Fi,~,Ki] = getParamVals(SignalParams);
    if ~(Ki(1)>0); Fi(1,:) = -1; end   % no interharmonics    
    [ Synx, Freqs, ROCOFs, iter, SynxH] = Fit4Param( F, 1/SampleRate, Samples', Fi);    
else
    % This is the classic PMU Calibration waveform type
    [Synx, Freqs, ROCOFs, iter, SynxH] =  Fit4PFourier( SignalParams, 1/SampleRate, Samples');
    
    % For delay corrections we need a vector of frequencies
    [~,F] = getParamVals(SignalParams);
    Ki = -1; %  so we don't get hugg up on the elseif statement    
end
if iter > 40
    warning ('4 parameter fit did not converge')
end


Ain = abs(Synx).*MagCorr;
Theta = angle(Synx)+ DelayCorr*1e-9*2*pi.*F;
Synx = (Ain/sqrt(2).*exp(-1i.*Theta)).';

%Calculating symmetrical components
nPhases = size(Synx,1);
if nPhases >= 3
    alfa = exp(2*pi*1i/3);
    Ai = (1/3)*[1 1 1; 1 alfa alfa^2; 1 alfa^2 alfa];
    
    Vabc = Synx(1:3,:);
    Vzpn = Ai*Vabc; %voltage: zero, positive and negative sequence
    vSynx = [ Vabc.' Vzpn(2)];    
    
    if nPhases >= 6
        Iabc = Synx(4:6,:);
        Izpn = Ai*Iabc; %curren: zero, positive and negative sequence
        Synx = [vSynx, Iabc.' Izpn(2)];
    end
end

if SignalParams(4,1) < 0
% For sum of waveforms, we will only be reporting the first phase of sinewaves  
    SineParams = SignalParams(5:end-1,1);
    SineParams = reshape(SineParams,[3,length(SineParams)/3]);
    F = SineParams(1,:);      
    Ain = abs(SynxH(:,1))*MagCorr(1);   % we only look at the first phase
    Theta = angle(SynxH(:,1))+ (DelayCorr(1)*1e-9*2*pi.*F)';
    SynxH = (Ain/sqrt(2).*exp(-1i.*Theta));
    Synx = horzcat(Synx, SynxH');    

%Harmonics or interharmonics are output to verify a calibrator
elseif Ki(1) > 0
    Ain = abs(SynxH).*MagCorr;
    Theta = angle(SynxH)+ DelayCorr*1e-9*2*pi.*F;
    SynxH = (Ain/sqrt(2).*exp(-1i.*Theta));
    Synx = horzcat(Synx, SynxH);    
end


Freq = mean(Freqs(1:3)); % average of the voltage frequencies 
ROCOF = mean(ROCOFs(1:3));
