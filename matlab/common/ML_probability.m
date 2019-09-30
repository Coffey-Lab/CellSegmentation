function new = ML_probability (probs, LowAreaLim, thresh)

%grab the red channel for epithelim
tm=probs(:,:,1);

tm=mat2gray(tm);

%set probability threshold to .45
tm=tm>thresh;
if max(tm(:))==0
    output=tm;
    return
end
%morphological filtering to smooth edges
new=bwareaopen(tm,500);
if max(new(:))==0
    output=new;
    return
end

new=imopen(new, strel('disk',5));
new=imerode (new,strel('disk',3));
%new=closesmallholes (new,2000);
new=imclose (new,strel('disk',7));


%additional filtering
new = MaskFiltration( new , LowAreaLim );

%morphological filtering to smooth edges
new=imerode (new, strel('disk',3));
new=closesmallholes (new,1000);
new=imopen(new, strel('disk',3));
new=imclose(new, strel('disk',3));
new=bwareaopen(new,500);
new=imdilate(new, strel('disk',4));


end