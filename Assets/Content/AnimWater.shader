Shader "Custom/AnimWater"
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

#pragma vertex vert
#pragma fragment frag

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
		float4 texCoord : TEXCOORD1;
	};

	struct vertexOutput
	{
		float4 pos : SV_POSITION;
		float4 texCoord : TEXCOORD0;
		float4 screenPos : TEXCOORD1;
	};

	vertexOutput vert(vertexInput input)
	{
		vertexOutput output;

		// convert to world space
		output.pos = UnityObjectToClipPos(input.vertex);

		// apply wave animation
		float noiseSample = tex2Dlod(_NoiseTex, float4(input.texCoord.xy, 0, 0));
		output.pos.y += _Height * sin((_Time + _TimeDelay)*_WaveSpeed*noiseSample)*_WaveAmp;
		output.pos.x += _Height * cos((_Time + _TimeDelay)*_WaveSpeed*noiseSample)*_WaveAmp;

		// compute depth
		output.screenPos = ComputeScreenPos(output.pos);

		// texture coordinates 
		output.texCoord = input.texCoord;

		return output;
	}

	float4 frag(vertexOutput input) : COLOR
	{
		// sample main texture
		float4 albedo = tex2D(_MainTex, input.texCoord.xy);

		float4 col = _Color * albedo;
		return col;
	}

		ENDCG
	}
	}
}