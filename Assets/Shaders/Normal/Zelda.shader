Shader "Unlit/Zelda"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Normal ("Normal", 2D) = "bump" {}
        _Limit ("Limit", Range(0, 1)) = 0
        _Light ("Light", Range(0.95, 1)) = 1
        _Low ("Low", Range(0, 1)) = 0.1
        _High ("High", Range(0, 1)) = 0.9
        _RimPower ("RimPower", Range(0, 10)) = 5
        _RimColor ("RimColor", Color) = (1, 1, 1, 1)
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

            sampler2D _MainTex;
            sampler2D _Normal;
            fixed4 _RimColor;
            float _Low;
            float _High;
            float _Limit;
            float _Light;
            float _RimPower;

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
                float3 worldPos : TEXCOORD1;
                half3 tspace0 : TEXCOORD4;
                half3 tspace1 : TEXCOORD2;
                half3 tspace2 : TEXCOORD3;
            };


            v2f vert (appdata v, float4 tangent : TANGENT)
            {
                v2f o;
                o.uv = v.uv;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                half3 wNormal = UnityObjectToWorldNormal(v.normal);
                half3 wTangent = UnityObjectToWorldDir(tangent.xyz);
                half tangentSign = tangent.w * unity_WorldTransformParams.w;
                half3 wBitangent = cross(wNormal, wTangent) * tangentSign;
                o.tspace0 = half3(wTangent.x, wBitangent.x, wNormal.x);
                o.tspace1 = half3(wTangent.y, wBitangent.y, wNormal.y);
                o.tspace2 = half3(wTangent.z, wBitangent.z, wNormal.z);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 color = tex2D(_MainTex, i.uv);
                float3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos);
                float3 lightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));

                float spec = saturate(dot(normalize(lightDir + viewDir), i.normal));

                half3 tnormal = UnpackNormal(tex2D(_Normal, i.uv));
                half3 worldNormal;
                i.normal.x = dot(i.tspace0, tnormal);
                i.normal.y = dot(i.tspace1, tnormal);
                i.normal.z = dot(i.tspace2, tnormal);
                i.normal = normalize(i.normal);

                float diff = saturate(0.5 * dot(lightDir, i.normal) + 0.5);
                float rim = 1 - saturate(dot(viewDir, i.normal));

                rim = pow(rim, _RimPower);

                if (spec < _Light)
                    spec = 0;
                else
                    spec = 1;
                spec = pow(spec, 64);
                if (diff > _Limit)
                    diff = _High;
                else{
                    diff = _Low;
                    rim = 0;
                }

                return color * diff + spec * float4(1, 1, 1, 1) + rim * _RimColor;
            }
            ENDCG
        }
    }
    Fallback "Diffuse"
}
