%% Converting Video in to the frames and definening constants
obj = VideoReader('drowsy_11blk.mp4'); 
NumberOfFrames = obj.NumFrames;

la_imagen=read(obj,1);
openEyes=0; openEyes70=0; openEyes80=0;
iterations=0;
R1=0; R2=0;

figure(1);
isFirstFrame = true;

%% For each frame check the eye  
for cnt = 1:NumberOfFrames       
    la_imagen=read(obj,cnt);

    % Be sure that object is converted right and make black parts more
    % obvious 
    if size(la_imagen,3)==3
        la_imagen=rgb2gray(la_imagen);
        la_imagenA=la_imagen;
        for i = 1:580
            for j = 1:326
            if la_imagen(j,i)>13 
                la_imagen(j,i) = la_imagen(j,i) + 5;
            else 
                la_imagen(j,i) = la_imagen(j,i);
            end
            end
        end
    end
        
%% Use the first frame as a referance frame as open eyes

    if isFirstFrame == true 
    
        subplot(212)
    piel=~im2bw(la_imagen,0.175);
    
    for i = 1:300
            for j = 1:80
           
                piel(j,i) = false;
           
            end
     end
    %     --

    piel=bwmorph(piel,'close');
    piel=bwmorph(piel,'open');
    piel=bwareaopen(piel,900);
    piel=imfill(piel,'holes');
    imagesc(piel);
    % Tagged objects in BW image
    L=bwlabel(piel);
    % Get areas and tracking rectangle
    out_a=regionprops(L);
    % Count the number of objects
    N=size(out_a,1);
    if N < 1 || isempty(out_a) % Returns if no object in the image
        solo_cara=[ ];
        continue
    end
    % ---
    % Select largest area
    areas=[out_a.Area];
    [Marea_max pam]=max(areas);
        
    R1 = sqrt(Marea_max/pi);

    subplot(211)
    imagesc(la_imagen);
    colormap gray
    hold on

    centro=round(out_a(pam).Centroid);
    Xfirst=centro(1);
    Yfirst=centro(2);

    isFirstFrame = false;
    
    else
%% Checking the eye condition 
    subplot(212)
    piel=~im2bw(la_imagen,0.13);
    %     --
    for i = 1:90
            for j = 1:90
                piel(j,i) = false;
            
            end
     end
    imshow(piel)
    
    piel=bwmorph(piel,'close');
    piel=bwmorph(piel,'open');
    piel=bwareaopen(piel,200);
    piel=imfill(piel,'holes');
    imagesc(piel);
    % Tagged objects in BW image
    L=bwlabel(piel);
    % Get areas and tracking rectangle
    out_a=regionprops(L);
    % Count the number of objects
    N=size(out_a,1);
    if N < 1 || isempty(out_a) % Returns if no object in the image
       
        solo_cara=[ ];
        continue
    end
    % ---
    % Select larger area
    areas=[out_a.Area];
    [area_max pam]=max(areas);
    subplot(211)
    imagesc(la_imagen);
    colormap gray
    hold on
    centro=round(out_a(pam).Centroid);
    X=centro(1);
    Y=centro(2);
  %% Classifying the eye condition by open-> Inverse of close -> %40, %30 and %20 open..   
    if  area_max >(Marea_max*0.4) && Yfirst-R1*2<Y && Y<Yfirst+R1*2 && Xfirst-R1<X
        
        rectangle('Position',out_a(pam).BoundingBox,'EdgeColor',[1 0 0],...
        'Curvature', [1,1],'LineWidth',2)
        plot(X,Y,'g+')     
        text(X+10,Y,['(',num2str(X),',',num2str(Y),')'],'Color',[1 1 1])
        title('Eyes Open');
        fprintf("The area now: %.3f\n",area_max);
        openEyes = openEyes +1;
    
    elseif  area_max >(Marea_max*0.3) && area_max <=(Marea_max*0.4) && Yfirst-R1<Y && Y<Yfirst+R1 && Xfirst-R1<X
        
        rectangle('Position',out_a(pam).BoundingBox,'EdgeColor',[1 0 0],...
        'Curvature', [1,1],'LineWidth',2)
        plot(X,Y,'g+')     
        text(X+10,Y,['(',num2str(X),',',num2str(Y),')'],'Color',[1 1 1])
        title('Eyes Open');
        openEyes70 = openEyes70 +1;

    elseif  area_max >=(Marea_max*0.2) && area_max <=(Marea_max*0.3) && Yfirst-R1<Y &&  Y<Yfirst+R1 && Xfirst-R1<X
        
        rectangle('Position',out_a(pam).BoundingBox,'EdgeColor',[1 0 0],...
        'Curvature', [1,1],'LineWidth',2)
        plot(X,Y,'g+')     
        text(X+10,Y,['(',num2str(X),',',num2str(Y),')'],'Color',[1 1 1])
        title('Eyes Open');
        openEyes80 = openEyes80 +1;
    else
        
        plot(X,Y)     
        title('Eye Closed');
    end 
    end
        
        hold off
        % --
        drawnow;
    iterations = iterations +1;
end 
        
        

%% Classify PERCLOSE rate and find the PERCLOSE %
         PERCLOSE60 = ((iterations-openEyes)/iterations)*100;
         PERCLOSE70 = ((iterations-(openEyes+openEyes70))/iterations)*100;
         PERCLOSE80 = ((iterations-(openEyes+openEyes70+openEyes80))/iterations)*100;
         fprintf("P60 ratio: %.3f\n", PERCLOSE60);
         fprintf("P70 ratio: %.3f\n", PERCLOSE70); 
         fprintf("P80 ratio: %.3f\n", PERCLOSE80);