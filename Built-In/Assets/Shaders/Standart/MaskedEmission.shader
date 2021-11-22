Shader "Custom/MaskedEmission"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _BumpMap("Normal", 2D) = "bump"{}
        _NormalStrength("NormalStrength", Float) = 1
        _EmissionMap("Emission Tex", 2D) = "white"{}
        [HDR] _EmissionColor1("EmissionColor1", Color) = (0,0,0,1)
        [HDR] _EmissionColor2("EmissionColor2", Color) = (0,0,0,1)
        [HDR] _EmissionColor3("EmissionColor4", Color) = (0,0,0,1)
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
        half4 _EmissionColor1;
        half4 _EmissionColor2;
        half4 _EmissionColor3;
        
        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            o.Albedo = tex2D(_MainTex, IN.uv_MainTex).rgb * _Color;            
            o.Normal = UnpackNormal(tex2D(_BumpMap, IN.uv_MainTex));
            o.Normal.z *= _NormalStrength;

            half4 emissionMap = tex2D(_EmissionMap, IN.uv_MainTex);
            half4 color1 = emissionMap.r * _EmissionColor1;
            half4 color2 = emissionMap.g * _EmissionColor2;
            half4 color3 = emissionMap.b * _EmissionColor3;

            o.Emission = color1 + color2 + color3;
          
        }
        ENDCG
    }
    FallBack "Diffuse"
}
