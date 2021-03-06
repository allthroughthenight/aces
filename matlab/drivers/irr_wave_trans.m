clear all
clc

%% ACES Update to MATLAB
%-------------------------------------------------------------
% Driver for Irregular Wave Transformation (page 3-2 of ACES User's 
% Guide). Yields cumulative probability distributions of wave heights as
% a field of irregular waves propagate from deep water through the surf
% zone.

% Updated by: Mary Anderson, USACE-CHL-Coastal Processes Branch
% Date Created: July 1, 2011
% Date Verified: June 8, 2012 

% Requires the following functions:
% ERRWAVBRK1
% GODA
% GODA2
% GODA3
% GODA4
% GODA5

% MAIN VARIABLE LIST:
%   INPUT
%   Ho: significant deepwater wave height
%   d: water depth
%   Ts: significant wave period
%   cotnsl: cotangent of nearshore slope
%   direc: principle direction of incident wave spectrum

%   OUTPUT
%   Hs: significant wave height
%   Hbar: mean wave height
%   Hrms: root-mean-square wave height
%   H10: average of highest 10 percent of all waves
%   H2: average of highest 2 percent of all waves
%   Hmax: maximum wave height
%   Ks: shoaling coefficient
%   psi: root-mean-square surf beat
%   Sw: wave setup
%   HoLo: deepwater wave steepness
%   Kr: effective refraction coefficient
%   doH: ratio of water depth to deepwater wave height
%   doL: relative water depth

%   OTHERS
%-------------------------------------------------------------

SET_PATHS();

[single_case] = USER_INPUT_SINGLE_MULTI_CASE();

[metric, g, labelUnitDist, labelUnitWt] = USER_INPUT_METRIC_IMPERIAL();

% Single case input
if single_case
    if metric
        [Ho] = USER_INPUT_DATA_VALUE('Enter Ho: significant deepwater wave height (m): ', 0.61, 6.09);
    else
        [Ho] = USER_INPUT_DATA_VALUE('Enter Ho: significant deepwater wave height (ft): ', 2.0, 20.0);
    end

    [d] = USER_INPUT_DATA_VALUE(['Enter d: water depth (' labelUnitDist '): '], 10.0, 5000.0);

    [Ts] = USER_INPUT_DATA_VALUE('Enter Ts: significant wave period (s): ', 4.0, 16.0);
    
    [cotnsl] = USER_INPUT_DATA_VALUE('Enter cotnsl: cotangent of nearshore slope: ', 30.0, 100.0);
    
    [direc] = USER_INPUT_DATA_VALUE('Enter direc: principle direction of incident wave spectrum (deg): ', -75.0, 75.0);

    numCases = 1;
else
    if metric
        multiCaseData = {'Ho: significant deepwater wave height (m)', 0.61, 6.09};
    else
        multiCaseData = {'Ho: significant deepwater wave height (ft)', 2.0, 20.0};
    end
    
    multiCaseData = [multiCaseData;...
        {['d: water depth (' labelUnitDist ')'], 10.0, 5000.0;...
        'Ts: significant wave period (s)', 4.0, 16.0;...
        'cotnsl: cotangent of nearshore slope', 30.0, 100.0;...
        'direc: principle direction of incident wave spectrum (deg)', -75.0, 75.0}];
    [varData, numCases] = USER_INPUT_MULTI_MODE(multiCaseData);
    
    HoList = varData(1, :);
    dList = varData(2, :);
    TsList = varData(3, :);
    cotnslList = varData(4, :);
    direcList = varData(5, :);
end

exporter = EXPORTER('output/exporterIrrWaveTrans.txt');

% Meter to centimeter constant
m2cm=100;
g=g*m2cm;

% File Output
fileOutputArgs = {};
[fileOutputData] = USER_INPUT_FILE_OUTPUT(fileOutputArgs);

if fileOutputData{1}
    fId = fopen('output\irr_wave_trans.txt', 'wt');

    fprintf(fId, 'Wave Height versus Cumulative Probability\nDistribution of Exceedance\n\n');
end

