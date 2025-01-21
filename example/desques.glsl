// Fork of "GCLH Fractal Spark Mandril #2f" by Yusef28. https://shadertoy.com/view/X3BXWD
// 2024-03-16 21:15:07

/*

INTRODUNCTION:
*****************************************************************************************************

This shader style is based on the coding styles of Shane and Evvvvil plus some ohter stuff
as over time I add my unique twist.

I came up with a template to help me iterate faster so here is a little guide on how that works.
What isn't covered in this guide is how to do texture mapping because there are a lot of different
ways based on the situation. WHen I used a ring shape I did a cyclincrical UV function for example.
Another easy one is triplanar blending you can find in a lot of shanes shaders.

The common function has some important functions as well as all the uv functions I've played with.
Buffer B is a multiscale truchet texture I've been using lately, bbut not used in this example.
Buffer A is the text generator for showing coordinates. More on that soon.





TEMPLATE GUIDE:
******************************************************************************************************
This shader can be used as a template to create aother KIFS fractals.

It has a built in work flow baed on "Development modes" which should be
set in different stages of development.

To set a development mode, just change the #define DEV_MODE to 1, 2 or 3

Development Modes:

1. Object before fractal Mode
This is the mode where you create an interesting shape using the code in the "tile" function.
You create distance functions but also pair them in a vec2 with an id. The id is linked to
a color-roughness pair in the "Object[] Materials " object which you can also adjust to your liking.


2. DEV_MODE 2 is the fractal fly through. So maybe these are out of order but it's nice to see what
you made right after the object creation stage.

3. Mode 3 is the mouse adjust mode. You get to see coordinates in the top right hand corner based on
where you click the mouse on the screen. This let's you set up transitions between different fractals
in the Camera Position Object



The last imporatnt thing for getting something unique up is the
:fractal_position: function whcih does the work of folding and rotating the space to make
the kaleidescopic effect.

The "Camera Position" object pairs feed in here and the transitions happen here,
To get a new base folding-rotation sequence you can go to this part of the function
"

if(DEV_MODE > 1.){

        p.xz = mod(p.xz,40.)-20.;
        for(int i=0;i<6;i++){
            p.xz*=rot(mm.x*float(i));
            p.xy*=rot(mm.y*float(i));
            p=abs(p)-vec3(2.6,5.2,5.1);
            //p.x -= 0.2+sin(op.z)*0.4;
            p=abs(p)-vec3(4.8,5.,5.5);

        }
    }

"

and play with the   p=abs(p)-vec3(4.8,5.,5.5); lines (there are two of them)







END OF GUIDE




*/











/*
Development Modes
--------------------------
1. Object Before Fractal
2. Fractal Fly Through
3. Mouse Adjust Fractal_P
*/

#define FAR 60.
#define DEV_MODE 2.

//the position of the camera for DEV_MODE = 1.
#define DEV_POSITION vec3(0.,1.,-5.);

#define PI 3.1415926
#define addH t = t.x < h.x ? t : h;
#define S smoothstep
float smin( float a, float b, float k )
{
	float h = clamp( 0.5 + 0.5*(b-a)/k, 0.0, 1.0 );
	return mix( b, a, h ) - k*h*(1.0-h);
}
float smax(float a, float b, float k)
{
    return smin(a, b, -k);
}
float rnd(vec2 p){
    vec2 seed = vec2(13.234, 72.1849);
    return fract(sin(dot(p,seed))*43251.1234);
}
//  1 out, 1 in...
float hash11(float p)
{
    p = fract(p * .1031);
    p *= p + 33.33;
    p *= p + p;
    return fract(p);
}
float rb(vec3 p, vec3 s, float r) {
    p = abs(p)-s;
	return length(max(p, 0.))+min(max(p.x, max(p.y, p.z)), 0.) - r;
}
float rbEdge(vec3 p, vec3 s, float r, float start, float end) {
    vec2 xzEdge = abs(p.xz)/s.xz;
    s.y -= S(start,end,xzEdge.x)*S(start,end,xzEdge.y)*s.y;
    p = abs(p)-s;
	return length(max(p, 0.))+min(max(p.x, max(p.y, p.z)), 0.) - r;
}

