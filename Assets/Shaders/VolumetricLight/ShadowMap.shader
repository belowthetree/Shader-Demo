Shader "Hidden/ShadowMap"
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
                float depth : TEXCOORD1;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.depth = o.vertex.z / o.vertex.w;
                o.uv = v.uv;
                return o;
            }

            sampler2D _MainTex;
            sampler2D _CameraDepthTexture;

            fixed4 frag (v2f i) : SV_Target
            {
                float depth0 = Linear01Depth(UNITY_SAMPLE_DEPTH(tex2D(_CameraDepthTexture, i.uv))).r;
                // #if defined (SHADER_TARGET_GLSL) 
                //     depth = depth*0.5 + 0.5; //(-1, 1)-->(0, 1)
                // #elif defined (UNITY_REVERSED_Z)
                //     depth = 1 - depth;       //(1, 0)-->(0, 1)
                // #endif
                float4 col = depth0;//depth0;// tex2D(_MainTex, i.uv);
                return EncodeFloatRGBA(i.depth);
            }
            ENDCG
        }
    }
}
