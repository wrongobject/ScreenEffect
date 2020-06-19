Shader "Custom/MyShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color("Color",Color) = (1,1,1,1)
        _Specular("Specular",float) = 1
        _Gloss("Gloss",float) = 0
    }
    SubShader
    {
        Tags
            {
                "LightMode" = "ForwardBase"
            }

      
        Pass
        {
            CGPROGRAM
            #pragma vertex Vert
            #pragma fragment Frag
            // make fog work
            #pragma multi_compile_fog
            #pragma multi_compile_instancing
            #pragma multi_compile_fwdbase
           
            
            #include "EnvCore.cginc"
                
            ENDCG
        }
    }
    FallBack "Diffuse"
}
