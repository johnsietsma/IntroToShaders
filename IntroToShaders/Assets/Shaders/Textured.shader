Shader "IntroShader/Textured"
{
	Properties
	{
		// This appears in the inspector, just like public C# variables
		_MainTex("Main Texture", 2D) = "white" {}
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }

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
				float2 uv : TEXCOORD0;
			};

			// This is the bridge from the property above into cg.
			// A sampler contains our texture (and mip maps)
			sampler2D _MainTex;

			// This has the texture tiling and offsets
			float4 _MainTex_ST;

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				// TRANSFORM_TEX will apply any tiling or offsets
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// Look up the sampler for the color at this uv coordinate
				return tex2D(_MainTex, i.uv);
			}
			ENDCG
		}
	}
}
