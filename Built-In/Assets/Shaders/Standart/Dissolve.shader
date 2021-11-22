Shader "Custom/Dissolve"
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
        _Tresh("Shadow Threshold" , Range(0, 2)) = 1
        _ShadowSmooth("Shadow Smoothness", Range(0.5, 1)) = 0.6
        _ShadowColor("Shadow Color", Color) = (0,0,0,1)
        [Space]
        [Header(Dissolve)]
        _DissolveTex("Dissolve Tex", 2D) = "white" {}
        _DissolveAmount("Disolve Amount", Range(0, 1)) = 0.5
        _DissolveScale("Dissolve Scale", Float) = 1
        _DissolveLine("Dissolve Line", Range(0, 2)) = 0.1
        [HDR]_DissolveLineColor("Dissolve Line Color", Color) = (1, 1 ,1 ,1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        #pragma surface surf Toon fullforwardshadows
        #pragma target 3.0

        half _Tresh;
        half _ShadowSmooth;
        half3 _ShadowColor;
        
        half4 LightingToon(SurfaceOutput s, half3 lightDir, half4 atten)
        {
            half d = pow(dot(s.Normal, lightDir) * 0.5 + 0.5, _Tresh);
            half shadow = smoothstep(0.5, _ShadowSmooth, d);
            half3 shadowColor = lerp(_ShadowColor, half3(1, 1, 1), shadow);
            half4 c;
            c.rgb = s.Albedo * shadowColor * _LightColor0.rgb * atten;
            c.a = s.Alpha;
            return c;
        }
        
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
        half _DissolveAmount;
        sampler2D _DissolveTex;
        half _DissolveScale;
        half _DissolveLine;
        half4 _DissolveLineColor;
        
        void surf (Input IN, inout SurfaceOutput o)
        {
            //Albedo
            o.Albedo = tex2D(_MainTex, IN.uv_MainTex).rgb * _Color;

            //Normals
            o.Normal = UnpackNormal(tex2D(_BumpMap, IN.uv_MainTex));
            o.Normal.z *= _NormalStrength;

            //Emision
            half d = 1 - pow(dot(o.Normal, IN.viewDir), _RimPower);
            o.Emission = _EmissionColor * tex2D(_EmissionMap, IN.uv_MainTex);
            o.Emission += _RimColor * d * smoothstep(0.5, max(0.5, _RimSmooth), d);
            o.Emission = saturate(o.Emission);
            
            //Dissolve Effect
            half4 noise = tex2D(_DissolveTex, IN.uv_MainTex * _DissolveScale);
            clip(noise - _DissolveAmount);

            o.Emission += step(noise.r, _DissolveAmount + _DissolveLine) * _DissolveLineColor;
            
        }
        ENDCG
    }
    FallBack "Diffuse"
}
