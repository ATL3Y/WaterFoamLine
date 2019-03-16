
Shader "ShaderMan/Flames"{

	Properties{
	_MainTex("MainTex", 2D) = "white" {}
	}

	SubShader{
	Tags { "RenderType" = "Transparent" "Queue" = "Transparent" }

	Pass{
	ZWrite Off
	Blend SrcAlpha OneMinusSrcAlpha

	CGPROGRAM
	#pragma vertex vert
	#pragma fragment frag
	#include "UnityCG.cginc"
	
	//VertexInput
	struct VertexInput {
	fixed4 vertex : POSITION;
	fixed2 uv : TEXCOORD0;
	fixed4 tangent : TANGENT;
	fixed3 normal : NORMAL;
	};

	//VertexOutput
	struct VertexOutput {
	fixed4 pos : SV_POSITION;
	fixed2 uv : TEXCOORD0;
	};

	//Variables
	float4 _iMouse;
	sampler2D _MainTex;


	// Created by inigo quilez - iq/2013
	// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
	fixed noise(in fixed3 x){
		fixed3 p = floor(x);
		fixed3 f = frac(x);
		f = f*f*(3.0 - 2.0*f);
		fixed2 uv = (p.xy + fixed2(37.0,17.0)*p.z) + f.xy;
		fixed2 rg = tex2Dlod(_MainTex,float4((uv + 0.5) / 256.0, 0.0 ,0)).yx;
		return lerp(rg.x, rg.y, f.z);
	}

	fixed4 map(in fixed3 p){
		fixed3 r = p; p.y += 0.6;
		// invert space
		p = -4.0*p / dot(p,p);
		// twist space
		fixed an = -1.0*sin(0.1*_Time.y + length(p.xz) + p.y);
		fixed co = cos(an);
		fixed si = sin(an);
		p.xz = mul(fixed2x2(co, -si, si, co), p.xz); //mul(p.xz, fixed2x2(co, -si, si, co));

		// distort
		p.xz += -1.0 + 2.0*noise(p*1.1);
		// pattern
		fixed f;
		fixed3 q = p*0.85 - fixed3(0.0,1.0,0.0)*_Time.y*0.12;
		f = 0.50000*noise(q); q = q*2.02 - fixed3(0.0,1.0,0.0)*_Time.y*0.12;
		f += 0.25000*noise(q); q = q*2.03 - fixed3(0.0,1.0,0.0)*_Time.y*0.12;
		f += 0.12500*noise(q); q = q*2.01 - fixed3(0.0,1.0,0.0)*_Time.y*0.12;
		f += 0.06250*noise(q); q = q*2.02 - fixed3(0.0,1.0,0.0)*_Time.y*0.12;
		f += 0.04000*noise(q); q = q*2.00 - fixed3(0.0,1.0,0.0)*_Time.y*0.12;
		fixed den = clamp((-r.y - 0.6 + 4.0*f)*1.2, 0.0, 1.0);
		fixed3 col = 1.2*lerp(fixed3(1.0,0.8,0.6), 0.9*fixed3(0.3,0.2,0.35), den);
		col += 0.05*sin(0.05*q);
		col *= 1.0 - 0.8*smoothstep(0.6,1.0,sin(0.7*q.x)*sin(0.7*q.y)*sin(0.7*q.z))*fixed3(0.6,1.0,0.8);
		col *= 1.0 + 1.0*smoothstep(0.5,1.0,1.0 - length((frac(q.xz*0.12) - 0.5) / 0.5))*fixed3(1.0,0.9,0.8);
		col = lerp(fixed3(0.8,0.32,0.2), col, clamp((r.y + 0.1) / 1.5, 0.0, 1.0));
		return fixed4(col, den);
	}

	//VertexFactory
	VertexOutput vert(VertexInput v){
	VertexOutput o;
	o.pos = UnityObjectToClipPos(v.vertex);
	o.uv = v.uv;
		
	return o;
	}

	fixed4 frag(VertexOutput i) : SV_Target{
		{

		// inputs
		fixed2 q = i.uv / 1;
		fixed2 p = (-1.0 + 2.0*q) * fixed2(1 / 1, 1.0);
		fixed2 mo = _iMouse.xy / 1;
		if (_iMouse.w <= 0.00001) mo = fixed2(0.0,0.0);

		//--------------------------------------
		// cameran    
		//--------------------------------------
		fixed an = -0.07*_Time.y + 3.0*mo.x;
		fixed3 ro = 4.5*normalize(fixed3(cos(an), 0.5, sin(an)));
		ro.y += 1.0;
		fixed3 ta = fixed3(0.0, 0.5, 0.0);
		fixed cr = -0.4*cos(0.02*_Time.y);

		// build rayn
		fixed3 ww = normalize(ta - ro);
		fixed3 uu = normalize(cross(fixed3(sin(cr),cos(cr),0.0), ww));
		fixed3 vv = normalize(cross(ww,uu));
		fixed3 rd = normalize(p.x*uu + p.y*vv + 2.5*ww);

		//--------------------------------------
		// raymarch
		//--------------------------------------
		fixed4 sum = fixed4(0.0 , 0.0 , 0.0 , 0.0);
		fixed3 bg = fixed3(0.4,0.5,0.5)*1.3;
		// dithering
		fixed t = 0.05*tex2D(_MainTex, i.uv / 62 ).x; // 100 -- width? tex2D(_MainTex, i.uv).x

		//[unroll(100)]
		for (int i = 0; i < 128; i++) {
			if (sum.a > 0.99) break;
			fixed3 pos = ro + t*rd;
			fixed4 col = map(pos);
			col.a *= 0.5;
			col.rgb = lerp(bg, col.rgb, exp(-0.002*t*t*t)) * col.a;
			sum = sum + col*(1.0 - sum.a);
			t += 0.05;
		}
		
		fixed3 col = clamp(lerp(bg, sum.xyz / (0.001 + sum.w), sum.w), 0.0, 1.0);

		//--------------------------------------
		// contrast + vignetting
		//--------------------------------------
		
		col = col*col*(3.0 - 2.0*col)*1.4 - 0.4;
		col *= 0.25 + 0.75*pow(16.0*q.x*q.y*(1.0 - q.x)*(1.0 - q.y), 0.1);
		col = col.xzy;

		return fixed4(col, 1.0);
		

		}

	}ENDCG
	}
	}
	}

