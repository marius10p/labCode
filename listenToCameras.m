function listenToCameras(mname, session)
%% this script sets up the cameras

root = 'D:\CAMS\';

global vidobj udpLogfileID % this is the video object


% we need a couple of global variables (at least for alpha version)
global camUDP % this is the UDP object used to communicate with the 'mpep' computer


clear vidobj src
ninputs = 5;
% define the video object
for j = 1:ninputs
    try
        %
        vidobj{j}                   = videoinput('pointgrey', j,  'F7_Raw8_640x512_Mode1');
        src{j}                      = getselectedsource(vidobj{j});
        src{j}.FrameRate            = 50;
        
               % do a preview so that the framerate is persistent after the reset
        preview(vidobj{j})
    catch
    end
end
ninputs = j;

% reset the video adapters, so that the new framerate is used for min/max values
imaqreset;

shtter = [19 4 2 1 19];

for j = 1:ninputs
    vidobj{j} = videoinput('pointgrey', j,  'F7_Raw8_640x512_Mode1');
    vidobj{j}.FramesPerTrigger  = Inf;
    
    fname                           = fullfile(root, sprintf('%s_%s_cam%d', mname, session, j));
    diskLogger                      = VideoWriter(fname, 'Motion JPEG 2000');
    diskLogger.MJ2BitDepth          = 8;
    diskLogger.LosslessCompression  = false;
    diskLogger.CompressionRatio     = 5;
     
    vidobj{j}.fname = fname;
    vidobj{j}.DiskLogger        = diskLogger;    
    vidobj{j}.LoggingMode       = 'disk';
    
    src{j}                      = getselectedsource(vidobj{j});
    
    vidobj{j}.FramesPerTrigger = 1;
    vidobj{j}.FramesAcquiredFcn = {@framesAvailableMouseCam,j};
    vidobj{j}.FramesAcquiredFcnCount = 100;
    vidobj{j}.LoggingMode = 'disk&memory';
    vidobj{j}.TriggerRepeat = Inf;
    triggerconfig(vidobj{j}, 'immediate');
    
    src{j}.Exposure             = 0.5; % default is 0.5
    src{j}.Shutter              = shtter(j); % default is 0.5
    src{j}.Gain                 = 18; % default is 8
    src{j}.Brightness           = 1.5; % default is 1.5    
    
   preview(vidobj{j}); 
   
   start(vidobj{j})
   
   % UDP
   filename = fullfile([fname '_UDPLog.txt']);
   udpLogfileID = fopen(filename, 'w');
   
   camUDP{j} = udp('1.1.1.1', 1103, 'LocalPort', 1000 + j);
   set(camUDP{j}, 'DatagramReceivedFcn', sprintf('cameraUDPcallback(%d)', j));
   fopen(camUDP{j});   
end

for j = 1:ninputs
    stop(vidobj{j})
    fclose(udpLogFileID);
end
