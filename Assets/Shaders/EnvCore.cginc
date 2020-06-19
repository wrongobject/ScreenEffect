#ifndef ENV_CORE_INCLUDE
#define ENV_CORE_INCLUDE


#include "UnityCG.cginc"
#include "Lighting.cginc"
#include "AutoLight.cginc"

float _Specular;
float _Gloss;
float4 _MainTex_ST;
sampler2D _MainTex;
float4 _Color;
struct VInput{
	
	float4 vertex : POSITION;
	half2 uv : TEXCOORD0;
	half3 normal : NORMAL;
	UNITY_VERTEX_INPUT_INSTANCE_ID	
};

struct FInput{
	float4 pos : SV_POSITION;
	half3 normal : NORMAL;
	half2 uv : TEXCOORD0;
	float4 worldPos : TEXCOORD1;	
	SHADOW_COORDS(2)
	//float4 _ShadowCoord : TEXCOORD2;
	UNITY_VERTEX_INPUT_INSTANCE_ID  
};
#if defined(UNITY_SUPPORT_INSTANCING) && defined(INSTANCING_ON)
UNITY_INSTANCING_BUFFER_START(Props)
	UNITY_DEFINE_INSTANCED_PROP(float4, _Color)
UNITY_INSTANCING_BUFFER_END(Props)
#endif

FInput Vert(VInput v)
{
	UNITY_SETUP_INSTANCE_ID(v)
	FInput o;
	
	UNITY_TRANSFER_INSTANCE_ID(v,o);
	o.worldPos = mul(unity_ObjectToWorld,v.vertex);
	o.pos = UnityWorldToClipPos(o.worldPos);
	o.uv = TRANSFORM_TEX(v.uv,_MainTex);
	o.normal = normalize(mul((float3x3)unity_ObjectToWorld,v.normal));
	//o._ShadowCoord = ComputeScreenPos(o.pos);
	TRANSFER_SHADOW(o)
	return o;
}

half4 Frag(FInput i) : SV_TARGET
{
	UNITY_SETUP_INSTANCE_ID(i)
#if defined(UNITY_SUPPORT_INSTANCING) && defined(INSTANCING_ON)
	UNITY_ACCESS_INSTANCED_PROP(Props,_Color);
#endif
	half4 c = tex2D(_MainTex,i.uv) * _Color;
		
	float atten = SHADOW_ATTENUATION(i);
	SurfaceOutput surf;
	UNITY_INITIALIZE_OUTPUT(SurfaceOutput,surf);
	surf.Albedo = c.rgb;
	surf.Normal = i.normal;
	surf.Alpha = c.a;
	surf.Specular = _Specular;
	surf.Gloss = _Gloss;
	UnityLight unityLight;
	UNITY_INITIALIZE_OUTPUT(UnityLight,unityLight);
	unityLight.color = _LightColor0;
	unityLight.dir = _WorldSpaceLightPos0.xyz;
	float3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
	half4 result = UnityBlinnPhongLight(surf,viewDir,unityLight) *  atten + UNITY_LIGHTMODEL_AMBIENT * c;

	return result;
}

#endif