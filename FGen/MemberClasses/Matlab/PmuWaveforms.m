% Generates multi=phase test signals for 60255.118.1 PMU testing
function [Signal,wfSize] = PmuWaveforms( ...
    t0, ...
    SettlingTime, ...
    sizeMax, ...
    FSamp, ...
    signalparams ...
    )


% For this signal, there may be multiple phases that can each be independent of the
% others (giving the ability to create unbalanced signals).  In the
% signalparms array, there is one column of parameters for each of
% the phases.


% t0 is an offset in seconds to the time vector.  For example, during a phase or 
% amplitude step, the step will occur at t = 0 so T0 may be set to -2 seconds.  
% The signal is phase shifted such that cos 0 occures after the initial settling time 
%
% SettlingTime in seconds will be applied to the beginning and end of the signal.  
% At the beginning it starts at negative time and the signal is phase shifted 
% such that cos 0 plus any phase shift occures at t = 0.  At the end it continues for SettlingTime.
%
% sizeMax:  in samples.  If SettlingTime = 0 and the signal is not a step, this produces the smallest signal (up to sizeMax) (in samples) that will allow a continuous reproduction without a discontinuity.  For stepsadn signals with settlingtime, the signal between the end of the initial and start of the final SettlingTime will be sizeMax samples long.


% signalparams  (Note that the labeling convention comes mostly from the standard)
    Xm = signalparams(1,:)*sqrt(2);     % phase amplitude (given by the user in RMS)
    Fin = signalparams(2,:);    % frequency (must be the same for all 6 channels or an error will be thrown
    Ps = signalparams(3,:);     % phase 
    Fh = signalparams(4,:);     % Frequency of the interfering signal
    Ph = signalparams(5,:);     % Phase of the interfering signal
    Kh = signalparams(6,:);     % index of the interfering signal    
    Fa = signalparams(7,:);     % phase (angle) moduation frequency
    Ka = signalparams(8,:);     % phase (angle) moduation index
    Fx = signalparams(9,:);     % amplitude moduation frequency
    Kx = signalparams(10,:);     % amplitude moduation index
    Rf = signalparams(11,:);     % ROCOF
    KaS = signalparams(12,:);   % phase (angle) step index
    KxS = signalparams(13,:);   % magnitude step index
    
    % ARG 20201226 added frequency and rocof step rows
    [r, c] = size(signalparams);
    KfS = zeros(1,c); KrS = KfS;
    if r > 13
        KfS = signalparams(14,:);
        KrS = signalparams(15,:);
    end
    
    % ARG 20220309 added band limited normally distributed noise
    Kn = zeros(1,c); Fn = Kn;
    if r > 15
        Kn = signalparams(16,:);
        Fn = signalparams(17,:);
    end 
    
    
   % ARG 20220306 adding the ability to create a signal from a set of individual sinewaves
   % If Fh is negative, then the signalparams will be sets of sine wave parameters as follows:
   %signalparams(4,:)  % all negatives
   %signalparams(5,:)  % second sine wave frequency
   %signalparams(6,:)  % second sine wave phase
   %signalparams(7,:)  % second sine wave index (fraction of Xm)
   ...
   %signalparams(5+n,:)  % nth sine wave frequency
   %signalparams(6+n,:)  % nth sine wave phase
   %signalparams(7+n,:)  % nth sine wave index (fraction of Xm)
   
   % ARG 20220312 changed the way frequency ramping works.  PAY ATTENTION
   % TO THE BELOW! Rf and KrS parameters set a frequency ramp rate.  Ramps
   % now ramp in one direction then return to the original frequency IF the
   % duration is long enough.  To set up the ramp duration, the combination
   % of sizeMax, SettlingTime, and t0 all need to be cooddinated as follows:
   %   First the frequency range over which to ramp must be determined.
   % Call this Fr.  Rf or Krs is the ramp rate, the settling time will be
   % the duration before the first ramp begins then the duration between
   % the first and second (returning) ramp.
   %    t0 is the duration of the ramping, it must be equal to the ramp
   % range divided by the ramp rate (t0 = Fr/Rf or Rf/KrS).
   %    sizeMax must be the number of samples of the ramping period and te
   % period between the two ramps and does not include the periods
   % before the first ramp and after the second ramp (those will be
   % SettlingTime in length).  So sizeMax equals (SettlingTime plus 2 times t0)
   % times the Sampling Rate: sizeMax = ((2*t0)+SettlingTime))*FSamp.

