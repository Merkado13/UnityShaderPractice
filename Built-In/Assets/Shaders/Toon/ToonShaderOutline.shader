Shader "Custom/ToonShaderOutline"
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
        [Header(Gloss)]
        _SpecMap("Spec Map", 2D) = "white" {}
        _Gloss("Glossiness",Range(0,20)) = 0
        _GlossSmoothness("Gloss Smoothness", Range(0, 2)) = 0
        [HDR]_GlossColor("Gloss Color", Color) = (1, 1, 1, 1)

        [Space]
        [Header(Outline)]
        _Outline("Outline Width", Range(0.0, 0.025)) = 0.03

    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        Cull Front
        CGPROGRAM
        #include "../Lib/ShaderCommon.cginc"
        #pragma surface surf Toon vertex:OutlineVert
        #pragma target 3.0

        float _Outline;


        void OutlineVert(inout appdata_full v)
        {
            v.vertex.xyz += v.normal * _Outline;
        }

        struct Input
        {
            float2 uv_MainTex;
        };

        void surf(Input IN, inout SurfaceOutput o)
        {
            o.Emission = Black;
        }
        ENDCG

        Cull Back
        CGPROGRAM
        #include "../Lib/ShaderCommon.cginc"
        #pragma surface surf Toon fullforwardshadows

        
        half _Tresh;
        half _ShadowSmooth;
        half3 _ShadowColor;

        half _Gloss;
        half4 _GlossColor;
        half _GlossSmoothness;
        
        sampler2D _MainTex;
        sampler2D _BumpMap;
        sampler2D _EmissionMap;
        sampler2D _SpecMap;

        
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
        
        void surf (Input IN, inout SurfaceOutput o)
        {
            InitLightingToon(_Tresh, _ShadowSmooth, _ShadowColor,
                _Gloss, _GlossSmoothness, _GlossColor);
            
            o.Albedo = tex2D(_MainTex, IN.uv_MainTex).rgb * _Color;            
            o.Normal = UnpackNormal(tex2D(_BumpMap, IN.uv_MainTex));
            o.Normal.z *= _NormalStrength;


            half d = 1 - pow(dot(o.Normal, IN.viewDir), _RimPower);
            o.Emission = _EmissionColor * tex2D(_EmissionMap, IN.uv_MainTex);
            o.Emission += _RimColor * d * smoothstep(0.5, max(0.5, _RimSmooth), d);
            o.Emission = saturate(o.Emission);

            o.Specular = tex2D(_SpecMap, IN.uv_MainTex).r;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
