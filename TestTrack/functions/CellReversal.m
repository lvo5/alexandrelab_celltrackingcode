function [ dataTumble, TumbleSpeed, TumbleAngle ] = CellReversal(AngleType,...
    factorP2M,VelData,AngvData,dataCLEAN,dt,VelDepthFactor,VelCutOff,...
    AngCutOff,Gama,RotDiff )
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% This Function Returns Reversal frequency for each cell
%
% INPUTS:
%       
%       NgoodCell is the number of good trajectories
%
%       dataCLEAN is the clean data
%
%       NumIDS is the number of frames fore each cell live
%
%       factorP2M is the factor from pixel to micron
%
%       dt is the time step between frames
%
%       RotDiff is the rotational diffusivity
%
%       Gama is the parameter in tumbling formula
%
%       AngCutOff is the angular velocity cuttoff
%
%       VelDepthFactor is the parameter in velocity formula
%
%       VelCutOff is the velocity cuttoff
%
%       AngvData is the angular velocity data
%
%       VelData is the velocity data
%
% OUTPUTS:
%
%       NtrackedCell is the number of cells
%
%       NumIDs is number of frames for each track
%
%       Vel is the average velocity for each cell
%
%       Acc
%
%       Avel is the average angular velocity for each cell
%
%       Aace
%
%       VelData is the velocity data
%       
%       AngvData is the angular velocity data
%
%       dataCLEAN is the clean data
%
%       dataTumble is the data about tumble for each track
%
% USE: 
%       
%       [ dataTumble,indxAng,indxVEL ] = CellReversal(NtrackedCell,...
%    VelData,AngvData,dataCLEAN,dt,VelDepthFactor,VelCutOff,AngCutOff,...
%    Gama,RotDiff,NumIDs );
% 
% Mustafa Elmas
% University of Tennessee - Knoxville
% melmas at utk dot edu
% September 15 2017 
% Written and tested in Matlab R2017a
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Calculate TUMBLING Frequency for each tracked bacteria
Ncol = size(dataCLEAN,2);    % ID column

% Angle Column
AngleCol = Ncol-2;

% Number of cells
NtrackedCell = max(dataCLEAN(:,Ncol));

% Memory for stops and reverses
dataTumble = zeros(NtrackedCell,4);

% information about stops:TumbleSpeed and reverses:TumbleAngle
TumbleSpeed = [];
TumbleAngle = [];

for s=1:NtrackedCell
% for s=4:4
    
    % Empty structure for Tumble info via speed
%     TumbleSpeed = [];
    
    % Struct for Speed index
    StructINDvel = 0;
    
    % Empty structure for Tumble info via Angle