float sdTorus( vec3 p, vec2 t )
{
  vec2 q = vec2(length(p.xz)-t.x,p.y);
  return length(q)-t.y;
}
float cc( vec3 p, float h, float r )
{
  vec2 d = abs(vec2(length(p.xz),p.y)) - vec2(r,h);
  return min(max(d.x,d.y),0.0) + length(max(d,0.0)) - 0.03;
}

float ccEdge( vec3 p, float h, float r )
{
  float rEdge = r-smoothstep(0.9,0.8,abs(p.y)/h)*0.1;


  vec2 d = abs(vec2(length(p.xz),p.y)) - vec2(rEdge,h);
  float f = min(max(d.x,d.y),0.0) + length(max(d,0.0));

  return f-0.01;

}

mat2 rot(float a){
     float c = cos(a),s = sin(a);
     return mat2(c, -s, s, c);
}


/*
The way these work is you set DEV_MODE to 3 and the click around until you find a
fractal you like. The coordinates are displayed in the top right hand corner so you
can enter them into the camera position array here for the shader to loop through.

Just make sure to set NUM_POSITIONS to the actual number you have in the array.
*/




vec2[] Camera_Positions = vec2[](
   vec2(0.96,0.01),

    vec2(0.03, 0.402),
    vec2(0.79,0.13),

    vec2(0.24, 0.92),
    vec2(0.47, 0.44),
   // vec2(0.5, 0.50),
   vec2(0.06, 0.71),
    vec2(0.36, 0.7),
    //vec2(0.52, 0.77),

   // vec2(0.17, 0.68),
    //vec2(0.15, 0.71),
    vec2(0.04,0.78)
//

    //this one 0.12,0.40 was found at 12:40pm today lol
);

//#define NUM_POSITIONS 7.
//more general (better) way to write this from Spalmer
#define NUM_POSITIONS float(Camera_Positions.length())

/*
Here you can set basic material properties that will be used for coloring
based on the Materials object which as properties "roughness"and "color""
*/

struct Object
{
    float rough;
    vec3 color;
};
vec3 gold = vec3(0.9,0.55,0.);
vec3 blue = vec3(0.,0.5,0.9);

Object[] Materials = Object[](


    //gold
    Object(0.99, vec3(0.99,0.55,0.)),

    //red which gets tthe bump map
    Object(0.1, vec3(1.)),//vec3(0.,0.5,0.9)),

    //red
    Object(0.1, vec3(0.))

    //blue which gets an interesting color and texture
   // Object(0.1, vec3(0.,0.9,0.9))

);



float glow = 0.;

//Path through the fractal but if in DEV_MODE 1 just stay at DEV_POSITION
vec3 path(float z){
    vec3 p = vec3(0.,0.,iTime*4.);
    //p.xz *= rot(iTime);
    return DEV_MODE > 1. ? p : DEV_POSITION;

}



