﻿Shader "Custom/Unlit_Fog_AnimWater"
{
	Properties
	{
		_Color("Color", Color) = (1, 1, 1, 1)
		_WaveSpeed("Wave Speed", float) = 1.0
		_WaveAmp("Wave Amp", float) = 0.2
		_NoiseTex("Noise Texture", 2D) = "white" {}
		_MainTex("Main Texture", 2D) = "white" {}
		_Height("Height", float) = 0.0
		_TimeDelay("TimeDelay", float) = 0.0
	}

	SubShader
	{
		Tags{ "Queue" = "Transparent" }

		Pass
		{
			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM
			#include "UnityCG.cginc"
			#include "UnityPBSLighting.cginc"
			#include "AutoLight.cginc"

// Define a FOG_DEPTH keyword when one of the fog modes is active.
#if defined(FOG_LINEAR) || defined(FOG_EXP) || defined(FOG_EXP2)
	#define FOG_DEPTH 1
#endif

			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fog

			// Properties
			float4 _Color;
			float  _WaveSpeed;
			float  _WaveAmp;
			sampler2D _NoiseTex;
			sampler2D _MainTex;
			float _Height;
			float _TimeDelay;

			struct vertexInput
			{
				float4 vertex : POSITION;
				float4 texCoord : TEXCOORD0;
			};

			struct vertexOutput
			{
				float4 pos : SV_POSITION;
				float4 texCoord : TEXCOORD0;
				float4 worldPos : TEXCOORD1;
			};

			vertexOutput vert(vertexInput input)
			{
				vertexOutput output;

				// convert to world space (UnityObjectToClipPos is the same as mul(UNITY_MATRIX_MVP, input.vertex)
				// but it ignores the w component of input.vertex to be faster.
				output.pos = UnityObjectToClipPos(input.vertex);

				// Store the world position for fog
				output.worldPos.xyz = mul(unity_ObjectToWorld, input.vertex);
#if FOG_DEPTH
				output.worldPos.w = output.pos.z;
#endif
				// We need a normal to process lights... 
				// output.normal = UnityObjectToWorldNormal(input.normal);

				// apply wave animation
				float noiseSample = tex2Dlod(_NoiseTex, float4(input.texCoord.xy, 0, 0));
				output.pos.y += _Height * sin((_Time + _TimeDelay)*_WaveSpeed*noiseSample)*_WaveAmp;
				output.pos.x += _Height * cos((_Time + _TimeDelay)*_WaveSpeed*noiseSample)*_WaveAmp;

				// texture coordinates 
				output.texCoord = input.texCoord;

				return output;
			}

			float length(float3 v) 
			{
				return sqrt(dot(v, v));
			}

			float4 frag(vertexOutput input) : COLOR
			{
				// sample main texture
				float4 albedo = tex2D(_MainTex, input.texCoord.xy);

				float4 col = _Color * albedo;

				// Apply fog
				// Length of vector from world pos of point to world pos of camera
				// Unanswered Question for Unity 2018: In single-pass stereo, 
				// does _WorldSpaceCameraPos essentially map to the center eye? 
				float viewDistance = length(_WorldSpaceCameraPos - input.worldPos.xyz);
#if FOG_DEPTH
				viewDistance = input.worldPos.w;
#endif
				// Account for weird Unity variations in clip space calculation
				viewDistance = UNITY_Z_0_FAR_FROM_CLIPSPACE(input.worldPos.w);

				UNITY_CALC_FOG_FACTOR_RAW(viewDistance);
				// Saturate() clamps the value between 0 and 1
				return lerp(unity_FogColor, col, saturate(unityFogFactor));

				return col;
			}

			ENDCG
		}
	}
}