obj = VideoReader('awake_8blk.mp4');
NumberOfFrames = obj.NumFrames;
% 
openEyes=0; openEyes70=0; openEyes80=0;
iterations=0;
R1=0; R2=0;
la_imagen=read(obj,1);

la_imagenA = im2gray(la_imagen);
la_imagen = la_imagenA;
plot(la_imagenA)
la_imagen = imbinarize(la_imagen,0.17); 

% imshow(la_imagen);
% d=drawline;
% pos = d.Position;
% diffPos = diff(pos);
% dia = hypot(diffPos(1),diffPos(2));
% rad = dia/2;
% ra = cast(rad,"int8");

se = strel("disk",30);
bw = imclose(la_imagen,se);
imshow(bw)




%imshow(bw)