%%    
wfSize = sizeMax;    % this is the waveform NOT INCLUDING the settling time added to both ends

% If SettlingTime <= 0, and this is not a step test or ramp, then determine the
% sample size that gives an interger number of periods of the "combined"
% frequency of the fundamental and any added intefering frequency or 
% modulation that may be added. 

stepIdx = all([Rf; KaS; KxS; KfS; KrS]');
noSteps = all(stepIdx == 0);
Freqs = [Fin(1,1)];
if Kh(1) > 0; Freqs = [Freqs, Fh(1,1)]; end
if Ka(1) > 0; Freqs = [Freqs, Fa(1,1)]; end
if Kx(1) > 0; Freqs = [Freqs, Fx(1,1)]; end
    
if (SettlingTime <= 0 && noSteps)
    wfSize = SizeLcmPeriods(Freqs, FSamp);
    if wfSize > sizeMax; wfSize = sizeMax; end
end
       
% calculate the angular frequencies
Wf = 2*pi*Fin;  % fundamental frequency
Wa = 2*pi*Fa;   % phase (angle) modulation frequency
Wx = 2*pi*Fx;   % amplitude modulation frequency
Wh = 2*pi*Fh;   % single harmonic frequency

% create the time array.  Add the settling time to both ends of the size
t = -SettlingTime:1/FSamp:((wfSize-1)/FSamp)+SettlingTime;
nSamples = length(t);
nPhases = length(Xm);


% Amplitude, AM and magnitude step
Ain = zeros(nPhases,nSamples);
for i = 1:nPhases
    % Amplitudes and amplitude modulation if Kx>0
    Ain(i,:) = Xm(i) *(1+Kx(i)*cos((Wx(i)*t)));
    % Amplitude Step: applied after time passes t0
    Ain(i,(t >= t0)&(t <= SettlingTime+t0)) = Ain(i,(t >= t0)&(t <= SettlingTime+t0))* (1 + KxS(i));
end

% Phase
Theta = zeros(nPhases,nSamples);
for i = 1:nPhases
    Theta(i,:) = (Wf(i)*t) ...                         % Fundamental
                 + Ps(i)*(pi/180) ...               % phase shift
                 - ( ...                 
                    (Ka(i)*cos((Wa(i)*t)-pi)) ...     % Phase modulation
                  );
end

% Phase Step
if KaS(1) ~= 0
    for i = 1:nPhases
        %Theta(i,t >= (0+t0)) = Theta(i,t >= (0+t0)) + (KaS(i) * pi/180);
        %Theta(i,(t >= (SettlingTime))&(t <= (SettlingTime+t0))) = Theta(i,(t >= (0+SettlingTime))&(t <= (SettlingTime+t0))) + (KaS(i) * pi/180);
        Theta(i,(t >= t0)&(t <= SettlingTime+t0)) = Theta(i,(t >= t0)&(t <= SettlingTime+t0)) + (KaS(i) * pi/180);
    end
end


% frequency ramp
rampIdx = any([Rf; KrS]');
if ~(all(rampIdx == 0))
    if all(Rf == 0); Rf = KrS; end  % prefer Rf over KrS
    Wr = pi*Rf;
    for i = 1:nPhases
        if Rf(i)~=0
            % five phases of ramping:
            %   from -settlingTime to t=0: no ramp,
            %   from t=0 to t0: ramp at Rf,
            %   from t0 to SettlingTime: no ramp
            %   from SettlingTime+t0 to SettlingTime+2*t0: ramp at -Rf
            %   from SettlingTime+2*t0 to 2*(SettlingTime+t0): no ramp
                Theta(i,t>=0 & t<=t0) = Theta(i,t>=0 & t<=t0) + (Wr(i)*t(t>=0 & t<=t0).^2); % First ramping period    
                Theta(i,t>t0) = Theta(i,t>t0) + Wr(i)*( (t0^2) + 2*t0*(t(t>t0)-t0) );  % set the remaining to the new frequency
                Theta(i,t>=t0+SettlingTime & t<= 2*t0+SettlingTime) = Theta(i,t>=t0+SettlingTime & t<= 2*t0+SettlingTime) - (Wr(i)*(t(t>=t0+SettlingTime & t<= 2*t0+SettlingTime)-(t0+SettlingTime)).^2); %second ramping period
                Theta(i,t>2*t0+SettlingTime) = Theta(i,t>2*t0+SettlingTime) - Wr(i)*( t0^2 + 2*(t0)*(t(t>(2*t0+SettlingTime))-(2*t0+SettlingTime))); % final non-ramping period                
                                    
            %This ramps only in one direction
            %endRamp = (wfSize/FSamp);
            %Theta(i,t>=(0+t0) & t<=endRamp) = Theta(i,t>=(0+t0) & t<=endRamp) + (pi*Rf(i)*t(t>=(0+t0) & t<=endRamp).^2);
            %Theta(i,t>(endRamp+t0)) = Theta(i,t>(endRamp+t0)) + (pi*Rf(i)*((endRamp+t0)^2)*t(t>(endRamp+t0))) + (pi*Rf(i))*(t(t>(endRamp+t0))-(endRamp+t0));
            
%           %==================== DEBUG Gradient Plot =====================
%           plot(t,gradient(Theta(i,:)*FSamp/(2*pi)))
%           % =============================================================
            
        end
    end
end

% frequency step
if ~(all(KfS == 0))
    for i = 1:nPhases
        if ~(KxS(i) == -1.0)
            %Theta(i,t>=(0+t0)) = Theta(i,t>=(0+t0)) + ((2*pi*KfS(i))*(t(t>=(0+t0))-t0));
            Theta(i,(t >= t0)&(t <= SettlingTime+t0)) = Theta(i,(t >= t0)&(t <= SettlingTime+t0)) + ((2*pi*KfS(i))*(t(t>=(0+t0))-t0));
        else
            % ARG 03/04/2022: Special test for frequency drop and restoration, frequency change after restoration
            Theta(i,t>=(SettlingTime+t0)) = Theta(i,t>=(SettlingTime+t0)) + ((2*pi*KfS(i))*(t(t>=(SettlingTime+t0))-t0));
        end
            
    end  
end

% Complex signals
 cSignal = (Ain.*exp(1i.*Theta));
 
%-------------------------debug: frequency plot--------------------------
% Theta = unwrap(angle(cSignal(1,:)));
% Freq = -(diff(Theta).*FSamp/(2*pi));
% plot(t(1:end-1),Freq);
%-------------------------------------------------------------------------
% Add a single harmonic or interharmonic
if (Fh > FSamp/2)
    error('Interfering signal frequency is above FGen Nyquist frequency.  Can not generate');
end % if

for i = 1:nPhases
    ThetaH(i,:) = (Wh(i)*t) + Ph(i)*(pi/180);
    cSignal(i,:) = cSignal(i,:) + ((Kh(i) * (Xm(i))) * (cos(ThetaH(i,:)) + 1i*sin(ThetaH(i,:))));
end


% Add band-limited normally distributed noise
if any(Kn > 0)
    cNoise = zeros(nPhases,nSamples);
    freqBins = (0:nSamples/2)'/nSamples*FSamp; % the frequency bins if the signal is to be band limited
    for i = 1:nPhases
        X = [1; exp(1i*2*pi*randn(nSamples/2-1,1));1]; % this is the full bandwidth noise in the frequency domain
        if Fn > 0
            X(find((freqBins < 100)|(freqBins > Fn(i)))) = 0; % sets all frequency bins above the cutoff to 0
        end
        X = [X;conj(flipud(X(2:end-1)))];
        iF = ifft(X);
        iFrms = sqrt(mean(iF.*iF));
        cNoise(i,:) = Xm(i)*Kn(i)*iF/iFrms; % RMS Noise power                
    end
    cSignal = cSignal+cNoise;
end        

Signal = real(cSignal);


%%-------------DEBUGGING-------------------------------------------------
%%In the step test, I learned from the below that unwrapping is needed when determining frequency!
%
%fig = 0;
%
%fig = fig+1;
%figure(fig)
%
%plot(real(cSignal(1,:)));
%hold on
%plot(imag(cSignal(1,:)));
%hold off
%
%Pi = angle(cSignal);
%Pi = unwrap(Pi')';
%fig=fig+1;
%figure(fig)
%plot(Pi(1,:));
%
%fig=fig+1;
%figure(fig)
%
%Fi = (-diff(Pi')*FSamp/(2*pi))';
%
%plot(Fi(1,:));
%%------------------------------------------------------------------------

 end  %function

