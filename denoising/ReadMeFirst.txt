--------------------------------------------------------
What this code do :

This code demonstrates impulse noise reduction from hyperspectral  images.

It solves following optimization problem :
 min_X || Y-X||_1 + lambda ||Dh*X||_1 + lamdba ||Dv*X||_1 + mu ||X||_*
 X: Hyperspectral image
 Y: Compressive measurements
 Dh, Dv: Horizontal and vertical finite difference operators
||X||_* : Nuclear norm of matrix X

--------------------------------
How to Run this code :

Just run the demoDenoising.m file. It takes around 15 seconds  to show the output on 160x160x64  hyperspectral image. 

--------------------------------
File Description :

demoDenoising.m                  : Simply run this file to see how the code works.
funDenoising.m                : It is the main function which solves above problem using split-Bregman technique.
HyperSpectralPatch.mat  : This is the portion of Washington DC mall image downloaded from here:
                          link: https://engineering.purdue.edu/%7ebiehl/MultiSpec/hyperspectral.html 
--------------------------------------------------------------------
Contact Information:

This code is released just to promote reproducible research and is not very robust.
If you face difficulty in running this code then please feel free to contact us. 

Hemant Kumar Aggarwal( jnu.hemant@gmail.com )  
Snigdha Tariyal (snigdha1491@iiitd.ac.in)



