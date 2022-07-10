﻿Shader "office01/diffuse_lightmap_worldcoord"
{
    Properties
    {
        _MainTex ("Diffuse", 2D) = "white" {}
        _Lightmap ("Lightmap", 2D) = "white" {}
        _LightIntensity ("LightIntensity", float) = 1.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
// Upgrade NOTE: excluded shader from DX11; has structs without semantics (struct v2f members position)
#pragma exclude_renderers d3d11
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal: NORMAL;
                float2 uv : TEXCOORD0;
                float2 uv2 : TEXCOORD1;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float2 uv2 : TEXCOORD1;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                float3 normal : NORMAL;
                float3 position : TEXCOORD2;
            };

            sampler2D _MainTex;
            sampler2D _Lightmap;
            float4 _MainTex_ST;
            float4 _Lightmap_ST;
            float _LightIntensity;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.uv2 = TRANSFORM_TEX(v.uv2, _Lightmap);
                o.normal = v.normal;
                UNITY_TRANSFER_FOG(o,o.vertex);
                o.position = v.vertex;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // Triplaner
                float2 tx = i.position.yz * 100;
                float2 ty = i.position.zx * 100;
                float2 tz = i.position.xy * 100;

                // Blending factor of triplaner mapping
                float3 bf = normalize(abs(i.normal));

                // sample the texture
                fixed4 col = tex2D(_MainTex, tx) * bf.x + tex2D(_MainTex, ty) * bf.y + tex2D(_MainTex, tz) * bf.z;

                // multiply lightmap
                col *= pow(tex2D(_Lightmap, i.uv2) * _LightIntensity, 1.444);
                
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}