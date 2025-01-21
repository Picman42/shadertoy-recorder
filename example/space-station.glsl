/*
    "Space Station" by @XorDev

    Based on Shane's Apollonian Fractal: https://www.shadertoy.com/view/4d2BW1

    Twigl: https://bit.ly/3xgtDUD
*/
void mainImage(out vec4 O, vec2 I)
{
    float i=0.,e,j,s,t=iTime * 4.0;
    //Resolution for scaling
    vec3 r = iResolution,
    //Position and transformed vector
    p = r-r,v;

    //Clear color
    for(O-=O;

        //Scroll forward
        v = p+t/r,

        //Rotate view
        v.xy *= mat2(sin(t*.1+vec4(0,11,33,0))),
        //Center
        v--,
        i++<2e2;


        //Shadow tracing after 100 iterations
        i>1e2 ?
            //Step forward in vec3(1,1,1) direction
            p += e+=1e-5,
            //Add lighting
            O += e
        :
            //Add fog and step forward
            O+=vec4(5,6,9, p+=(vec3(I+I,r)-r)/r.x*e )/1e2*e
    )
    //Apollonian fractal
    for(j=s=4.;j++<11.;e=length(v*=e)/s-p.z/4e2)
            s*=e=1.5/dot(v=mod(--v,2.)-1.,v);
    O=min(O*O*O,1.);
}