%     TumbleAngle = [];
    
    % Struct for Angle index
    StructINDang = 0;
    
    %>>>>>>>>>>>>>>>>>>>>>>>>>> SPEED <<<<<<<<<<<<<<<<<<<<<<<<<
    % Extract velocities of sth trajectory
    ind = find(VelData(:,2) == s);          % Local indices
    TotalFrames = length(ind);              % The length of the m th trajectory
    Time = VelData(ind(2:end),3);                  % Local Time
    LocalVEL = VelData(ind(2:end),1);              % Local Velocities
    NlocalVEL = length(LocalVEL(:,1));      % Number of local frames
    
    % Find all local MINIMUM VELOCITY for sth cell
    [MaxVelVALUE,IDmaxVEL,MinVelVALUE,IDminVEL] = LocalMinMax( LocalVEL);
    Nlocalmin = length(IDminVEL);
            
    % Union max & min indices
    UNmaxmin = union(IDmaxVEL,IDminVEL);
    
    % Set counter to zero for each trajectory
    counterVEL1 = 0;
    counterVEL2 = 0;
    
    % Start Analyzing local minima
    for v = 1:Nlocalmin
                        
        % If the FIRST one is minumum
        if (IDminVEL(v) == 1 || IDminVEL(v) == NlocalVEL)
            continue;
            
        else
            indxLOCAL = find(UNmaxmin(:) == IDminVEL(v));
               indMin = UNmaxmin(indxLOCAL);
              indMax1 = UNmaxmin(indxLOCAL-1);
              indMax2 = UNmaxmin(indxLOCAL+1);
            
              % Local min and neighboring maxima
               LocMinVEL = LocalVEL(indMin);
              LocMaxVEL1 = LocalVEL(indMax1);
              LocMaxVEL2 = LocalVEL(indMax2);
 
              % Velocity depth
              dv = max(LocMaxVEL1-LocMinVEL,LocMaxVEL2-LocMinVEL);
              
              % LOCAL VELOCITY CUTOFF
              if dv/LocMinVEL > VelCutOff   
        
                  % Update StructIND 
                  StructINDvel = StructINDvel + 1;
        
                  % Index where it tumbles
                  TumbleINDspeed = indMin;
                  
                % LOCAL VELOCITY THRESHOLD
                VELthresh = LocMinVEL + VelDepthFactor*dv;
                
                % Check up to Left Maxima
                for ii = indMin-1:-1:indMax1
                    if LocalVEL(ii) <= VELthresh
                        counterVEL1 = counterVEL1 + 1;
                    else
                        % Left side stopping point
                        indMax1 = ii+1;
                        break;
                    end
                end     % END FOR ii
                
                % Check up to Right Maxima
                for jj = indMin+1:1:indMax2
                    if LocalVEL(jj) <= VELthresh
                        counterVEL2 = counterVEL2 + 1;
                    else
                        % Right side stopping point
                        indMax2 = jj-1;
                        break;
                    end
                end     % END FOR jj
                
                % Location where it STOPS
                TumbleIND = indMax1:indMax2;
                TumbleSpeed(s).LocalTumble(StructINDvel).ID = s;
                TumbleSpeed(s).LocalTumble(StructINDvel).LocID = v;
                TumbleSpeed(s).LocalTumble(StructINDvel).index = TumbleINDspeed;
                TumbleSpeed(s).LocalTumble(StructINDvel).speed = LocMinVEL;
                TumbleSpeed(s).LocalTumble(StructINDvel).location = TumbleIND;
%                 LocMinVEL
             end % END CUTOFF
        end     % END if
                     
    end % END v: speed
       
    %>>>>>>>>>>>>>>>>>>>>>>>>>> ANGLE <<<<<<<<<<<<<<<<<<<<<<<<<
    % Extract velocities of sth trajectory
            indAng = find(AngvData(:,2) == s);              % Local indices
          LocAngle = dataCLEAN(indAng(1:end),AngleCol);     % Local Angles
       LocalAngVEL = AngvData(indAng(1:end),1);             % Local Ang. Vel.
    AbsLocalAngVEL = abs(LocalAngVEL);                      % Abs value of Ang. Vel.
           TimeAng = AngvData(indAng(1:end),3);             % Local Time
      NlocalAngVEL = length(LocalAngVEL(:,1));              % Number of local frames
    
    % Find all local MINIMUM VELOCITY for sth cell
    [MaxAngVelVALUE,IDmaxAngVEL,MinAngVelVALUE,IDminAngVEL] = LocalMinMax( AbsLocalAngVEL);
    NlocalmaxAng = length(IDmaxAngVEL);
    
