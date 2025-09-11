clear all; close all; clc

% Load data
twix_obj_1 = mapVBVD('C:\Users\Mohammed Karem\Desktop\Spring23-24\EEE474\Project\gre_scans\meas_MID83_GRE_lb_1_FID8266.dat');
twix_obj_2 = mapVBVD('C:\Users\Mohammed Karem\Desktop\Spring23-24\EEE474\Project\gre_scans\meas_MID84_GRE_lb_2_FID8267.dat');
twix_obj_3 = mapVBVD('C:\Users\Mohammed Karem\Desktop\Spring23-24\EEE474\Project\gre_scans\meas_MID85_GRE_lb_3_FID8268.dat');

%% Visualize coil phase images

do_unwrapping = false;
plot_all_channels = false;

data_1 = twix_obj_1.image.unsorted();
data_1 = permute(data_1, [1, 3, 2]);

nCoils = size(data_1, 3);

data_2 = twix_obj_2.image.unsorted();
data_2 = permute(data_2, [1, 3, 2]);
data_3 = twix_obj_3.image.unsorted();
data_3 = permute(data_3, [1, 3, 2]);

% to become compatible with the ICE reco the exmple sequence now uses an
% inverted phase encoding ordering, so a reversal of the dimension is needed
data_1 = flip(data_1, 2);
data_2 = flip(data_2, 2);
data_3 = flip(data_3, 2);

images_1 = zeros(size(data_1));
images_2 = zeros(size(data_2));
images_3 = zeros(size(data_3));

avg_1 = zeros(size(data_1, [1,2]));
avg_2 = zeros(size(avg_1));
avg_3 = zeros(size(avg_1));

if nCoils > 1 && plot_all_channels
    figure
end

% https://www.mathworks.com/matlabcentral/fileexchange/45393-phase-unwrapping-using-recursive-orthogonal-referring-puror
debug_PUROR = 0;
th4unwrap = 0.0; % the pixels included in the unwrapping mask
th4supp = 8.0; % the pixels included in the support mask
th4stack = 16.0; % the pixels used for stacking the multiple slices

for ii = 1:nCoils
    images_1(:,:,ii) = ifftshift(ifft2(data_1(:,:,ii))).';
    images_2(:,:,ii) = ifftshift(ifft2(data_2(:,:,ii))).';
    images_3(:,:,ii) = ifftshift(ifft2(data_3(:,:,ii))).';
    if nCoils > 1
        if do_unwrapping == false
            angle_1 = angle(images_1(:,:,ii));
            angle_2 = angle(images_2(:,:,ii));
            angle_3 = angle(images_3(:,:,ii));
        else
            th4noise_1 = NoiseEstimation(images_1(:,:,ii));
            [mask4unwrap_1, mask4supp_1, mask4stack_1] = mask_generation(images_1(:,:,ii), th4noise_1, th4unwrap, th4supp, th4stack);
            angle_1 = PUROR2D(images_1(:,:,ii), mask4unwrap_1, mask4supp_1, mask4stack_1, debug_PUROR );
            th4noise_2 = NoiseEstimation(images_2(:,:,ii));
            [mask4unwrap_2, mask4supp_2, mask4stack_2] = mask_generation(images_2(:,:,ii), th4noise_2, th4unwrap, th4supp, th4stack);
            angle_2 = PUROR2D(images_2(:,:,ii), mask4unwrap_2, mask4supp_2, mask4stack_2, debug_PUROR );
            th4noise_3 = NoiseEstimation(images_3(:,:,ii));
            [mask4unwrap_3, mask4supp_3, mask4stack_3] = mask_generation(images_3(:,:,ii), th4noise_3, th4unwrap, th4supp, th4stack);
            angle_3 = PUROR2D(images_3(:,:,ii), mask4unwrap_3, mask4supp_3, mask4stack_3, debug_PUROR );
        end
        avg_1 = avg_1 + 1/nCoils*angle_1;
        avg_2 = avg_2 + 1/nCoils*angle_2;
        avg_3 = avg_3 + 1/nCoils*angle_3;
        if plot_all_channels
            subplot(2,2,1)
            imshow(angle_1, []); colorbar; colormap('jet')
            title(['TE1 RF Coil ' num2str(ii)]);
            subplot(2,2,2)
            imshow(angle_2, []); colorbar; colormap('jet')
            title(['TE2 RF Coil ' num2str(ii)]);
            subplot(2,2,3)
            imshow(angle_3, []); colorbar; colormap('jet')
            title(['TE3 RF Coil ' num2str(ii)]);
            pause(0.05)
        end
        %         imwrite(tmp, ['img_coil_' num2str(ii) '.png'])
    end
end

