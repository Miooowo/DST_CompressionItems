   vfx_particle_add   	   MatrixPVW                                                                                SAMPLER    +         vfx_particle_add.vs^  uniform mat4 MatrixPVW;

attribute vec3 POSITION;
attribute vec3 TEXCOORD0_LIFE;
attribute vec4 DIFFUSE;

varying vec3 PS_TEXCOORD_LIFE;
varying vec4 PS_COLOUR;

void main()
{
	gl_Position = MatrixPVW * vec4( POSITION.xyz, 1.0 );

	PS_TEXCOORD_LIFE.xyz = TEXCOORD0_LIFE.xyz;
	PS_COLOUR = DIFFUSE;
	PS_COLOUR.rgb *= PS_COLOUR.a;
}

    vfx_particle_add.ps�  #if defined( GL_ES )
precision mediump float;
#endif

uniform sampler2D SAMPLER[1];

varying vec3 PS_TEXCOORD_LIFE;
varying vec4 PS_COLOUR;

void main()
{
	vec4 colour = texture2D( SAMPLER[0], PS_TEXCOORD_LIFE.xy );
	gl_FragColor = vec4( colour.rgb * PS_COLOUR.rgb, colour.a * PS_COLOUR.a );
	//gl_FragColor.r += 1.0;
	//gl_FragColor.g += 1.0;
	//gl_FragColor.b += 1.0;
	//gl_FragColor.a = 1.0;
}

              