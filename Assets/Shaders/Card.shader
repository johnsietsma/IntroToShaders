Shader "IntroShader/Card"
{
	Properties
	{
		_MainTex("Main Texture", 2D) = "white" {}
		_MaskTex("Mask Texture", 2D) = "" {}
		_ScrollTex("Scroll Texture", 2D) = "black" {}
		_ScrollSpeedU("Scroll Speed U", Range(-5,5)) = 1
		_ScrollSpeedV("Scroll Speed V", Range(-5,5)) = 1
		_ScrollMaskTex("Scroll Mask Texture", 2D) = "black" {}
		_ScrollAdditiveAmount("Scroll Additive Amount", Range(0,1)) = 0
		_NoiseTex("Noise Texture", 2D) = "black" {}
		_NoiseAmount("Noise Amount", Range(0,0.5)) = 1
		_AdditiveColor("Additive Color", Color) = (1,1,1,1)
		_AdditiveAmount("Additive Amount", Range(0,1)) = 0
		_CardOverlayTex("Card Overlay Texture", 2D) = "black" {}
	}
	SubShader
	{
		Tags { "RenderType"="Transparent" "Queue"="Transparent" }
		LOD 100

		Blend SrcAlpha OneMinusSrcAlpha

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
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;

			sampler2D _MaskTex;

			sampler2D _ScrollTex;
			float4 _ScrollTex_ST;
			sampler2D _ScrollMaskTex;
			float _ScrollSpeedU;
			float _ScrollSpeedV;
			float _ScrollAdditiveAmount;

			sampler2D _NoiseTex;
			float _NoiseAmount;

			sampler2D _AdditiveTex;
			float4 _AdditiveColor;
			float _AdditiveAmount;

			sampler2D _DissolveTex;
			float _DissolveAmount;
			float _DissolveWidth;

			sampler2D _CardOverlayTex;

			v2f vert (appdata v)
			{
				float2 scrollUv = v.uv;

				// Scroll the uv
				scrollUv += _Time.y * fixed2(_ScrollSpeedU, _ScrollSpeedV);

				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.mainUv = TRANSFORM_TEX(v.uv, _MainTex);
				o.scrollUv = TRANSFORM_TEX(scrollUv, _ScrollTex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// Clip fragments outside the mask
				fixed cardMaskValue = tex2D(_MaskTex, i.mainUv).r;
				clip(cardMaskValue - 0.5);

				// Find the noise offset
				fixed2 noiseOffset = tex2D(_NoiseTex, i.mainUv).rg;
				noiseOffset = (noiseOffset - 0.5) * 2;

				fixed4 scrollMaskValue = tex2D(_ScrollMaskTex, i.mainUv).r;

				// Get the distorted scroll layer color and mask the result
				float2 scrollUv = i.scrollUv;
				scrollUv += noiseOffset * _NoiseAmount;
				fixed4 scrollColor = tex2D(_ScrollTex, scrollUv) * scrollMaskValue * _ScrollAdditiveAmount;

 				// Add in the additive color
				fixed4 mainColor = tex2D(_MainTex, i.mainUv);
				fixed4 additiveColor = _AdditiveColor * _AdditiveAmount * scrollMaskValue;
				float4 color = mainColor + additiveColor + scrollColor;

				// Add the card overlay
				float4 overlayColor = tex2D(_CardOverlayTex, i.mainUv);
				color = lerp(color, overlayColor, overlayColor.a);

				return color;
			}
			ENDCG
		}
	}
}
