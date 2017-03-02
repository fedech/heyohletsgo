function [users] = createUsers (param)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   CREATE USERS is used to generate a struct with the users                   %
%                                                                              %
%   Function fingerprint                                                       %
%   param.numUsers  ->  number of UEs                                          %
%   param.velocity  ->  number of LTE subframes for macro eNodeBs              %
%                                                                              %
%   users  					-> struct with all users details                           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Not a very interesting module for now, it is structured like this for scalability
	% Initialise struct
	stations(param.numUsers).velocity = param.velocity;

	for i = 1: (param.numUsers)
    users(i).Position = positionUser();
    users(i).Velocity = param.velocity;
	end

end
