Shader "Custom/Relief"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_Size("Size",float) = 500
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
            };
		
            sampler2D _MainTex;
            float4 _MainTex_ST;
			float _Size;
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);                
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                float4 col = tex2D(_MainTex, i.uv);
				float4 col_rd = tex2D(_MainTex,i.uv + float2(1,1) / _Size);
				float4 delta = col - col_rd;
				float max0 = max(delta.r,delta.g);
				max0 = max(max0,delta.b);
                float result = clamp(max0 + 0.4,0,1);
				
                return fixed4(result,result,result,1);
            }
            ENDCG
        }
    }
}
