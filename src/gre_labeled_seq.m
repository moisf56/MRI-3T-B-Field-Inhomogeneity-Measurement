
sys = mr.opts('MaxGrad', 28, 'GradUnit', 'mT/m', ...
    'MaxSlew', 150, 'SlewUnit', 'T/m/s', 'rfRingdownTime', 20e-6, ...
    'rfDeadTime', 100e-6, 'adcDeadTime', 10e-6);

seq=mr.Sequence(sys);         % create a new sequence object

fov=224e-3; Nx=256; Ny=Nx; % field of view
alpha=10;                  % flip angle
thickness=3e-3;            % thickness of the slice
Nslices=1;        % number of slices
TR=100e-3;                    % repetition time
TE=5e-3;                 % echo time
rfSpoilingInc=117;      % RF spoiling increment           
roDuration=3.2e-3;      % readout duration           

%G_z gradient for slice selection
[rf, gz] = mr.makeSincPulse(alpha*pi/180,'Duration',3e-3,...
    'SliceThickness',thickness,'apodization',0.42,'timeBwProduct',4,'system',sys);      % slice selection pulse          

%other gradients and ADC    
deltak=1/fov;
gx = mr.makeTrapezoid('x','FlatArea',Nx*deltak,'FlatTime',roDuration,'system',sys); % readout gradient
adc = mr.makeAdc(Nx,'Duration',gx.flatTime,'Delay',gx.riseTime,'system',sys);   % ADC event
gxPre = mr.makeTrapezoid('x','Area',-gx.area/2,'Duration',1e-3,'system',sys);   % prephasing
gzReph = mr.makeTrapezoid('z','Area',-gz.area/2,'Duration',1e-3,'system',sys);  %` rephasing
phaseAreas = -((0:Ny-1)-Ny/2)*deltak; % phase area should be Kmax for clin=0 and -Kmax for clin=Ny... strange

%spoiling
gxSpoil=mr.makeTrapezoid('x','Area',2*Nx*deltak,'system',sys);      % 2x to ensure spoiling in case of partial Fourier
gzSpoil=mr.makeTrapezoid('z','Area',4/thickness,'system',sys);      % 4x to ensure spoiling in case of imperfect slice profile

% sequence timing
delayTE=ceil((TE - mr.calcDuration(gxPre) - gz.fallTime - gz.flatTime/2 ...
    - mr.calcDuration(gx)/2)/seq.gradRasterTime)*seq.gradRasterTime;
delayTR=ceil((TR - mr.calcDuration(gz) - mr.calcDuration(gxPre) ...
    - mr.calcDuration(gx) - delayTE)/seq.gradRasterTime)*seq.gradRasterTime;
assert(all(delayTE>=0));
assert(all(delayTR>=mr.calcDuration(gxSpoil,gzSpoil)));

rf_phase=0;
rf_inc=0;

seq.addBlock(mr.makeLabel('SET','REV', 1)); 

% loop over slices, phase encodings and repetitions
for s=1:Nslices
    rf.freqOffset=gz.amplitude*thickness*(s-1-(Nslices-1)/2);
    for i=1:Ny
      for c=1:length(TE)
        rf.phaseOffset=rf_phase/180*pi;
        adc.phaseOffset=rf_phase/180*pi;
        rf_inc=mod(rf_inc+rfSpoilingInc, 360.0);
        rf_phase=mod(rf_phase+rf_inc, 360.0);
        %
        seq.addBlock(rf,gz);
        gyPre = mr.makeTrapezoid('y','Area',phaseAreas(i),'Duration',mr.calcDuration(gxPre),'system',sys);
        seq.addBlock(gxPre,gyPre,gzReph);
        seq.addBlock(mr.makeDelay(delayTE(c)));
        seq.addBlock(gx,adc);
        gyPre.amplitude=-gyPre.amplitude;
        spoilBlockContents={mr.makeDelay(delayTR(c)),gxSpoil,gyPre,gzSpoil}; % here we demonstrate the technique to combine variable counter-dependent content into the same block
        if c~=length(TE)
            spoilBlockContents=[spoilBlockContents {mr.makeLabel('INC','ECO', 1)}];
        else
            if length(TE)>1
                spoilBlockContents=[spoilBlockContents {mr.makeLabel('SET','ECO', 0)}];
            end
            if i~=Ny
                spoilBlockContents=[spoilBlockContents {mr.makeLabel('INC','LIN', 1)}];
            else
                spoilBlockContents=[spoilBlockContents {mr.makeLabel('SET','LIN', 0), mr.makeLabel('INC','SLC', 1)}];
            end
        end
        seq.addBlock(spoilBlockContents{:});
      end
    end
end

%% Timing check 
[ok, error_report]=seq.checkTiming;

if (ok)
    fprintf('Timing check passed successfully\n');
else
    fprintf('Timing check failed! Error listing follows:\n');
    fprintf([error_report{:}]);
    fprintf('\n');
end

seq.setDefinition('FOV', [fov fov thickness*Nslices]);
seq.setDefinition('Name', 'gre_lbl');
seq.write('gre_lb_1.seq')       


%% k-spaces and k-trajectories plots

seq.plot('timeRange', [0 32]*TR, 'TimeDisp', 'ms', 'Label', 'LIN,SLC'); % plot sequence with zoom in time and labels
[ktraj_adc, t_adc, ktraj, t_ktraj, t_excitation, t_refocusing] = seq.calculateKspacePP();   % calculate k-space and k-trajectory

% k-spaces and k-trajectories plots
figure; plot(t_ktraj, ktraj'); 
hold; plot(t_adc,ktraj_adc(1,:),'.');
title('k-trajectory with respect to time');
figure; plot(ktraj(1,:),ktraj(2,:),'b'); 
axis('equal'); 
hold;plot(ktraj_adc(1,:),ktraj_adc(2,:),'r.'); 
title('2D k-space');

%% labels Evaluation for reconstruction 
adc_lbl=seq.evalLabels('evolution','adc');
figure; plot(adc_lbl.SLC);
hold on; plot(adc_lbl.LIN);
legend('slc','lin');
title('evolution of labels/counters');


