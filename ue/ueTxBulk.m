function [Stations, compoundWaveforms, Users] = ueTxBulk(Stations,Users, NSubframe, NFrame)

	%   TX Bulk performs bulk operations on the transmitters for uplink
	%
	%   Function fingerprint
	%   Stations	->  EvolvedNodeB array
	%   Users			->  UserEquipment array
	%
	%   stations  		-> EvolvedNodeB with updated Rx attributes

  % loop through the UEs based on sets of common serving station
  compoundWaveforms(1:length(Stations), 1) = struct(...
    'eNodeBId', -1,...
    'ueGroup', [],...
    'txWaveform', [],...
    'Pmax',[]);
    
  for iStation = 1:length(Stations)
    enb = Stations(iStation);
    cwf = compoundWaveforms(iStation);

    cwf.eNodeBId = enb.NCellID;
    cwf.ueGroup = find([Users.ENodeBID] == enb.NCellID);

    for iUser = 1:length(cwf.ueGroup)
      ue = Users((cwf.ueGroup(iUser)));
      % Set the scheduling slots for this UE
      ue = ue.setSchedulingSlots(enb);

      % set subframe and frame number 
      ue.NSubframe = NSubframe;
      ue.NFrame = NFrame;
      
      % Create local resource grid and modulate
      [ue.Tx, harqReportReset] = ue.Tx.mapGridAndModulate(ue);

      if harqReportReset
        ue = ue.resetHarqReport();
      end
      % Append waveform to compound one
      % TODO check shaping and positioning
      cwf.txWaveform = cat(1, cwf.txWaveform, ue.Tx.Waveform);
      cwf.Pmax = ue.Pmax;
      % Update the UE in the main data structure that we return
      mainIUser = find([Users.NCellID] == ue.NCellID);
      Users(mainIUser) = ue;
    end
    % Update main structure
    compoundWaveforms(iStation) = cwf;
  end

end