for loopIndex = 1:numCases
    if ~single_case
        Ho = HoList(loopIndex);
        d = dList(loopIndex);
        Ts = TsList(loopIndex);
        cotnsl = cotnslList(loopIndex);
        direc = direcList(loopIndex);
    end
    
    errorMsg = '';
    
   % Convert meter input to centimeters
    Ho=Ho*m2cm;
    d=d*m2cm;

    [Hb]=ERRWAVBRK1(d,0.78);
%     assert(Ho<Hb,'Error: Input wave broken (Hb = %6.2f m)',Hb)
    if not(Ho<Hb)
        errorMsg = sprintf('Error: Input wave broken (Hb = %6.2f m)',Hb);
        disp(errorMsg);
    else
        [Ks,Kr,Hmax,Hrms,Hbar,Hs,H10,H02,SBrms,HoLo,dLo,dHo,deepd,theta,Sw,Hxo,cdfo,Hx,cdfx]=GODA(Ho,d,Ts,cotnsl,direc,g);

        fprintf('\t\t %s \t %s \t\t %s \n','Subject','Deep','Units')
        fprintf('%s \t\t %-6.2f \t %-6.2f \t %s \n','Hs',Hs(2)/m2cm,Hs(1)/m2cm,labelUnitDist)
        fprintf('%s \t %-6.2f \t %-6.2f \t %s \n','Hmean',Hbar(2)/m2cm,Hbar(1)/m2cm,labelUnitDist)
        fprintf('%s \t %-6.2f \t %-6.2f \t %s \n','Hrms',Hrms(2)/m2cm,Hrms(1)/m2cm,labelUnitDist)
        fprintf('%s \t %-6.2f \t %-6.2f \t %s \n','H10%',H10(2)/m2cm,H10(1)/m2cm,labelUnitDist)
        fprintf('%s \t %-6.2f \t %-6.2f \t %s \n','H02%',H02(2)/m2cm,H02(1)/m2cm,labelUnitDist)
        fprintf('%s \t %-6.2f \t %-6.2f \t %s \n','Hmax%',Hmax(2)/m2cm,Hmax(1)/m2cm,labelUnitDist)
        disp(' ')
        fprintf('%s \t\t %-6.4f \t %-6.4f \n','Ks',Ks(2),Ks(1))
        fprintf('%s \t %-6.4f \t %-6.4f \t %s \n','SBrms',SBrms(2)/m2cm,SBrms(1)/m2cm,labelUnitDist)
        fprintf('%s \t\t %-6.4f \t %-6.4f \t %s \n','Sw',Sw(2)/m2cm,Sw(1)/m2cm,labelUnitDist)
        fprintf('%s \t %-6.4f \t %-6.4f \n','Ho/Lo',HoLo(1),HoLo(1))
        fprintf('%s \t\t %-6.4f \n','Kr',Kr(1))
        fprintf('%s \t %-6.4f \t %-6.4f \n','d/Ho',dHo(2),dHo(1))
        fprintf('%s \t %-6.4f \t %-6.4f \n','d/Lo',dLo(2),dLo(1))
    end
    
    if fileOutputData{1}
        if ~single_case
            fprintf(fId, 'Case #%d\n\n', loopIndex);
        end
        
        fprintf(fId, 'Input\n');
        fprintf(fId, 'Ho\t%6.2f %s\n', Ho/m2cm, labelUnitDist);
        fprintf(fId, 'd\t%6.2f %s\n', d/m2cm, labelUnitDist);
        fprintf(fId, 'Ts\t%6.2f s\n', Ts);
        fprintf(fId, 'cotnsl\t%6.2f\n', cotnsl);
        fprintf(fId, 'direc\t%6.2f deg\n\n', direc);
        
        if length(errorMsg) > 0
            fprintf(fId, '%s\n', errorMsg);
        else
            fprintf(fId, '\t%s\t\t%s\t%s\n','Subject','Deep','Units');
            fprintf(fId, '%s\t%6.2f\t\t%6.2f\t%s\n','Hs',Hs(2)/m2cm,Hs(1)/m2cm,labelUnitDist);
            fprintf(fId, '%s\t%6.2f\t\t%6.2f\t%s\n','Hmean',Hbar(2)/m2cm,Hbar(1)/m2cm,labelUnitDist);
            fprintf(fId, '%s\t%6.2f\t\t%6.2f\t%s\n','Hrms',Hrms(2)/m2cm,Hrms(1)/m2cm,labelUnitDist);
            fprintf(fId, '%s\t%6.2f\t\t%6.2f\t%s\n','H10%',H10(2)/m2cm,H10(1)/m2cm,labelUnitDist);
            fprintf(fId, '%s\t%6.2f\t\t%6.2f\t%s\n','H02%',H02(2)/m2cm,H02(1)/m2cm,labelUnitDist);
            fprintf(fId, '%s\t%6.2f\t\t%6.2f\t%s\n','Hmax%',Hmax(2)/m2cm,Hmax(1)/m2cm,labelUnitDist);

            fprintf(fId, '\n');

            fprintf(fId, '%s\t%6.4f\t\t%6.4f\n','Ks',Ks(2),Ks(1));
            fprintf(fId, '%s\t%6.4f\t\t%6.4f\t%s\n','SBrms',SBrms(2)/m2cm,SBrms(1)/m2cm,labelUnitDist);
            fprintf(fId, '%s\t%6.4f\t\t%6.4f\t%s\n','Sw',Sw(2)/m2cm,Sw(1)/m2cm,labelUnitDist);
            fprintf(fId, '%s\t%6.4f\t\t%6.4f\n','Ho/Lo',HoLo(1),HoLo(1));
            fprintf(fId, '%s\t%6.4f\n','Kr',Kr(1));
            fprintf(fId, '%s\t%6.4f\t\t%6.4f\n','d/Ho',dHo(2),dHo(1));
            fprintf(fId, '%s\t%6.4f\t\t%6.4f\n','d/Lo',dLo(2),dLo(1));
        end
        
        if loopIndex < numCases
            fprintf(fId, '\n--------------------------------------\n\n');
        end
        exportData = {Ho/m2cm, d/m2cm, Ts, cotnsl, direc };
        if length(errorMsg) > 0
            exportData = [exportData {errorMsg}];
        else
            exportData = [exportData {Hs(2)/m2cm, Hs(1)/m2cm,...
                Hbar(2)/m2cm, Hbar(1)/m2cm, Hrms(2)/m2cm,Hrms(1)/m2cm,...
                H10(2)/m2cm,H10(1)/m2cm, H02(2)/m2cm,H02(1)/m2cm,...
                Hmax(2)/m2cm,Hmax(1)/m2cm, Ks(2),Ks(1),...
                SBrms(2)/m2cm,SBrms(1)/m2cm, Sw(2)/m2cm,Sw(1)/m2cm,...
                HoLo(1),Kr(1),dHo(2),dHo(1),dLo(2),dLo(1)}];
        end
        exporter.writeData(exportData);
    end
