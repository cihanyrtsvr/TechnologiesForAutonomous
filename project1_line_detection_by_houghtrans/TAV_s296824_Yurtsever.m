clc;
clear all;
%close all;
%% camera sensor parameters
camera = struct('ImageSize',[480 640],'PrincipalPoint',[320 240],...
                'FocalLength',[320 320],'Position',[1.8750 0 1.2000],...
                'PositionSim3d',[0.5700 0 1.2000],'Rotation',[0 0 0],...
                'LaneDetectionRanges',[6 30],'DetectionRanges',[6 50],...
                'MeasurementNoise',diag([6,1,1]));
focalLength    = camera.FocalLength;
principalPoint = camera.PrincipalPoint;
imageSize      = camera.ImageSize;
% mounting height in meters from the ground
height         = camera.Position(3);  
% pitch of the camera in degrees
pitch          = camera.Rotation(2);  
            
camIntrinsics = cameraIntrinsics(focalLength, principalPoint, imageSize);
sensor        = monoCamera(camIntrinsics, height, 'Pitch', pitch);

%% define area to transform
distAheadOfSensor = 30; % in meters, as previously specified in monoCamera height input
spaceToOneSide    = 8;  % all other distance quantities are also in meters
bottomOffset      = 6;
outView   = [bottomOffset, distAheadOfSensor, -spaceToOneSide, spaceToOneSide]; % [xmin, xmax, ymin, ymax]
outImageSize = [NaN, 250]; % output image width in pixels; height is chosen automatically to preserve units per pixel ratio

birdsEyeConfig = birdsEyeView(sensor, outView, outImageSize);

videoReader = VideoReader('dL.mp4');
Output_Video=VideoWriter('Output_video');
Output_Video.FrameRate= 25;
open(Output_Video);
%% process video frame by frame
while hasFrame(videoReader)
 
    frame = readFrame(videoReader); % get the next video frame
% figure('Name','Original Image'), imshow(frame);

    birdsEyeImage1 = transformImage(birdsEyeConfig, frame);
    birdsEyeImage2 = rgb2gray(birdsEyeImage1);
%% Lane detection which applied gausse and binarization 
    % manuelly assigned parameter to gaussian image
    
    % binarization by default value
    binaryEyeImage3 = imbinarize(birdsEyeImage2);
      
   
    %% Detecting edges in the image and detecting right left turn
    %lets detech the Image of the binary eye birt image
    BW = edge(binaryEyeImage3,'canny');

    % Put the size of the Image which we ll use as a limit of our lines
    [rcc, ccc]=size(binaryEyeImage3);
    imshow(BW)

    %H-> Hough matrix
    %R-> Rho which the vectoral distance of the point matrix
    %T-> Theta angle between X axis and the Rho vector
    [H,T,R] = hough(BW);
    imshow(H,[],'XData',T,'YData',R,...
            'InitialMagnification','fit');
    xlabel('\theta'), ylabel('\rho');
    axis on, axis normal, hold on;

    %P-> peak we will have at max 7 lines can be detected and the smallest
    %int that is greather than 0.005*maximum of Hough matrix value
    P  = houghpeaks(H,7,'threshold',ceil(0.005*max(H(:))));

    %Finding the X starting and Y starting and ending points of the line
    x = T(P(:,2)); y = R(P(:,1));
    plot(x,y,'s','color','white');
    lines = houghlines(BW,T,R,P,'FillGap',0.2*rcc,'MinLength',0.005*rcc);
    
    %for each line check the angle of the line point 
    %if they are passing the treshold make them red if it is left make it geeen
    figure, imshow(binaryEyeImage3), hold on
    for k = 1:length(lines) 
        if lines(k).theta >4 || lines(k).theta <-2 
        xy = [lines(k).point1; lines(k).point2];
        plot(xy(:,1),xy(:,2),'LineWidth',5,'Color','red');
        else
        xy = [lines(k).point1; lines(k).point2];
        plot(xy(:,1),xy(:,2),'LineWidth',3,'Color','green');
        end
    end

   
   %collect the frames to make them video
   writeVideo(Output_Video,getframe);
end

%Closing Save Video File Variable
close(Output_Video);

%the representation of the image of the last frame
%stairs(1:size(binaryEyeImage,2),sum(binaryEyeImage));