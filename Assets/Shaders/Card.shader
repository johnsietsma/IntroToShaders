Shader "IntroShader/Card"
{
	Properties
	{
		_MainTex("Main Texture", 2D) = "white" {}
		_MaskTex("Mask Texture", 2D) = "" {}
		_ScrollTex ("Scroll Texture", 2D) = "black" {}
		_ScrollSpeedU("Scroll Speed U", Range(-5,5)) = 1
		_ScrollSpeedV("Scroll Speed V", Range(-5,5)) = 1
		_ScrollMaskTex("Scroll Mask Texture", 2D) = "black" {}
		_NoiseTex("Noise Texture", 2D) = "black" {}
		_NoiseAmount("Noise Amount", Range(0,0.5)) = 1
		_AdditiveTex("Additive Texture", 2D) = "black" {}
		_AdditiveColor("Additive Color", Color) = (1,1,1,1)
		_AdditiveAmount("Additive Amount", Range(0,1)) = 0
		_DissolveTex("Dissolve Texture", 2D) = "white" {}
		_DissolveAmount("Dissolve Amount", Range(0,1.2)) = 0
		_DissolveWidth("Dissolve Width", Range(0,0.5)) = 0.01
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
				float2 mainUv : TEXCOORD0;
				float2 scrollUv : TEXCOORD1;
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;

			sampler2D _MaskTex;

			sampler2D _ScrollTex;
			float4 _ScrollTex_ST;
			sampler2D _ScrollMaskTex;
			float _ScrollSpeedU;
			float _ScrollSpeedV;

			sampler2D _NoiseTex;
			float _NoiseAmount;

			sampler2D _AdditiveTex;
			float4 _AdditiveColor;
			float _AdditiveAmount;

			sampler2D _DissolveTex;
			float _DissolveAmount;
			float _DissolveWidth;

			sampler2D _CardOverlayTex;

			const float ScrollAmplitude = 3;
			const float ScrollFrequency = 5;

			
			v2f vert (appdata v)
			{
				float2 scrollUv = v.uv;

				// Scroll the uv
				scrollUv += _Time.y * fixed2(_ScrollSpeedU, _ScrollSpeedV);

				// Scroll the uv up and down
				scrollUv.y += sin(_Time.y * ScrollFrequency) * ScrollAmplitude;

				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.mainUv = TRANSFORM_TEX(v.uv, _MainTex);
				o.scrollUv = TRANSFORM_TEX(scrollUv, _ScrollTex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// Get the main color
				fixed4 mainColor = tex2D(_MainTex, i.mainUv);
				fixed4 maskColor = tex2D(_MaskTex, i.mainUv);

				clip(maskColor.r - 0.5);

				// Find the noise offset
				fixed2 noiseOffset = tex2D(_NoiseTex, i.mainUv).rg;
				noiseOffset = (noiseOffset - 0.5) * 2;

				// Get the distorted scroll layer color
				float2 scrollUv = i.scrollUv;
				scrollUv += noiseOffset * _NoiseAmount;
				fixed4 scrollColor = tex2D(_ScrollTex, scrollUv);

				// Mask the scroll layer
				fixed4 scrollMaskColor = tex2D(_ScrollMaskTex, i.mainUv);
				float scrollColorAmount = scrollColor.r * scrollMaskColor.r; // TODO, make it alpha
				float4 color = mainColor + scrollColor * scrollColorAmount;

				// Add in the Additive layer
				float AdditiveValue = tex2D(_AdditiveTex, i.mainUv).r;
				color.rgb += _AdditiveColor * AdditiveValue * _AdditiveAmount;

				// Add the card overlay
				float4 overlayColor = tex2D(_CardOverlayTex, i.mainUv);
				color = lerp(color, overlayColor, overlayColor.a);

				// Dissolve the combined color
				float dissolve = tex2D(_DissolveTex, i.mainUv);
				float halfDissolveWidth = _DissolveWidth * 0.5;
				color.a = smoothstep(_DissolveAmount - halfDissolveWidth, _DissolveAmount + halfDissolveWidth, dissolve);

				return color;
			}
			ENDCG
		}
	}
}
