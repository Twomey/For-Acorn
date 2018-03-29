% Peak fire month file (map); calculation and netcdf output

typetag = {'wildland';'agriculture';'otherpres'};
yeartag = {'2001';'2002';'2003';'2004';'2005';'2006';'2007';'2008';...
    '2009';'2010'};
monthtag = {'01';'02';'03';'04';'05';'06';'07';'08';'09';'10';'11';'12'};

start_lon = -130; end_lon = -65;
start_lat = 50; end_lat = 20;

newxdata = [start_lon:0.5:end_lon];
newydata = [start_lat:-0.5:end_lat]';
nlon = 131; nlat = 61;

xdata_2d = zeros(nlat,nlon);
ydata_2d = zeros(nlat,nlon);

for i =1:nlon; ydata_2d(:,i) = newydata; end;
for i =1:nlat; xdata_2d(i,:) = newxdata; end;

for it = 1:length(typetag)
    
    temp = zeros(nlat,nlon,12);
    
    for iy = 1:length(yeartag)
        
        for im = 1:length(monthtag)
            
        openname = ['/Users/hsiaowen/Documents/US_Trend/For_DougM',...
           '/monthlyoutput/',typetag{it},'_',yeartag{iy},monthtag{im},'.nc'];
        ncid = netcdf.open(openname,'NC_NOWRITE'); 

         [varname, xtype, varDimIDs, varAtts] = netcdf.inqVar(ncid,0); % lon
            varid = netcdf.inqVarID(ncid,varname);
            xdata = netcdf.getVar(ncid,varid);
         
         [varname, xtype, varDimIDs, varAtts] = netcdf.inqVar(ncid,1); % lat
            varid = netcdf.inqVarID(ncid,varname);
            ydata = netcdf.getVar(ncid,varid);
        
         [varname, xtype, varDimIDs, varAtts] = netcdf.inqVar(ncid,2); % var
            varid = netcdf.inqVarID(ncid,varname);
            data = netcdf.getVar(ncid,varid);
            data(data==-9999)=0;
            
        netcdf.close(ncid);
       
        data(isnan(data))=0;
        temp(:,:,im) = temp(:,:,im) + data(:,:);
        
        end
    end
    
    meanvalue = temp ./length(yeartag);
    
    peakmonth_result = zeros(nlat,nlon);
    
    for ilat = 1:nlat
        for ilon = 1:nlon
            if sum(meanvalue(ilat,ilon,:))~=0
                grid_value = squeeze(meanvalue(ilat,ilon,:));
                grid_peakvalue = max(grid_value);
                
                num_month = find(grid_value==grid_peakvalue);
                
                if length(num_month) ==1
                    peakmonth_result(ilat,ilon)...
                    = num_month;
                else
                    peakmonth_result(ilat,ilon)...
                    = num_month(1);
                end
                
            end
        end
    end
    
    
    
    % Save netcdf data
    
    savename = ['/Users/hsiaowen/Documents/US_Trend/For_DougM',...
           '/monthlyoutput/peakmonth_',typetag{it},'.nc'];
    ncid = netcdf.create(savename,'CLOBBER'); 

        xdim = netcdf.defDim(ncid,'lon',nlon);
        ydim = netcdf.defDim(ncid,'lat',nlat);

        xvarid = netcdf.defVar(ncid,'longtitude','double',[ydim,xdim]);
        yvarid = netcdf.defVar(ncid,'latitude','double',[ydim,xdim]);

        varid = netcdf.defVar(ncid,'peak_month','double',[ydim,xdim]);
        netcdf.endDef(ncid);

        netcdf.putVar(ncid,xvarid,xdata_2d);
        netcdf.putVar(ncid,yvarid,ydata_2d);

        peakmonth_result(peakmonth_result==0)=-9999;
        netcdf.putVar(ncid,varid,peakmonth_result);

        netcdf.reDef(ncid);
        
        globvarid = netcdf.getConstant('NC_GLOBAL');
        netcdf.putAtt(ncid,globvarid,'Nodata =',-9999);
        netcdf.endDef(ncid);
        
        netcdf.close(ncid);
       
    
end