% imshow(abs(image1(:,:,ii)), []);
% image1 = ifftshift(ifft2(sos));
%% Average combination
figure
if do_unwrapping == false
    subplot(2, 2, 1)
    imshow(avg_1,[]); colorbar; colormap('hsv')
    title('TE1 Combined Phase')
    subplot(2, 2, 2)
    imshow(avg_2,[]); colorbar; colormap('hsv')
    title('TE2 Combined Phase')
    subplot(2, 2, 3)
    imshow(avg_3,[]); colorbar; colormap('hsv')
    title('TE3 Combined Phase')
else
    subplot(2, 2, 1)
    imshow(avg_1.*mask,[]); 
    colorbar
    % colormap('jet')
    % title('Phase Image (TE')
    subplot(2, 2, 2)
    imshow(avg_2.*mask,[]); 
    colorbar;
    % colormap('jet')
    %title('TE2 Combined Phase')
    subplot(2, 2, 3)
    imshow(avg_3.*mask,[]); 
    colorbar;
    %colormap('jet')
    %title('TE3 Combined Phase')
end

% imwrite(sos, ['my_se3.png'])
%% Estimate Theta
theta = zeros(size(images_1, 1), size(images_1, 2), 3);

theta(:,:,2) = dot(images_1, conj(images_2), 3);
theta(:,:,3) = dot(images_1, conj(images_3), 3);

if do_unwrapping == false
    theta = angle(theta);
else
    th4noise = NoiseEstimation(theta);
    [mask4unwrap, mask4supp, mask4stack] = mask_generation(theta, th4noise, th4unwrap, th4supp, th4stack);
    theta = PUROR2D(theta, mask4unwrap, mask4supp, mask4stack, debug_PUROR );
end

figure
subplot(2,1,1)
imshow(theta(:,:,2), []); cb=colorbar; colormap('jet');cb.Label.String  = 'rad';
%title('Theta n=1 m=2')
subplot(2,1,2)
imshow(theta(:,:,3), []); cb=colorbar; colormap('jet'); cb.Label.String  = 'rad';
%title('Theta n=1 m=3')

%% Sum of squares combination --> W
M = zeros(size(images_1, 1), size(images_1, 2), 3);

M(:,:,1) = abs(sqrt(sum((images_1).^2, 3)));

M(:,:,2) = abs(sqrt(sum((images_1 - images_2).^2, 3)));

M(:,:,3) = abs(sqrt(sum((images_1 - images_3).^2, 3)));

figure
subplot(2,2,1)
imshow(M(:,:,1), []); colorbar
title('Combined image for TE1')
subplot(2,2,2)
imshow(M(:,:,2), []); colorbar
title('Combined image difference between TE1 and TE2')
subplot(2,2,3)
imshow(M(:,:,3), []); colorbar
title('Combined image difference between TE1 and TE3')
% imwrite(sos, ['my_se3.png'])

% Estimate W
W = M.^2 ./ (M.^2 + M(:,:,1).^2);

%% Estimate Delta B
gamma = 42.58e6; %Hz/T
TE1 = 5e-3; %sec
TE2 = 12e-3; %sec
TE3 = 20e-3; %sec
B0 = 3; %T; Siemens

numerator = theta(:,:,2) .* (TE2 - TE1) .* W(:,:,2);
numerator = numerator + theta(:,:,3) .* (TE3 - TE1) .* W(:,:,3);

denomenator = (TE2 - TE1).^2 .* W(:,:,2);
denomenator = denomenator + (TE3 - TE1).^2 .* W(:,:,3);

DeltaB = 1/(2*pi*gamma) .* numerator ./ denomenator; %T
 DeltaB = DeltaB / B0 * 1e6; %ppm

% Average all images to boost SNR
avg_sos = (abs(sqrt(sum((images_1).^2, 3))) + abs(sqrt(sum((images_2).^2, 3))) + abs(sqrt(sum((images_3).^2, 3))))/3;
avg_sos = avg_sos ./ max(avg_sos(:)); % normalize for effective binarization
bin_sos = imbinarize(avg_sos, graythresh(avg_sos)/4); % Otsu threshold
% imshow(avg_sos, []); colorbar
% imshow(bin_sos, []); colorbar

% some image processing to make the mask "cleaner"
se = strel('disk', 50); % need this for imclose to work 
mask = bwareaopen(bin_sos, 10); % remove small speckles
mask = imclose(mask, se); % remove holes
% imshow(mask, []); colorbar

figure
subplot(2,2,1)
imshow(DeltaB, []); cb = colorbar; colormap('jet'); cb.Label.String  = 'ppm';
%title('\Delta B')
subplot(2,2,4); colormap('gray')
imshow(mask, []); colorbar
title('Mask')
subplot(2,2,2)
imshow(DeltaB.*mask, []); cb = colorbar; colormap('jet'); cb.Label.String  = 'ppm';
%title('\Delta B (masked)')