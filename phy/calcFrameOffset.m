function [off,off_auto] = calcFrameOffset(Station, User)

% 	CALCULATE FRAME OFFSET is used to calculate the offset of the received frame
%
%   Function fingerprint
%   Station							-> 	the TX eNodeB
%   User								->	the UE
%
% 	off									-> symbols padded
	enb = cast2Struct(Station);
	ue = cast2Struct(User);
	off = lteDLFrameOffset(enb, ue.RxWaveform);
    [~,off_auto] = max(autocorr(ue.RxWaveform));
end