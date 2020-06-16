// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "Unlit/DemoUnlit"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Diffuse ("Diffuse", color) = (1, 1, 1, 1)
        _Specular ("Specular", color) = (1, 1, 1, 1)
        _Power ("power", range(0, 120)) = 64
        _Edge ("Edge", Range(0, 60)) = 10
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
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 normal : NORMAL;
                float3 pos : TEXCOORD1;
            };

            sampler2D _MainTex;
            float _Edge;
            fixed4 _Diffuse;
            float4 _Specular;
            float2 _MainTex_TexelSize;
            float _Power;

            fixed luminance(fixed4 color){
                return color.r * 0.33 + color.g * 0.33 + color.b * 0.33;
            }

            half edge(half2 uv){
                const half Gx[9] = {-1,  0,  1,
                                -2,  0,  2,
                                -1,  0,  1};
                const half Gy[9] = {-1, -2, -1,
                                        0,  0,  0,
                                        1,  2,  1}; 
                half dx = 0, dy = 0;
                half center = luminance(tex2D(_MainTex, uv));
                for (int i = -1;i < 2;i++){
                    for (int j = -1;j < 2;j++){
                        half x = _MainTex_TexelSize.x * i;
                        half y = _MainTex_TexelSize.y * j;
                        half color = luminance(tex2D(_MainTex, uv + half2(x, y)));
                        dx += Gx[(i + 1) * 3 + j + 1] * color;
                        dy += Gy[(i + 1) * 3 + j + 1] * color;
                    }
                }
                return (abs(dx) + abs(dy)) * 10;
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.pos = mul(unity_ObjectToWorld, v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                i.normal = normalize(i.normal);
                fixed4 col = tex2D(_MainTex, i.uv);
                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                float3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.pos);
                // viewDir = mul(unity_ObjectToWorld, viewDir);
                // i.normal = mul(unity_WorldToObject, i.normal);
                float spec = saturate(dot(normalize(lightDir + viewDir), i.normal));
                float diff = saturate(0.5 * dot(lightDir, i.normal) + 0.5);
                // diff = max(0, diff);
                spec = max(0, spec);
                spec = pow(spec, _Power);

                float rate = 1;
                if (edge(i.uv) > _Edge)
                    rate = 0;

                col = col * diff * _Diffuse + spec * _Specular;
                return col * rate;
            }
            ENDCG
        }
    }
        Fallback "Specular"
}
