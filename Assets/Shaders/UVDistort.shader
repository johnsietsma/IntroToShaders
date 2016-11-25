Shader "IntroShader/UVDistort"
{
	Properties
	{
		_MainTex("Main Texture", 2D) = "white" {}
		_MaskTex("Mask Texture", 2D) = "" {}
		_ScrollTex("Scroll Texture", 2D) = "white" {}
		_ScrollSpeedU("Scroll Speed U", Range(-5,5)) = 1
		_ScrollSpeedV("Scroll Speed V", Range(-5,5)) = 1
		_ScrollMaskTex("Scroll Mask Texture", 2D) = "white" {}
		_NoiseTex("Noise Texture", 2D) = "black" {}
		_NoiseAmount("Noise Amount", Range(0,0.5)) = 1
		_AdditiveColor("Additive Color", Color) = (1,1,1,1)
		_AdditiveAmount("Additive Amount", Range(0,1)) = 1
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
				float2 scrollUv : TEXCOORD1;
				float2 noiseUv : TEXCOORD2;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;

			sampler2D _MaskTex;

			sampler2D _ScrollTex;
			float4 _ScrollTex_ST;

			float _AdditiveAmount;

			sampler2D _ScrollMaskTex;

			float _ScrollSpeedU;
			float _ScrollSpeedV;

			sampler2D _NoiseTex;
			float4 _NoiseTex_ST;

			sampler2D _DistortMaskTex;

			float _NoiseAmount;

			v2f vert (appdata v)
			{
				float2 scrollUv = v.uv;
				scrollUv.x += _Time.y * _ScrollSpeedU;
				scrollUv.y += _Time.y * _ScrollSpeedV;

				// Scroll the noise texture
				float2 noiseUv = v.uv;

				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.mainUv = TRANSFORM_TEX(v.uv, _MainTex);
				o.scrollUv = TRANSFORM_TEX(scrollUv, _ScrollTex);
				o.noiseUv = TRANSFORM_TEX(v.uv, _NoiseTex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed cardMaskValue = tex2D(_MaskTex, i.mainUv).r;
				clip(cardMaskValue - 0.5);

				// The noise texture uses the red and green channels to store the noise
				fixed2 noiseOffset = tex2D(_NoiseTex, i.noiseUv).rg;

				// Rescale the noise from 0:1 to -1:1
				noiseOffset = (noiseOffset - 0.5) * 2;

				fixed4 scrollMaskValue = tex2D(_ScrollMaskTex, i.mainUv).r;
			
				fixed2 distortedScrollUv = i.scrollUv;
				// Apply the noise per pixel, scrolling was done in vert.
				distortedScrollUv += noiseOffset * _NoiseAmount;

				fixed4 distortedScrollColor = tex2D(_ScrollTex, distortedScrollUv);
				fixed4 mainColor = tex2D(_MainTex, i.mainUv);
				fixed4 color = mainColor + distortedScrollColor * _AdditiveAmount * scrollMaskValue;


				return color;
			}
			ENDCG
		}
	}
}
