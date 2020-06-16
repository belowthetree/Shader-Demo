Shader "Unlit/DemoUnlit1"
{
    Properties
    {
        _Color ("Color", Color) = (0, 0.5, 0.9, 1)
		_Specular("Specular", Color) = (1, 1, 1, 1)
		_Emission("Emission", Color) = (0, 0, 0, 0)
		_Shiness("Shiness", Color) = (1, 1, 1, 1)
		_MainTex("Main Tex", 2D) = "white" {}
	}
		SubShader
	{
		LOD 100
		Pass{
		name "FirstPass"
		Tags { "RenderType" = "Opaque" "LightMode" = "ForwardBase"}
		    CGPROGRAM
		#pragma vertex vert
		#pragma fragment frag
		#include "UnityCG.cginc"

		float4 _Color;
		float4 _Specular;
		float4 _Emission;
		float4 _Shiness;
		sampler2D _MainTex;

		struct Input{
			float2 uv : TEXCOORD0;
			float4 pos : POSITION;
		};

		struct v2f {
			fixed4 color : Color;
			fixed2 uv : TEXCOORD0 ;
			float4 pos : POSITION;
		};
		
		v2f vert (Input v)
		{
			v2f o;
			o.pos = UnityObjectToClipPos(v.pos);
			o.color = float4(1, 1, 1, 1);
			o.uv = v.uv;
			return o;
		}

		struct outer{
			float4 color : SV_TARGET;
		};

		struct outer frag(v2f i){
			outer color;
			if (ComputeScreenPos(i.pos).x > 0.1)
				color.color = float4(1, 0, 0, 1);
			else
				color.color = tex2D(_MainTex, i.uv);
			return color;
		}
		
		ENDCG
		}
    }
}
