Shader "IntroShader/UVDistort"
{
	Properties
	{
		_MainTex("Main Texture", 2D) = "white" {}
		_NoiseTex ("Noise Texture", 2D) = "white" {}
		_NoiseAmount("Noise Amount", Range(0,0.5)) = 1
		_DistortSpeed("Distort Speed", Float) = 5
		_DistortAmount("Distort Amount", Float) = 0.1
		_DistortMaskTex("Distort Mask Texture", 2D) = "white" {}
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float2 mainUv : TEXCOORD0;
				float2 noiseUv : TEXCOORD1;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;

			sampler2D _NoiseTex;
			float4 _NoiseTex_ST;

			sampler2D _DistortMaskTex;

			float _NoiseAmount;
			float _DistortSpeed;
			float _DistortAmount;

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.mainUv = TRANSFORM_TEX(v.uv, _MainTex);
				o.noiseUv = TRANSFORM_TEX(v.uv, _NoiseTex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed2 noiseUv = i.noiseUv;
				noiseUv += sin(_Time.y * _DistortSpeed) * _DistortAmount;

				// The noise texture uses the red and green channels to store the noise
				fixed2 noiseOffset = tex2D(_NoiseTex, noiseUv).rg;

				// Rescale the noise from 0:1 to -1:1
				//noiseOffset = (noiseOffset - 0.5) * 2;
			
				fixed2 uv = i.mainUv;
				// Apply the noise per pixel, scrolling was done in vert.
				uv += noiseOffset * _NoiseAmount;

				fixed4 maskColor = tex2D(_DistortMaskTex, i.mainUv);

				fixed4 distortedColor = tex2D(_MainTex, uv);
				fixed4 mainColor = tex2D(_MainTex, i.mainUv);

				// Mix the distorted and undistorted colors based on the mask
				return lerp(mainColor, distortedColor, maskColor.r);
			}
			ENDCG
		}
	}
}
