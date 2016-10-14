Shader "IntroShader/Card"
{
	Properties
	{
		_MainTex("Main Texture", 2D) = "white" {}
		_MaskTex("Mask Texture", 2D) = "white" {}
		_ScrollTex ("Scroll Texture", 2D) = "white" {}
		_ScrollSpeed("Scroll Speed", Range(0,5)) = 1
		_NoiseTex("Noise Texture", 2D) = "white" {}
		_NoiseAmount("Noise Amount", Range(0,0.5)) = 1
		_SparkleTex("Sparkle Texture", 2D) = "white" {}
		_SparkleColor("Sparkle Color", Color) = (1,1,1,1)
		_SparkleAmount("Sparkle Amount", Range(0,1)) = 0
		_DissolveTex("Dissolve Texture", 2D) = "white" {}
		_DissolveAmount("Dissolve Amount", Range(0,1.2)) = 0
		_DissolveWidth("Dissolve Width", Range(0,0.5)) = 0.01
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

			float _ScrollSpeed;

			sampler2D _NoiseTex;
			float4 _NoiseTex_ST;

			float _NoiseAmount;

			sampler2D _SparkleTex;
			float4 _SparkleColor;
			float _SparkleAmount;

			sampler2D _DissolveTex;
			float _DissolveAmount;
			float _DissolveWidth;

			const float ScrollAmplitude = 0.3;
			const float ScrollFrequency = 5;

			
			v2f vert (appdata v)
			{
				float2 scrollUv = v.uv;
				scrollUv.x += _Time * _ScrollSpeed;
				scrollUv.y += sin(_Time * ScrollFrequency) * ScrollAmplitude;

				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.mainUv = TRANSFORM_TEX(v.uv, _MainTex);
				o.scrollUv = TRANSFORM_TEX(scrollUv, _ScrollTex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 mainColor = tex2D(_MainTex, i.mainUv);
				fixed4 maskColor = tex2D(_MaskTex, i.mainUv);
				fixed2 noise = tex2D(_NoiseTex, i.mainUv);

				float2 scrollUv = i.scrollUv;
				scrollUv += noise * _NoiseAmount;
				fixed4 scrollColor = tex2D(_ScrollTex, scrollUv);

				float scrollLerpAmount = scrollColor.r * (1-maskColor.r); // TODO, make it alpha
				float4 color = mainColor + scrollColor * scrollLerpAmount;

				float sparkleValue = tex2D(_SparkleTex, i.mainUv).r;
				color.rgb += _SparkleColor * sparkleValue * _SparkleAmount;

				float dissolve = tex2D(_DissolveTex, i.mainUv);

				//color.a = step(_DissolveAmount, dissolve);
				float halfDissolveWidth = _DissolveWidth * 0.5;
				color.a = smoothstep(_DissolveAmount - halfDissolveWidth, _DissolveAmount + halfDissolveWidth, dissolve);

				return color;
			}
			ENDCG
		}
	}
}
