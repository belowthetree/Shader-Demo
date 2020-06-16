Shader "Unlit/EdgeDetect"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Edge ("Edge", Range(0, 2)) = 0.1
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
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float2 dxy : TEXCOORD1;
            };

            sampler2D _MainTex;
            sampler2D _CameraDepthTexture;
            float2 _MainTex_TexelSize;
            float _Edge;

            fixed luminance(fixed4 color){
                return color.r * 0.33 + color.g * 0.33 + color.b * 0.33;
            }

            half edge(half2 uv, float2 xy){
                half offset = 0;
                half center = Linear01Depth(UNITY_SAMPLE_DEPTH(tex2D(_CameraDepthTexture, uv)));
                for (int i = -1;i < 2;i++){
                    for (int j = -1;j < 2;j++){
                        offset += center - 
                        Linear01Depth(UNITY_SAMPLE_DEPTH(tex2D(_CameraDepthTexture, uv + 
                        half2(i * xy.x, j * xy.y))));
                        //offset += abs(center - luminance(tex2D(_MainTex, uv + half2(i, j))));
                    }
                }
                return abs(offset) * 10000;
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.dxy = _MainTex_TexelSize.xy;

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // float depth = saturate(UNITY_SAMPLE_DEPTH(tex2D(_CameraDepthTexture, i.uv)));
                // depth = Linear01Depth(depth);
                // fixed4 color = fixed4(depth, depth, depth, 1);
                fixed4 color = tex2D(_MainTex, i.uv);//fixed4(depth, depth, depth, 1);
                float rate = saturate(edge(i.uv, i.dxy));
                
                rate = rate > _Edge ? 0 : 1;
                
                return color * rate;// fixed4(rate, rate, rate, 1);
            }
            ENDCG
        }
    }
    Fallback "Diffuse"
}
