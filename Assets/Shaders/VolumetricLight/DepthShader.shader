Shader "Hidden/DepthShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        // No culling or depth
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
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float4 proj : TEXCOORD1;
            };

            float4x4 _LightProjection;

            v2f vert (appdata v)
            {
                v2f o;
                float4x4 tmp = mul(_LightProjection, unity_ObjectToWorld);
                o.proj = mul(tmp, v.vertex);
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            sampler2D _MainTex;
            sampler2D _ShadowMap;
            sampler2D _CameraDepthTexture;
            float theta;

            fixed4 frag (v2f i) : SV_Target
            {
                i.proj.xy = i.proj.xy / i.proj.w;
                i.proj.xy = i.proj.xy * 0.5 + 0.5;
                fixed4 col = 1;//Linear01Depth(UNITY_SAMPLE_DEPTH(tex2D(_CameraDepthTexture, i.uv))).r;
                float4 d = tex2D(_ShadowMap, i.uv);
                float depth = DecodeFloatRGBA(d);
                if (depth <= i.proj.z)
                    col = 0.2;
                else
                    col = 1;
                
                return i.vertex.z * theta;//depth / theta;//i.vertex.z / i.vertex.w;
            }
            ENDCG
        }
    }
}
