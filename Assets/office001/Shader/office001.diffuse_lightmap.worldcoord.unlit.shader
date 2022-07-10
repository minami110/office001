Shader "office01/diffuse_lightmap_worldcoord"
{
    Properties
    {
        [NoScaleOffset] _MainTex ("Diffuse", 2D) = "white" {}
        [NoScaleOffset] _Lightmap ("Lightmap", 2D) = "white" {}
        _LightIntensity ("LightIntensity", float) = 1.0
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
                float3 normal: NORMAL;
                float2 uv2 : TEXCOORD1;
            };

            struct v2f
            {
                float3 uv : TEXCOORD0;
                float2 uv2 : TEXCOORD1;
                float3 normal : NORMAL;
                UNITY_FOG_COORDS(2)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            sampler2D _Lightmap;
            float _LightIntensity;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.vertex;
                o.uv2 = v.uv2;
                o.normal = v.normal;
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // Triplaner
                float triplanerscale = 100.0;
                float2 tx = i.uv.yz * triplanerscale;
                float2 ty = i.uv.zx * triplanerscale;
                float2 tz = i.uv.xy * triplanerscale;

                // Blending factor of triplaner mapping
                float3 bf = normalize(abs(i.normal));

                // sample the texture
                fixed4 col = tex2D(_MainTex, tx) * bf.x + tex2D(_MainTex, ty) * bf.y + tex2D(_MainTex, tz) * bf.z;

                // multiply lightmap
                col *= pow(tex2D(_Lightmap, i.uv2) * _LightIntensity, 1.444444);
                // col *= tex2D(_Lightmap, i.uv2) * _LightIntensity;
                
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
