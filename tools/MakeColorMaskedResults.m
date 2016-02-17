function out = MakeColorMaskedResults(in, mask)

[outHeight, outWidth] = size(in);
dispR = in(:);
dispG = in(:);
dispB = in(:);
dispR(logical(~mask)) = 0;
dispG(logical(~mask)) = 1;
dispB(logical(~mask)) = 0;
dispR = reshape(dispR, outHeight, outWidth);
dispG = reshape(dispG, outHeight, outWidth);
dispB = reshape(dispB, outHeight, outWidth);
out = zeros(outHeight, outWidth,3);
out(:,:,1) = dispR;
out(:,:,2) = dispG;
out(:,:,3) = dispB;
