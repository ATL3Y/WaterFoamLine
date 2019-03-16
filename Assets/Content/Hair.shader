Shader "LWRP/Unlit/Hair"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
	_Color("Color", Color) = (1, 1, 1, 1)
		_Cutoff("AlphaCutout", Range(0.0, 1.0)) = 0.0
	}
		SubShader
	{
		Tags{ "RenderType" = "TransparentCutout" "IgnoreProjector" = "True" "Queue" = "Transparent" "RenderPipeline" = "LightweightPipeline" }

		//Depth only prepass
		Pass
	{
		Name "DepthOnly"
		Tags{ "LightMode" = "DepthOnly" }
		ZWrite On
		ColorMask 0

		HLSLPROGRAM

#pragma prefer_hlslcc gles
#pragma exclude_renderers d3d11_9x
#pragma target 2.0

		//#pragma shader_feature _ALPHATEST_ON

#pragma vertex DepthOnlyVertex
#pragma fragment DepthOnlyFragment

#include "LWRP/ShaderLibrary/InputSurfaceUnlit.hlsl"
#include "LWRP/ShaderLibrary/LightweightPassDepthOnly.hlsl"

		ENDHLSL
	}

		//Main pass
		Pass
	{
		Name "StandardUnlit"

		ColorMask RGB
		Blend SrcAlpha OneMinusSrcAlpha
		ZWrite Off
		Cull Off

		HLSLPROGRAM

#pragma prefer_hlslcc gles
#pragma exclude_renderers d3d11_9x
#pragma target 2.0

		//Define vertex and fragment function
#pragma vertex vert
#pragma fragment frag
#include "UnityCG.cginc"

		//Basic input
		struct appdata
	{
		float4 vertex : POSITION;
		float2 uv : TEXCOORD0;
	};

	//Basic fragment input
	struct v2f
	{
		float2 uv : TEXCOORD0;
		float4 vertex : SV_POSITION;
	};

	//Vars
	sampler2D _MainTex;
	float4 _MainTex_ST;
	float4 _Color;
	float _Cutoff;

	//Basic vertex function
	v2f vert(appdata v)
	{
		v2f o;
		o.vertex = UnityObjectToClipPos(v.vertex);
		o.uv = TRANSFORM_TEX(v.uv, _MainTex);
		return o;
	}

	//Alpha cutoff function
	void AlphaDiscard(half alpha, half cutoff, half offset = 0.0001h)
	{
		clip(alpha - cutoff + offset);
	}

	//Basic fragment function with alpha support
	fixed4 frag(v2f i) : SV_Target
	{
		half4 texColor = tex2D(_MainTex, i.uv);
		half3 color = texColor.rgb * _Color.rgb;
		AlphaDiscard(texColor.a, _Cutoff);
		return half4(color, texColor.a);
	}

		ENDHLSL
	}
	}
		FallBack "Hidden/InternalErrorShader"
}