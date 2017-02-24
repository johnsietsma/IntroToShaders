Shader "IntroShader/UVScroll"
{
	Properties
	{
		_MainTex("Main Texture", 2D) = "white" {}
		_ScrollTex ("Scroll Texture", 2D) = "white" {}
		_ScrollSpeedU("Scroll Speed U", Range(-5,5)) = 1
		_ScrollSpeedV("Scroll Speed V", Range(-5,5)) = 1

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

			float _ScrollSpeedU;
			float _ScrollSpeedV;

			v2f vert (appdata v)
			{
				// Store the uv in a variable so we can change it.
				float2 scrollUv = v.uv;

				// _Time.y has the time since game start
				// Make this texture scroll to the left by looking up
				//   pixels to the right!
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
				fixed4 scrollColor = tex2D(_ScrollTex, i.scrollUv);

				// Additive blend, good for glows, sparkles, etc.
				return mainColor + scrollColor;
			}
			ENDCG
		}
	}
}
