% Test bed for genC37Signal and AnnexDPmu

F0 = 60;
Fs = 60;
FSamp = 960;
SettlingTime = 7;
bPosSeq = true(1);
WindowType = 'Hamming';
FilterParams = [8.19,164];

T0 = 0;
Duration = 10.0;

signalParams(1,:) =  [70,70,70,5,5,5];          % phase amplitude (given by the user in RMS
signalParams(2,:) = [60.1,60.1,60.1,60.1,60.1,60.1];        % frequency (must be the same for all 6 channels or an error will be thrown
signalParams(3,:) = [0,-120,120,0,-120,120];    % phase
signalParams(4,:) = [0,0,0,0,0,0];              % Frequency of the interfering signal
signalParams(5,:) = [0,0,0,0,0,0];              % Phase of the interfering signal
signalParams(6,:) = [0,0,0,0,0,0];              % index of the interfering signal
signalParams(7,:) = [0,0,0,0,0,0];              % phase (angle) moduation frequency
signalParams(8,:) = [0,0,0,0,0,0];              % phase (angle) moduation index
signalParams(9,:) = [0,0,0,0,0,0];              % amplitude moduation frequency
signalParams(10,:) = [0,0,0,0,0,0];             % amplitude moduation index
signalParams(11,:) = [0,0,0,0,0,0];             % ROCOF
signalParams(12,:) = [0,0,0,0,0,0];             % phase (angle) step index
signalParams(13,:) = [0,0,0,0,0,0];             % magnitude step index

tStart = -SettlingTime;
tEnd = Duration + SettlingTime;
t = (tStart:1/FSamp:tEnd);
EndTime = Duration;

[Signal] = genC37Signal( ...
    t, ...
    FSamp, ...
    signalParams, ...
    EndTime ...
    );

%plot (t,Signal(1,:));
Signal = Signal.';

[Timestamp,...
          Synx,...
          Freq,...
          ROCOF] = AnnexDPmu( ...
                        Signal, ...
                        bPosSeq, ...
                        FilterParams, ...
                        WindowType, ...
                        T0, ...
                        F0, ...
                        Fs, ...
                        FSamp, ...
                        SettlingTime ...
                      );  