Shader "Unlit/Cube"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
	CGINCLUDE
	// make fog work
	#pragma multi_compile_fog

	#include "UnityCG.cginc"	
	#include "Quaternion.cginc"

	struct Particle
	{
		float3 position;
		float4 rotation;
		float4 rotationAxisY;
	};

	struct appdata
	{
		float4 vertex : POSITION;
		float3 normal : NORMAL;
		float2 uv : TEXCOORD0;
	};

	struct v2f
	{
		float2 uv : TEXCOORD0;
		float3 normal : NORMAL;
		float4 vertex : SV_POSITION;
	};

	sampler2D _MainTex;
	float4 _MainTex_ST;

	StructuredBuffer<Particle> _ParticleBuffer;

	v2f vert(appdata v)
	{
		v2f o;

		float4 rot = quaternionMultiply(_ParticleBuffer[0].rotationAxisY, _ParticleBuffer[0].rotation);

		v.vertex.xyz = rotateVector(v.vertex.xyz, rot);

		o.vertex = UnityObjectToClipPos(v.vertex);
		o.normal = v.normal;
		o.uv = TRANSFORM_TEX(v.uv, _MainTex);
		return o;
	}

	fixed4 frag(v2f i) : SV_Target
	{
		fixed4 col = tex2D(_MainTex, i.uv);
		col.rgb = 0.5 + 0.5 * i.normal.xyz;
		return col;
	}

	ENDCG

    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex   vert
            #pragma fragment frag            
            ENDCG
        }
    }
}
