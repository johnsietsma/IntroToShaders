Shader "IntroShader/AlphaCutoff"
{
	Properties
	{
		_MainTex("Main Texture", 2D) = "white" {}
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
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;

			sampler2D _DissolveTex;
			float _DissolveAmount;
			float _DissolveWidth;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 color = tex2D(_MainTex, i.uv);
				float dissolve = tex2D(_DissolveTex, i.uv).r;

				//
				// Here are three ways to dissolve
				//

				// 1. clip. Discard the pixel from rendering.
				clip(dissolve - _DissolveAmount);

				// 2. Simple alpha. Alpha is either on or off
				//color.a = step(_DissolveAmount, dissolve);

				// 3. Smooth alpha. Alpha has a gradient over the dissolve width
				//float halfDissolveWidth = _DissolveWidth * 0.5;
				//color.a = smoothstep(_DissolveAmount - halfDissolveWidth, _DissolveAmount + halfDissolveWidth, dissolve);

				return color;
			}
			ENDCG
		}
	}
}