/*


    THE BASIC FRACTAL SHAPE
*********************************************************************
*/
vec2 tile(vec3 p){


    if(DEV_MODE == 1.){
        if(iMouse.z == 0.5){
            p.zx *= rot(iTime);
        }
     }
     // p.zx *= rot(0.5);
    //  p.yx *= rot(-0.1);
     vec3 op = p;
     vec3 pp = p;;//I keep reframing pp as p to have a fresh coordinate system to work from
     //vector two for a basic rounded box wiht an id set to 2
   // p.xz = mod(p.xz,vec2(3.,4.))-vec2(1.5,2.);
   p.xz = abs(p.xz)-vec2(1.5,2.);
   //p.xz = abs(p.xz)-vec2(1.5,2.);
     vec2  t = vec2(100.,1.), h = vec2(100.,1.);

    // p = abs(p)-vec3(0.9,0.,0.9);
     //main block
     pp = p;
     h = vec2(rb(pp,vec3(2.1,0.2,0.5), 0.04), 0.);

     addH;


     //second thin full length block in middle less tall
     pp = p;
     h = vec2(rb(pp,vec3(2.,0.3,0.2), 0.04), 1.);
     glow += 0.01/pow(h.x,2.)*0.034;
     addH;

    //thin full length block in middle
     pp = p;
     h = vec2(rb(pp,vec3(2.0,0.4,0.1), 0.04), 2.);

     addH;


     //peice in middle
     pp = p;
     h = vec2(rb(pp,vec3(0.1,0.6,0.1), 0.04),2.);
     addH;

     //full width peice in middle
     pp = p;
     h = vec2(rb(pp,vec3(0.2,0.5,0.7), 0.04), 1.);
     glow += 0.01/pow(h.x,2.)*0.034;
     addH;

     //second full width peice in middle less length
     pp = p;
     h = vec2(rb(pp,vec3(0.15,0.55,0.8), 0.04), 0.);

     addH;


     //second full width nub peice in middle less length less height
     pp = p;
     h = vec2(rb(pp,vec3(0.15,0.15,0.9), 0.04), 2.);

     addH;


     //bottom part


     p = op;
   //  p.xz = mod(p.xz,vec2(3.,4.))-vec2(1.5,2.);
   p.xz = abs(p.xz)-vec2(1.5,2.);
   //p.xz = abs(p.xz)-vec2(1.5,2.);
    // p = abs(p)-vec3(2.9,1.6,2.9);
     //flat bottom peice
     pp = p;
     h = vec2(rb(pp+vec3(0.,1.,0.),vec3(2.3,0.05,1.5), 0.04), 0.);

     addH;


     //panels
     pp = abs(p+vec3(0.,1.,0.))-vec3(1.1,0.,0.7);
     h = vec2(rb(pp,vec3(.9,0.15,0.5), 0.04), 2.);

     addH;

     //spheres
     pp = abs(p+vec3(0.,0.9,0.))-vec3(2.1,0.,1.4);
     h = vec2(length(pp)-0.1, 2.);
     addH;

     //tori
     pp = abs(p+vec3(0.,0.9,0.))-vec3(2.1,0.,1.4);
     h = vec2(sdTorus(pp,vec2(0.1,0.03)), 1.);
     glow += 0.01/pow(h.x,2.)*0.034;
     addH;

    // t.x = max(t.x,(rb(op,vec3(5.), 0.04)));
     return t;
}


/*
Mirroring and rotating the space all happends here
as well as the animation between fractals from "camera_position"
*/

vec3 fractal_position(vec3 p){
    vec3 op = p;
    //Animate the fractal positions
    vec2 t = vec2(iTime*0.3,iTime*0.3+1.);
    vec2 tt = (mod(floor(t), NUM_POSITIONS));
    vec2 mm = mix(Camera_Positions[int(tt.x)],
                   Camera_Positions[int(tt.y)],
                   smoothstep(0.8,1.,fract(t.x)));

    //mm = Camera_Positions[1]; //to look at just one fractal position
    //if DEV_MODE 3 then you use the mouse to find positions

    //if(DEV_MODE == 3.){

    //    mm = iMouse.xy/iResolution.xy;
    //}


    //if DEV_MODE is not the object mode 1 then make the fractal
    if(DEV_MODE > 1.){

       //p.xyz = mod(p.xyz,40.)-20.;
      // p.xz = mod(p.xz,40.)-20.;
        for(int i=0;i<4;i++){
            p.xz*=rot(mm.x*float(i));
            p.xy*=rot(mm.y*float(i));
            //p=abs(p)-vec3(.6,.3,.1);
          //  p.x += 0.5;
            p=abs(p)-vec3(.8,1.,.5);

                //with angles *2 0.73, 0.37, is good, and 0.00, 0.67, and 0.00, 0.68, and 0.24, 0.41, 0.70,0.76, 0.23, 0.90
                //0.2, 0.42
        }
    }
    return p;
}


vec2 map(vec3 p){
    vec3 op = p;
   // p.zy*=rot(PI/2.);
    p.z = mod(p.z,12.)-6.;
    p = fractal_position(p);
    vec2 t = vec2(tile(p));

    //glow*= float(length(op.xy)-2. > 2.5);
    if(DEV_MODE > 1.){
       // op -= vec3(60., -10., 0);
        t.x = smax(t.x, -(length(op.xy)-1.), 0.1);
        glow*= float(length(op.xy)-1. > 0.2);
    }
  /*  p = op;
    p.xy *= rot(iTime*3.);
 p.zy *= rot(iTime*2.);
    vec2 h = vec2(cc(p, 0.3, 2.1 ),0.);
    h.x = smax(h.x,-cc(p, 0.9, 1. ),0.4);
    addH;
    h = vec2(cc(p, 0.6, 2. ),2.);
    h.x = smax(h.x,-cc(p, 0.9, 1. ),0.4);
    addH;
    h = vec2(cc(p, 0.8, 1.5 ),1.);
    h.x = smax(h.x,-cc(p, 0.9, 1. ),0.4);
    addH;

    p = op;
    p.yz *= rot(iTime*3.);
    p.xy *= rot(iTime*1.);
    h = vec2(cc(p, 0.3, 3.1 ),0.);
    h.x = smax(h.x,-cc(p, 0.9, 1. ),0.4);
    addH;
    h = vec2(cc(p, 0.6, 3. ),2.);
    h.x = smax(h.x,-cc(p, 0.9, 1. ),0.4);
    addH;
    h = vec2(cc(p, 0.8, 2.5 ),1.);
    h.x = smax(h.x,-cc(p, 0.9, 1. ),0.4);
    addH;*/
    return t;
}

