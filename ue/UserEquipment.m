%   USER EQUIPMENT defines a value class for creating and working with UEs

classdef UserEquipment
	%   USER EQUIPMENT defines a value class for creating and working with UEs
	properties
		NCellID;
		ENodeBID;
		NULRB;
		RNTI;
		DuplexMode;
    CyclicPrefixUL;
		NSubframe;
    NFrame;
    NTxAnts;
		Position;
		PLast; % indexes in trajectory vector of the latest position of the UE
		Queue;
		PlotStyle;
		Scheduled;
		Sinr;
		TLast; % timestamp of the latest movement done by the UE
		Trajectory;
		Velocity;
		RxAmpli;
		Rx;
		Tx;
		Symbols;
		SymbolsInfo;
		Codeword;
		CodewordInfo;
		TransportBlock;
		TransportBlockInfo;
		Mac;
		Rlc;
		SchedulingSlots;
		Hangover;
		Pmax;
    Seed;
	end

	methods
		% Constructor
		function obj = UserEquipment(Param, userId)
            obj.NCellID = userId;
            obj.Seed = userId*Param.seed;
			obj.ENodeBID = -1;
			obj.NULRB = Param.numSubFramesUE;
			obj.RNTI = 1;
			obj.DuplexMode = 'FDD';
			obj.CyclicPrefixUL = 'Normal';
			obj.NSubframe = 0;
			obj.NFrame = 0;
			obj.NTxAnts = 1;
			obj = setQueue(obj, struct('Size', 0, 'Time', 0, 'Pkt', 0));
			obj.Scheduled = false;
			obj.PlotStyle = struct(	'marker', '^', ...
				'colour', rand(1,3), ...
				'edgeColour', [0.1 0.1 0.1], ...
				'markerSize', 8, ...
				'lineWidth', 2);
			switch Param.mobilityScenario
				case 'pedestrian'
					obj.Velocity = 1; % in m/s
                    [x, y] = traffic_mobility(1, obj.Velocity, obj.Seed);
                    obj = setTrajectory(obj, x, y, Param);
				case 'vehicular'
					obj.Velocity = 10; % in m/s
                    [x, y] = traffic_mobility(2, obj.Velocity, obj.Seed);
                    obj = setTrajectory(obj, x, y, Param);
				case 'static'
					obj.Velocity = 0; % in m/s
                    [x, y] = traffic_mobility(1, obj.Velocity, obj.Seed);
                    obj = setTrajectory(obj, x, y, Param);
				case 'superman'
					obj.Velocity = 100; % in m/s
                    [x, y] = traffic_mobility(1, obj.Velocity, obj.Seed);
                    obj = setTrajectory(obj, x, y, Param);
                case 'straight'
                    obj.Velocity = 10 / 12; % in m/s
                    [x, y] = straight_mobility( obj.Velocity, obj.Seed, Param );
                    obj = setTrajectory(obj, x, y, Param);
				otherwise
					sonohilog('Unknown mobility scenario selected','ERR');
					return;
			end
			obj.TLast = 0;
			obj.PLast = [1 1];
			obj.RxAmpli = 1;
			obj.Rx = ueReceiverModule(Param, obj);
			obj.Tx = ueTransmitterModule(Param, obj);
			obj.Symbols = [];
			obj.SymbolsInfo = [];
			obj.Codeword = [];
			obj.CodewordInfo = [];
			obj.TransportBlock = [];
			obj.TransportBlockInfo = [];
			if Param.rtxOn
					obj.Mac = struct('HarqRxProcesses', HarqRx(Param, 0), 'HarqReport', struct('pid', [0 0 0], 'ack', -1));
					obj.Rlc = struct('ArqRxBuffer', ArqRx(Param, 0));
			end
			obj.Hangover = struct('TargetEnb', -1, 'HoState', 0, 'HoStart', -1, 'HoComplete', -1);
			obj.Pmax = 10; %10dBm
		end

		% sets user trajectory
		function obj = setTrajectory(obj, x, y, Param)
			obj.Trajectory(1:length(x),1) = x;
			obj.Trajectory(1:length(y),2) = y;
			obj.Position = [obj.Trajectory(1, 1) obj.Trajectory(1, 2) Param.ueHeight];

			% Plot UE position and trajectory in scenario
			if Param.draw
				plotUEinScenario(obj, Param);
			end
		end

		% Change queue
		function obj = setQueue(obj, queue)
			obj.Queue = queue;
		end

		% toggle scheduled
		function obj = setScheduled(obj, status)
			obj.Scheduled = status;
		end

		% move User
		function obj = move(obj, ts, Param)
			% if we are at the beginning, don't move
			if ts ~= 0

				% delta of time since last step
				tDelta = ts - obj.TLast;

				% check if the current position is the last one of the trajectory
				if obj.PLast(1) == length(obj.Trajectory)
					% reverse the trajectory and use it upside down
					obj.Trajectory = flipud(obj.Trajectory);
					obj.PLast = [0 0];
				end

				% get current position and trajectory
				p0 = obj.Position;
				p0(3) = [];
				trj = obj.Trajectory;

				% get next position
				x1 = trj(obj.PLast(1) + 1, 1);
				y1 = trj(obj.PLast(2) + 1, 2);
				p1 = [x1, y1];

				% get distance
				dist = sqrt((p1(1)-p0(1))^2 + (p1(2)-p0(2))^2 );

				% time to pass the distance
				td = dist/obj.Velocity;

				% check whether we need to make this step
				if td >= tDelta
					% move UE and update attributes
					obj.Position = [x1 y1 obj.Position(3)];
					obj.TLast = ts;
					obj.PLast = obj.PLast + 1;
				end

			end
		end

		% set TransportBlock
		function obj = set.TransportBlock(obj, tb)
			obj.TransportBlock = tb;
		end

		% set TransportBlockInfo
		function obj = set.TransportBlockInfo(obj, info)
			obj.TransportBlockInfo = info;
		end

		% set Codeword
		function obj = set.Codeword(obj, cw)
			obj.Codeword = cw;
		end

		% set CodewordInfo
		function obj = set.CodewordInfo(obj, info)
			obj.CodewordInfo = info;
		end

		% set Symbols
		function obj = set.Symbols(obj, sym)
			obj.Symbols = sym;
		end

		% set SymbolsInfo
		function obj = set.SymbolsInfo(obj, info)
			obj.SymbolsInfo = info;
		end

		% set NSubframe
		function obj = set.NSubframe(obj, num)
			obj.NSubframe = num;
		end

		% set NFrame
		function obj = set.NFrame(obj, num)
			obj.NFrame = num;
		end

		% set NULRB
		function obj = set.NULRB(obj, num)
			obj.NULRB = num;
		end

		% cast object to struct
		function objstruct = cast2Struct(obj)
			objstruct = struct(obj);
		end

		% Find indexes in the serving eNodeB for the UL scheduling
		function obj = setSchedulingSlots(obj, Station)
      obj.SchedulingSlots = find(Station.ScheduleUL == obj.NCellID);
			obj.NULRB = length(obj.SchedulingSlots);
    end

		% Reset the HARQ report
		function obj = resetHarqReport(obj)
			obj.Mac.HarqReport = struct('pid', [0 0 0], 'ack', -1);
		end
		
		%Reset properties that change every round
		function obj = reset(obj)
			obj.Scheduled = false;
			obj.Symbols = [];
			obj.SymbolsInfo = [];
			obj.Codeword = [];
			obj.CodewordInfo = [];
			obj.TransportBlock = [];
			obj.TransportBlockInfo = [];
			obj.Tx = obj.Tx.reset();
			obj.Rx = obj.Rx.reset();
		end

	end

	methods (Access = private)

	end

end
