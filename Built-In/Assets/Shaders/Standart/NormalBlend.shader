Shader "Custom/NormalBlend"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _BumpMap("Normal", 2D) = "bump"{}
        _NormalStrength("NormalStrength", Float) = 1
        [HDR] _EmissionColor("EmissionColo", Color) = (0,0,0,1)
        _EmissionMap("Emission Tex", 2D) = "white"{}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        #pragma surface surf Standard fullforwardshadows
        #pragma target 3.0

        sampler2D _MainTex;
        sampler2D _BumpMap;
        sampler2D _EmissionMap;
        
        struct Input
        {
            float2 uv_MainTex;
        };

        fixed4 _Color;
        float _NormalStrength;
        half4 _EmissionColor;
        
        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            o.Albedo = tex2D(_MainTex, IN.uv_MainTex).rgb * _Color;            
            o.Normal = UnpackNormal(tex2D(_BumpMap, IN.uv_MainTex));
            o.Normal.z *= _NormalStrength;

            o.Emission = _EmissionColor * tex2D(_EmissionMap, IN.uv_MainTex);
        }
        ENDCG
    }
    FallBack "Diffuse"
}
