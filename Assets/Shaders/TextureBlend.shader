Shader "Custom/TextureBlend"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_SecondTex("SecondTexture",2D) = "white" {}
		_ShakeTex("ShakeTexture",2D) = "white" {}
		_RandOffsetX("RandOffsetx",float) = 0
		_RandOffsetY("RandOffsety",float) = 0
		_TimeScale("TimeScale",float) = 1
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
                float2 uv1 : TEXCOORD1;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
			sampler2D _SecondTex;
			sampler2D _ShakeTex;
			float _RandOffsetX;
			float _RandOffsetY;
			float _TimeScale;
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.uv1 = o.uv + float2(_Time.x * _TimeScale + _RandOffsetX,_RandOffsetY);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
				fixed4 col2 = tex2D(_SecondTex,i.uv);
				fixed4 col3 = tex2D(_ShakeTex,i.uv1);
                return col * col2 * col3;
            }
            ENDCG
        }
    }
}
