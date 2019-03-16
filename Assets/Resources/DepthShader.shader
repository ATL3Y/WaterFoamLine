Shader "Custom/DepthShader"
{
	HLSLINCLUDE

#include "PostProcessing/Shaders/StdLib.hlsl"


		TEXTURE2D_SAMPLER2D(_CameraDepthTexture, sampler_CameraDepthTexture);

	float4 Frag(VaryingsDefault i) : SV_Target
	{
		float depth = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, sampler_CameraDepthTexture, i.texcoordStereo));
		depth = depth / 100.0;
	return float4(depth, depth, depth, 0);
	}

		ENDHLSL
		SubShader
	{
		Cull Off ZWrite Off ZTest Always

			Pass
		{
			HLSLPROGRAM

#pragma vertex VertDefault
#pragma fragment Frag

			ENDHLSL
		}
	}
}