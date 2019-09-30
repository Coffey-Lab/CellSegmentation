%'C:\Users\Ken Lau\Dropbox (VU Basic Sciences)\LauLab\susie\pics\Duo Images\membranes'
%k_size = 1, k_area=0.00001, LowAreaLim = 0.01
function output = tubsegbatch (epi,  k_size , k_area, LowAreaLim)

tm=TubeMaskADV2batch (epi,k_size , k_area);
tm=im2bw(tm);
if max(tm(:))==0
    output=tm;
    return
end
new=closesmallholes (tm,2000);
new = MaskFiltration( new , LowAreaLim );
new=imclose (new,strel('disk',7));
new=imerode (new,strel('disk',3));
%se = strel('disk',3);
%new=imerode (new,se);
new=closesmallholes (new,1000);
output=new;

end