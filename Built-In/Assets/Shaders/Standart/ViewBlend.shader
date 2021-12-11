Shader "Custom/ViewBlend"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _BumpMap("Normal", 2D) = "bump"{}
        _NormalStrength("NormalStrength", Float) = 1
        [HDR] _EmissionColor("EmissionColo", Color) = (0,0,0,1)
        _EmissionMap("Emission Tex", 2D) = "white"{}
        [HDR] _RimColor("Rim Color", Color) = (1,1,1,1)
        _RimPower("Rim Fill", Range(0, 2)) = 0.1
        _RimSmooth("RimSmoothness", Range(0.5, 1)) = 1
        [Space]
        [HDR] _CenterCol ("Center Color", Color) = (1,1,1,1)
        [HDR] _LeftCol ("Left Color", Color) = (1,1,1,1)
        [HDR] _RightCol ("Right Color", Color) = (1,1,1,1)
        _LeftTex("Blend Left Tex", 2D) = "white"{}
        _CenterTex ("Blend Center Tex", 2D) = "white"{}
        _RightTex("Blend Right Tex", 2D) = "white"{}
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
            float3 viewDir;
        };

        fixed4 _Color;
        float _NormalStrength;
        half4 _EmissionColor;
        half4 _RimColor;
        float _RimPower;
        float _RimSmooth;

        sampler2D _LeftTex, _CenterTex, _RightTex;
        half3 _LeftCol, _CenterCol, _RightCol;
        
        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            o.Albedo = tex2D(_MainTex, IN.uv_MainTex).rgb * _Color;            
            o.Normal = (tex2D(_BumpMap, IN.uv_MainTex));
            o.Normal.z *= _NormalStrength;

            /*half d = 1 - pow(dot(o.Normal, IN.viewDir), _RimPower);
            o.Emission = _EmissionColor * tex2D(_EmissionMap, IN.uv_MainTex);
            o.Emission += _RimColor * d * smoothstep(0.5, max(0.5, _RimSmooth), d);
            o.Emission = saturate(o.Emission);*/

            half dotLeft = dot(IN.viewDir, float3(1,0,0));
            half dotRight = dot(IN.viewDir, float3(-1,0,0));
            half dotCenter = min((1- dotLeft), 1 - dotRight);

            dotLeft = max(0, dotLeft - dotCenter);
            dotRight = max(0, dotRight - dotCenter);

            half3 colorMix = lerp(lerp(lerp(half3(1,1,1),_CenterCol, dotCenter),
                _LeftCol, dotLeft),
                _RightCol, dotRight);
            
            o.Albedo = dotLeft;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
