function res = recordUEResults(Users, Stations, res, ix)

	%   RECORD UE RESULTS records UE-space results
	%
	%   Function fingerprint
	%   Users		->  UEs list
	%   res			->  results data structure
	%   ix			->  index of scheduling round

	% 	res			-> updeted results

	for iUser = 1:length(Users)
		rx = Users(iUser).Rx;
		iServingStation = find([Stations.NCellID] == Users(iUser).ENodeB);
		res(iUser, ix + 1) = struct(...
			'blocks', rx.Blocks,...
			'preEvm', rx.PreEvm, ...
			'postEvm', rx.PostEvm, ...
			'bits', rx.Bits,...
			'sinr', rx.SINRdB, ...
			'snr', rx.SNRdB, ...
			'rxPosition', Users(iUser).Position, ...
			'txPosition', Stations(iServingStation).Position);
	end
end
