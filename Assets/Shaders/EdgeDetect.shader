Shader "Custom/EdgeDetect"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_EdgeColor("EdgeColor",Color) = (1,1,1,1)

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
			
                float2 uv[9] : TEXCOORD0;            
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
			float4 _EdgeColor;
            float4 _MainTex_ST;
			float4 _MainTex_TexelSize;
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
				float2 uv = TRANSFORM_TEX(v.uv, _MainTex);
			
                o.uv[0] = uv + _MainTex_TexelSize.xy * float2(-1,1);
				o.uv[1] = uv + _MainTex_TexelSize.xy * float2(0,1);
				o.uv[2] = uv + _MainTex_TexelSize.xy * float2(-1,1);
				o.uv[3] = uv + _MainTex_TexelSize.xy * float2(-1,0);
				o.uv[4] = uv;
				o.uv[5] = uv + _MainTex_TexelSize.xy * float2(1,0);
				o.uv[6] = uv + _MainTex_TexelSize.xy * float2(-1,-1);
				o.uv[7] = uv + _MainTex_TexelSize.xy * float2(0,-1);
				o.uv[8] = uv + _MainTex_TexelSize.xy * float2(1,-1);
               
                return o;
            }
			//计算饱和度
			float luminance(float4 col)
			{
				return col.r * 0.2125 + col.g * 0.7154 + col.b * 0.0721;
			}

			half sobel(v2f o)
			{
				const half gx[9] = {
					-1,-2,-1,
					0,0,0,
					1,2,1
				};
				const half gy[9] = {
					-1,0,1,
					-2,0,2,
					-1,0,1
				};
				float edgex;
				float edgey;
				for(int i = 0;i < 9; i++){
					float lum = luminance(tex2D(_MainTex,o.uv[i]));
					edgex = edgex + lum * gx[i];
					edgey = edgey + lum * gy[i];
				}
				return 1-abs(edgex)-abs(edgey);
			}
				
            fixed4 frag (v2f i) : SV_Target
            {
				half edge = sobel(i);
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv[4]);
                fixed4 result = lerp(_EdgeColor,col,edge);
                return result;
            }
            ENDCG
        }
    }
}
