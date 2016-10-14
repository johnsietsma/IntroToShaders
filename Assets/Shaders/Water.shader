Shader "IntroShader/Water"
{
	Properties
	{
		_WaveSpeed ("Wave Speed", FLOAT ) = 1
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
			};

			float _WaveSpeed;

			v2f vert (appdata v)
			{
				float4 vertex = UnityObjectToClipPos(v.vertex);
				float waveOffset = (_Time + v.uv.x) * _WaveSpeed.x;
				float waveHeight = sin(waveOffset);
				vertex.y += waveHeight;

				v2f o;
				o.vertex = vertex;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				return fixed4(0,0,1,0.3);
			}
			ENDCG
		}
	}
}
