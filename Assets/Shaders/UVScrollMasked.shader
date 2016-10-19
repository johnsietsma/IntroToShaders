Shader "IntroShader/UVScrollMasked"
{
	Properties
	{
		_MainTex("Main Texture", 2D) = "white" {}
		_ScrollTex ("Scroll Texture", 2D) = "white" {}
		_ScrollSpeed("Scroll Speed", Range(0,5)) = 1
		_ScrollMaskTex("Scroll Mask Texture", 2D) = "white" {}
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

			sampler2D _ScrollTex;
			float4 _ScrollTex_ST;

			sampler2D _ScrollMaskTex;

			float _ScrollSpeed;

			v2f vert (appdata v)
			{
				float2 scrollUv = v.uv;
				scrollUv.x += _Time.y * _ScrollSpeed;

				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.mainUv = TRANSFORM_TEX(v.uv, _MainTex);
				o.scrollUv = TRANSFORM_TEX(scrollUv, _ScrollTex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 mainColor = tex2D(_MainTex, i.mainUv);
				fixed4 maskColor = tex2D(_ScrollMaskTex, i.mainUv);
				fixed4 scrollColor = tex2D(_ScrollTex, i.scrollUv);
				
				// If we multiple the scroll color by the mask
				//   when the mask is 0 the scroll color disappears
				return mainColor + scrollColor * (1-maskColor.r);
			}
			ENDCG
		}
	}
}