%     figure;    
%     plot(TimeAng, AbsLocalAngVEL)
%     hold on
%     plot(TimeAng(IDmaxAngVEL), AbsLocalAngVEL(IDmaxAngVEL), 'r*')
%     hold on
%     plot(TimeAng(IDminAngVEL), AbsLocalAngVEL(IDminAngVEL), 'g*')
    
    % Union max & min indices
    UNmaxminAng = union(IDmaxAngVEL,IDminAngVEL);
    
    % Set counter to zero for each trajectory
    counterAngVEL1 = 0;
    counterAngVEL2 = 0;
    
    % Start Analyzing local minima
    for w = 1:NlocalmaxAng
                        
        % If the FIRST one is minumum
        if (IDmaxAngVEL(w) == 2 || IDmaxAngVEL(w) == NlocalAngVEL)
            continue;
            
        else
            indxLOCALang = find(UNmaxminAng(:) == IDmaxAngVEL(w));
               indMaxAng = UNmaxminAng(indxLOCALang); 
              indMinAng1 = UNmaxminAng(indxLOCALang-1);
              indMinAng2 = UNmaxminAng(indxLOCALang+1);
              
              % First angle is zero, consider the next one
              if (indMinAng1 == 1 ) 
                  indMinAng1 = indMinAng1 +1;
              end
                  
              % Local min and neighboring maxima
               LocMaxAngVEL = AbsLocalAngVEL(indMaxAng);
              LocMinAngVEL1 = AbsLocalAngVEL(indMinAng1);
              LocMinAngVEL2 = AbsLocalAngVEL(indMinAng2);
 
              % Velocity depth
              dw = max(LocMaxAngVEL-LocMinAngVEL1,LocMaxAngVEL-LocMinAngVEL2);
              
              % Abs valueangle difference from indMinAng1 to indMinAng2
               AngChange = abs(LocAngle(indMinAng1)-LocAngle(indMinAng2));
               
               % Correction: Angle change between 0 and 180
               if (AngChange > pi) 
                   AngChange = abs(AngChange - 2*pi);
               end
               
               % Angular Threshold
               FrameDiff = indMinAng2 - indMinAng1; % Frame Difference
               
               % Correction on Angle threshold
%                if(FrameDiff > 3)
%                    FrameDiff = 3;
%                end
                
                % Angle threshold
               AngleThreshold = Gama*sqrt(RotDiff*FrameDiff*dt);
               
              % LOCAL VELOCITY CUTOFF
              if AngChange > AngleThreshold 
%                   AngChange
%                     AngleThreshold

                  % Update StructIND 
                  StructINDang = StructINDang + 1;
        
                  % Index where it tumbles
                  TumbleINDangle = indMaxAng;
                  
%                   % LOCAL ANGULAR VELOCITY THRESHOLD
%                   AngVELthresh = AngCutOff*dw;
                
%                 % Check up to Left Maxima
%                 for ii = indMaxAng-1:-1:indMinAng1
%                     if abs(LocMaxAngVEL  - AbsLocalAngVEL(ii)) <= AngVELthresh
%                         counterAngVEL1 = counterAngVEL1 + 1;
%                     else
%                         % Left side reversal point
%                         indMinAng1 = ii + 1;
%                         break;
%                     end
%                 end     % END FOR ii
%                 
%                 % Check up to Right Maxima
%                 for jj = indMaxAng+1:1:indMinAng2
%                     if abs(LocMaxAngVEL  - AbsLocalAngVEL(jj)) <= AngVELthresh
%                         counterAngVEL2 = counterAngVEL2 + 1;
%                     else
%                         % Right side reversal point
%                         indMinAng2=jj-1;
%                         break;
%                     end
%                 end     % END FOR jj
                
                % Location where it STOPS
                TumbleIND = indMinAng1:indMinAng2;
                TumbleAngle(s).LocalTumble(StructINDang).ID = s;
                TumbleAngle(s).LocalTumble(StructINDang).LocID = w;
                TumbleAngle(s).LocalTumble(StructINDang).index = TumbleINDangle;
                TumbleAngle(s).LocalTumble(StructINDang).angle = AngChange;
                TumbleAngle(s).LocalTumble(StructINDang).location = TumbleIND;
                
             end % END CUTOFF
        end     % END if
                     
    end % END w: angular velocity 
          
        % UPDATE dataTUMBLE
         dataTumble(s,1) = s;
         dataTumble(s,2) = TotalFrames*dt;
         dataTumble(s,3) = StructINDvel;
         dataTumble(s,4) = StructINDang;
end % END s

end % END FUNCTION
