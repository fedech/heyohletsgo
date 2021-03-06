function [res, Users] = recordUEResults(Users, Stations, res, ix)

%   RECORD UE RESULTS records UE-space results
%
%   Function fingerprint
%   Users		->  UEs list
%   res			->  results data structure
%   ix			->  index of scheduling round

% 	res			-> updeted results

for iUser = 1:length(Users)
	rx = Users(iUser).Rx;
	user = Users(iUser);
	iServingStation = [Stations.NCellID] == Users(iUser).ENodeBID;
	resM = struct(...
		'blocks', rx.Blocks,...
		'cqi', rx.CQI, ...
		'preEvm', rx.PreEvm, ...
		'postEvm', rx.PostEvm, ...
		'bits', rx.Bits,...
		'sinr', rx.SINRdB, ...
		'snr', rx.SNRdB, ...
		'rxPosition', Users(iUser).Position, ...
		'txPosition', Stations(iServingStation).Position,...
		'symbols', rx.Symbols,...
        'scheduled', user.Scheduled,...
        'servingStation',Stations(iServingStation).NCellID);

		% Check if user is scheduled.
    station = Stations(iServingStation);
    scheduled = checkUserSchedule(Users(iUser),station);
    if ~scheduled
      res(ix + 1, iUser) = resultHook(resM);
    else
      res(ix + 1, iUser) = resM;
    end
    
    % Add to local history object
    Users(iUser).Rx = Users(iUser).Rx.addToHistory('SINRdB',Stations(iServingStation).NCellID);
    Users(iUser).Rx = Users(iUser).Rx.addToHistory('SNRdB',Stations(iServingStation).NCellID);
    Users(iUser).Rx = Users(iUser).Rx.addToHistory('RxPwdBm',Stations(iServingStation).NCellID);
end


  function userresM = resultHook(userres)
    % Hook for adjusting saved results.
    % Removal of reception metrics (e.g. demodulated statistics) if not
    % scheduled given the round
    %
    %   Function fingerprint
    %   userres    ->  results related to single user

    %   userresM   ->  Mutated results returned
    userres.cqi = NaN;
    userres.preEvm = NaN;
    userres.postEvm = NaN;
    userres.blocks.tot = NaN;
    userres.blocks.err = NaN;
    userres.blocks.ok = NaN;
    userres.bits.tot = NaN;
    userres.bits.err = NaN;
    userres.bits.ok = NaN;
    userres.snr = NaN;
    userres.sinr = NaN;
    userresM = userres;
  end


end
