function y_spl = calculate_1_3_octave(y,fs,ref,fc)

switch nargin
    case 3
        fc = [63	80	100	125	160	200	250	315	400	500	630	800	1000	1250	...
            1600 2000 2500 3150	4000	5000	6300	8000];%	10000];%	12500];
        
    case 2
        ref = .0000011219; % for josh's 70 dB SPL cal tone
        fc = [63	80	100	125	160	200	250	315	400	500	630	800	1000	1250	...
            1600 2000 2500 3150	4000	5000	6300	8000];%	10000];%	12500];
    case 1
        fs=22050;
        ref = .0000011219; % for josh's 70 dB SPL cal tone
        fc = [63	80	100	125	160	200	250	315	400	500	630	800	1000	1250	...
            1600 2000 2500 3150	4000	5000	6300	8000];%	10000];%	12500];
end

y_spl = NaN(1,length(fc)+1); % last column is the overall level

% create 1/3 octave filters
for i = 1:length(fc)
    [B(i,:),A(i,:)] = oct3dsgn(fc(i),fs);
end

for j = 1:length(fc)
    try
        y_spl(j) = calculate_spl(filter(B(j,:),A(j,:),y),ref);
    catch
        keyboard
    end
end
y_spl(end) = calculate_spl(y,ref);


end

