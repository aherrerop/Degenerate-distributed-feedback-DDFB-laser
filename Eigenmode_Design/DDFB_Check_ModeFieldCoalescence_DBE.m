function [Coalescence_Parameter] = DDFB_Check_ModeFieldCoalescence_DBE(fullpathexports)

% fullpathexports = 'C:\Users\AHerrero\Documents\GitHub\FullWave-SIP-Waveguide\Corrugated_Waveguide\3D\Eigenmode\Eigenmode_CW_CheckModes_SuperposeModes\Export\3d';
E_field_data_mode1 = h5read([fullpathexports '\Mode 1_e.h5'],'/E-Field/');
E_field_data_mode2 = h5read([fullpathexports '\Mode 2_e.h5'],'/E-Field/');
E_field_data_mode3 = h5read([fullpathexports '\Mode 3_e.h5'],'/E-Field/');
E_field_data_mode4 = h5read([fullpathexports '\Mode 4_e.h5'],'/E-Field/');

[X_pos, Y_pos, Z_pos] = size(E_field_data_mode1.x.re);

E_x1 = E_field_data_mode1.x.re + 1i*E_field_data_mode1.x.im;
E_y1 = E_field_data_mode1.y.re + 1i*E_field_data_mode1.y.im;
E_z1 = E_field_data_mode1.z.re + 1i*E_field_data_mode1.z.im;

E_x2 = E_field_data_mode2.x.re + 1i*E_field_data_mode2.x.im;
E_y2 = E_field_data_mode2.y.re + 1i*E_field_data_mode2.y.im;
E_z2 = E_field_data_mode2.z.re + 1i*E_field_data_mode2.z.im;

E_x3 = E_field_data_mode3.x.re + 1i*E_field_data_mode3.x.im;
E_y3 = E_field_data_mode3.y.re + 1i*E_field_data_mode3.y.im;
E_z3 = E_field_data_mode3.z.re + 1i*E_field_data_mode3.z.im;

E_x4 = E_field_data_mode4.x.re + 1i*E_field_data_mode4.x.im;
E_y4 = E_field_data_mode4.y.re + 1i*E_field_data_mode4.y.im;
E_z4 = E_field_data_mode4.z.re + 1i*E_field_data_mode4.z.im;

for xx = 1:X_pos
    for yy = 1:Y_pos
        for zz = 1:Z_pos
            
            E_perp_Mode1 = [E_x1(xx,yy,zz) E_y1(xx,yy,zz) E_z1(xx,yy,zz)];
            E_perp_Mode2 = [E_x2(xx,yy,zz) E_y2(xx,yy,zz) E_z2(xx,yy,zz)];
            E_perp_Mode3 = [E_x3(xx,yy,zz) E_y3(xx,yy,zz) E_z3(xx,yy,zz)];
            E_perp_Mode4 = [E_x4(xx,yy,zz) E_y4(xx,yy,zz) E_z4(xx,yy,zz)];

            E_norm_Mode1 = E_perp_Mode1/norm(E_perp_Mode1);
            E_norm_Mode2 = E_perp_Mode2/norm(E_perp_Mode2);
            E_norm_Mode3 = E_perp_Mode3/norm(E_perp_Mode3);
            E_norm_Mode4 = E_perp_Mode4/norm(E_perp_Mode4);

            V1 = E_norm_Mode1;
            V2 = E_norm_Mode2;
            V3 = E_norm_Mode3;
            V4 = E_norm_Mode4;

            C12=abs(acos(abs(sum(V1.*conj(V2)))));
            C23=abs(acos(abs(sum(V2.*conj(V3)))));
            C31=abs(acos(abs(sum(V3.*conj(V1)))));
            C14=abs(acos(abs(sum(V1.*conj(V4)))));
            C24=abs(acos(abs(sum(V2.*conj(V4)))));
            C34=abs(acos(abs(sum(V3.*conj(V4)))));

            sigma(xx,yy,zz)=(C12^2+C23^2+C31^2+C14^2+C24^2+C34^2)^0.5;            
        end
    end
end

Coalescence_Parameter = sum(sigma(:));


end