end

if fileOutputData{1}
    fclose(fId);
end

exporter.close();

if single_case && length(errorMsg) == 0
    plot1Hxo = Hxo/m2cm;
    figure(1)
    plot(plot1Hxo,cdfo)
    title('Deep Water')
    xlabel(['H [' labelUnitDist ']'])
    ylabel('CDF')

    plot2Hx = Hx/m2cm;
    figure(2)
    plot(plot2Hx,cdfx)
    title('Subject Depth')
    xlabel(['H [' labelUnitDist ']'])
    ylabel('CDF2')

    if fileOutputData{1}
        fId = fopen('output\irr_wave_trans_plot.txt', 'wt');

        fprintf(fId, 'Wave Height versus Cumulative Probability\nDistribution of Exceedance\n\n');
        
        fprintf(fId, 'Deep Water\tWater Depth = %-6.2f %s\n', d/m2cm, labelUnitDist);
        fprintf(fId, 'H (%s)\tCDF\tH(%s)\tCDF2\n', labelUnitDist, labelUnitDist);

        for loopIndex2 = 1:length(plot1Hxo)
            fprintf(fId, '%-6.3f\t%-6.3f\t%-6.3f\t%-6.3f\n',...
                plot1Hxo(loopIndex2),...
                cdfo(loopIndex2),...
                plot2Hx(loopIndex2),...
                cdfx(loopIndex2));
        end
    end
end