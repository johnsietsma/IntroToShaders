Shader "IntroShader/UVScrollMasked"
{
	Properties
	{
		_MainTex("Main Texture", 2D) = "white" {}
		_MaskTex("Mask Texture", 2D) = "" {}
		_ScrollTex("Scroll Texture", 2D) = "white" {}
		_ScrollSpeedU("Scroll Speed U", Range(-5,5)) = 1
		_ScrollSpeedV("Scroll Speed V", Range(-5,5)) = 1
		_ScrollMaskTex("Scroll Mask Texture", 2D) = "white" {}
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

			v2f vert (appdata v)
			{
				float2 scrollUv = v.uv;
				scrollUv.x += _Time.y * _ScrollSpeedU;
				scrollUv.y += _Time.y * _ScrollSpeedV;

				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.mainUv = TRANSFORM_TEX(v.uv, _MainTex);
				o.scrollUv = TRANSFORM_TEX(scrollUv, _ScrollTex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 mainColor = tex2D(_MainTex, i.mainUv);
				fixed maskValue = tex2D(_MaskTex, i.mainUv).r;

				fixed4 scrollColor = tex2D(_ScrollTex, i.scrollUv);
				fixed4 scrollMaskValue = tex2D(_ScrollMaskTex, i.mainUv).r;
				
				// If we multiple the scroll color by the mask
				//   when the mask is 0 the scroll color disappears
				fixed4 color = mainColor + scrollColor *_AdditiveAmount * scrollMaskValue;

				// This masks the entire quad, rather then just the scroll layer
				//  Any mask value less then 0.5 will cause this fragment to be discarded
				clip(maskValue - 0.5);

				return color;
			}
			ENDCG
		}
	}
}
