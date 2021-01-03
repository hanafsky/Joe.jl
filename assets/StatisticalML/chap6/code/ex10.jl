# This file was generated, do not modify it. # hide
u_seq = -6:0.02:6;
v_seq6 = spline6(x,y,u_seq);
v_seq11 = spline11(x,y,u_seq);
w_seq6 = spline6(x,y,u_seq;splinematrix=Joe.natural_spline_matrix);
w_seq11 = spline11(x,y,u_seq;splinematrix=Joe.natural_spline_matrix);