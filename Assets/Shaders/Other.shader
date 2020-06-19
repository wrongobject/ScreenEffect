Shader "Custom/Forward Rendering"
{
    Properties
    {
        _MainTex("Main Texture", 2D) = "white" {}
        _Specular("Specular", Color) = (1,1,1,1)
        _Gloss("Gloss", Range(8,256)) = 8
    }

    SubShader
    {
        Pass
        {
            Tags
            {
                "LightMode" = "ForwardBase"
            }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase

            #include "UnityCg.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            sampler2D _MainTex;
            fixed4 _Specular;
            float _Gloss;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 worldNormal : TEXCOORD1;
                float4 worldPos: TEXCOORD2;
                SHADOW_COORDS(3)
            };

            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                TRANSFER_SHADOW(o);
                return o;
            }

            fixed4 frag(v2f i) : SV_TARGET
            {
                fixed4 albedo = tex2D(_MainTex, i.uv);
                fixed4 ambient = albedo * UNITY_LIGHTMODEL_AMBIENT;

                float3 worldLight = normalize(UnityWorldSpaceLightDir(i.worldPos.xyz));
                float3 worldView = normalize(UnityWorldSpaceViewDir(i.worldPos.xyz));
                fixed4 diff = albedo * _LightColor0 * max(0, dot(i.worldNormal, worldLight));

                float3 halfDir = normalize(worldView + worldLight);
                fixed4 spec = albedo * _Specular * pow(max(0, dot(halfDir, i.worldNormal)), _Gloss);

                float shadow = SHADOW_ATTENUATION(i);
                fixed4 col = ambient + (diff + spec) * shadow;
                return fixed4(shadow,shadow,shadow,1);
            }

            ENDCG
        }

        Pass
        {
            Tags
            {
                "LightMode" = "ForwardAdd"
            }
            Blend One One

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdadd

            #include "UnityCg.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            sampler2D _MainTex;
            fixed4 _Specular;
            float _Gloss;
            
            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 worldNormal : TEXCOORD1;
                float4 worldPos: TEXCOORD2;
                SHADOW_COORDS(3)
            };

            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                TRANSFER_SHADOW(o);
                return o;
            }

            fixed4 frag(v2f i) : SV_TARGET
            {
                fixed4 albedo = tex2D(_MainTex, i.uv);

                float3 worldLight = normalize(UnityWorldSpaceLightDir(i.worldPos.xyz));
                float3 worldView = normalize(UnityWorldSpaceViewDir(i.worldPos.xyz));
                fixed4 diff = albedo * _LightColor0 * max(0, dot(i.worldNormal, worldLight));

                float3 halfDir = normalize(worldView + worldLight);
                fixed4 spec = albedo * _Specular * pow(max(0, dot(halfDir, i.worldNormal)), _Gloss);

                // 参考 AutoLight.cginc
                float atten;
                #ifdef USING_DIRECTIONAL_LIGHT
                atten = 1;
                #else
                    float4 lightCoord = mul(unity_WorldToLight, i.worldPos);
                    #ifdef POINT
                    atten = tex2D(_LightTexture0, dot(lightCoord.xyz,lightCoord.xyz).xx).UNITY_ATTEN_CHANNEL;
                    #elif SPOT
                    atten = (lightCoord.z > 0) * tex2D(_LightTexture0, lightCoord.xy / lightCoord.w + 0.5).w * tex2D(_LightTextureB0, dot(lightCoord, lightCoord).xx).UNITY_ATTEN_CHANNEL;
                    #endif
                #endif

                float shadow = SHADOW_ATTENUATION(i);

                fixed4 col = (diff + spec) * atten * shadow;
                return col;
            }

            ENDCG
        }
    }

    Fallback "VertexLit"
}