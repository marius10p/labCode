function cameraUDPCallback(id)

global camUDP

global udpLogfileID eyeLog

timestamp = clock;

receivedData = fread(camUDP{id});


str=char(receivedData');
fprintf('Received ''%s'' from %s:%d\n', str, ip, port);

if ~isfield(eyeLog, 'udpEventTimes')
    eyeLog.udpEventTimes{1, 1} = timestamp;
    eyeLog.udpEvents{1, 1} = sprintf('%s', str);
else
    eyeLog.udpEventTimes{end+1, 1} = timestamp;
    eyeLog.udpEvents{end+1, 1} = sprintf('%s', str);
end

fprintf(udpLogfileID, '[%d, %s \r\n', ...
    eyeLog.udpEventTimes{end}, eyeLog.udpEvents{end});

s