vec2 trace(vec3 ro, vec3 rd){
   	vec2 t = vec2(0.),dist;
    for(int i=0; i<96; i++)
    {
         dist = map(ro + rd*t.x);

         if(dist.x<0.01 || t.x > FAR){break;}
         //turn the step down if we use smoothstep in our map functions
         t.x += dist.x*0.95;
         t.y = dist.y;
    }
 return t;
}
vec3 normal(vec3 p) {
    vec2 e = vec2(.001, 0);
    vec3 n = map(p).x -
        vec3(
            map(p-e.xyy).x,
            map(p-e.yxy).x,
            map(p-e.yyx).x
            );

    return normalize(n);
}
float calculateAO(in vec3 pos, in vec3 nor){
    //function from shane
	float sca = 2.0, occ = 0.0;
    for( int i=0; i<5; i++ ){

        float hr = 0.01 + float(i)*0.5/4.0;
        float dd = map(nor * hr + pos).x;
        occ += (hr - dd)*sca;
        sca *= 0.7;
    }
    return clamp( 1.0 - occ, 0.0, 1.0 );
}

vec2 mapUV(vec3 p, vec3 n){
    if(DEV_MODE == 1.){
        if(iMouse.z < 0.5){
            p.zx *= rot(iTime);
            n.zx *= rot(iTime);
        }
    }
  //  p.z = mod(p.z,12.)-6.;
    p = fractal_position(p);
    p = fract(p*0.3);
    n = fractal_position(n);
    n = abs(n);
    //n = n*0.5+0.5;
    return (p.xy*n.z + p.xz*n.y + p.yz*n.x)/(n.x+n.y+n.z);
}
float bumpSurf3D( in vec3 p, in vec3 n, float id){
    vec2 uv = mapUV(p,n);//id == 4. ? mapCylUV(p,n) : mapUVF(p,n);
    return 0.0;

}
vec3 doBumpMap(in vec3 p, in vec3 nor, float bumpfactor, float id){
    //this function is from shane
    const vec2 e = vec2(0.01, 0);
    float ref = bumpSurf3D(p, nor,id);
    vec3 grad = (vec3(bumpSurf3D(p - e.xyy, nor,id),
                      bumpSurf3D(p - e.yxy, nor,id),
                      bumpSurf3D(p - e.yyx, nor,id) )-ref)/(2.*e.x);

    grad -= nor*dot(nor, grad);

    return normalize( nor + grad*bumpfactor );

}
vec3 lighting(vec3 sp, vec3 sn, vec3 lp, vec3 rd, float id){
    vec3 color;
    //vector from hit position to light position (shane)
    vec3 lv = lp - sp;
    //length of that vector (shane)
    float ldist = max(length(lv), 0.00);
    //direction of that vector (shane)
    vec3 ldir = lv/ldist;
    //attenuation (shane)
    float atte = 1.0/(1. + 0.02*ldist*ldist );
    //diffuse color
    if(id == 2.){
 //      sn = doBumpMap(sp*2.,sn,0.05,id);
    }
    float diff = max(dot(ldir, sn),0.);
    //specular reflection (shane)
    float spec = pow(max(dot(reflect(-ldir, sn), -rd), 0.0), 10.);
	//ambient occlusion
    float ao = calculateAO(sp, sn);
    //reflecton
    vec3 refl = reflect(rd, sn);
    //getting reflected and refracted color froma cubemap, only refl is used
    vec4 reflColor = texture(iChannel0, refl);
    //orage specular
    vec3 hotSpec = vec3(0.9,0.5, 0.2);

    //vec2 uv = mapUVF(sp,sn);//id == 4. ? mapCylUV(sp,sn) : mapUV(sp,sn);
    float tex = 0.0; //texture(iChannel1,mapUV(sp,sn)).r;//truchet
     float tex2 = 0.8; //texture(iChannel3,mapUV(sp,sn)).r;//metal
   /* Materials[3].color  *= (0.8-0.5*cos(vec3(1.,2.,4.)/4. +sp.x+sp.y+sp.z));//+ texture(iChannel3, sp*0.05+vec3(0.,0.,iTime*0.1)).rgb*5.));//texture(iChannel3,(uv+3.)*0.2).rgb*4.;
    Materials[2].color += pow(tex2,9.)*4.;
    Materials[1].color += (0.8-0.5*cos(vec3(1.,2.,4.)/4. +sp.x*0.7+sp.y*0.8+sp.z))*0.4;
    Materials[3].color += pow(tex,2.);*/
    vec3 obj_color = Materials[int(id)].color;
    float rough = Materials[int(id)].rough;

    color = obj_color*0.1+(diff*obj_color +  spec*hotSpec +reflColor.xyz*rough )*atte;
    return color*ao;

}
float vig(vec2 fragCoord){
    vec2 uv = fragCoord.xy/iResolution.xy;
    uv *=  1.0 - uv.yx;
    float vig = uv.x*uv.y * 50.0;
    return clamp(pow(vig, 0.3),0.,1.);
}
void mainImage( out vec4 fragColor, in vec2 fragCoord ){

	vec2 uv = (fragCoord - iResolution.xy*.5)/iResolution.y;
	//uv = normalize(uv) * tan(asin(length(uv) *1.));//fisheye

	//Camera Setup.
	vec3 lk = path(0.);
	vec3 ro = lk + vec3(0.,0.,-0.5);
  //  ro.xz *= rot(iTime);
 	vec3 lp = ro + vec3(0, 3.75, 10);
    vec2 m = (iMouse.xy - iResolution.xy*.5)/iResolution.y;

    float FOV = 1.57;
    vec3 fwd = normalize(lk-ro);
    vec3 rgt = normalize(vec3(fwd.z, 0., -fwd.x ));
    vec3 up = cross(fwd, rgt);
    vec3 rd = normalize(fwd + FOV*uv.x*rgt + FOV*uv.y*up);
    if(iMouse.z > 0.5){
        //rd.yz *= rot(-m.y*2.);
        if(DEV_MODE == 1.){
            ro.xz *= rot(-m.x*4.);
            rd.xz *= rot(-m.x*4.);

            ro.xy *= rot(-m.y*4.);
            rd.xy *= rot(-m.y*4.);
        }
        else if(DEV_MODE == 2.){
            rd.yz *= rot(-m.y*2.);
            rd.xz *= rot(-m.x*4.);
        }
    }
    else{
        if(DEV_MODE == 2.){
            rd.xy *= rot(sin(iTime*0.5)*0.1);
        }
    }
    vec3 sky =vec3(0.9,0.5,0.)*0.03*vig(fragCoord);// mix(vec3(0.,0.5,0.8)*0.2,vec3(0.3), rd.y);//2.*mix(vec3(0.9, 0.5, 0.2)*4., vec3(0.0)-0.4, pow(abs(rd.y), 1./3.))/8.;
    vec3 color = sky;//*(1./pow(abs(length(rd.xy)-0.4), 1./3.))/8.;
    //= sky;
    vec2 t = trace(ro, rd);
    vec3 sp = ro + rd*t.x;
    vec3 sn = normal(sp);
    if(t.x < FAR){
    color = lighting(sp, sn, lp, rd, t.y);

        float far = smoothstep(0.0, 1.0, t.x/120.);

        color = mix(color, sky, far);
    }

    color = pow(color,vec3(0.65));
    //if(DEV_MODE == 3.){
    //    color += texture(iChannel2,uv).rgb;
    //}
    vec3 palette = 0.7+0.3*cos(vec3(1.,2.,4.)/2. + (ro + rd*t.x).rgb);
	fragColor = vec4(color+palette*glow,1.0);
}
